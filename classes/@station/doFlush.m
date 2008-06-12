function doFlush(s,time)
    setValves(s,ones(1,s.numPorts));
    pause(time)
    setValves(s,zeros(1,s.numPorts));