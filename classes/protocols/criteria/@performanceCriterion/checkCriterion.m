function [graduate details] = checkCriterion(c,subject,trainingStep,trialRecords)

trialsThisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;
stochastic = [trialRecords.didStochasticResponse];
humanResponse = [trialRecords.didHumanResponse];
forcedRewards = [trialRecords.containedForcedRewards]==1;

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