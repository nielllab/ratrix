function out=stimMgrOKForTrialMgr(sm,tm)
if isa(tm,'trialManager')
    switch class(tm)
        case 'freeDrinks'
            out=1;
        case 'nAFC' %was old standard, now the phased one mimicks it
            out=1;
        case 'promptedNAFC' %used for eyeDevelopment
            out=0;  % we don't use this anymore, but should switch to nAFC with delayManager 
        case 'phasednAFC' %fans addition, new format, but same idea as NAFC
            out=0;  % everything uses the phased version now... its just called normal nAFC
        case 'autopilot'
            out=1; % useful for physiology
        case 'goNoGo'
            out=1;
        otherwise % useful for headfixed
            out=0;
    end
else
    error('need a trialManager object')
end