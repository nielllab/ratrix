function outStr = getNameFragment(trialManager)
% returns abbreviated class name
% should be overriden by trialManager-specific strings
% used to generate names for trainingSteps

outStr = class(trialManager);

end % end function