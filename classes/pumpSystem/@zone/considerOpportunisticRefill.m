function [pump didOpportunisiticRefill]=considerOpportunisticRefill(z,pump)
if getCurrentPosition(pump)>=getMlOpportunisticRefill(pump)

    setValve(z,z.reservoirValveBit,z.const.valveOn);
    [durs t pump]=doAction(pump,getMlOpportunisticRefill(pump),'withdrawl');
    setValve(z,z.reservoirValveBit,z.const.valveOff);

    didOpportunisiticRefill=1;
else
    didOpportunisiticRefill=0;
end