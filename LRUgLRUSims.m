%  Generates figures 3, 4, and 5 and data from Tables 2,5, 6
% Note that if one has already run the simulations and generated
% 'simout1.mat' you can skip the first section. You may also want to omit
% sizeType 2 and 3 to speed things up as those results are only included
% in the appendix of the paper.


n = 1000; % number of files



alpha = [.8 1.2]; % Parameter for zipf
Cprop = [.1 .2]; % Size of cache as a fraction of total file size
font_size = 16;

sizeType = [1 2 3];
% 1 indicates independence between popularity and file size, 2 indicates
% positive correlation, and 3 indicates negative correlation


stupd = [3 4]; % Start up delay
clen = [1 2 3 4]; % chunk length
traffic = [.1 .5 .9]; % Traffic rate
procrate = [1 2 10 30]; % Server processing rate
out1 = zeros(2, 2, 3, 2, 4, 3, 4, 10);
% mypool = parpool(4)
parfor g = 1:4
    for a = 1:2
        for b = 1:2
            for c = 1:3
                for d = 1:2
                    for e = 1:4
                        for f = 1:3                
                           out1(a,b,c,d,e,f,g,:) = ...
                               CachesimCompEff(n,alpha(a),10,Cprop(b),sizeType(c), ...
                               stupd(d), clen(e), traffic(f), procrate(g),.01);
                        end
                    end
                end
            end
        end
    end
end
% delete(mypool)
save('simout1.mat','out1')


%% Analysis of non correlated simulations
load('simout1.mat')
diff = round(out1(:,:,1,:,:,:,:,1:5)-out1(:,:,1,:,:,:,:,6:10),2);
diffPerc = diff./out1(:,:,1,:,:,:,:,6:10);
diffPerc(isnan(diffPerc(:))) = 0;
i = zeros(20,7);
m = zeros(20,1);
inp = diffPerc(:,:,:,:,:,:,:,1);
sum(inp(:)>0)
sum(inp(:)<0)
mean(inp(:))
median(inp(:))
inp = diffPerc(:,:,:,:,:,:,:,2);
sum(inp(:)>0)
sum(inp(:)<0)
mean(inp(:))
median(inp(:))
inp = diffPerc(:,:,:,:,:,:,:,3);
sum(inp(:)>0)
sum(inp(:)<0)
mean(inp(:))
median(inp(:))
inp = diffPerc(:,:,:,:,:,:,:,4);
sum(inp(:)>0)
sum(inp(:)<0)
mean(inp(:))
median(inp(:))
inp = diffPerc(:,:,:,:,:,:,:,5);
sum(inp(:)>0)
sum(inp(:)<0)
mean(inp(:))
median(inp(:))

inp = diff(:,:,:,:,:,:,:,1);
mean(inp(:))
median(inp(:))
inp = diff(:,:,:,:,:,:,:,2);
mean(inp(:))
median(inp(:))
inp = diff(:,:,:,:,:,:,:,3);
mean(inp(:))
median(inp(:))
inp = diff(:,:,:,:,:,:,:,4);
mean(inp(:))
median(inp(:))
inp = diff(:,:,:,:,:,:,:,5);
mean(inp(:))
median(inp(:))




% Worst Gross
inp = diff(:,:,:,:,:,:,:,1);
[m(1), ind] = min(inp(:));
[i(1,1),i(1,2),i(1,3),i(1,4),i(1,5),i(1,6),i(1,7)] = ind2sub(size(diff),ind);

inp = diff(:,:,:,:,:,:,:,2);
[m(2), ind] = max(inp(:));
[i(2,1),i(2,2),i(2,3),i(2,4),i(2,5),i(2,6),i(2,7)] = ind2sub(size(diff),ind);

inp = diff(:,:,:,:,:,:,:,3);
[m(3), ind] = max(inp(:));
[i(3,1),i(3,2),i(3,3),i(3,4),i(3,5),i(3,6),i(3,7)] = ind2sub(size(diff),ind);

inp = diff(:,:,:,:,:,:,:,4);
[m(4), ind] = max(inp(:));
[i(4,1),i(4,2),i(4,3),i(4,4),i(4,5),i(4,6),i(4,7)] = ind2sub(size(diff),ind);

inp = diff(:,:,:,:,:,:,:,5);
[m(5), ind] = max(inp(:));
[i(5,1),i(5,2),i(5,3),i(5,4),i(5,5),i(5,6),i(5,7)] = ind2sub(size(diff),ind);


