function [durs pump] =doInfuse(z,pump,mlVol,needsEqualization)
durs=[];

if mlVol>getMlMaxSinglePump(pump)
    numPumps=ceil(mlVol/getMlMaxSinglePump(pump));
    volPerPump=mlVol/numPumps;

    for i=1:numPumps
        [dursTemp pump] = doInfuse(z,pump,volPerPump,needsEqualization);
        durs=[durs dursTemp];
        needsEqualization=0;
    end
else
    
    if outsidePositionBounds(pump)
        [dursTemp t pump]=resetPumpPosition(z,pump);
        durs=[durs dursTemp];
        needsEqualization=0;
    end
    
    if needsEqualization %|| true
        [pump dursTemp]=equalizePressure(z,pump);
        durs=[durs dursTemp];
    end
    %[durs pump] = [durs doAction(z,'infuse',z.toStationsValveBit,pump,mlVol)];
    %[durs pump] = [durs doAction(z,'withdrawl',z.reservoirValveBit,pump,mlVol)];


    setValve(z,z.toStationsValveBit,z.const.valveOn);
    [durs t pump]=doAction(pump,mlVol,'infuse');
    setValve(z,z.toStationsValveBit,z.const.valveOff);
end