function [graduate details] = checkCriterion(c,subject,trainingStep,trialRecords)

fieldNames = fields(trialRecords);

% Old version is guaranteed to have this information. Do I check for this
% too?
trialsThisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;


forcedRewards = 0;
stochastic = 0;
humanResponse = 0;
warnStatus = false;
% looks ugly
if any(ismember(fieldNames,{'containedForcedRewards'}))
    forcedRewards = [trialRecords.containedForcedRewards]==1;
else 
    warnStatus = warnStatus | true;
end
if any(ismember(fieldNames,{'didStochasticResponse'}))
    stochastic = [trialRecords.didStochasticResponse];
else 
    warnStatus = warnStatus | true;
end
if any(ismember(fieldNames,{'didHumanResponse'}))
    humanResponse = [trialRecords.didHumanResponse];
else 
    warnStatus = warnStatus | true;
end

if warnStatus
    warning('checkCriterion found trialRecords of the older format. some necessary fields are missing and have been assigned arbitrarily.');
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