function st=makeDefaultStation(id,path,mac,physicalLocation,screenNum,rewardMethod,pportaddr,soundOn)

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
% 8   data              i/o indexPulse
% 9   data              i/o framePulse
% 10  status            i   center lick sensor
% 11  status    inv     i	localPump motorRunning
% 12  status            i   right lick sensor
% 13  status            i   left lick sensor
% 14  control	inv     i/o	localPump withdrawnTooFar
% 15  status            i
% 16  control           i/o phasePulse
% 17  control	inv     i/o stimPulse

% sprintf('port address %d',pportaddr)
% keyboard
[a b]=getMACaddress;

if ~exist('pportaddr','var') || isempty(pportaddr)
    pportaddr= '0378';
    %[a b]=getMACaddress;
    if a
        switch b
            %some rig stations have special pport setups
            case '0014225E4685' %dell machine w/nvidia card + sound card + nidaq card
                pportaddr='FFF8'; %the pcmcia add on card
            case '001372708179' %dell machine w/ati card
                pportaddr='B888'; %the pci add on card
            case 'BCAEC555FC4B' %2p machine
                pportaddr='C800'; %pci add on
            case '60A44CB25405'
                pportaddr = 'E030';  %%% pilot computer
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
    
    if length(Screen('Screens'))>1
        %[a b]=getMACaddress;
        if a
            switch b
                case {'001D7D9ACF80','00095B8E6171'} %phys rig (00095B8E6171 is the netgear GA302T added for talking to eyelink (and returned by ptb's macid/getmac), 001D7D9ACF80 is the integrated)
                    %screenNum=int8(max(Screen('Screens')));
                    screenNum=int8(0); %normally used for single header phys on CRT
                    %screenNum=int8(2); %used for other monitor on OLED tests, or dual header tests
                    %screenNum=int8(1); %used for local screen tests
                case '0014225E4685' %left hand rig computer
                    screenNum=int8(1);
                otherwise
                    %pass
            end
        end
    end
end

if ~exist('soundOn','var') || isempty(soundOn)
    soundOn=true;
    
    %[a b]=getMACaddress;
    if a
        switch b
            case '001D7DA5B8D5'
                soundOn=false; %erik's dev machine's sound is busted
            otherwise
                %pass
        end
    end
end

dn=[];
et=[];

if a
    switch b
        %some rig stations have eyeTrackers and datanets available
        case {'001D7D9ACF80','00095B8E6171'}  %phys stim machine stolen from 2F
            if false  %now datanet is started in chunk mode
                ai_parameters.numChans=3;
                ai_parameters.sampRate=40000;
                ai_parameters.inputRanges=repmat([-1 6],ai_parameters.numChans,1);
                dn=datanet('stim','localhost','132.239.158.179','\\132.239.158.179\datanet_storage',ai_parameters)
            end
            if false% true (temp off for calibration)
                %calc stim should set the method to 'cr-p', calls set
                %resolution should update et
                alpha=12; %deg above...really?
                beta=0;   %deg to side... really?
                settingMethod='none';  % will run with these defaults without consulting user, else 'guiPrompt'
                maxWidth=1;
                maxHeight=1;
                preAllocatedStimSamples=200000; % 300000 300 sec --> 5 min (if no drops)
                et=geometricTracker('cr-p', 2, 3, alpha, beta, int16([1280,1024]), [42,28], int16([maxWidth,maxHeight]), [400,290], 300, -55, 0, 45, 0,settingMethod,preAllocatedStimSamples);
            end
    end
end

stationSpec.id                                = id;
stationSpec.path                              = path;
stationSpec.MACaddress                        = mac;
stationSpec.physicalLocation                  = physicalLocation;
stationSpec.screenNum                         = screenNum;
stationSpec.soundOn                           = soundOn;
stationSpec.rewardMethod                      = rewardMethod;
stationSpec.portSpec.parallelPortAddress      = pportaddr;
stationSpec.portSpec.valveSpec                = int8([4,3,2]);
stationSpec.portSpec.sensorPins               = int8([13,10,12]);
stationSpec.portSpec.framePins                = int8(9);
stationSpec.portSpec.eyePuffPins              = int8(6);
stationSpec.datanet                           = dn;
stationSpec.eyeTracker                        = et;
stationSpec.portSpec.phasePins                = int8(16);
stationSpec.portSpec.stimPins                 = int8(17);
stationSpec.portSpec.indexPins                = int8(8);
stationSpec.portSpec.laserPins                = uint8([]);

if a
    switch b
        case {'F46D04EFE0FF','5404A6EF6720','14DAE971D50E'}
            stationSpec.portSpec.valveSpec=int8(3); %mini-3-way-lickometer and ball only use center valve
        case {'08002700D40D','C860005FBB51'} % sue's vaio, aldis' station
            stationSpec.portSpec.laserPins = uint8(9);
            stationSpec.portSpec.framePins = [];
    end
end

if ismac || IsLinux
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