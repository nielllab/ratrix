function goods=getGoods(d,type,removeHuman,includeCenterResponses)

if ~exist('removeHuman','var') || isempty(removeHuman)
    removeHuman=true;
end

if ~exist('includeCenterResponses','var') || isempty(includeCenterResponses)
    includeCenterResponses=false;  %non-2AFC paradigms will need to include these to analyze center response trials
end

if ~exist('type', 'var') || isempty(type)
    type='basic';
end

if ismember('correctionTrial',fields(d))
    CTs=(d.correctionTrial==1);
else
    CTs=zeros(size(d.correct)); %freeDrinks never defined this
end

if ismember('responseTime', fields(d))
    tooFast=d.responseTime<0.02; % remove those too fast to be a rat (water block)
else
    tooFast=zeros(size(d.date));
end

%containedManualPokes=d.containedManualPokes==1;  this fact breaks during free drinks

manualKill=(d.response==0);
dualResponse=(d.response==-1);
otherBadResponses=(d.response<-1);
if ismember('maxCorrectForceSwitch', fields(d))
    nonRandom=(d.maxCorrectForceSwitch==1);
else
    nonRandom=zeros(size(d.date));
end

if ismember('didStochasticResponse', fields(d))
    didStochasticResponse=(d.didStochasticResponse==1);
else
    didStochasticResponse=zeros(size(d.date));
end

if ismember('containedForcedRewards', fields(d))
    containedForcedRewards=(d.containedForcedRewards==1);
else
    containedForcedRewards=zeros(size(d.date));
end

if ismember('didHumanResponse', fields(d))
    didHumanResponse=(d.didHumanResponse==1);
else
    didHumanResponse=zeros(size(d.date));
end

afterError=[0 d.correct(1:end-1)==0];

%afterCTs=[0 CTs(1:end-1)];
%ignore=union(union(CTs,afterCTs),union(manualKill,dualResponse));
%goods=logical(ones(1,totalTrials));
%goods(ignore)=0;

switch type
 case 'basic'
        goods=(~CTs  & ~manualKill & ~dualResponse & ~nonRandom & ~tooFast & ~didStochasticResponse & ~containedForcedRewards); %including afterError in goods
    case 'withoutAfterError'
        goods=(~CTs  & ~manualKill & ~dualResponse & ~nonRandom & ~tooFast & ~didStochasticResponse & ~containedForcedRewards& ~afterError);
    case 'justAfterError' %without correctionTrials
        goods=(~CTs  & ~manualKill & ~dualResponse & ~nonRandom & ~tooFast & ~didStochasticResponse & ~containedForcedRewards & afterError);
    case 'justCorrectionTrials'
        goods=CTs & ~manualKill & ~dualResponse & ~tooFast & ~didStochasticResponse & ~containedForcedRewards; %
    case 'humanPsych'
        goods=(~CTs  & ~manualKill & ~dualResponse & ~nonRandom & ~didStochasticResponse & ~containedForcedRewards); %including afterError in goods
        removeHuman=false;
    case 'forBias'
        error('just includeCenterResponses')
        
        %this is to ignore center responses in free drinks, if you want
        %to analyze free drinks stuff, the notion of bias must be
        %updated, rigth now numRight+numLeft=total.  Another type of
        %bias would have a harder time analyzing trials that are of
        %BOTH 2AFC and all three ports equal...
        goods=(~manualKill & ~dualResponse & ~centerResponses & ~tooFast & ~didStochasticResponse & ~containedForcedRewards & ~otherBadResponses);
    otherwise
        error('wrong type')
end


if ~includeCenterResponses
    centerResponses = d.response==2;
    goods=goods & ~centerResponses;
end


%remove trials where correctness is not known
goods(isnan(d.correct))=0;

%remove trials where response is not nominal
if ismember('result', fields(d))
    %all trials in the future would have nominal==1
    goods(d.result~=1 & ~isnan(d.result))=0;
    %many trials in the past may have nan for result, so thats still an
    %acceptable answer for now... maybe we can remove this if every rat
    %ever on the ratrix is recompiled. (including non-active ones)
end



if removeHuman
    goods=goods&~didHumanResponse;
end