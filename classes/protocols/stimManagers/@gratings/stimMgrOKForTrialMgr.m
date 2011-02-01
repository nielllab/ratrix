function out=stimMgrOKForTrialMgr(sm,tm)
if isa(tm,'trialManager')
    switch class(tm)
        case 'freeDrinks'
            out=1;
        case 'nAFC'
            if sm.doCombos
                error('can''t do combos with nAFC')
            end
            
            %COULD USE THIS CHECK IF gratings nAFC does multiple orients
            %             if mod(length(sm.orientations),2)~=0
            %                 error('must have an even number of orientations for 2AFC')
            %                 %this could be divisiblble by n one day, if nAFC has n>2
            %             end
            out=1;
        case 'autopilot'
            out=1;
        case 'goNoGo'
            out=1;
        otherwise
            out=0;
    end
else
    error('need a trialManager object')
end