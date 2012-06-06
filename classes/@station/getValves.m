function valves =getValves(s)
if strcmp(s.responseMethod,'parallelPort')
    
    [~,m]=getMACaddress;
    if ~ismember(m,{'08002700F8DC'})
        
        status=fastDec2Bin(lptread(s.valvePins.decAddr));
        
        valves=status(s.valvePins.bitLocs)=='1'; %need to set parity in station, assumes normally closed valves
        valves(s.valvePins.invs)=~valves(s.valvePins.invs); %dangerous line if all s.valvePins.invs are 0 -- we get empties
    else
        valves = false(size(s.valvePins.bitLocs));
    end
    
    % temporary hack -- right now we rely on the fact that no one
    % (including the station) accesses the valves except through
    % setValves and getValves, but we can't guarantee this.
    if length(valves)~=s.numPorts
        if isscalar(valves)
            valves=valves(ones(1,s.numPorts)); %will confuse anyone expecting a valve to be in the state they put it in
        else
            error('bad valve vector')
        end
    end
else
    if ~ismac
        warning('can''t read ports without parallel port')
    end
    valves=false(1,s.numPorts);%*s.valvePins.bitLocs;
end