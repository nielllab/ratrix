function outStr = getNameFragment(cr)
% returns abbreviated class name
% should be overriden by criterion-specific strings
% used to generate names for trainingSteps

outStr = class(cr);

end % end function