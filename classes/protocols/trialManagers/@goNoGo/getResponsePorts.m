function out=getResponsePorts(trialManager,totalPorts)

out=setdiff(1:totalPorts,getRequestPorts(trialManager,totalPorts));