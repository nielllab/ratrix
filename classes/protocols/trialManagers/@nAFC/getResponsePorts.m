function out=getResponsePorts(trialManager,totalPorts)

out=setdiff(1:totalPorts,getRequestPorts(trialManager,totalPorts)); % old: response ports are all non-request ports
% 5/4/09 - what if we want nAFC L/R target/distractor, but no request port (using delayManager instead)
% responsePorts then still needs to only be L/R, not all ports (since request ports is empty)

if isempty(getRequestPorts(trialManager,totalPorts)) % removes center port if no requestPort defined
    out(ceil(length(out)/2))=[];
end