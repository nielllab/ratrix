function pump=doAntiRock(z,pump)

    setValve(z,z.reservoirValveBit,z.const.valveOn);
    [durs t pump]=doAction(pump,getMlAntiRock(pump),'infuse');
    [pump durs]=equalizePressure(z,pump);
    setValve(z,z.reservoirValveBit,z.const.valveOff);