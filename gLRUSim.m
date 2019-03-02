function out=gLRUSim(trace_file, avg_chunk, cache_prop, aPT, stupd, ...
    avg_len, stepNum, size_as_id, timestamp, requested_file, file_sizes, obj_ids)
% This script takes trace data as input and outputs performance metrics
% glRU cache replacement policy
% Trace_file: filename where trace data is tored
% avg_chunk: average number of chunks for each file
% cache_prop: size of cache in proportion of total number of chunks
% aPT: average processing time of each video chunk as a proportion of
%               chunk lenth
% avg_len: average length of each file (in seconds)
% stupd: Start up delay for watching a video file (in seconds)

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
    aProcTime = clen * aPT;
    
    %% Complete Simulation
   disp('Entering gLRU Simulation')
   cache = zeros(1,cachesize); 
   newcache = zeros(1,cachesize);
   queue_time = 0; % Time until all object in queue are processed
   numin = containers.Map(obj_ids,obj_ids*0);
   totalin = 0;
   hits = zeros(1,stepNum);
   miss = zeros(1,stepNum);
   wait = zeros(1,stepNum);
   delay = zeros(1,stepNum);
   sel_sizes = zeros(1,stepNum);
   out = zeros(1,6);
   for k = 1:2
       hitsum =0;
       sizesum = 0;
       numhitsum = 0;
       waitsum = 0;
       delaysum = 0;
       numdelaysum = 0;
       queue_time = 0;
       for j = 1:num_row

           %Check if space overflow
           i = mod(j,stepNum);
           if i == 0
               i = stepNum;
           end

           %Advance time left in queue by interrarrival time
           if j > 1
               time_step = (timestamp(j)-timestamp(j-1))*10^(-7);
           else
               time_step = timestamp(1)*10^(-7);
           end
           queue_time = max(0, queue_time - time_step);

           %Extract index of selected object; note that we take the file ID to
           %be the file size
           chosen = requested_file(j);


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

           % Make sure file isn't larger than cache
           if numin(chosen) >= cachesize
               newcache = cache;
           %If not all chunks of requested file are already stored
           elseif notin > 0 

               % Move cached chunks to front
               newcache(1:numin(chosen)) = chosen;
               ind = cache == chosen;
               newcache(numin(chosen)+1:end) = cache(~ind);

               %Account for chunk pushed out the end
               if totalin == cachesize
                   numin(newcache(end)) = numin(newcache(end)) - 1;
               else
                   totalin = totalin + 1;
               end


               % Move all chunks plus 1 to front of cache
               newcache(2:end) = newcache(1:end-1);
               newcache(1) = chosen;
               numin(chosen) = numin(chosen)+1;



           %If all chunks are cached
           else
               %Move Chunks to the front
               newcache(1:sizes(chosen)) = chosen;
               ind = cache == chosen;
               newcache(numin(chosen)+1:end) = cache(~ind);
               delay(i) = 0;
               wait(i) = 0;
           end
           cache = newcache;

           %Calculate Stats  
           if mod(j,stepNum) == 0 || j == num_row
               j
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
    %            numhitsd = sqrt(((j-stepNum-1)*numhitsd^2 + (stepNum-1)*std(hits==0)^2)/(j-1))
    %            waitsd = sqrt(((j-stepNum-1)*waitsd^2 + (stepNum-1)*std(wait)^2)/(j-1))
    %            delaysd = sqrt(((j-stepNum-1)*delaysd^2 + (stepNum-1)*std(delay)^2)/(j-1))
    %            numdelaysd = sqrt(((j-stepNum-1)*numdelaysd^2 + (stepNum-1)*std(delay>0)^2)/(j-1))
               hits = zeros(1,stepNum);
               miss =  zeros(1,stepNum);
               wait = zeros(1,stepNum);
               delay = zeros(1,stepNum);
               sel_sizes = zeros(1,stepNum);
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
    
%     save('glRUout.mat', 'out')
end