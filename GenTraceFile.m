trace0 = readtable('mds_0.csv', 'Format', '%f%s%u%s%u%u%f');

% Consider only read requests
trace0 = trace0(cellfun(@(lam)isequal(lam,'Read'), trace0{:,4}), :);

% Save First Trace
timestamp = double(trace0{:,1});
file_sizes = double(trace0{:,6});
save('trace0_data.mat', 'timestamp', 'file_sizes')


trace0 = readtable('CAMRESWEBA03-lvm0.csv', 'Format', '%f%s%u%s%u%u%f');

% Consider only read requests
trace0 = trace0(cellfun(@(lam)isequal(lam,'Read'), trace0{:,4}), :);

% Save Second Trace
timestamp = double(trace0{:,1});
file_sizes = double(trace0{:,6});
save('webtrace0_data.mat', 'timestamp', 'file_sizes')
