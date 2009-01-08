function outStr = getNameFragment(stimManager)
% returns abbreviated class name
% should be overriden by stimManager-specific strings
% used to generate names for trainingSteps

outStr = class(stimManager);

end % end function