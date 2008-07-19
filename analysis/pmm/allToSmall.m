function smallDataCombined=allToSmall(subjects,dateRange,suppressUpdatesFromStations,forceSmallDataUpdate)
%make a new function for assembling smalls appropriately
%load(fullfile(dataStorageIPAndPath, 'rat_102','current'))  %gets smallData

%combine sessionIDs in smallData

%setup
if ~exist('subjects','var')
    subjects={'rat_132'};
end


if isempty(dateRange); clear dateRange; end
if ~exist('dateRange','var')
    dateRange=[now-9999 now]
    selectSubsetLoadMethodParams=dateRange; 
    selectSubsetLoadMethod='all'
else
    selectSubsetLoadMethodParams=dateRange;
    selectSubsetLoadMethod='betweenDates';
end

if ~exist('suppressUpdatesFromStations','var')
    suppressUpdatesFromStations=0;
end

if ~exist('forceSmallDataUpdate','var')
    forceSmallDataUpdate=0;
end



%this needs to be called outside a function?
rootPath='C:\pmeier\';
warning('off','MATLAB:dispatcher:nameConflict')
%addpath(genpath(fullfile(rootPath, 'RSTools')));
%addpath(genpath(fullfile(rootPath, 'dataXfer')));
%addpath(genpath(fullfile(rootPath, 'Ratrix/Server')));
addpath(genpath(fullfile(rootPath, 'Ratrix','classes')));
addpath(genpath(fullfile(rootPath, 'Ratrix','analysis')));
warning('on','MATLAB:dispatcher:nameConflict')

dataStoragePath='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\';

verbose=0;
saveSmallDataSessions=1;
saveLargeDataSessions=1;
saveValveErrors=0; %if this is true need to support single trial record reporting of errors
saveCurrentSmallData=1; 
if diff(selectSubsetLoadMethodParams)>9998  %assumes you never keep rats 30 yrs
    saveAllSmallData=1; 
else
    saveAllSmallData=0; 
end
    




%these apply to data in pmeier ratix
distalSourcePath='c\pmeier\Ratrix\Boxes\box1\'; %this is expected to be on the c drive
subjectFoldersInsideDataFolder=1;

dataStorageIP='132.239.158.181';  %same as sourceIP='Reinagel-lab.ad.ucsd.edu';
dataStoragePath='\rlab\Rodent-Data\behavior\rats';
dataStorageIPAndPath=fullfile('\\',dataStorageIP,dataStoragePath);



%forcing subjects to be all lower case
subjects=lower(subjects);

%make subject folders if they don't exist
makeFoldersIfTheyDontExist(dataStorageIPAndPath,subjects,{'smallData','largeData','valveErrorData','saveLogHistory'});
%%
i=1;
j=1;
k=1;


