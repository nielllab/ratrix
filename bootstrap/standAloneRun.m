function standAloneRun(ratrixPath,setupFile,subjectID,recordInOracle,backupToServer,justDoSetup)
%standAloneRun([ratrixPath],[setupFile],[subjectID],[recordInOracle],[backupToServer],[justDoSetup])
%
% ratrixPath (optional, string path to preexisting ratrix ServerData directory (contains 'db.mat' file))
% defaults to checking for db.mat in ...\<ratrix install directory>\..\ratrixData\ServerData\
% if none present, makes new ratrix located there, with a dummy subject
%
% setupFile (optional, name or handle to a setProtocol file on the path, typically in the setup directory)
% defaults to @setProtocolDEMO
% if subject already exists in ratrix and has a protocol, default is no action
%
% subjectID (optional, must be string id of subject -- will add to ratrix if not already present)
% default is some unspecified subject in ratrix (you can't depend on which
% one unless there is only one)
%
% recordInOracle (optional, must be logical, default false)
% if true, subject must be in oracle database and history file name loading from
% database will be exercised.
%
% backupOnServer (optional, must be logical or a path to the server, default false)
% if true, will also replicate to a hard-coded server path
% all trial record indexing (standAlonePath) is still handled locally
%
% recordNeuralData (optional, must be logical, default false)
% if true, will start datanet for nidaq recording
%
% justDoSetup (optional, logical, default false)
% if true, will just create subject, protocol, add to ratrix, and make .bat file

setupEnvironment;

if ~exist('justDoSetup','var') || isempty(justDoSetup)
    justDoSetup = false;
end

if ~exist('recordInOracle','var') || isempty(recordInOracle)
    recordInOracle = false;
elseif ~islogical(recordInOracle)
    error('recordInOracle must be logical')
end

if ~exist('backupToServer','var') || isempty(backupToServer)
    backupToServer = false;
elseif islogical(backupToServer);
    xtraServerBackupPath='\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\behavior\standAloneRecords';
elseif isDirRemote(backupToServer)
    xtraServerBackupPath=backupToServer;
    backupToServer=true;
else
    error('backupToServer must be logical or a valid path')
end

if ~exist('ratrixPath','var') || isempty(ratrixPath)
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
else
    dataPath=ratrixPath;
end

serverDataPath=fullfile(dataPath, 'ServerData');

if isdir(serverDataPath)
    rx=ratrix(serverDataPath,0);
else
    defaultLoc=serverDataPath;
    d=dir(fullfile(defaultLoc, 'db.mat'));
    
    if length(d)==1
        rx=ratrix(defaultLoc,0);
    else
        try
            [success mac]=getMACaddress();
            if ~success
                mac='000000000000';
            end
        catch
            mac='000000000000';
        end
        
        machines={{'1U',mac,[1 1 1]}};
        rx=createRatrixWithDefaultStations(machines,dataPath,'localTimed');
        permStorePath=fullfile(dataPath,'PermanentTrialRecordStore');
        mkdir(permStorePath);
        rx=setStandAlonePath(rx,permStorePath);
        fprintf('created new ratrix\n')
    end
end

needToAddSubject=false;
needToCreateSubject=false;
if ~exist('subjectID','var') || isempty(subjectID)
    ids=getSubjectIDs(rx);
    if length(ids)>0
        subjectID=ids{1};
    else
        subjectID='demo1';
        needToCreateSubject=true;
        needToAddSubject=true;
    end
else
    if ~strcmp(subjectID,lower(subjectID))
        error('must use all lower case for subject id''s')
    end
    subjectID=lower(subjectID); % edf can't remember why he thought this was a good idea, and can't think of any bad implications of removing it, but hasn't carefully verified + tested
    try
        isSubjectInRatrix=getSubjectFromID(rx,subjectID);
    catch ex
        if ~isempty(strfind(ex.message,'request for subject id not contained in ratrix'))
            if recordInOracle
                sub =createSubjectsFromDB({subjectID});
                if isempty(sub)
                    subjectID
                    error('subject not defined in oracle database')
                else
                    needToAddSubject=true;
                end
            else
                needToCreateSubject=true;
                needToAddSubject=true;
            end
        else
            rethrow(ex)
        end
    end
