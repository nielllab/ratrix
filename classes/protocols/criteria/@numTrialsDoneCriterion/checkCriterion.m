function [graduate, details] = checkCriterion(c,subject,trainingStep,trialRecords)
% this criterion will graduate if we have done a certain number of trials in this trainingStep


%determine what type trialRecord are
recordType='largeData'; %circularBuffer

thisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;
trialsUsed=trialRecords(thisStep);

graduate=0;
if ~isempty(trialRecords)
    %get the correct vector
    switch recordType
        case 'largeData'
            if length(trialsUsed) >= c.numTrialsNeeded
                graduate = 1;
            end
        case 'circularBuffer'
            error('not written yet');
        otherwise
            error('unknown trialRecords type')
    end
end


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
        details.trialsPerMin = trialsPerMin;
    end
end