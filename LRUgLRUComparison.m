% Generates figure 1

alpha = .8;
n = 10000;
chunks = 5;
C = 1000;
sizeType = 4;
pop = zipf_rand(n,alpha,n);
pop = sort(pop,'descend');
shape = 2;
scale = 300;
k = 1/shape;
sig = scale*k;
theta = sig/k;
sizes = ones(1,n) * chunks;
biggest = max(sizes);  
totpop = sum(pop);
lambda = 1;
clen = 120;
fileLen = clen*chunks;
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

%% Solve for tc
disp('Solving for root')
func = @(t) timeapprox(t,n,pop,sizes)-C;
funcLRU = @(t) timeapproxLRU(t,n,pop,sizes)-C;
options = optimset('TolX', 10^(-16));
tc = fzero(func,0,options)
options = optimset('TolX', 10^(-16));
tcLRU = fzero(funcLRU,0,options)

%% Define Hit rate Function
prob = zeros(1,n);
probLRU = zeros(1,n);
hitrate = @(t,pop,k) expcdf(t,1/pop).^k;
for i = 1:n
   prob(i) =  hitrate(tc,pop(i),1);
   probLRU(i) = hitrate(tcLRU,pop(i),1);
end

proball = zeros(1,n);
proballLRU = zeros(1,n);
for i = 1:n
   proball(i) =  hitrate(tc,pop(i),sizes(i));
end

%% Plot
hold off
plot(1:n,prob, 'b-','LineWidth',1.5);
xlabel('Popularity Ranking')
ylabel('Probability')
% ylim([0 1])
hold on
plot(1:n,probLRU,'k--','LineWidth',1.5)
hold on
plot(1:n,proball, 'r:','LineWidth',1.5);
set(gca,'fontsize',16)
legend('gLRU - A', 'LRU - A',...
    'gLRU - F');
filename = strcat('LRUvgLRU_n_',string(n),'_alpha_', ...
string(alpha),'_C_',string(C),'_chunks_',string(chunks),...
    'sizeType',string(sizeType),'.png');
fig = gcf;
print(fig,'-dpng',filename{1})