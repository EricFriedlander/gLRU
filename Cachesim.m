function worst=Cachesim(N, alpha, chunks, C)

    %% Input Parameters
    n = 10000;
    pop = zipf_rand(n,alpha,n);
    pop = sort(pop,'descend');
    % sizes = unidrnd(7,1,n);
    sizes = ones(1,n) * chunks;
    biggest = max(sizes);  
    totpop = sum(pop);
    lambda = 1;
    font_size = 24;
    line_width = 3;
    marker_size = 15;

    %% Solve for tc
    disp('Solving for root')
    func = @(t) timeapproxgLRU(t,n,pop,sizes)-C;
    options = optimset('TolX', 10^(-16));
    tc = fzero(func,0,options)

    %% Define Hit rate Function

    hitrate = @(pop,k) expcdf(tc,1/pop).^k- expcdf(tc,1/pop).^(k+1);

    %% Generate interarrrival times and file selections
    fileselect = randsample(1:n, N, true, pop/totpop);

    %% Complete Simulation
    disp('Entering Simulation')
    cache = zeros(1,C);
    newcache = zeros(1,C);
    numin = zeros(1,n);
    hits = zeros(1,N);
    for i = 1:N
       chosen = fileselect(i);
       if numin(chosen) > 0
           ind = cache == chosen;
           newcache(1:numin(chosen)) = cache(ind);
           newcache(numin(chosen)+1:end) = cache(~ind);
           cache = newcache;
       end


       if numin(chosen) < sizes(chosen)
           if cache(end) ~= 0
                numin(cache(end)) = numin(cache(end)) - 1;
           end
           cache(2:end) = cache(1:end-1);
           cache(1) = fileselect(i);
           hits(i) = numin(chosen);
           numin(chosen) = numin(chosen)+1;

       else
           hits(i) = numin(chosen);
       end
       if mod(i,100000) == 0
           disp(i/N)
       end
    end
    worst = 0
    hold off
    selected = fileselect == 1;
    tbl = tabulate(hits(selected));
    hitest = hitrate(pop(1),0:sizes(1)-1);

    plot(0:sizes(1),[hitest 1-sum(hitest)], 'b-','LineWidth',line_width);
    xlabel('Number of file chunks')
    ylabel('Probability of finding in cache')
    ylim([0 1])
    hold on
    plot(tbl(:,1),tbl(:,3)/100,'b*','MarkerSize',marker_size)
    hold on
    set(gca,'fontsize',font_size)
    padded = zeros(length(hitest)+1,1);
    padded(1:length(tbl(:,3))) = transpose(tbl(:,3)/100);
    worst_temp = max(abs(transpose([hitest 1-sum(hitest)]) - padded))
    worst = max(worst, worst_temp)


%     tbl = tabulate(hits(10));
%     selected = fileselect == 10;
%     tbl = tabulate(hits(selected));
%     hitest = hitrate(pop(10),0:sizes(10)-1);
% 
%     plot(0:sizes(10),[hitest 1-sum(hitest)], 'k--','LineWidth',1.5);
%     xlabel('Number of file chunks')
%     ylabel('Probability of finding in cache')
%     ylim([0 1])
%     hold on
%     plot(tbl(:,1),tbl(:,3)/100,'k+','LineWidth',1.5)
%     hold on
%     set(gca,'fontsize',font_size)
%     padded = zeros(length(hitest)+1,1);
%     padded(1:length(tbl(:,3))) = transpose(tbl(:,3)/100);
%     worst_temp = max(abs(transpose([hitest 1-sum(hitest)]) - padded));
%     worst = max(worst, worst_temp);
%     
    fileselect = fileselect(C+1:end);
    hits = hits(C+1:end);
    selected = fileselect == 100;
    tbl = tabulate(hits(selected));
    hitest = hitrate(pop(100),0:sizes(100)-1);
%     

    plot(0:sizes(100),[hitest 1-sum(hitest)], 'r:','LineWidth',line_width);
    xlabel('Number of file chunks')
    ylabel('Probability of finding in cache')
    ylim([0 1])
    hold on
    plot(tbl(:,1),tbl(:,3)/100,'ro','MarkerSize',marker_size)
    hold on
    set(gca,'fontsize',font_size)
    padded = zeros(length(hitest)+1,1);
    padded(1:length(tbl(:,3))) = transpose(tbl(:,3)/100);
    worst_temp = max(abs(transpose([hitest 1-sum(hitest)]) - padded));
    worst = max(worst, worst_temp);

    selected = fileselect == 1000;
    tbl = tabulate(hits(selected));
    hitest = hitrate(pop(1000),0:sizes(1000)-1);

    plot(0:sizes(1000),[hitest 1-sum(hitest)], 'm-.','LineWidth',line_width);
    xlabel('Number of file chunks')
    ylabel('Probability of finding in cache')
    ylim([0 1])
    hold on
    plot(tbl(:,1),tbl(:,3)/100,'mx','MarkerSize',marker_size)
    set(gca,'fontsize',font_size)
    filename = strcat('cachesim_N_',string(N),'_n_',string(n),'_alpha_', ...
    string(alpha),'_C_',string(C),'_chunks_',string(chunks),'.png');
    fig = gcf;
    print(fig,'-dpng',filename{1})
    padded = zeros(length(hitest)+1,1);
    padded(1:length(tbl(:,3))) = transpose(tbl(:,3)/100);
    worst_temp = max(abs(transpose([hitest 1-sum(hitest)]) - padded));
    worst = max(worst, worst_temp);

end

