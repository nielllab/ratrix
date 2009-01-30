function [targetPorts distractorPorts details]=assignPorts(details,lastTrialRec,responsePorts)

% figure out if this is a correction trial
lastResponse=[];
lastCorrect=[];
lastWasCorrection=0;
if ~isempty(lastTrialRec) % if there were previous trials
    lastResponse=find(lastTrialRec.response);
    lastCorrect=lastTrialRec.correct;

    if any(strcmp(fields(lastTrialRec.stimDetails),'correctionTrial'))
        lastWasCorrection=lastTrialRec.stimDetails.correctionTrial;
    else
        lastWasCorrection=0;
    end

    if length(lastResponse)>1
        lastResponse=lastResponse(1);
    end
end

% determine correct port
if ~isempty(lastCorrect) && ~isempty(lastResponse) && ~lastCorrect && length(lastTrialRec.targetPorts)==1 && (lastWasCorrection || rand<details.pctCorrectionTrials)
    details.correctionTrial=1;
    %'correction trial!'
    targetPorts=lastTrialRec.targetPorts; % same ports are correct
else
    details.correctionTrial=0;
    targetPorts=responsePorts(ceil(rand*length(responsePorts))); %choose random response port to be correct answer
end
distractorPorts=setdiff(responsePorts,targetPorts);