% Worst by Percent
inp = diffPerc(:,:,:,:,:,:,:,1);
[m(6), ind] = min(inp(:));
[i(6,1),i(6,2),i(6,3),i(6,4),i(6,5),i(6,6),i(6,7)] = ind2sub(size(diff),ind);

inp = diffPerc(:,:,:,:,:,:,:,2);
[m(7), ind] = max(inp(:));
[i(7,1),i(7,2),i(7,3),i(7,4),i(7,5),i(7,6),i(7,7)] = ind2sub(size(diff),ind);

inp = diffPerc(:,:,:,:,:,:,:,3);
[m(8), ind] = max(inp(:));
[i(8,1),i(8,2),i(8,3),i(8,4),i(8,5),i(8,6),i(8,7)] = ind2sub(size(diff),ind);

inp = diffPerc(:,:,:,:,:,:,:,4);
[m(9), ind] = max(inp(~isinf(inp(:))));
[i(9,1),i(9,2),i(9,3),i(9,4),i(9,5),i(9,6),i(9,7)] = ind2sub(size(diff),ind);

inp = diffPerc(:,:,:,:,:,:,:,5);
[m(10), ind] = max(inp(~isinf(inp(:))));
[i(10,1),i(10,2),i(10,3),i(10,4),i(10,5),i(10,6),i(10,7)] = ind2sub(size(diff),ind);


%Best Gross
inp = diff(:,:,:,:,:,:,:,1);
[m(11), ind] = max(inp(:));
[i(11,1),i(11,2),i(11,3),i(11,4),i(11,5),i(11,6),i(11,7)] = ind2sub(size(diff),ind);

inp = diff(:,:,:,:,:,:,:,2);
[m(12), ind] = min(inp(:));
[i(12,1),i(12,2),i(12,3),i(12,4),i(12,5),i(12,6),i(12,7)] = ind2sub(size(diff),ind);

inp = diff(:,:,:,:,:,:,:,3);
[m(13), ind] = min(inp(:));
[i(13,1),i(13,2),i(13,3),i(13,4),i(13,5),i(13,6),i(13,7)] = ind2sub(size(diff),ind);

inp = diff(:,:,:,:,:,:,:,4);
[m(14), ind] = min(inp(:));
[i(14,1),i(14,2),i(14,3),i(14,4),i(14,5),i(14,6),i(14,7)] = ind2sub(size(diff),ind);

inp = diff(:,:,:,:,:,:,:,5);
[m(15), ind] = min(inp(:));
[i(15,1),i(15,2),i(15,3),i(15,4),i(15,5),i(15,6),i(15,7)] = ind2sub(size(diff),ind);

% Best by Percent
inp = diffPerc(:,:,:,:,:,:,:,1);
[m(16), ind] = max(inp(:));
[i(16,1),i(16,2),i(16,3),i(16,4),i(16,5),i(16,6),i(16,7)] = ind2sub(size(diff),ind);

inp = diffPerc(:,:,:,:,:,:,:,2);
[m(17), ind] = min(inp(:));
[i(17,1),i(17,2),i(17,3),i(17,4),i(17,5),i(17,6),i(17,7)] = ind2sub(size(diff),ind);

inp = diffPerc(:,:,:,:,:,:,:,3);
[m(18), ind] = min(inp(:));
[i(18,1),i(18,2),i(18,3),i(18,4),i(18,5),i(18,6),i(18,7)] = ind2sub(size(diff),ind);

inp = diffPerc(:,:,:,:,:,:,:,4);
[m(19), ind] = min(inp(~isinf(inp(:))));
[i(19,1),i(19,2),i(19,3),i(19,4),i(19,5),i(19,6),i(19,7)] = ind2sub(size(diff),ind);

inp = diffPerc(:,:,:,:,:,:,:,5);
[m(20), ind] = min(inp(~isinf(inp(:))));
[i(20,1),i(20,2),i(20,3),i(20,4),i(20,5),i(20,6),i(20,7)] = ind2sub(size(diff),ind);


%% Generate histogrames for relative differences with no correlation
inp = diffPerc(:,:,:,:,:,:,:,1);
[m(16), ind] = max(inp(:));
[i(16,1),i(16,2),i(16,3),i(16,4),i(16,5),i(16,6),i(16,7)] = ind2sub(size(diff),ind);
histogram(inp(:))
xlabel('p_c Relative Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_pc.png');
fig = gcf;
print(fig,'-dpng',filename)

