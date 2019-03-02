
avg_chunk = [10 , 50, 100];
cache_prop = [.01, .02, .025, .05, .1, .2, .25, .5];
aPT = .001;
stupd = 1;
avg_len = 30*60;
stepNum = 1000;
kmin = .5;
c_start = 15;


[avg_chunk, cache_prop] = ndgrid([10 50 100], [.01 .02 .025 .05 .1 .2 .25 .5]);
results = zeros(3, 2, numel(avg_chunk), 6); 
% mypool = parpool(64)
% configCluster
% configCluster('killdevil')
% ClusterInfo.setUserDefinedOptions('-o out.%J')
% matlabpool open 24
parfor i = 1:numel(avg_chunk)
        input_files =  'trace0_data.mat'
        temp = adaptSizeSim(input_files, avg_chunk(i), cache_prop(i), aPT, stupd, avg_len, c_start, stepNum, true); 
        results(3, 1, i, :) = temp;

end

parfor i = 1:numel(avg_chunk)
            input_files =  'trace0_data.mat'
            temp = gLRUSim(input_files, avg_chunk(i), cache_prop(i), aPT, stupd, avg_len, stepNum, true);
            results(1, 1, i, :) = temp;
end

parfor i = 1:numel(avg_chunk)
                        


            input_files =  'trace0_data.mat'
            
            temp = segLRUSim(input_files, avg_chunk(i), cache_prop(i), aPT, stupd, kmin, avg_len, stepNum, true);
            results(2, 1, i, :) = temp;

            
end

parfor i = 1:numel(avg_chunk)
                        

                        
            input_files =  'webtrace0_data.mat'
            temp = gLRUSim(input_files, avg_chunk(i), cache_prop(i), aPT, stupd, avg_len, stepNum, true);
            results(1, 2, i, :) = temp;

end

parfor i = 1:numel(avg_chunk)
                        



            input_files =  'webtrace0_data.mat'

            temp = segLRUSim(input_files, avg_chunk(i), cache_prop(i), aPT, stupd, kmin, avg_len, stepNum, true);
            results(2, 2, i, :) = temp;

end

parfor i = 1:numel(avg_chunk)
                        


   
                        
            input_files =  'webtrace0_data.mat'
            temp = adaptSizeSim(input_files, avg_chunk(i), cache_prop(i), aPT, stupd, avg_len, c_start, stepNum, true); 
            results(3, 2, i, :) = temp;
                        

end
% matlabpool close 
save('SimResults.mat', 'results')

