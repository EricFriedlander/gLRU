cd ..
cd MSR-Cambridge/
trace0 = readtable('mds_0.csv', 'Format', '%f%s%u%s%u%u%f');
trace1 = readtable('mds_1.csv', 'Format', '%f%s%u%s%u%u%f');

% Consider only read requests
trace0 = trace0(cellfun(@(lam)isequal(lam,'Read'), trace0{:,4}), :);
trace1 = trace1(cellfun(@(lam)isequal(lam, 'Read'), trace1{:,4}), :);


cd ..
cd TraceSim/

% Save First Trace
timestamp = double(trace0{:,1});
file_sizes = double(trace0{:,6});
save('trace0_data.mat', 'timestamp', 'file_sizes')

% Save Second Trace
timestamp = double(trace1{:,1});
file_sizes = double(trace1{:,6});
save('trace1_data.mat', 'timestamp', 'file_sizes')


cd ..
cd MSR-Cambridge/
trace0 = readtable('CAMRESWEBA03-lvm0.csv', 'Format', '%f%s%u%s%u%u%f');
trace1 = readtable('CAMRESWEBA03-lvm2.csv', 'Format', '%f%s%u%s%u%u%f');

% Consider only read requests
trace0 = trace0(cellfun(@(lam)isequal(lam,'Read'), trace0{:,4}), :);
trace1 = trace1(cellfun(@(lam)isequal(lam, 'Read'), trace1{:,4}), :);


cd ..
cd TraceSim/

% Save First Trace
timestamp = double(trace0{:,1});
file_sizes = double(trace0{:,6});
save('webtrace0_data.mat', 'timestamp', 'file_sizes')

% Save Second Trace
timestamp = double(trace1{:,1});
file_sizes = double(trace1{:,6});
save('webtrace2_data.mat', 'timestamp', 'file_sizes')
    