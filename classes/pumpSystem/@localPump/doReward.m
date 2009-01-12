function s=doReward(s,mlVol,valves,dontReset)

if ~s.inited
    error('localPump not inited')
end

if ~isempty(find(valves))

    if isa(s.station,'station')
        verifyValvesClosed(s.station);
    else
        error('not inited')
    end

    setRezValve(s,s.const.valveOff);

    if outsidePositionBounds(s.pump)
        s=resetPosition(s);
    end

    numPumps=ceil(mlVol/getMlMaxSinglePump(s.pump));
    volPerPump=mlVol/numPumps;

    if volPerPump>0
        setValves(s.station, valves);
        WaitSecs(s.valveDelay);
        for i=1:numPumps
            try
                [durs t s.pump]=doAction(s.pump,volPerPump,'infuse');
            catch
                ex=lasterror;
                if ~isempty(findstr(ex.message,'request will put pump outside max/min position -- reset pump position first'))
                    setValves(s.station, 0*valves);
                    WaitSecs(s.valveDelay);
                    s=resetPosition(s);
                    setValves(s.station, valves);
                    WaitSecs(s.valveDelay);
                    [durs t s.pump]=doAction(s.pump,volPerPump,'infuse');
                else
                    rethrow(ex)
                end
            end
        end
        setValves(s.station, 0*valves);
        WaitSecs(s.valveDelay);

        if ~dontReset
            s=resetPosition(s);
        end
    end
else
    error('valves must have a nonzero entry')
end