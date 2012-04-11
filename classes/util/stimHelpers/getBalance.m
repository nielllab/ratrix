function [lefts rights] = getBalance(responsePorts,targetPorts)

targets = ismember(responsePorts,targetPorts);

leftMid = floor(length(targets)/2);
rightMid = 1+ceil(length(targets)/2);

lefts = sum(targets(1:leftMid));
rights = sum(targets(rightMid:end));
end