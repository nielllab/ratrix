function setPuff(s,state )
if strcmp(s.responseMethod,'parallelPort')
    if ~isempty(s.eyePuffPins)
        if islogical(state)
            state(s.eyePuffPins.invs)=~state(s.eyePuffPins.invs);
            lptWriteBits(s.eyePuffPins.decAddr,s.eyePuffPins.bitLocs,state);
        else
            error('state must be logical');
        end
    else
        warning('no airpuff on this station')
    end
else
    if ~ismac
        warning('can''t set puff without parallel port')
    end
end