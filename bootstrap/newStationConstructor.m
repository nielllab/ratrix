setupEnvironment;

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

stationNum=1;
path=fullfile(dataPath, 'Stations',sprintf('station%d',stationNum));

s=station(...
    int8(stationNum),...	%id
    1280,...                %width
    1024,...                %height
    path,...                %path
    int8(0),...             %screenNum
    true,...                %soundOn
    'localTimed',...        %rewardMethod
    '000000000000',...      %MACaddress
    int8([1 1 1]),...       %physicalLocation([rackID shelf position] -- upperleft is 1,1)
    '0378',...              %parallelPortAddress
    'parallelPort',...      %responseMethod
    int8([4,3,2]),...       %valvePins (valveOpenCodes used to be [6,7,8])
    int8([13,10,12]),...    %sensorPins (portCodes used to be [4,2,3])
    int8(9),...             %framePulsePins (used to be 1)
    int8(6));               %eyepuffPins (valve 5)

%if you have a local pump:
infTooFarPin=int8(1);
wdrTooFarPin=int8(14);
motorRunningPin= int8(11);
%dirPin = int8(7); %not used
rezValvePin = int8(5);  %valve 4


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


