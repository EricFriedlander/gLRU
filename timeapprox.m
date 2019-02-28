function out = timeapprox(t,n, popularity,sizes)
%     Computes approximate time to traverse gLRU queue
    out = 0;
    for i = 1:n
        out = out + expinqueue(t,popularity(i),sizes(i));
    end
end