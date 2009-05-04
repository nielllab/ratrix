function f=delayFunction(label)
% the base delayFunction class
% OBJ=delayFunction(label)
% currently, i cant think of any fields that this base class needs to have
% we only use this so that every method can inherit the abstract getDelayAndTimeout function

f.label=label;
f = class(f,'delayFunction');

end % end function