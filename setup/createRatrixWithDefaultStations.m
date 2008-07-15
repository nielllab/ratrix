function r=createRatrixWithDefaultStations(machines,dataPath,servePump)

if servePump
    rewardMethod='serverPump';
else
    rewardMethod = 'localTimed';
end

serverDataPath = fullfile(dataPath, 'ServerData');
r=ratrix(serverDataPath,1);


multiDisplaySetup=true;
if multiDisplaySetup
    warning('you are running with local multidisplay -- timing will be bad!')
    Screen('Preference', 'SkipSyncTests',1)
end

for i=1:length(machines)
    id=machines{i}{1};

    width=1024;
    height=768;
    path=fullfile(dataPath, 'Stations',sprintf('station%s',id));
    if multiDisplaySetup
        screenNum=int8(max(Screen('Screens')));
    else
        screenNum=int8(0);
    end
    macAddr=machines{i}{2};
    macLoc=int8(machines{i}{3});

    if ismac
        stations{i}=station(...
            id,...          %id
            width,...       %width
            height,...      %height
            path,...        %path
            screenNum,...   %screenNum
            true,...       %soundOn
            'localTimed',...%rewardMethod
            macAddr,...     %MACaddress
            macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
            int8(3));             %numPorts
    elseif ispc

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
            'B888',...      %parallelPortAddress
            'parallelPort',...%responseMethod
            int8([6,7,8]),... %valveOpenCodes
            int8([4,2,3]),... %portCodes
            int8(1));       %framePulseCodes
    else
        error('unknown OS')
    end

    boxes(i)=box(int8(i),fullfile(dataPath,'Boxes' , sprintf('box%d',i)));
    r=addBox(r,boxes(i));
    r=addStationToBoxID(r,stations{i},getID(boxes(i)));
end