%
%plots the firing frequence as a function of time for all clusters of a sorted channel
%used to check if there is electrode movement
%
%urut/oct06
function plotInstFiringOfClusters( filename, clusters )
%clusters={3298,2901};
%load('/data/SF_032406/sortNORE/5/A8_sorted_new.mat');

load(filename);
timestamps=newTimestampsNegative;
assigned=assignedNegative;


colors={'r','b','g','m','c','y'};

windowSizeIn=1;

kSize=20;
gaussKernel1 = getGaussianKernel(windowSizeIn*10, kSize);

figure(21);
hold on
for i=1:length(clusters)
    
    [nrSpikes,start,stop] = getBinnedSpikeCountForCluster( timestamps, assigned, clusters{i}, windowSizeIn );

    %smoothen
     smooth = conv(nrSpikes, gaussKernel1);

     y=smooth;
    plot( ([1:length(y)]*windowSizeIn)+start/1000, y, colors{i})

end
hold off
ylabel('Hz');
xlabel('sec');


