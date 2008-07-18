function setPuff(s,state )
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