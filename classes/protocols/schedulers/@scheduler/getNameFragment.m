function outStr = getNameFragment(sch)
% returns abbreviated class name
% should be overriden by scheduler-specific strings
% used to generate names for trainingSteps

outStr = class(sch);

end % end function