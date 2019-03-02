sizes = [15 30];
caches = [1000 5000];
alphas = [.8 1.2];


for i = 1:length(sizes)
    for j = 1:length(caches)
        for k = 1:length(alphas)
            Cachesim(10000000, alphas(k), sizes(i), caches(j))
        end
    end
end