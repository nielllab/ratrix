function out=stationOKForTrialManager(t,s)
    if isa(s,'station')
        out = getNumPorts(s)>=1;
    else
        error('need a station object')
    end