%%
for i=1:length(subjects)
    saveLog = getSaveLog(subjects(i),dataStorageIPAndPath);
    stations=findStationsForSubject(subjects{i});
    if verbose
        disp(sprintf('checking stations: %s',num2str(stations)))
    end
    stationIPs=findIPforStation(stations);

    smallDataCombined=[];
    for j=1:size(stations,2)

        if ~suppressUpdatesFromStations
            %determine requested Session IDs From Stations
            fullSourcePath=sprintf('\\\\%s\\%s',char(stationIPs(j)),distalSourcePath);
            [sourcePaths]= selectSubsetOfDataFiles(fullSourcePath,subjects{i},selectSubsetLoadMethod,selectSubsetLoadMethodParams,subjectFoldersInsideDataFolder,verbose);
            sessionIDs=getSessionIDsFromFilePaths (sourcePaths,0);
        else
            %determine requested Session IDs From saveLog
            sessionIDs=saveLog.sessionID;
            %could try and load from server and then compare that it matches the saveLog. for now just using the saveLog
           
            %restrict to the requested range for speed
            dateRange=selectSubsetLoadMethodParams;
            sessionIDs=sessionIDs( sessionIDs>dateRange(1) & sessionIDs<dateRange(2) );  % won't include trials in the session that comes right after then last
        end

        for k=1:size(sessionIDs,2) %each requested sessions

            %find the indices from the saveLog that corresponds to this request
            saveLogInd= find(saveLog.sessionID==sessionIDs(k));

            %Check to see if the session has been extracted and saved, if not:
            haveIt=saveLog.largeExists(saveLogInd);
            if isempty(haveIt)
                haveIt=0;
            end

            %transfer large data to the server if you need to
            if ~haveIt
                loadMethod='singleSession';
                loadMethodParams=sourcePaths(k);
                suc=xferDataToServer(distalSourcePath,dataStoragePath,dataStorageIP,stationIPs(j),subjects{i},loadMethod,loadMethodParams,subjectFoldersInsideDataFolder, verbose);
                if suc
                    haveIt=1;
                    saveLog=addToSaveLog(saveLog,subjects(i),dataStorageIPAndPath,sessionIDs(k),{'subjectID','stationID','saveDate','largeExists', 'smallExists'},{subjects{i},stations(j),now,1,0},0);
                end
            end

            if haveIt
                %Update the saveLogInd to reflect potential addition of large data
                saveLogInd= find(saveLog.sessionID==sessionIDs(k));

                %figure out if you have small data on the server
                noSmallYet=~saveLog.smallExists(saveLogInd);
                if isempty(noSmallYet)
                    noSmallYet=0;
                end

                %convert small data if you need to
                if noSmallYet | forceSmallDataUpdate
                    loadMethod='singleSession';
                    loadMethodParams=sessionIDs(k);
                    smallData=convertLargeToSmallData(dataStoragePath,dataStorageIP,subjects{i},stations(j),loadMethod,loadMethodParams,saveValveErrors,1,verbose);
                    saveLog=addToSaveLog(saveLog,subjects(i),dataStorageIPAndPath,sessionIDs(k),{'conversionDate','smallExists'},{now,1},0);
                    save(fullfile(fullfile(dataStorageIPAndPath, char(subjects(i))),['lastSmall-', 'current']) , 'smallData');
                else
                    %load small data
                    if verbose
                        disp(sprintf('load existing smallData %s %s %converted on: %s', datestr(sessionIDs(k),30),datestr(sessionIDs(k)),datestr(saveLog.conversionDate(saveLogInd))))
                    end
                    pathAndName=fullfile(fullfile(dataStorageIPAndPath, char(subjects{i})),'smallData',['Data.' datestr(sessionIDs(k),30) '.mat']);
                    load(pathAndName, 'smallData');
                end

                if saveCurrentSmallData;
                    acceptableDaysOverLap=999;
                    smallDataCombined=combineTwoSmallDataFiles(smallDataCombined, smallData, acceptableDaysOverLap,verbose);
                end

                disp(sprintf('%s completed saving and converting session %s %s',char(subjects{i}), datestr(sessionIDs(k),30),datestr(sessionIDs(k))))
            end


        end %sessions on this station

        
        smallDataCombined=sortSmallData(smallDataCombined);
        smallData=smallDataCombined;
        
        if saveCurrentSmallData
            save(fullfile(fullfile(dataStorageIPAndPath, char(subjects(i))),['smallData']) , 'smallData')        
        end

        if saveAllSmallData
            save(fullfile(fullfile(dataStorageIPAndPath, char(subjects(i))),['allSmall']) , 'smallData')
        end
        
    end %stations
end %subjects






%function  listOfWhoWhere()   % not used; for reference

% %overnight
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_113'},loadMethod,loadMethodParams,3,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_102'},loadMethod,loadMethodParams,1,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_106'},loadMethod,loadMethodParams,2,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_114'},loadMethod,loadMethodParams,11,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_116'},loadMethod,loadMethodParams,9,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_117'},loadMethod,loadMethodParams,4,[],1)
%
% %morn
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_126'},loadMethod,loadMethodParams,3 ,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_127'},loadMethod,loadMethodParams,1 ,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_128'},loadMethod,loadMethodParams,2 ,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_129'},loadMethod,loadMethodParams,11,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_130'},loadMethod,loadMethodParams,9 ,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_131'},loadMethod,loadMethodParams,4,[],1)
%
% %aft
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_112'},loadMethod,loadMethodParams,3,[],1)
% %[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_***'},loadMethod,loadMethodParams,1,[],1)
% %[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_***'},loadMethod,loadMethodParams,2,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_115'},loadMethod,loadMethodParams,11,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_118'},loadMethod,loadMethodParams,9,[],1)
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_119'},loadMethod,loadMethodParams,4,[],1)
%
%
%
