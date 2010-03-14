function [out]=getResponseWindowStart(trialManager)

if isfield(trialManager.trialManager,'responseWindowMs')
    out=trialManager.trialManager.responseWindowMs(1)/1000;
else
    out=nan;
end

end