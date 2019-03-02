function out = timeapproxLRU(t,n, popularity,sizes)
    out = 0;
    for i = 1:n
        out = out + expcdf(t,1/popularity(i)) * sizes(i);
    end
end