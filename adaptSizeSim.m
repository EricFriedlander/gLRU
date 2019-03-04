function out=adaptSizeSim(trace_file, avg_chunk, cache_prop, aPT, ...
    stupd, avg_len, c_start, stepNum,  size_as_id, timestamp, requested_file, file_sizes, obj_ids)
% This script takes trace data as input and outputs performance metrics
% glRU cache replacement policy
% Trace_file: filename where trace data is tored
% avg_chunk: average number of chunks for each file
% cache_prop: size of cache in proportion of total number of chunks
% aPT: average processing time of each video chunk as a proportion of
%               chunk lenth
% avg_len: average length of each file (in seconds)
% c_start: initial value of c
% stupd: Start up delay for watching a video file

    %% Input Parameters
    if ~exist('timestamp')
        load(trace_file)
    end
    if size_as_id
        obj_ids = double(unique(file_sizes));
        requested_file = file_sizes;
        file_sizes = obj_ids;
    end
    num_row = length(requested_file);
    chunksize = mean(obj_ids) / avg_chunk;
    sizes = containers.Map(obj_ids,  ceil(file_sizes/chunksize)); % Number of chunks in each file
    clen =  avg_len / mean(file_sizes/chunksize);% Length of each video chunk
    cachesize = ceil(sum(file_sizes/chunksize) * cache_prop);   
    num_obj = length(obj_ids);
    id_to_ind = containers.Map(obj_ids,  1:num_obj);
    aProcTime = clen * aPT;
    c = c_start;
    c = -avg_chunk/log(.5)
    c_max = -max(file_sizes)/log(.99)
   
    
    %% Complete Simulation
   disp('Entering  Adapt Size Simulation')
   cache = zeros(1,cachesize); 
   newcache = zeros(1,cachesize);
   queue_time = 0; % Time until all object in queue are processed
   numin = containers.Map(obj_ids, obj_ids*0);
   totalin = 0;
   hits = zeros(1,stepNum);
   miss = zeros(1,stepNum);
   wait = zeros(1,stepNum);
   delay = zeros(1,stepNum);
   sel_sizes = zeros(1,stepNum);
   requests = obj_ids * 0;
   out = zeros(1,6);
   for k = 1:2
       hitsum =0;
       sizesum = 0;
       numhitsum = 0;
       waitsum = 0;
       delaysum = 0;
       numdelaysum = 0;
       for j = 1:num_row

           % Check if space overflow
           i = mod(j,stepNum);
           if i == 0
               i = stepNum;
           end

           % Advance time left in queue by interrarrival time
           if j > 1
               time_step = (timestamp(j)-timestamp(j-1))*10^(-7);
           else
               time_step = timestamp(1)*10^(-7);
           end
           queue_time = max(0, queue_time - time_step);

           %Extract index of selected object; note that we take the file ID to
           %be the file size
           chosen = requested_file(j);
           requests(id_to_ind(chosen)) = requests (id_to_ind(chosen)) +1;


           %Collect data
           hits(i) = numin(chosen);
           notin = sizes(chosen)-numin(chosen);
           miss(i) = notin;
           sel_sizes(i) = sizes(chosen);
           proctimes = exprnd((aProcTime), 1, notin);
           delay(i) = sum(max([(cumsum(proctimes) + queue_time) ...
               - ([double(numin(chosen):(sizes(chosen)-1))] .* clen + stupd) 0]));
           queue_time = queue_time + sum(proctimes);
           wait(i) = queue_time;





           % Move all cached segments to front of stack
            newcache(1:numin(chosen)) = chosen;
            ind = cache == chosen;
            newcache(numin(chosen)+1:end) = cache(~ind);
            admit = binornd(1, exp(-double(notin/c)));

            % Add any additional chunks if necessary and account for those
            % which fall out the end
            if (notin > 0 && admit == 1)

                % Compute number of empty spots in queue and number to evict
                emptyspots =  cachesize - totalin;
                numtoevict = min(max(notin - emptyspots, 0), cachesize);
                totalin = min(totalin + notin, cachesize);
                numtoadd = min(notin, cachesize);
                
                % Evict necessary cunks
                if numtoevict > 0                
                    [evicted, ~ ,ic] = unique(newcache(end-numtoevict-emptyspots+1:end-emptyspots));
                    ev_counts = accumarray(ic,1);    
                    ev_counts = ev_counts(evicted>0);
                    evicted = evicted(evicted>0);
                    for k = 1:length(evicted)
                        numin(evicted(k)) = numin(evicted(k)) - ev_counts(k);
                    end
                end
                
                if numtoadd < cachesize
                    newcache(numtoadd+1:end) = newcache(1:end-numtoadd); 
                    newcache(1:numtoadd) = chosen;
                    numin(chosen) = numin(chosen)+numtoadd;
                else
                    newcache(1:end) = chosen;
                    numin(chosen) = cachesize;
                end
            end
           cache = newcache;

           %Calculate Stats  
           if mod(j,stepNum) == 0 || j == num_row
               j;
               if j/stepNum > 1
                   c_opt = @(c_can)-getC(c_can, double(requests), ...
                       (timestamp(j) - timestamp(j-stepNum))*10^(-7), ...
                       sizes, cachesize, num_obj, obj_ids);
               else
                   c_opt = @(c_can)-getC(c_can, double(requests), ...
                       (timestamp(j)-timestamp(1))*10^(-7), ...
                       sizes, cachesize, num_obj, obj_ids);
               end
               [a,b] = max(requests);
               if mod(j,stepNum) == 0
                    [c, best] = fminbnd(c_opt, 0, c_max)
               end
               hitsum = hitsum + sum(hits);
               sizesum = sizesum + sum(sel_sizes);
               numhitsum = numhitsum + sum(hits == 0);
               waitsum = waitsum + sum(wait);
               delaysum = delaysum + sum(delay);
               numdelaysum = numdelaysum + sum(delay >0);
               out(1) = hitsum/sizesum;
               out(2) = numhitsum/j;
               out(3) = waitsum/j;
               out(4) = delaysum/j;
               out(5) = numdelaysum/j;
               hits = zeros(1,stepNum);
               miss =  zeros(1,stepNum);
               wait = zeros(1,stepNum);
               delay = zeros(1,stepNum);
               sel_sizes = zeros(1,stepNum);
               requests = zeros(1,num_obj);
           end
           j = j+1;
       end
   end
    
    j = j-1;
    disp('Proportion from Cache')
    out(1)
    disp('Prop Entire Miss')
    out(2) 
    disp('Mean Wait Time')
    out(3) 
    disp('Mean Delay')
    out(4)
    disp('Prop Delayed')
    out(5) 
    
%     save('adaptSizeout.mat', 'out')
end