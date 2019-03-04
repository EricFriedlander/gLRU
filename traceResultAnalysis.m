avg_chunk = [10 , 50, 100];
cache_prop = [.01, .02, .025, .05, .1, .2, .25, .5];
aPT = .001;
stupd = 1;
avg_len = 30*60;
stepNum = 1000;
kmin = .5;
c_start = 15;
load('prodSimResults.mat')




metr = ["pc", "pm", "Tw", "Td", "pd"];
for i = 1:5
    disp(strcat('Now should results for metric :', metr(i)))
    temp = results(1,:,:,i) - results(2,:,:,i);
    disp('gLRU larger than segLRU')
    sum(temp(:) > 0)
    disp('gLRU less than segLRU')
    sum(temp(:) < 0)
    disp('gLRU equal to segLRU')
    sum(temp(:) == 0)
    non_zero = results(2,:,:,i) ~= 0;
    disp('Number of segLRU not equal to zero')
    sum(non_zero(:))
    disp('Number where both zero')
    sum(temp(:) == 0 & ~non_zero(:))
    rel = temp./results(2,:,:,i);
    disp('Minimum relative difference between gLRU and segLRU')
    min(rel(non_zero))
    disp('Median relative difference between gLRU and segLRU')
    median(rel(non_zero))
    disp('Maximum relative difference between gLRU and segLRU')
    max(rel(non_zero))
    pause;
end


for i = 1:5
    disp(strcat('Now should results for metric :', metr(i)))
    temp = results(1,:,:,i) - results(3,:,:,i);
    disp('gLRU larger than AdaptSize')
    sum(temp(:) > 0)
    disp('gLRU less than AdaptSize')
    sum(temp(:) < 0)
    disp('gLRU equal to AdaptSize')
    sum(temp(:) == 0)
    non_zero = results(3,:,:,i) ~= 0;
    disp('Number of AdaptSize not equal to zero')
    sum(non_zero(:))
    disp('Number where both zero')
    sum(temp(:) == 0 & ~non_zero(:))
    rel = temp./results(3,:,:,i);
    disp('Minimum relative difference between gLRU and AdaptSize')
    min(rel(non_zero))
    disp('Median relative difference between gLRU and AdaptSize')
    median(rel(non_zero))
    disp('Maximum relative difference between gLRU and AdaptSize')
    max(rel(non_zero))
    pause;
end