end
if needToCreateSubject
    warning('creating dummy subject')
    sub = subject(subjectID, 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
end
auth='edf';
if needToAddSubject
    rx=addSubject(rx,sub,auth);
end

if (~exist('setupFile','var') || isempty(setupFile)) && ~isa(getProtocolAndStep(getSubjectFromID(rx,subjectID)),'protocol')
    setupFile=@setProtocolDEMO;
end

if exist('setupFile','var') && ~isempty(setupFile)
    if ischar(setupFile) && 2==exist(setupFile)
        x=what(fileparts(which(setupFile)));
        if isempty(x) || isempty({x.m}) || ~any(ismember(lower({setupFile,[setupFile '.m']}),lower(x.m)))
            setupFile
            error('if setupFile supplied, it must be the name of a setProtocol file on the path (typically in the setup directory)')
        end        
        su=str2func(setupFile); %weird, str2func does not check for existence!
    elseif isa(setupFile,'function_handle')
        su=setupFile;
    else
        error('setupFile must be string to setProtocol file on the path or a function handle')
    end
    rx=su(rx,{subjectID});
end

if justDoSetup
    makeBatFile(subjectID,dataPath);
end

if ~justDoSetup
    try
        deleteOnSuccess = true;
        
        if backupToServer
            replicationPaths={getStandAlonePath(rx),xtraServerBackupPath};
        else
            replicationPaths={getStandAlonePath(rx)};
        end

        replicateTrialRecords(replicationPaths,deleteOnSuccess, recordInOracle,fileparts(getStandAlonePath(rx)));
        
        s=getSubjectFromID(rx,subjectID);
        
        try
            % any advantage to doing this in ...\ratrix\classes\@station\doTrials.m ?
            
            tic
            ssd = getSpreadsheetData; % takes 5 sec
            [~,idx] = ismember(subjectID,{ssd.subject});
            if ~isscalar(idx) || idx == 0
                subjectID
                {ssd.subject}
                error('no unique matching subject id')
            end
            [s, rx] = setReinforcementParam(s,'rewardULorMS',ssd(idx).reward ,'all',rx,'','spreadsheet');
            [s, rx] = setReinforcementParam(s,'msPenalty'   ,ssd(idx).timeout,'all',rx,'','spreadsheet');
            toc
        catch ex
            warning('updating reinforcement params failed, continuing with values stored in ratrix db')
            getReport(ex)            
            
            sca
            keyboard
        end
        
        [rx ids] = emptyAllBoxes(rx,'starting trials in standAloneRun',auth);
        boxIDs=getBoxIDs(rx);
        rx=putSubjectInBox(rx,subjectID,boxIDs(1),auth);
        b=getBoxIDForSubjectID(rx,getID(s));
        st=getStationsForBoxID(rx,b);

        %struct(st(1))
        rx=doTrials(st(1),rx,0,[],~recordInOracle); %0 means keep running trials til something stops you (quit, error, etc)
        [rx ids] = emptyAllBoxes(rx,'done running trials in standAloneRun',auth);
        
        replicateTrialRecords(replicationPaths,deleteOnSuccess, recordInOracle,fileparts(getStandAlonePath(rx)));
        compilePath=fullfile(fileparts(getStandAlonePath(rx)),'CompiledTrialRecords');
        mkdir(compilePath);
        %     compileTrialRecords([],[],[],{subjectID},getStandAlonePath(rx),compilePath);
        compileDetailedRecords([],{subjectID},[],getStandAlonePath(rx),compilePath);
        subjectAnalysis(compilePath);
        cleanup;
    catch ex
        disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
        cleanup;
        rethrow(ex)
    end
end
end

function cleanup
sca
if usejava('desktop')
    FlushEvents('mouseUp','mouseDown','keyDown','autoKey','update');
end
ListenChar(0)
ShowCursor(0)
end