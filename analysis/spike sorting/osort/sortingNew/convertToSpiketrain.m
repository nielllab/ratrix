%
%converts array of timestamps to spiketrain, with 1ms binsize
%
%
function n = convertToSpiketrain(timestamps)

spiketrain=(timestamps/1000);  %now in ms
spiketrain=spiketrain-spiketrain(1); %offset gone
roundedSpiketrain = round(spiketrain);
n=zeros(1,roundedSpiketrain(end));
n( roundedSpiketrain(find(roundedSpiketrain>0)) )=1;
