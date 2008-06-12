function out=getStimPatch(t, patch)

switch patch
    case 'target'
        out=t.cache.goRightStim;
        disp('only goRightTarget returned');
    case 'flanker'
        out=t.cache.flankerStim;
    otherwise
        error('that patch not available');
end

