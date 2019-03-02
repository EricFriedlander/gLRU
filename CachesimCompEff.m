function out = CachesimCompEff( n, alpha, fileLen, Cprop, sizeType, stupd, clen, traffic, procrate, acc)

    %% Input Parameters   
    pop = zipf_rand(n,alpha,n);
    pop = sort(pop,'descend');
    shape = 2;
    scale = 300;
    k = 1/shape;
    sig = scale*k;
    theta = sig/k;
    sizes = zeros(1,n);
    i = 1;
    while i <= n
        sizes(i) = round(gprnd(k,sig,theta)/clen);
        if sizes(i) <= round(3600/clen)
            i = i+1;
        end
    end
%     sizes = ones(1,n) * chunks;
    if sizeType == 2
        sizes = sort(sizes,'descend');
    elseif sizeType == 3
        sizes = sort(sizes,'ascend');
    elseif sizeType == 4
        sizes = ones(1,n) .* fileLen/clen; 
    end
    totpop = sum(sizes);
    C = round(Cprop*sum(sizes));
    lentomb = 3.13;
    qlam = (clen * lentomb / procrate)^(-1);
    rateMult = sum(pop .* sizes);
    lambda = traffic * qlam / rateMult;
    burnin = 2*5*C;
    disp('Burnin')
    burnin
    N=burnin;
    out = zeros(1,10);


    %% Generate interarrrival times and file selections

    times = exprnd((lambda)^(-1),1,N);
    fileselect = randsample(1:n, N, true, pop/totpop);
    clc = cumsum(times);
    
    %% Complete Simulation
    profile on
    disp('Entering Simulation')
    cache = zeros(1,n);
    newcache = zeros(1,n);
    queue = 0;
    numin = zeros(1,n);
    numfin = 0;
    hits = zeros(1,N);
    miss = zeros(1,N);
    qind = 1;
    wait = zeros(1,N);
    delay = zeros(1,N);
    i = 1;
    stop = 0;
    hitsum =0;
   sizesum = 0;
   numhitsum = 0;
   waitsum = 0;
   delaysum = 0;
   numdelaysum = 0;
   numhitsd = 0;
   waitsd = 0;
   delaysd = 0;
   numdelaysd =0;
   while stop ==0
       j = mod(i,N);
       if j == 0
           j = N;
       end
       queue = max(0, queue - times(j));
       chosen = fileselect(j);
       
       %Move requested file to front of cache

       newcache(1) = chosen;
       if numin(chosen) > 0 
           ind = cache == chosen;
           newcache(2:end) = cache(~ind);
       else
           newcache(2:end) = cache(1:end-1);
           numfin = numfin+1;
       end
       cache = newcache;
       
       %If not all the chunks are in the cache then add one
       if numin(chosen) < sizes(chosen)
           %If cache is full then remove the last element in the cache
           if sum(numin) >= C
               numin(cache(numfin)) = numin(cache(numfin)) - 1;
               if numin(cache(numfin)) == 0
                   cache(numfin) = 0;
                   numfin = numfin - 1;
               end
           end
           notin = sizes(chosen)-numin(chosen);
           hits(j) = numin(chosen);
           miss(j) = sizes(chosen)-numin(chosen);
           proctimes = exprnd((qlam)^(-1),1,notin);
           delay(j) = sum(max([(cumsum(proctimes) + queue) - ([numin(chosen):(sizes(chosen)-1)] .*clen + stupd) 0]));
           queue = queue + sum(proctimes);
           numin(chosen) = numin(chosen)+1;
           wait(j) = queue;
       else
           hits(j) = numin(chosen);  
           wait(j) = 0;
           delay(j) = 0;
       end
       if mod(i,N) == 0
           if i > burnin 
               hitsum = hitsum + sum(hits);
               sizesum = sizesum + sum(sizes(fileselect));
               numhitsum = numhitsum + sum(hits ==0);
               waitsum = waitsum + sum(wait);
               delaysum = delaysum + sum(delay);
               numdelaysum = numdelaysum + sum(delay >0);
               out(1) = hitsum/sizesum
               out(2) = numhitsum/(i-burnin)
               out(3) = waitsum/(i-burnin)
               out(4) = delaysum/(i-burnin)
               out(5) = numdelaysum/(i-burnin)
               numhitsd = sqrt(((i-N-burnin-1)*numhitsd^2 + (N-1)*std(hits==0)^2)/(i-burnin-1))
               waitsd = sqrt(((i-N-burnin-1)*waitsd^2 + (N-1)*std(wait)^2)/(i-burnin-1))
               delaysd = sqrt(((i-N-burnin-1)*delaysd^2 + (N-1)*std(delay)^2)/(i-burnin-1))
               numdelaysd = sqrt(((i-N-burnin-1)*numdelaysd^2 + (N-1)*std(delay>0)^2)/(i-burnin-1))
               max([(numhitsd*1.96/(acc*out(2)))^2 (waitsd*1.96/(acc*out(3)))^2 ...
                   (delaysd*1.96/(acc*out(4)))^2 (numdelaysd*1.96/(acc*out(5)))^2])
