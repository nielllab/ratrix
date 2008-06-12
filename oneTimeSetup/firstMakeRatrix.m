function r = firstMakeRatrix()

servePump=false;
standalone=false;
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

if servePump
    rewardMethod='serverPump';
else
    rewardMethod = 'localTimed';
end

% machines={...
%     {7,'0018F35DFADB',[2 1 1]},... %'0018F35E0281' philip took
%     {8,'0018F35DEE62',[2 1 2]},...
%     {9,'0018F34EAE45',[2 1 3]},...
%     {10,'001A4D9326C2',[2 2 1]},...
%     {11,'001A4D523D5C',[2 2 2]},...
%     {12,'001D7D9ACF80',[2 2 3]}}; %'001A4D528033' broke
% % '001A4D4F8C2F' new server

machines={};
stations=getRatrixStationInfo([]);
for i=1:length(stations)
    if isMACaddress(stations{i}{1})
        machines{end+1}={stations{i}{1,[2 1]} [stations{i}{1,[4 5 6]}]};
    end
end
stations={};


r=ratrix(fullfile(dataPath, 'ServerData'),1);

for i=1:length(machines)
    stationNum=machines{i}{1};

    id=int8(stationNum);
    width=1024;
    height=768;
    path=fullfile(dataPath, 'Stations',sprintf('station%d',stationNum));
    screenNum=int8(0);
    macAddr=machines{i}{2};
    macLoc=int8(machines{i}{3});

    stations{i}=station(...
        id,...          %id
        width,...       %width
        height,...      %height
        path,...        %path
        screenNum,...   %screenNum
        true,...        %soundOn
        rewardMethod,...%rewardMethod
        macAddr,...     %MACaddress
        macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
        '0378',...      %parallelPortAddress
        'parallelPort',...%responseMethod
        int8([6,7,8]),... %valveOpenCodes
        int8([4,2,3]),... %portCodes
        int8(1));       %framePulseCodes
    
    boxes(i)=box(int8(stationNum),fullfile(dataPath,'Boxes' , sprintf('box%d',stationNum)));
    r=addBox(r,boxes(i));
    r=addStationToBoxID(r,stations{i},getID(boxes(i)));
end