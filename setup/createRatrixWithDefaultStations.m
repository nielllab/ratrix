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

for i=1:length(machines)
    id=machines{i}{1};
    path=fullfile(dataPath, 'Stations',sprintf('station%s',id));
    mac=machines{i}{2};
    physicalLocation=int8(machines{i}{3});
    stations{i}=makeDefaultStation(id,path,mac,physicalLocation,screenNum,rewardMethod);

    boxes(i)=box(int8(i),fullfile(dataPath,'Boxes' , sprintf('box%d',i)));
    r=addBox(r,boxes(i));
    r=addStationToBoxID(r,stations{i},getID(boxes(i)));
end