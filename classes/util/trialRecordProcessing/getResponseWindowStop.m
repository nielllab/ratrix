function [out]=getResponseWindowStop(trialManager)

if isfield(trialManager.trialManager,'responseWindowMs')
    out=trialManager.trialManager.responseWindowMs(2)/1000;
else
    out=nan;
end

end