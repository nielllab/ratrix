function out=stationOKForTrialManager(t,s)
    if isa(s,'station')
        out = getNumPorts(s)>=3;
    else
        error('need a station object')
    end