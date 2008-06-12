function setPuff(s,state )
if ~isempty(s.eyepuffPin)
    if islogical(state)
        lptWriteBit(s.parallelPortAddress,s.eyepuffPin,state);
    else
        error('state must be logical');
    end
else
    warning('no airpuff on this station')
end