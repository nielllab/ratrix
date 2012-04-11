function [targetPorts, distractorPorts, details, text] = assignPorts(trialManager,trialRecords,responsePorts)
lastResult = [];
lastCorrect = [];
lastWasCorrection = false;

if ~isempty(trialRecords) && length(trialRecords)>1
    lastRec=trialRecords(end-1);
    
    try % may not have result field
        lastResult = find(lastRec.result);
    end
    try % may not have trialDetails.correct field
        lastCorrect = lastRec.trialDetails.correct;        
    catch
        try % may not have correct field
            lastCorrect = lastRec.correct; %who normally sets this?  i can only find runRealTimeLoop.313 where it is inited to []
        end
    end
    
    try % may not have correctionTrial field
        lastWasCorrection = lastRec.stimDetails.correctionTrial;
    end
    
    if length(lastResult)>1
        lastResult = lastResult(1);
    end
    
end

if ~isempty(lastCorrect) && ...
        ~isempty(lastResult) && ...
        ~lastCorrect && ...
        (length(lastRec.targetPorts)==1 || strcmp(trialRecords(end).trialManagerClass,'ball')) && ... %ugh!
        (lastWasCorrection || rand<trialManager.percentCorrectionTrials)
    
    details.correctionTrial = 1;
    targetPorts = lastRec.targetPorts;
    text = 'correction trial!';
else
    details.correctionTrial = 0;
    targetPorts = responsePorts(ceil(rand*length(responsePorts)));
    text = '';
end

distractorPorts = setdiff(responsePorts,targetPorts);
end