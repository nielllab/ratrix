function r=createRatrixWithDefaultStations(machines,dataPath,rewardMethod,localMultiDisplaySetup)

serverDataPath = fullfile(dataPath, 'ServerData');
r=ratrix(serverDataPath,1);

screenNum=int8(0);
pportaddr=[];

if localMultiDisplaySetup
    if ismac
        error('you probably don''t really mean localMultiDisplaySetup on mac')
    end
    warning('you are running with local multidisplay -- timing will be bad!')
    Screen('Preference', 'SkipSyncTests',1) %hmm, i think startPTB will undo this
    
    screenNum=int8(max(Screen('Screens')));
    
    %screenNum=int8(1); %may need to uncomment for some dual-headed rig stations
    %rather than set special rig station pportaddr's here, set up a mapping to their mac address in makeDefaultStation
end
    
for i=1:length(machines)
    id=machines{i}{1};
    path=fullfile(dataPath, 'Stations',sprintf('station%s',id));
    mac=machines{i}{2};
    physicalLocation=int8(machines{i}{3});
    stations{i}=makeDefaultStation(id,path,mac,physicalLocation,screenNum,rewardMethod,pportaddr);

    boxes(i)=box(int8(i),fullfile(dataPath,'Boxes' , sprintf('box%d',i)));
    r=addBox(r,boxes(i));
    r=addStationToBoxID(r,stations{i},getID(boxes(i)));
end