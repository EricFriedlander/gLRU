function out = expinqueue(t,pop,s)
    %      Computes hit probabilities gives popularity
    hitprob = @(popu,k) expcdf(t,1/popu).^k;
    out = sum(hitprob(pop,1:s));
end