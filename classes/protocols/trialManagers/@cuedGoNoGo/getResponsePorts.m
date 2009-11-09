function out=getResponsePorts(trialManager,totalPorts)

out=setdiff(1:totalPorts,getRequestPorts(trialManager,totalPorts)); % old: response ports are all non-request ports
%nAFC tries to remove the center port. but cuedGoNoGo likes the center port, and keeps it enabled.

enableCenterPortResponseWhenNoRequestPort=true; %false in nAFC
if ~enableCenterPortResponseWhenNoRequestPort
    if isempty(getRequestPorts(trialManager,totalPorts)) % removes center port if no requestPort defined
        out(ceil(length(out)/2))=[];
    end
end