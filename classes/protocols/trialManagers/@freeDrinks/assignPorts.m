function [targetPorts, distractorPorts, details, text] = assignPorts(trialManager,trialRecords,responsePorts)
[~, ~, details] = assignPorts(trialManager.trialManager,trialRecords,responsePorts);

lastResponse = [];

if ~isempty(trialRecords) && length(trialRecords)>1
    lastRec=trialRecords(end-1);
    try
        pNum = find(strcmp('reinforcement',{lastRec.phaseRecords.phaseLabel}));
        rDetails = lastRec.phaseRecords(pNum-1).responseDetails;
        lastResponse = find(rDetails.tries{end});
    end
end

if length(lastResponse)>1
    lastResponse = lastResponse(1);
end
if trialManager.allowRepeats
    targetPorts = responsePorts;
else
    targetPorts = setdiff(responsePorts,lastResponse);
end
distractorPorts = [];

text = '';
end