%            pcache = std(hits(burnin+1:end)) < out(1)*acc * sqrt(i)/1.96
               pmiss =numhitsd < max(out(2)*acc, .001)* sqrt(i-burnin)/1.96
               mwt = waitsd < max(out(3)*acc, .001)* sqrt(i-burnin)/1.96
               md = delaysd < max(out(4)*acc, .001)* sqrt(i-burnin)/1.96
               propD = numdelaysd < max(out(5)*acc, .001)* sqrt(i-burnin)/1.96
               stopCrit = min([pmiss mwt md propD]);
               if stopCrit == 1
                    stop = 1;
               end
           end
           i
           times = exprnd((lambda)^(-1),1,N);
           fileselect = randsample(1:n, N, true, pop/totpop); 
           hits = zeros(1,N);
           miss =  zeros(1,N);
           wait = zeros(1,N);
           delay = zeros(1,N);
       end
       i = i+1;
    end
    
    i = i-1;
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

    
  %% Complete Simulation
    disp('Entering Simulation of LRU')
    cache = zeros(1,n);
    newcache = zeros(1,n);
    queue = 0;
    numin = zeros(1,n);
    numfin = 0;
    hits = zeros(1,N);
    miss = zeros(1,N);
    qind = 1;
    wait = zeros(1,N);
    delay = zeros(1,N);
    i = 1;
    stop = 0;
    hitsum =0;
   sizesum = 0;
   numhitsum = 0;
   waitsum = 0;
   delaysum = 0;
   numdelaysum = 0;
   numhitsd = 0;
   waitsd = 0;
   delaysd = 0;
   numdelaysd =0;
    while stop == 0
       j = mod(i,N);
       if j == 0
           j = N;
       end

       queue = max(0, queue - times(j));
       chosen = fileselect(j);
       %Move requested file to front of cache

       newcache(1) = chosen;
       if numin(chosen) > 0 
           ind = cache == chosen;
           newcache(2:end) = cache(~ind);
       else
           newcache(2:end) = cache(1:end-1);
           numfin = numfin+1;
       end
       cache = newcache;


       %If not all the chunks are in the cache then add the remaining
       if numin(chosen) < sizes(chosen)
           notin = sizes(chosen)-numin(chosen);
           hits(j) = numin(chosen);
           miss(j) = sizes(chosen)-numin(chosen);
           proctimes = exprnd(qlam^(-1),1,notin);
           delay(j) = sum(max([(cumsum(proctimes) + queue) - ([numin(chosen):(sizes(chosen)-1)] .*clen+ stupd) 0]));
           queue = queue + sum(proctimes);
           wait(j) = queue;
           numin(chosen) = sizes(chosen);         
           while sum(numin) > C
               numin(cache(numfin)) = numin(cache(numfin)) - min(sum(numin)-C,numin(cache(numfin)));
               if numin(cache(numfin)) == 0
                   cache(numfin) = 0;
                   numfin = numfin - 1;
               end
           end           
       else
           hits(j) = numin(chosen);  
           wait(j) = 0;
           delay(j) = 0;
       end
       if mod(i,N) == 0
           if i > burnin 
               hitsum = hitsum + sum(hits);
               sizesum = sizesum + sum(sizes(fileselect));
               numhitsum = numhitsum + sum(hits ==0);
               waitsum = waitsum + sum(wait);
               delaysum = delaysum + sum(delay);
               numdelaysum = numdelaysum + sum(delay >0);
               out(6) = hitsum/sizesum
               out(7) = numhitsum/(i-burnin)
               out(8) = waitsum/(i-burnin)
               out(9) = delaysum/(i-burnin)
               out(10) = numdelaysum/(i-burnin)
               numhitsd = sqrt(((i-N-burnin-1)*numhitsd^2 + (N-1)*std(hits==0)^2)/(i-burnin-1))
               waitsd = sqrt(((i-N-burnin-1)*waitsd^2 + (N-1)*std(wait)^2)/(i-burnin-1))
               delaysd = sqrt(((i-N-burnin-1)*delaysd^2 + (N-1)*std(delay)^2)/(i-burnin-1))
               numdelaysd = sqrt(((i-N-burnin-1)*numdelaysd^2 + (N-1)*std(delay>0)^2)/(i-burnin-1))
               max([(numhitsd*1.96/(acc*out(7)))^2 (waitsd*1.96/(acc*out(8)))^2 ...
                   (delaysd*1.96/(acc*out(9)))^2 (numdelaysd*1.96/(acc*out(10)))^2])
%            pcache = std(hits(burnin+1:end)) < out(1)*acc * sqrt(i)/1.96
               pmiss =numhitsd <= max(out(7)*acc , .001)* sqrt(i-burnin)/1.96
               mwt = waitsd <= max(out(8)*acc , .001)* sqrt(i-burnin)/1.96
               md = delaysd <= max(out(9)*acc, .001)* sqrt(i-burnin)/1.96
               propD = numdelaysd <= max(out(10)*acc, .001)* sqrt(i-burnin)/1.96
               stopCrit = min([pmiss mwt md propD]);
               if stopCrit == 1
                    stop = 1;
               end
           end
           i
           times = exprnd((lambda)^(-1),1,N);
           fileselect = randsample(1:n, N, true, pop/totpop); 
           hits = zeros(1,N);
           miss =  zeros(1,N);
           wait = zeros(1,N);
           delay = zeros(1,N);
       end
       i = i+1;
    end
    i = i-1;
    disp('Proportion from Cache')
    out(6)
    disp('Prop Entire Miss')
    out(7) 
    disp('Mean Wait Time')
    out(8)
    disp('Mean Delay')
    out(9)
    disp('Prop Delayed')
    out(10)
    
end