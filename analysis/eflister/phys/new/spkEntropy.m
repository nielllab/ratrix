function [bitsPerSpk bitsPerSec]=spkEntropy(spkTimesSecs)
%p log p of the isi distribution, lower bound for entropy of spike train
%edf's rewrite of pam's original (simplified by not expecting binned spike times)

maxSecs=1;
nBins=1000; %any problem with making this huge?  i think we need bins to have multiple spikes, should be smart about choosing bins so that the biggest bins have say 20 spikes?

isiDist=hist(diff(spkTimesSecs),linspace(0,maxSecs,nBins)); 
isiDist=isiDist/sum(isiDist);
isiDist=isiDist(isiDist>0);

bitsPerSpk = -sum( isiDist .* log2(isiDist) );
% now in units of per isi, which is to say, per spike. 
% multiply by spikes/sec to convert to units of bits/sec, 
bitsPerSec = bitsPerSpk * length(spkTimesSecs)/range(spkTimesSecs);