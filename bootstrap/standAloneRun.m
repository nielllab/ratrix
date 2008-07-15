function standAloneRun(ratrixPath,setupFile,subjectID,recordInOracle)
%standAloneRun([ratrixPath],[setupFile],[subjectID],[recordInOracle])
%
% ratrixPath (optional, string path to preexisting ratrix 'db.mat' file)
% defaults to checking for db.mat in ...\<ratrix install directory>\..\ratrixData\ServerData\
% if none present, makes new ratrix located there, with a dummy subject
%
% setupFile (optional, name of a setProtocol file on the path, typically in the setup directory)
% defaults to 'setProtocolDEMO'
% if subject already exists in ratrix and has a protocol, default is no action
%
% subjectID (optional, must be string id of subject -- will add to ratrix if not already present)
% default is some unspecified subject in ratrix (you can't depend on which
% one unless there is only one)
%
% recordInOracle (optional, must be logical, default false)
% if true, subject must be in oracle database and history file name loading from
% database will be exercised.

setupEnvironment;

if ~exist('recordInOracle','var') || isempty(recordInOracle)
    recordInOracle = false;
elseif ~islogical(recordInOracle)
    error('recordInOracle must be logical')
end

if exist('ratrixPath','var') && ~isempty(ratrixPath)
    if isdir(ratrixPath)
        rx=ratrix(ratrixPath,0);
    else
        ratrixPath
        error('if ratrixPath supplied, it must be a path to a preexisting ratrix ''db.mat'' file')
    end
else
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
    defaultLoc=fullfile(dataPath, 'ServerData');

    d=dir(fullfile(defaultLoc, 'db.mat'));

    if length(d)==1
        rx=ratrix(defaultLoc,0);
        'loaded ratrix from default location'
    else
        if IsWin
            macidcom = [PsychtoolboxRoot 'PsychContributed\macid '];
            [rc mac] = system(macidcom);
            mac=strtrim(mac);
        end
        if ~IsWin || rc~=0 || ~isMACaddress(mac)
            mac='000000000000';
        end

        machines={{'1U',mac,[1 1 1]}};
        rx=createRatrixWithDefaultStations(machines,dataPath,false,false);
        permStorePath=fullfile(dataPath,'PermanentTrialRecordStore');
        mkdir(permStorePath);
        rx=setPermanentStorePath(rx,permStorePath);
        'created new ratrix'
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
    subjectID=lower(subjectID);
    try
        isSubjectInRatrix=getSubjectFromID(rx,subjectID);
    catch e
        if strcmp(e.message,'request for subject id not contained in ratrix')
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
            rethrow(e)
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
    setupFile='setProtocolDEMO';
end

if exist('setupFile','var') && ~isempty(setupFile)
    x=what(fileparts(which(setupFile)));
    if isempty(x) || isempty({x.m}) || ~any(ismember({setupFile,[setupFile '.m']},x.m))
        setupFile
        error('if setupFile supplied, it must be the name of a setProtocol file on the path (typically in the setup directory')
    end

    su=str2func(setupFile); %weird, str2func does not check for existence!
    rx=su(rx,{subjectID});
    %was:  r=feval(setupFile, r,{getID(sub)});
    %but edf notes: eval is bad style
    %http://www.mathworks.com/support/tech-notes/1100/1103.html
    %http://blogs.mathworks.com/loren/2005/12/28/evading-eval/
end

try
    deleteOnSuccess = true;

    replicateTrialRecords({getPermanentStorePath(rx)},deleteOnSuccess, recordInOracle);

    s=getSubjectFromID(rx,subjectID);

    [rx ids] = emptyAllBoxes(rx,'starting trials in standAloneRun',auth);
    boxIDs=getBoxIDs(rx);
    rx=putSubjectInBox(rx,subjectID,boxIDs(1),auth);    
    b=getBoxIDForSubjectID(rx,getID(s));
    st=getStationsForBoxID(rx,b);
    rx=doTrials(st(1),rx,0,[],~recordInOracle); %0 means keep running trials til something stops you (quit, error, etc)
    [rx ids] = emptyAllBoxes(rx,'done running trials in standAloneRun',auth);

    replicateTrialRecords({getPermanentStorePath(rx)},deleteOnSuccess, recordInOracle);

    compilePath=fullfile(fileparts(getPermanentStorePath(rx)),'CompiledTrialRecords');
    mkdir(compilePath);
    compileTrialRecords([],[],[],[],getPermanentStorePath(rx),compilePath);
    subjectAnalysis(compilePath);
    cleanup;
catch
    ple
    cleanup;
    rethrow(lasterror)
end

function cleanup
sca
ListenChar(0)
ShowCursor(0)