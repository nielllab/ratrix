function st=initRatrixPorts(mac)

stationSpec.id                                = '99Z';
stationSpec.path                              = fullfile('Stations','DefaultStation');
stationSpec.MACaddress                        = mac;
stationSpec.physicalLocation                  = int8([1 1 1]);
stationSpec.screenNum                         = int8(0);
stationSpec.soundOn                           = true;
stationSpec.rewardMethod                      = 'localTimed';
stationSpec.portSpec.parallelPortAddress      = '0378';
stationSpec.portSpec.valvePins                = int8([4,3,2]);
stationSpec.portSpec.sensorPins               = int8([13,10,12]);
stationSpec.portSpec.framePulsePins           = int8(9);
stationSpec.portSpec.eyePuffPins              = int8(6);

if ismac
    stationSpec.portSpec = int8(3);
elseif ispc
    %do nothing
else
    error('unknown OS')
end

st=station(stationSpec);

currentValveStates=verifyValvesClosed(st)