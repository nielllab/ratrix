function [bitsPerSpk bitsPerSec]=spkEntropy(spkTimesSecs)
%p log p of the isi distribution, lower bound for entropy of spike train
%edf's rewrite of pam's original (simplified by not expecting binned spike times)
%we get the same answers, but awfully high ~15 bits per spike for poisson @13 hz?

test=false;
if test
    clc
    close all
    numMins=30;
    spkRate=13;
    spkTimesSecs=sort(rand(1,spkRate*60*numMins)*60*numMins);
end

if ~isvector(spkTimesSecs) || ~all(diff(spkTimesSecs)>=0)
    error('must be ascending vector')
end

maxSecs=1;
nBins=1000; %any problem with making this huge?  i think we need bins to have multiple spikes, should be smart about choosing bins so that the biggest bins have say 20 spikes?
%the test below shows it asymptotes to an upper limit, but need 0.1 us bins!

[bitsPerSpk bitsPerSec isiDist]=entHelp(spkTimesSecs,maxSecs,nBins);

if test
    %compare to pam's
    deltat=1000*maxSecs/nBins;
    spk=hist(spkTimesSecs,min(spkTimesSecs):deltat/1000:max(spkTimesSecs))';
    [isid, isidbin, Hcapac, nspk, FiringRate] = spk_entropyPR(spk, deltat, maxSecs*1000);
    %arg 1:    spk(i) is the number of spikes in the i'th time bin
    %        %edf notes: her code assumes it's a column
    %arg 2:    deltat is the time bin size
    %        %edf asks: what units? assuming ms.
    %arg 3:    maxisi is the longest isi for histogram, in msec (default 1000)
    
    fprintf('firing rate: edf:%g | pr:%g\n',length(spkTimesSecs)/range(spkTimesSecs),FiringRate)
    fprintf('entropy rate: edf:%g | pr:%g\n',bitsPerSec,Hcapac)
    
    subplot(2,1,1)
    plot(isiDist)
    
    subplot(2,1,2)
    bins=10.^[1:7];%[10 50 100 500 1000 5000 10000 50000 100000];
    bitsPerSpk=nan(size(bins));
    for i=1:length(bins)
        bitsPerSpk(i)=entHelp(spkTimesSecs,1,bins(i));
    end
    plot(bins,bitsPerSpk)
end

function [bitsPerSpk bitsPerSec isiDist]=entHelp(spkTimesSecs,maxSecs,nBins)
isiDist=hist(diff(spkTimesSecs),linspace(0,maxSecs,nBins));
isiDist=isiDist/sum(isiDist);
isiDist=isiDist(isiDist>0);

bitsPerSpk = -sum( isiDist .* log2(isiDist) );
%the entropy of a distribution is the average info content of a draw from it, right?

%don't we need to divide by length(spkTimesSecs) to get bits per spike?  
%no, now that sounds wrong to me...
%bitsPerSpk = bitsPerSpk/length(spkTimesSecs);

% now in units of per isi, which is to say, per spike.
% multiply by spikes/sec to convert to units of bits/sec,
bitsPerSec = bitsPerSpk * length(spkTimesSecs)/range(spkTimesSecs);

%from PR: 9/17/97
function [isid, isidbin, Hcapac, nspk, FiringRate] = spk_entropyPR(spk, deltat, maxisi)
% function [isid, isidbin, Hcapac,Nspk, FiringRate] =
%                  spkentropy(spk, deltat, maxisi, mincount)
%    spk(i) is the number of spikes in the i'th time bin
%    deltat is the time bin size
%    maxisi is the longest isi for histogram, in msec (default 1000)
%
% 	  can handle >1 spike in a bin properly
%	  note: if too little data for ISID, entropy is UNDERestimated not OVER

if nargin<3, maxisi=1000; end

% get stuff from spk
spktimes= full(find(spk)* deltat);
nspk=full(sum(spk)); % actual spikes
nbins=length(spk); % time bins
nspiketimes=length(spktimes); % number of spike time entries
TotTime=nbins*deltat/1000; % in sec
FiringRate=full(nspk/TotTime); % in Hz

% first get the intervals for spikes in different bins
isi=spktimes(2:nspiketimes) - spktimes(1:nspiketimes-1);
% then find bins with >1 spike and add these intervals (time irrelevant)
withinbin = sum( spk(find(spk>1)) - 1); %for each addl spike count one isi
isi=[isi; deltat*ones(withinbin,1)]; %append this many isis of 0..deltat

% compute isid
[isid, isidbin] =hist(isi,deltat:deltat:maxisi); % make histogram
isid=isid/sum(isid); % express as probabilities
nbin=length(isid);

% omit empty bins and pool if specified, before P log P calcs.
ind = find(isid); % nonzero bins
Hcapac=-1*sum( isid(ind) .* log2(isid(ind)) );
% Hcapac now in units of per isi, which is to say, per spike.
% multiply by spikes/sec to convert to units of bits/sec,
% also convert to full if sparse
Hcapac = full(Hcapac * FiringRate);