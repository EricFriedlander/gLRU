# gLRU

The code in this repo can be used to recreate the images of "Friedlander, Eric, and Vaneet Aggarwal. "Generalization of LRU cache replacement policy with applications to video streaming." arXiv preprint arXiv:1806.10853 (2018)." 

Note that you will have to download zipf_rand from:
https://www.mathworks.com/matlabcentral/fileexchange/53568-zipf_rand-n-expn-m
in order to run the code in this repo.

Figure 1 can be generated using the scipt "LRUgLRUComparison.m".

All graphs in Figure 2 can be generated using the script "approxSimComp.m". 

 "LRUgLRUSims.m" generates figures 3 and 5 and data from Table 2. It is recommended that you run this code in parallel for the sake of time. There is already a parfor loop in the code, but the user must configer the code to run on their particular cluster. The output of our simulations is stored in
 'simout1.mat' and can be used to recreate the figures and tables.