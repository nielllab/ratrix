function r=createRatrixWithDefaultStations(machines,dataPath,servePump,localMultiDisplaySetup)

if servePump
    rewardMethod='serverPump';
else
    rewardMethod='localTimed';
end

serverDataPath = fullfile(dataPath, 'ServerData');
r=ratrix(serverDataPath,1);

if localMultiDisplaySetup
    warning('you are running with local multidisplay -- timing will be bad!')
    Screen('Preference', 'SkipSyncTests',1)
    screenNum=int8(max(Screen('Screens')));
else
    screenNum=int8(0);
end

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

stationSpec.screenNum                         = screenNum;
stationSpec.soundOn                           = true;
stationSpec.rewardMethod                      = rewardMethod;
stationSpec.portSpec.parallelPortAddress      = '0378';
stationSpec.portSpec.valveSpec                = int8([4,3,2]);
stationSpec.portSpec.sensorPins               = int8([13,10,12]);
stationSpec.portSpec.framePulsePins           = int8(9);
stationSpec.portSpec.eyePuffPins              = int8(6);

%if you have a local pump:
infTooFarPin=int8(1);
wdrTooFarPin=int8(14);
motorRunningPin= int8(11);
%dirPin = int8(7); %not used
rezValvePin = int8(5);  %valve 4

for i=1:length(machines)
    stationSpec.id=machines{i}{1};
    stationSpec.path=fullfile(dataPath, 'Stations',sprintf('station%s',stationSpec.id));
    stationSpec.MACaddress=machines{i}{2};
    stationSpec.physicalLocation=int8(machines{i}{3});

    if ismac
        stationSpec.portSpec = int8(3);
    elseif ispc
        %do nothing
    else
        error('unknown OS')
    end
    
    stations{i}=station(stationSpec);

    boxes(i)=box(int8(i),fullfile(dataPath,'Boxes' , sprintf('box%d',i)));
    r=addBox(r,boxes(i));
    r=addStationToBoxID(r,stations{i},getID(boxes(i)));
end