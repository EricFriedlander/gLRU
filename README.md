# gLRU

The code in this repo can be used to recreate the figures and tables from "Friedlander, Eric, and Vaneet Aggarwal. "Generalization of LRU cache replacement policy with applications to video streaming." arXiv preprint arXiv:1806.10853 (2018)." 

Note that you will have to download zipf_rand from:
https://www.mathworks.com/matlabcentral/fileexchange/53568-zipf_rand-n-expn-m
in order to run the code in this repo.

Figure 1 can be generated using the scipt "LRUgLRUComparison.m".

All graphs in Figure 2 can be generated using the script "approxSimComp.m". 

 "LRUgLRUSims.m" generates Figures 3, 4, and 5 and data from Tables 2, 5, and 6. It is recommended that you run this code in parallel for the sake of time. There is already a parfor loop in the code, but the user must configer the code to run on their particular cluster. The output of our simulations is stored in
 'simout1.mat' and can be used to recreate the figures and tables by ignoring the first section of the script.



In order to run the MSR Cambrdige Traces, download them from :
http://iotta.snia.org/traces/388.
Once they are downloaded run them through the script "GenTraceFile.m".
After you have generated "mdstrace0_data.mat" and "webtrace0_data.mat", run "prodTraceSim.m" to run the simulations. Again, it is highly recommended that you alter the code to run in parallel.
Once "prodSimResults.mat" is generated, run "traceResultAnalysis.m" to get the data from Tables 3 and 4.