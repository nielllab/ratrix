function pump=emptyRez(z,pump)

while ~infTooFar(pump)
    setValve(z,z.toStationsValveBit,z.const.valveOn);
    [durs t pump]=doAction(pump,getMlOpportunisticRefill(pump),'infuse');
end
setValve(z,z.toStationsValveBit,z.const.valveOff);

while ~wdrTooFar(pump)
    setValve(z,z.reservoirValveBit,z.const.valveOn);
    [durs t pump]=doAction(pump,getMlOpportunisticRefill(pump),'withdrawl');
end
[durs t pump]=doAction(pump,0,'reset position');
setValve(z,z.reservoirValveBit,z.const.valveOff);