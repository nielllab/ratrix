function out=stationOKForTrialManager(t,s)
    if isa(s,'station')
        out = getNumPorts(s)>=2;
    else
        error('need a station object')
    end