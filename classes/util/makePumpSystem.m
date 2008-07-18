function sys=makePumpSystem()

if ~ispc
    error('pump systems only supported on pc')
end

pportAddr={'0378','B888'};

p = pump('COM1',...             %serPortAddr
    9.65,...                    %mmDiam
    500,...                     %mlPerHr
    false,...                   %doVolChks
    {pportAddr{2},int8(11)},... %motorRunningBit   %%%WEIRD -- B888's pin 15 is stuck hi???
    {pportAddr{1},int8(13)},... %infTooFarBit
    {pportAddr{1},int8(10)},... %wdrTooFarBit
    1.0,...                     %mlMaxSinglePump
    1.0,...                     %mlMaxPos
    0.1,...                     %mlOpportunisticRefill
    0.05);                      %mlAntiRock

eqDelay=0.3; %seems to be lowest that will work
valveDelay=0.02;

%         rezSensorBit             reservoirValveBit        toStationsValveBit       fillRezValveBit         valveDelay  equalizeDelay
zLow=zone({pportAddr{2},int8(13)}, {pportAddr{1},int8(2)},  {pportAddr{1},int8(4)},  {pportAddr{2},int8(4)}, valveDelay, eqDelay);
zMid=zone({pportAddr{2},int8(12)}, {pportAddr{1},int8(6)},  {pportAddr{1},int8(3)},  {pportAddr{2},int8(3)}, valveDelay, eqDelay);
zHi =zone({pportAddr{2},int8(10)}, {pportAddr{1},int8(5)},  {pportAddr{2},int8(5)},  {pportAddr{2},int8(2)}, valveDelay, eqDelay);

sys=pumpSystem(p,{zHi,zMid,zLow});