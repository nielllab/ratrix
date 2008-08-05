function [graduate details] = checkCriterion(c,subject,trainingStep,trialRecords)

fieldNames = fields(trialRecords);

trialsThisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;

forcedRewards = 0;
stochastic = 0;
humanResponse = 0;

warnStatus = false;

if ismember({'containedForcedRewards'},fieldNames)
    ind = find(cellfun(@isempty,{trialRecords.containedForcedRewards}));
    if ~isempty(ind)
        warning('using pessimistic values for containedForcedRewards');
        trialRecords(ind).containedForcedRewards = 1;
    end
    forcedRewards = [trialRecords.containedForcedRewards]==1;
else 
    warnStatus = true;
end
if ismember({'didStochasticResponse'},fieldNames)
    ind = find(cellfun(@isempty,{trialRecords.didStochasticResponse}));
    if ~isempty(ind)
        warning('using pessimistic values for didStochasticResponse');
        trialRecords(ind).didStochasticResponse = 1;
    end
    stochastic = [trialRecords.didStochasticResponse];
else 
    warnStatus = true;
end
if ismember({'didHumanResponse'},fieldNames)
    ind = find(cellfun(@isempty,{trialRecords.didHumanResponse}));
    if ~isempty(ind)
        warning('using pessimistic values for didHumanResponse');
        trialRecords(ind).didHumanResponse = 1;
    end
    humanResponse = [trialRecords.didHumanResponse];
else 
    warnStatus = true;
end

if warnStatus
    warning(['checkCriterion found trialRecords of the older format. some necessary fields are missing. ensure presence of ' ...
    '''containedForcedRewards'',''didStochasticResponse'' and ''didHumanResponse'' in trialRecords to remove this warning']);
end

which= trialsThisStep & ~stochastic & ~humanResponse & ~forcedRewards;

[graduate whichCriteria correct]=aboveThresholdPerformance(c.consecutiveTrials,c.pctCorrect,trialRecords(which));

%play graduation tone
if graduate
    beep;
    waitsecs(.2);
    beep;
    waitsecs(.2);
    beep;
    waitsecs(1);
    [junk stepNum]=getProtocolAndStep(subject);
    for i=1:stepNum+1
        beep;
        waitsecs(.4);
    end
    if (nargout > 1)
        details.date = now;
        details.criteria = c;
        details.graduatedFrom = stepNum;
        details.allowedGraduationTo = stepNum + 1;
        details.correct = correct;
        details.whichCriteria = whichCriteria;
    end
end