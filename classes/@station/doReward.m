function s=doReward(s,msDurOrML,valves)
if ~isempty(find(valves))
    switch s.rewardMethod
        case 'localTimed'
            error('not implemented')
        case 'localPump'
            if ~ s.localPumpInited
                s.localPump=initLocalPump(s.localPump,s,s.parallelPortAddress);
                s.localPumpInited=true;
            end
            s.localPump=doReward(s.localPump,msDurOrML,valves);
        case 'serverPump'
            error('not implemented')
        otherwise
            s.rewardMethod
            error('unknown reward method')
    end
else
    error('valves must have a nonzero entry')
end