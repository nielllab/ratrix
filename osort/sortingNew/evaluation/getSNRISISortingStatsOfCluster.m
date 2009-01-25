%
%gets, for all clusters of a particular channel, the %ISI < 3ms for each cluster as well as the SNR of the mean waveform.
%originally in evalSNRAllCells.m, moved to this function march07.
%
%
%urut/march07
function [stats,nrSorted] = getSNRISISortingStatsOfCluster(channel, sessionID, useNegative, assignedNegative, newSpikesNegative, newTimestampsNegative, stdEstimateOrig)
stats=[];
nrSorted=0;
for k=1:length(useNegative)
    clNr = useNegative(k);
    inds = find( assignedNegative == clNr );
    mWaveform = mean ( newSpikesNegative(inds,:) );
    SNR = calcSNR( mWaveform, stdEstimateOrig);

    ISI = diff(newTimestampsNegative(inds));
    ISI = ISI/1000; %to ms

    ISIbelowAbs  = length(find( ISI < 3.0 ));
    ISIbelowPerc = ISIbelowAbs*100/length(ISI);

    entry = [ sessionID channel clNr length(inds) stdEstimateOrig SNR max(mWaveform) ISIbelowPerc ISIbelowAbs];
    entryNr = size(stats,1)+1;

    nrSorted=nrSorted+length(inds);

    stats(entryNr,:) = entry;
end
