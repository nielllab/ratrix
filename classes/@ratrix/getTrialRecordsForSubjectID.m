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

if numTrials>0 
    if numTrials-length(localTrialRecords) > 0
        remoteNumTrials = numTrials-length(localTrialRecords);
        % Get only the remaining N trials from the remote store
        remoteTrialRecords=getTrialRecordsFromPermanentStore(subjPermStorePath,sID,...
            {filterType,int32(remoteNumTrials)}, trustOsRecordFiles,subjectSpecificPermStore);
    end    
else
    % Get all of the remote records
    remoteTrialRecords=getTrialRecordsFromPermanentStore(subjPermStorePath,sID,filter, trustOsRecordFiles,subjectSpecificPermStore);
end
% Get from permanent store
localIndex = length(remoteTrialRecords)+1;
'this is local index'
localIndex
length(localTrialRecords)
length(remoteTrialRecords)
trialRecords = [remoteTrialRecords localTrialRecords];
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