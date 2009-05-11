function f=delayManager(label)
% the base delayManager class
% OBJ=delayManager(label)
% currently, i cant think of any fields that this base class needs to have
% we only use this so that every method can inherit the abstract getDelayAndTimeout function

f.label=label;
f = class(f,'delayManager');

end % end function