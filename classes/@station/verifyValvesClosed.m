function currentValveStates=verifyValvesClosed(station)

%currentValveStates=logical(readPorts(station)); %this was reading licks!?!?
currentValveStates=getValves(station);
if any(currentValveStates)
    
    currentValveStates =...
        setAndCheckValves(station,0*currentValveStates,0*currentValveStates,[],GetSecs,'verify valves closed found open valves');

    setPuff(false);
    
    warning('verify valves closed found open valves')
end