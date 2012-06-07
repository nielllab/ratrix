function [graduate details] = checkCriterion(c,subject,trainingStep,trialRecords)
% this criterion will graduate if we have done a certain number of trials in this trainingStep

if trialRecords(end).trialNumber > c.numTrialsNeeded && length(trialRecords) < c.numTrialsNeeded
    length(trialRecords)
    trialRecords(end).trialNumber
    c.numTrialsNeeded
    error('criterion is longer than the circular buffer set in @station/doTrials (roughly line 76) -- how architect?')
end

thisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;
thisStep(1:find(~thisStep,1,'last')) = false;
trialsUsed=trialRecords(thisStep);

details=[];
graduate=0;
if length(trialsUsed) >= c.numTrialsNeeded
    graduate = 1;
    playGraduationTone(subject);
end