function r=setupRig1(rackID, stationID)
%r=setupRig1(101, 'A')

if ~exist('rackID','var')
    %there is no rack up here, using 101
    rackID=101;
end

if ~exist('stationID', 'var')
    stationID=[num2str(rackID) 'A']; % B for right computer
else
    stationID=[num2str(rackID) stationID]; 
end

%new ratrix
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
serverDataPath = fullfile(dataPath, 'ServerData');
r=ratrix(serverDataPath,1);

%station fields
width=1024;
height=768;

path=fullfile(dataPath, 'Stations',sprintf('station%s',stationID));
screenNum=int8(max(Screen('Screens')));
rewardMethod='localTimed';
switch stationID
    case '101A'
        macAddr='0014225E4685' ;%rig1 leftside dataack
        macLoc =int8([rackID,1,1]);
        parallelPortAddress='FFF8'; ;%is rig1 left computer(Quatech PCMCIA)
    case '101B'
        macAddr='001372708179' ;%rig1 rightside eyetrack
        macLoc =int8([rackID,1,2]);
        parallelPortAddress='B888'; ;%is rig1 right computer
    otherwise
        error ('station does not exist on rig1');
end

statn=station(...
    stationID,...   %id
    width,...       %width
    height,...      %height
    path,...        %path
    screenNum,...   %screenNum
    true,...        %soundOn
    rewardMethod,...%rewardMethod
    macAddr,...     %MACaddress
    macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
    parallelPortAddress,...      %parallelPortAddress
    'parallelPort',...%responseMethod
    int8([6,7,8]),... %valveOpenCodes
    int8([4,2,3]),... %portCodes
    int8(1));       %framePulseCodes

%add subject
switch stationID
    case '101A'
        subjects={'test_rig1a','127','124'}; %needs a new test: testRig1A
    case '101B'
        subjects={'test_rig1b','162','131','164'};
    otherwise
        error ('station does not exist on rig1');
end

for i=1:length(subjects)
    subj = subject(char(subjects(i)), 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories');
    r=addSubject(r,subj,'pmm');
end

mkdir(fullfile(dataPath, 'localPermanentStore'));

% r=setPermanentStorePath(r,getSubDirForRack(rackID));
r=setPermanentStorePath(r,(fullfile(dataPath, 'localPermanentStore'))); %permanent store is local so we can trustOsRecordFiles

%% set protocol
r=setHeadFixProtocol(r,subjects);

%% add box and station
i=1;
b=box(int8(i),fullfile(dataPath,'Boxes' , sprintf('box%d',i)));
r=addBox(r,b);
r=addStationToBoxID(r,statn,getID(b));

