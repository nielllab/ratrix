function st=makeDefaultStation(id,path,mac,physicalLocation,screenNum,rewardMethod,pportaddr)

% our standard parallel port pin assignments
% pin register	invert	dir	purpose
%---------------------------------------------------
% 1   control	inv     i/o	localPump infusedTooFar
% 2   data              i/o right reward valve (cooldrive valve 1)
% 3   data              i/o	center reward valve (cooldrive valve 2)
% 4   data              i/o	left reward valve (cooldrive valve 3)
% 5   data              i/o	localPump rezervoir valve (cooldrive valve 4)
% 6   data              i/o eyePuff valve (cooldrive valve 5)
% 7   data              i/o	localPump direction control
% 8   data              i/o
% 9   data              i/o framePulse
% 10  status            i   center lick sensor
% 11  status    inv     i	localPump motorRunning
% 12  status            i   right lick sensor
% 13  status            i   left lick sensor
% 14  control	inv     i/o	localPump withdrawnTooFar
% 15  status            i
% 16  control           i/o
% 17  control	inv     i/o

if ~exist('pportaddr','var') || isempty(pportaddr)
    pportaddr= '0378';
    [a b]=getMACaddress;
    if a
        switch b
            case '0014225E4685'
                pportaddr='FFF8'; %the pcmcia add on card
            case '00095B8E6171' %this is what psychtoolbox's macid returns, but it happens to be the pci netgear 302T we added, not the main nvidia builtin connection (001372708179)
                pportaddr='B888'; %the pci add on card
            otherwise
                %pass
        end
    end
end

if ~exist('rewardMethod','var') || isempty(rewardMethod)
    rewardMethod= 'localTimed';
end

if ~exist('screenNum','var') || isempty(screenNum)
    screenNum=int8(0);
end

stationSpec.id                                = id;
stationSpec.path                              = path;
stationSpec.MACaddress                        = mac;
stationSpec.physicalLocation                  = physicalLocation;
stationSpec.screenNum                         = screenNum;
stationSpec.soundOn                           = true;
stationSpec.rewardMethod                      = rewardMethod;
stationSpec.portSpec.parallelPortAddress      = pportaddr;
stationSpec.portSpec.valveSpec                = int8([4,3,2]);
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

if ismember(stationSpec.id,{'3A','3B','3C','3D','3E','3F'}) || strcmp(rewardMethod,'localPump')

    infTooFarPin=int8(1);
    wdrTooFarPin=int8(14);
    motorRunningPin= int8(11);
    %dirPin = int8(7); %not used
    rezValvePin = int8(5);  %valve 4
    eqDelay=0.3; %seems to be lowest that will work
    valveDelay=0.02;

    pmp =localPump(...
        pump('COM1',...             %serPortAddr
        9.65,...                    %mmDiam
        500,...                     %mlPerHr
        false,...                   %doVolChks
        {stationSpec.portSpec.parallelPortAddress,motorRunningPin},... %motorRunningBit
        {stationSpec.portSpec.parallelPortAddress,infTooFarPin},... %infTooFarBit
        {stationSpec.portSpec.parallelPortAddress,wdrTooFarPin},... %wdrTooFarBit
        1.0,...                     %mlMaxSinglePump
        1.0,...                     %mlMaxPos
        0.1,...                     %mlOpportunisticRefill
        0.05),...                   %mlAntiRock
        rezValvePin,eqDelay,valveDelay);

    stationSpec.rewardMethod='localPump';
    stationSpec.portSpec.valveSpec.valvePins=stationSpec.portSpec.valveSpec;
    stationSpec.portSpec.valveSpec.pumpObject=pmp;
end

st=station(stationSpec);