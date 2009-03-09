function [dpr cr h f]=getDprMesh(numBins)
% returns a mesh of dprime and criteria
% dpr = norminv(h)-norminv(f);  
% cr =-(norminv(h)+norminv(f))/2;  

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

zHit = norminv(h) ;
zFA  = norminv(f) ;
dpr = zHit - zFA;    %this is within rounding error of what I use (from code)
%dpr = sqrt(2) * (erfinv((hits - misses)/numSigs) + erfinv((CR -FA)/numNoSigs)); %
cr = (zHit + zFA) ./ (-2);



