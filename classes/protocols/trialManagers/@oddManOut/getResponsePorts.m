function out=getResponsePorts(trialManager,totalPorts)

% only differs from nAFC in that if requestPorts='none', then the center port becomes a responsePort (not a 'nothing' port)
out=setdiff(1:totalPorts,getRequestPorts(trialManager,totalPorts));

end % end function
