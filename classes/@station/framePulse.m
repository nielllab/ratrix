function framePulse(s)
if strcmp(s.responseMethod,'parallelPort')
    if ~isempty(s.framePulsePins)
        state=false*ones(1,length(s.framePulsePins.pinNums));
        state(s.framePulsePins.invs)=~state(s.framePulsePins.invs);
        lptWriteBits(s.framePulsePins.decAddr,s.framePulsePins.bitLocs,state);
        lptWriteBits(s.framePulsePins.decAddr,s.framePulsePins.bitLocs,~state);
    end
end;