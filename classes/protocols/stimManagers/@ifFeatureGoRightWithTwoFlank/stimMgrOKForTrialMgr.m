function out=stimMgrOKForTrialMgr(sm,tm)
if isa(tm,'trialManager')
    switch class(tm)
        case 'freeDrinks'
            out=1;
        case 'nAFC' %old standard
            out=1;
        case 'promptedNAFC' %used for eyeDevelopment
            out=1;
        case 'phasednAFC' %fans addition, new format, but same idea as NAFC
            out=1;
        case 'autopilot'
            out=1;
        otherwise
            out=0;
    end
else
    error('need a trialManager object')
end