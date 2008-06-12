function [durs t pump]=resetPumpPosition(z,pump)
durs=[];
durs=[durs ensureRezFilled(z)];
setValve(z,z.reservoirValveBit,z.const.valveOn);
[dursTemp t pump]=doAction(pump,0,'reset position');
durs=[durs dursTemp];
setValve(z,z.reservoirValveBit,z.const.valveOff);
durs=[durs ensureRezFilled(z)];