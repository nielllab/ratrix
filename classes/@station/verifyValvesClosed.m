function currentValveStates=verifyValvesClosed(station)

currentValveStates=getValves(station);
if any(currentValveStates)
    
    currentValveStates =...
        setAndCheckValves(station,0*currentValveStates,0*currentValveStates,[],GetSecs,'verify valves closed found open valves');

  
    
    warning('verify valves closed found open valves')
end