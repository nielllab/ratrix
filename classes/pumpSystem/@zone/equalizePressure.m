function [pump dur]=equalizePressure(z,pump)
dur=ensureRezFilled(z);




setValve(z,z.reservoirValveBit,z.const.valveOn);

%WaitSecs(z.equalizeDelay);

equalizeVol=.01;

[durs t pump]=doAction(pump,equalizeVol,'infuse');
WaitSecs(z.equalizeDelay);

 setValve(z,z.reservoirValveBit,z.const.valveOff);
 
 
     if outsidePositionBounds(pump)
        [dursTemp t pump]=resetPumpPosition(z,pump);
        pump = equalizePressure(z,pump);
    end
