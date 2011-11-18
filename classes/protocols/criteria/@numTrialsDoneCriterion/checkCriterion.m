function [graduate details] = checkCriterion(c,subject,trainingStep,trialRecords)
% this criterion will graduate if we have done a certain number of trials in this trainingStep

thisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;
thisStep(1:find(~thisStep,1,'last')) = false;
trialsUsed=trialRecords(thisStep);

details=[];
graduate=0;
if length(trialsUsed) >= c.numTrialsNeeded
    graduate = 1;
    playGraduationTone(subject);
end