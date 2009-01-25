%
%classifies waveforms and only returns good ones.
%
%urut/april04
function [OKspikes, OKtimestamps,nrSpikesKilled, killedSpikes] = classifySpikes( allSpikes, allTimestamps )

allSpikes = upsampleSpikes( allSpikes );

toKeep=zeros(1,size(allSpikes,1));
for i=1:size(allSpikes,1)
        waveFormStat = classifyWave( allSpikes(i,:) );
        if waveFormStat==true
            toKeep(i)=1;
        end
end

OKspikes = allSpikes(find(toKeep),:);
OKtimestamps = allTimestamps(find(toKeep));

nrSpikesKilled = length(find(toKeep==0));

killedSpikes = allSpikes(find(toKeep==0),:);