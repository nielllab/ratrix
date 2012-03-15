function [targetPorts, distractorPorts, details, text] = assignPorts(trialManager,trialRecords,responsePorts)
[~, ~, details, text] = assignPorts(trialManager.nAFC,trialRecords,responsePorts);
targetPorts = [];
distractorPorts = [];

if details.correctionTrial
    details.target = sign(trialRecords(end-1).stimDetails.target);
else
    details.target = sign(randn);
end
end