inp = diffPerc(:,:,:,:,:,:,:,2);
[m(17), ind] = min(inp(:));
[i(17,1),i(17,2),i(17,3),i(17,4),i(17,5),i(17,6),i(17,7)] = ind2sub(size(diff),ind);
histogram(inp(:))
xlabel('p_m Relative Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_pm.png');
fig = gcf;
print(fig,'-dpng',filename)


inp = diffPerc(:,:,:,:,:,:,:,3);
[m(18), ind] = min(inp(:));
[i(18,1),i(18,2),i(18,3),i(18,4),i(18,5),i(18,6),i(18,7)] = ind2sub(size(diff),ind);
histogram(inp(:))
xlabel('T_w Relative Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_tw.png');
fig = gcf;
print(fig,'-dpng',filename)

inp = diffPerc(:,:,:,:,:,:,:,4);
[m(19), ind] = min(inp(:));
[i(19,1),i(19,2),i(19,3),i(19,4),i(19,5),i(19,6),i(19,7)] = ind2sub(size(diff),ind);
edges = [-1.2:.1:0];
histogram(inp(:),edges)
xlabel('T_d  Relative Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_td.png');
fig = gcf;
print(fig,'-dpng',filename)

inp = diffPerc(:,:,:,:,:,:,:,5);
[m(20), ind] = min(inp(:));
[i(20,1),i(20,2),i(20,3),i(20,4),i(20,5),i(20,6),i(20,7)] = ind2sub(size(diff),ind);
histogram(inp(:))
xlabel('p_d Relative Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_pd.png');
fig = gcf;
print(fig,'-dpng',filename)


%% Genereate Histograms for gross differences with no correlation
gLRU = out1(:,:,1,:,:,:,:,4);
LRU = out1(:,:,1,:,:,:,:,9);

histogram(round(gLRU(:)-LRU(:),2))
xlabel('T_d Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_tdgr.png');
fig = gcf;
print(fig,'-dpng',filename)

gLRU = out1(:,:,1,:,:,:,:,5);
LRU = out1(:,:,1,:,:,:,:,10);
histogram(round(gLRU(:)-LRU(:),2))
xlabel('p_d Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_pdgr.png');
fig = gcf;
print(fig,'-dpng',filename)

gLRU = out1(:,:,1,:,:,:,:,1);
LRU = out1(:,:,1,:,:,:,:,6);
histogram(round(gLRU(:)-LRU(:),2))
xlabel('p_c Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_pcgr.png');
fig = gcf;
print(fig,'-dpng',filename)

gLRU = out1(:,:,1,:,:,:,:,2);
LRU = out1(:,:,1,:,:,:,:,7);
histogram(round(gLRU(:)-LRU(:),2))
xlabel('p_m Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_pmgr.png');
fig = gcf;
print(fig,'-dpng',filename)

