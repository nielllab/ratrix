%returns binned spikecounts (in Hz) for a cluster
%
%timestamps: all the timestamps that belong to this cluster, in us
%windowSizeIn: in sec, size of window for estimating the spike count
%
%urut/oct06
function [nrSpikes,start,stop] = getBinnedSpikeCountForCluster( timestamps, assigned, clNr, windowSizeIn )
clTimes = timestamps( find(assigned==clNr) );
clTimes = clTimes ./ 1000;
start = min( clTimes );
stop = max( clTimes );

%get nr spikes every X sec
windowSize=windowSizeIn*1000; %in ms

nrSpikes=[];
for k=start:windowSize:stop
    nrSpikes = [nrSpikes length(find( clTimes >= k & clTimes < k+windowSize ))];
end
nrSpikes = nrSpikes / (windowSize/1000); %conv to Hz
