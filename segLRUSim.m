function out=segLRUSim(trace_file, avg_chunk, cache_prop, aPT, stupd, ...
    kmin, avg_len, stepNum, size_as_id, timestamp, requested_file, file_sizes, obj_ids)
% This script takes trace data as input and outputs performance metrics
% glRU cache replacement policy
% Trace_file: filename where trace data is tored
% chunksize: size in MB of each chunk
% cache_prop: size of cache in proportion of total number of chunks
% aPT: average processing time of each video chunk as a proportion of
%               chunk lenth
% avg_len: average length of each file (in seconds)
% stupd: Start up delay for watching a video file
% kmin: proportion of cache devoted to initial chunks
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
    sizes = ceil(obj_ids/chunksize); % Number of chunks in each file
    clen =  avg_len / mean(file_sizes/chunksize);% Length of each video chunk
    cachesize = ceil(sum(file_sizes/chunksize) * cache_prop);
   
    num_obj = length(obj_ids);
    id_to_ind = containers.Map(obj_ids,  1:num_obj);
    biggest = max(sizes); % Compute size of largest objects
    aProcTime = clen * aPT;
    smallcachesize = round(kmin * cachesize);
    bigcachesize = cachesize - smallcachesize;
    
    % Compute number and size of segments
    maxnumsegs = ceil(log2(double(biggest)))+1;
    sigsizes = 1;
    kmineff = [1, 1];
    below_thresh = 0;
    for i = 1:maxnumsegs
        sigsizes = [sigsizes, 2^(i-1)];
        bigger = sizes > 2^i;
        below_thresh = below_thresh + sum(bigger) * 2^(i-1);
        if below_thresh < .25 * sum(sizes)
            kmineff(1) = i+1;
            kmineff(2) = 2^i; 
        end
    end
    
    % Compute numerber of segments for each file
    allsizes = containers.Map(obj_ids, sizes);
    sizess = containers.Map(obj_ids,  min(kmineff(2), sizes)); % Number of small chunks for each file
    sizesb = containers.Map(obj_ids,  max(0, sizes-kmineff(2))); % Number of big chunks for each file
    
    
    
    %% Complete Simulation
   disp('Entering segLRU Simulation')
   smallcache = zeros(1,smallcachesize);
   newsmallcache = zeros(1, smallcachesize);
   queue_time = 0; % Time until all object in queue are processed
   numins = containers.Map(obj_ids,zeros(1,num_obj));
   numinb = containers.Map(obj_ids,zeros(1, num_obj));
   numsegin = zeros(1, num_obj);
   lastreq = zeros(1, num_obj);
   fintime = zeros(1, num_obj);
   totalins = 0;
   totalinb = 0;
   hits = zeros(1,stepNum);
   hitss = zeros(1,stepNum);
   miss = zeros(1,stepNum);
   wait = zeros(1,stepNum);
   delay = zeros(1,stepNum);
   sel_sizes = zeros(1,stepNum);
   out = zeros(1,6);
   for k = 1:2
       hitsum =0;
       hitssum =0;
       sizesum = 0;
       numhitsum = 0;
       waitsum = 0;
       delaysum = 0;
       numdelaysum = 0;
       time = 0;
       queue_time = 0;
    %    numhitsd = 0;
    %    waitsd = 0;
    %    delaysd = 0;
    %    numdelaysd =0;
       for j = 1:num_row

           %Check if space overflow
           i = mod(j,stepNum);
           if i == 0
               i = stepNum;
           end

           %Advance time
           if j > 1
               time_step = (timestamp(j)-timestamp(j-1))*10^(-7);
           else
               time_step = timestamp(1)*10^(-7);
           end
           queue_time = max(0, queue_time - time_step);
           time = time + time_step;

           %Extract index of selected object; note that we take the file ID to
           %be the file size
           chosen = requested_file(j);


           %Collect data
           numin = numins(chosen) + numinb(chosen);
           hitss(i) = numins(chosen);
           hits(i) = numin;
           notins = sizess(chosen)-numins(chosen);
           miss(i) = allsizes(chosen)- hits(i);
           sel_sizes(i) = allsizes(chosen);
           proctimes = exprnd((aProcTime), 1, miss(i));
           delay(i) = sum(max([(cumsum(proctimes) + queue_time) ...
               - ([double(numin:(allsizes(chosen)-1))] .* clen + stupd) 0]));
           queue_time = queue_time + sum(proctimes);
           if hits(i) == allsizes(chosen)
               wait(i) = 0;
           else
               wait(i) = queue_time;
           end
           fintime(id_to_ind(chosen)) = time + delay(i) + clen * allsizes(chosen);

            % First handle smaller, pure LRU stack

            % Move all cached segments to front of stack
            newsmallcache(1:numins(chosen)) = chosen;
            ind = smallcache == chosen;
            newsmallcache(numins(chosen)+1:end) = smallcache(~ind);

            % Add any additional chunks if necessary and account for those
            % which fall out the end
            if notins > 0

                % Compute number of empty spots in queue and number to evict
                emptyspots =  smallcachesize - totalins;
                numtoevict = max(notins - emptyspots, 0);
                totalins = min(totalins + notins, smallcachesize);
                % Evict necessary cunks
                if numtoevict > 0                
                    [evicted, ~ ,ic] = unique(newsmallcache(end-numtoevict-emptyspots+1:end-emptyspots));
                    ev_counts = accumarray(ic,1);    
                    ev_counts = ev_counts(evicted>0);
                    evicted = evicted(evicted>0);
                    for k = 1:length(evicted)
                        numins(evicted(k)) = numins(evicted(k)) - ev_counts(k);
                    end
                end
                newsmallcache(notins+1:end) = newsmallcache(1:end-notins); 
                newsmallcache(1:notins) = chosen;
                numins(chosen) = numins(chosen)+notins;
            end






            % Now handle larger queue
            if lastreq(id_to_ind(chosen)) > 0 && numins(chosen) == sizess(chosen)

                % only iterate through segments if the previous one has been
                % added
                added = 1;
                while added == 1 && sizesb(chosen) > numinb(chosen)

                    % iterate until enough replacements are evicted to provide
                    % space for new
                    newspace = bigcachesize - totalinb;

                    if newspace < sigsizes(numsegin(id_to_ind(chosen))+1)
                        space = 0;
                    else
                        space = 1;
                    end
                    nocand = 0;
                    while space == 0 && nocand == 0

                        %only want to focus on chunks not currently playing
                        notplaying = time > fintime;
                        anyin = numsegin > 0;

                        % find file with lowest replacment value
                        scores = 1./(time - lastreq.*numsegin)...
                            .*notplaying.*anyin;
                        [canmin, tempcan] = min(scores(scores>0));
                        

                        % check if lower than requested segment
                        if canmin < 1/(time - lastreq(id_to_ind(chosen))*numsegin(id_to_ind(chosen)))

                            can = find(scores, tempcan);
                            
                            % compute space freed up
                            newspace = newspace + sigsizes(numsegin(can(1)));
                            if newspace > sigsizes(numsegin(id_to_ind(chosen))+1)
                                space = 1;
                            end
                            numsegin(can) = numsegin(can) - 1;
                        else
                            nocand = 1;
                        end
                    end

                    % If enough space is created then add new chunk
                    if space == 1
                        numsegin(id_to_ind(chosen)) = numsegin(id_to_ind(chosen)) + 1;
                        numinb(chosen) = min(numinb(chosen) + sigsizes(numsegin(id_to_ind(chosen))), sizesb(chosen));
                        totalinb = totalinb + sigsizes(numsegin(id_to_ind(chosen)));
                    else
                        added = 0;
                    end
                end
            end
            lastreq(id_to_ind(chosen)) = time;
            smallcache = newsmallcache;



           %Calculate Stats  
           if mod(j,stepNum) == 0 || j == num_row
               j;
               hitsum = hitsum + sum(hits);
               hitssum = hitssum + sum(hitss);
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
               out(6) = hitssum/sizesum;
    %            numhitsd = sqrt(((j-stepNum-1)*numhitsd^2 + (stepNum-1)*std(hits==0)^2)/(j-1))
    %            waitsd = sqrt(((j-stepNum-1)*waitsd^2 + (stepNum-1)*std(wait)^2)/(j-1))
    %            delaysd = sqrt(((j-stepNum-1)*delaysd^2 + (stepNum-1)*std(delay)^2)/(j-1))
    %            numdelaysd = sqrt(((j-stepNum-1)*numdelaysd^2 + (stepNum-1)*std(delay>0)^2)/(j-1))
               hits = zeros(1,stepNum);
               hitss = zeros(1,stepNum);
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
    disp('Proportion from Small Cache')
    out(6)
    
%     save('seglRUout.mat', 'out')
end