gLRU = out1(:,:,1,:,:,:,:,3);
LRU = out1(:,:,1,:,:,:,:,8);
histogram(round(gLRU(:)-LRU(:),2))
xlabel('T_w Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('hist_twgr.png');
fig = gcf;
print(fig,'-dpng',filename)


%% Examine Different Popularities (I.e. correlations between popularity and file size
diff2 = round(out1(:,:,2,:,:,:,:,1:5)-out1(:,:,2,:,:,:,:,6:10),2);
diffPerc2 = diff./out1(:,:,2,:,:,:,:,6:10);
diffPerc2(isnan(diffPerc2(:))) = 0;


diff3 = round(out1(:,:,3,:,:,:,:,1:5)-out1(:,:,3,:,:,:,:,6:10),2);
diffPerc3 = diff./out1(:,:,3,:,:,:,:,6:10);
diffPerc3(isnan(diffPerc3(:))) = 0;

inp = diffPerc2(:,:,:,:,:,:,:,1);
mean(inp(:))
inp = diffPerc2(:,:,:,:,:,:,:,2);
mean(inp(:))
inp = diffPerc2(:,:,:,:,:,:,:,3);
mean(inp(:))
inp = diffPerc2(:,:,:,:,:,:,:,4);
mean(inp(:))
inp = diffPerc2(:,:,:,:,:,:,:,5);
mean(inp(:))

inp = diffPerc3(:,:,:,:,:,:,:,1);
mean(inp(:))
inp = diffPerc3(:,:,:,:,:,:,:,2);
mean(inp(:))
inp = diffPerc3(:,:,:,:,:,:,:,3);
mean(inp(:))
inp = diffPerc3(:,:,:,:,:,:,:,4);
mean(inp(:))
inp = diffPerc3(:,:,:,:,:,:,:,5);
mean(inp(:))



diffgLRU = round(out1(:,:,2,:,:,:,:,1:5)-out1(:,:,3,:,:,:,:,1:5),2);
diffLRU = round(out1(:,:,2,:,:,:,:,6:10)-out1(:,:,3,:,:,:,:,6:10),2);
diffPerc2 = diffgLRU./out1(:,:,3,:,:,:,:,1:5);
diffPerc2(isnan(diffPerc2(:))) = 0;
diffPerc3 = diffLRU./out1(:,:,3,:,:,:,:,6:10);
diffPerc3(isnan(diffPerc3(:))) = 0;
inp = diffPerc2(:,:,:,:,:,:,:,1);
mean(inp(:))
inp = diffPerc2(:,:,:,:,:,:,:,2);
mean(inp(:))
inp = diffPerc2(:,:,:,:,:,:,:,3);
mean(inp(:))
inp = diffPerc2(:,:,:,:,:,:,:,4);
mean(inp(:))
inp = diffPerc2(:,:,:,:,:,:,:,5);
mean(inp(:))

inp = diffPerc3(:,:,:,:,:,:,:,1);
mean(inp(:))
inp = diffPerc3(:,:,:,:,:,:,:,2);
mean(inp(:))
inp = diffPerc3(:,:,:,:,:,:,:,3);
mean(inp(:))
inp = diffPerc3(:,:,:,:,:,:,:,4);
mean(inp(:))
inp = diffPerc3(:,:,:,:,:,:,:,5);
mean(inp(:))


% 
% Percent
hold off
inp1 = diffgLRU(:,:,:,:,:,:,:,1);
inp2 = diffLRU(:,:,:,:,:,:,:,1)
histogram(inp1(:),'facealpha',.5,'facecolor','r')
hold on
histogram(inp2(:),'facealpha',.5,'facecolor','g')
legend('gLRU','LRU','location','northeast')
xlabel('p_c Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('histcomp_pc.png');
fig = gcf;
print(fig,'-dpng',filename)

hold off
inp1 = diffgLRU(:,:,:,:,:,:,:,2);
inp2 = diffLRU(:,:,:,:,:,:,:,2)
histogram(inp1(:),'facealpha',.5,'facecolor','r')
hold on
histogram(inp2(:),'facealpha',.5,'facecolor','g')
legend('gLRU','LRU','location','northeast')
xlabel('p_m Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('histcomp_pm.png');
fig = gcf;
print(fig,'-dpng',filename)

hold off
inp1 = diffgLRU(:,:,:,:,:,:,:,3);
inp2 = diffLRU(:,:,:,:,:,:,:,3)
histogram(inp1(:),'facealpha',.5,'facecolor','r')
hold on
histogram(inp2(:),'facealpha',.5,'facecolor','g')
legend('gLRU','LRU','location','northeast')
xlabel('T_w Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('histcomp_tw.png');
fig = gcf;
print(fig,'-dpng',filename)

hold off
inp1 = diffgLRU(:,:,:,:,:,:,:,4);
inp2 = diffLRU(:,:,:,:,:,:,:,4)
histogram(inp1(:),'facealpha',.5,'facecolor','r')
hold on
histogram(inp2(:),'facealpha',.5,'facecolor','g')
legend('gLRU','LRU','location','northeast')
xlabel('T_d Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('histcomp_td.png');
fig = gcf;
print(fig,'-dpng',filename)

hold off
inp1 = diffgLRU(:,:,:,:,:,:,:,5);
inp2 = diffLRU(:,:,:,:,:,:,:,5)
histogram(inp1(:),'facealpha',.5,'facecolor','r')
hold on
histogram(inp2(:),'facealpha',.5,'facecolor','g')
legend('gLRU','LRU','location','northeast')
xlabel('p_d Gross Difference')
set(gca,'fontsize',font_size)
filename = strcat('histcomp_pd.png');
fig = gcf;
print(fig,'-dpng',filename)