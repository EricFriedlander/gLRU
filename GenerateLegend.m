
   
clear all; close all;
figure;
marker_size = 10
line_width = 3
p1 = plot(NaN,NaN,  'b-','LineWidth',line_width);
hold on;
p2 = plot(NaN,NaN,'b*','MarkerSize',marker_size)
hold on;
% p3 = plot(NaN,NaN,  'k--','LineWidth',1);
% hold on;
% p4 = plot(NaN,NaN,'k+')
% hold on;
p5 = plot(NaN,NaN,  'r:','LineWidth',line_width);
hold on;
p6 = plot(NaN,NaN,'ro','MarkerSize',marker_size)
hold on;
p7 = plot(NaN,NaN,  'm-.','LineWidth',line_width);
hold on;
p8 = plot(NaN,NaN,'mx','MarkerSize',marker_size)
hold on;


% legend('Estimated hit rates for most popular file', 'Actual hit rates for most popular file',...
%     'Estimated hit rates for 10th most popular file', 'Actual hit rates for 10th most popular file',...
%     'Estimated hit rates for 100th most popular file', 'Actual hit rates for 100th most popular file',...
%     'Estimated hit rates for 1000th most popular file', 'Actual hit rates for 1000th most popular file');


legend('Estimated hit rates for most popular file', 'Actual hit rates for most popular file',...
    'Estimated hit rates for 100th most popular file', 'Actual hit rates for 100th most popular file',...
    'Estimated hit rates for 1000th most popular file', 'Actual hit rates for 1000th most popular file');

