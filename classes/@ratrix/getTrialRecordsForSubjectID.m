function [trialRecords localIndex sessionNumber]=getTrialRecordsForSubjectID(r,sID,filter, trustOsRecordFiles)
% r,sID, {filterType filterParameters}
% {'dateRange',[dateFromInclusive dateToInclusive]}
% {'lastNTrials', numTrials}
%
disp(sprintf('loading records for %s (from ratrix)',sID))
startTime=GetSecs();
bID=getBoxIDForSubjectID(r,sID);
if ~exist('filter','var') ||  isempty(filter)
    filter = {'all'};
else
    if ~iscell(filter) || ~isvector(filter)
        error('Filter invalid')
    end
end
filterType = filter{1};
switch(filterType)
    case 'lastNTrials'
        numTrials = filter{2};
    case 'all'
        numTrials = 0;
    otherwise
        error('Only filters ''all'' and ''lastNTrials'' supported when running')
end
if bID==0
    error('no box for that subject') %edf changed -- the serverDataPath is where the ratrix db is, not where trial records would be
%    subPath=getServerDataPathForSubjectID(r,sID);
%    localTrialRecords=loadMakeOrSaveTrialRecords(subPath);
else
    b=getBoxFromID(r,bID);
    localTrialRecords=getTrialRecordsForSubjectID(b,sID,r);
end

remoteTrialRecords=[];
% 9/17/08 - fixed to do subject-specific trialRecords
% ========================
% subjPermStorePath = getPermanentStorePath(r);

subjectSpecificPermStore = false;
subjPermStorePath = getStandAlonePath(r);

if isempty(subjPermStorePath)
    conn = dbConn();
    subjPermStorePath = getPermanentStorePathBySubject(conn, sID);
    closeConn(dbConn());
    subjPermStorePath = subjPermStorePath{1};
    subjectSpecificPermStore = true;
end
% ========================
% 9/30/08 - added serverDataPath argument to getTrialRecordsFromPermanentStore call for location of temp.mat file
serverDataPath = getServerDataPath(r);

if numTrials>0 
    if numTrials-length(localTrialRecords) > 0
        remoteNumTrials = numTrials-length(localTrialRecords);
        % Get only the remaining N trials from the remote store
        remoteTrialRecords=getTrialRecordsFromPermanentStore(subjPermStorePath,sID,...
            {filterType,int32(remoteNumTrials)}, trustOsRecordFiles,subjectSpecificPermStore,serverDataPath);
    end    
else
    % Get all of the remote records
    remoteTrialRecords=getTrialRecordsFromPermanentStore(subjPermStorePath,sID,filter, trustOsRecordFiles,subjectSpecificPermStore,serverDataPath);
end
% Get from permanent store
localIndex = length(remoteTrialRecords)+1;
% 'this is local index'
% localIndex
% length(localTrialRecords)
% length(remoteTrialRecords)
% 1/28/09 - if remoteTrialRecords and localTrialRecords have different fields, give a warning and dont concat them
% this will happen if the current session is the first of a new trialRecord format - should be rare enough that we can live with 
% the consequences of losing some history temporarily
if isstruct(remoteTrialRecords) && isstruct(localTrialRecords) && ...
        length(intersect(fieldnames(remoteTrialRecords),fieldnames(localTrialRecords)))==length(fieldnames(localTrialRecords))
    trialRecords = [remoteTrialRecords localTrialRecords];
else
    warning('local and remote trialRecords have different formats - throwing out remote records!');
    trialRecords = localTrialRecords;
    % also reset localIndex
    localIndex = localIndex - length(remoteTrialRecords);
end
if ~isempty(trialRecords)
trialNums = [trialRecords.trialNumber];
else
    trialNums=[];
end
if ~all(diff(trialNums)==1)
    diff(trialNums)
    error('missing trials!')
end
disp(sprintf('done loading records for %s: %g s elapsed',sID,GetSecs()-startTime))

% Return the next session number
if isempty(trialRecords)
    sessionNumber = 1;
else
    if isfield(trialRecords(end),'sessionNumber')
        sessionNumber=trialRecords(end).sessionNumber+1;
    else
        error('Trial records do not have session number!')
    end
end