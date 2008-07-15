function [dpr h f]=getDprMesh(numBins)

if ~exist('numBins','var')
numBins=101; %101
end

numTrials=2*(numBins-1); %200

%assume equal number of signal present / no signal
fractionSigs=0.5;
numSigs=round(fractionSigs*numTrials); %100
numNoSigs=round((1-fractionSigs)*numTrials); %100

%thus 101 bins will be like 100 trials for the target present

%these values are not rates, but number of trials
[FA misses]=meshgrid(0:numSigs, 0:numNoSigs);
CR=numNoSigs-FA;
hits=numSigs-misses;

h=hits/numSigs;
f=FA/numNoSigs;


dpr = sqrt(2) * (erfinv((hits - misses)/numSigs) + erfinv((CR - FA)/numNoSigs)); %what I use (from code)

% dpr2 = sqrt(2) * (erfinv((2*h - 1)) + erfinv((1-2*f))) 
% diff=(dpr-dpr2)
%why isnt' this true?... rounding errors??
% imagesc(diff)

%dpr=flipud(dpr);