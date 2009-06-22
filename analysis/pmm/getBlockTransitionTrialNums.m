function [trialIDs details]=getBlockTransitionTrialNums(d,transitionFilter,trialsBeforeAfter,trialsPerBin)
%returns the trialNumbers for when there were transitions, blocked into temporal bins

%trialIDs is size (numInstances,numBins,trialsPerBin)
%transitionFilter=1; %a single whole number to denote the block ID change (ie. all increases by 2 steps)
                    %OR two numbers  [m n] indicating a pairwise transition from m to n]
                    %OR Inf for all increases
                    %OR -Inf for all decreases
%trialsBeforeAfter=[50 100]  %two number for the number of trials before  and afer included in analysis
%binSize=[5]          %number of trials in a row included in a bin.


if ~exist('d','var') || isempty(d)
    d=getSmalls('234');
end

if ~exist('transitionFilter','var') || isempty(transitionFilter)
    transitionFilter=Inf;
end

if ~exist('trialsBeforeAfter','var') || isempty(trialsBeforeAfter)
    trialsBeforeAfter=[50 100];
end

if ~exist('trialsPerBin','var') || isempty(trialsPerBin)
    trialsPerBin=5;
end


binsBeforeAfter=floor(trialsBeforeAfter/trialsPerBin);
if ~all(binsBeforeAfter~=trialsBeforeAfter*trialsPerBin)
    error('trialsPerBin must fit evenly into trialsBeforeAfter')
end

baseID=min(find(~isnan(d.trialThisBlock)));
if length(transitionFilter)==1 && isinf(transitionFilter) % all increases   
    instances=baseID+find(diff(d.blockID(baseID:end))*sign(transitionFilter)>=1);  %the index into the dat were the transition happens
elseif length(transitionFilter)==1 && iswholenumber(transitionFilter)
        instances=baseID+find(diff(d.blockID(baseID:end))==transitionFilter);  %the index into the dat were the transition happens
end
   
binStartStop=[linspace(-trialsBeforeAfter(1),trialsBeforeAfter(2)-trialsPerBin,sum(binsBeforeAfter));
    linspace(-trialsBeforeAfter(1)+trialsPerBin,trialsBeforeAfter(2),sum(binsBeforeAfter))-1];

trialIDs=nan(length(binStartStop),length(instances),trialsPerBin); % init
for i=1:length(binStartStop)
    for j=1:length(instances)      
        trialIDs(i,j,:)=instances(j)+[binStartStop(1,i):binStartStop(2,i)];
    end
end

% don't look in places greater than the length of the data
trialIDs(trialIDs>length(d.date))=nan;
trialIDs(trialIDs<1)=nan;

% remove trials that are not good


details.binsBeforeAfter=binsBeforeAfter;
details.instances=instances;
details.binStartStop=binStartStop;


