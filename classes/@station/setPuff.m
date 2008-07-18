function setPuff(s,state )
if ~isempty(s.eyePuffPins)
    if islogical(state)
        state(s.eyePuffPins.invs)=~state(s.eyePuffPins.invs);
        lptWriteBit(s.eyePuffPins.decAddr,s.eyepuffPins.bitLocs,state);
    else
        error('state must be logical');
    end
else
    warning('no airpuff on this station')
end