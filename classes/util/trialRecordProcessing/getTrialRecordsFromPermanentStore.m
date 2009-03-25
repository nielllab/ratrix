function trialRecords = getTrialRecordsFromPermanentStore(permanentStorePath, subjectID, filter, trustOsRecordFiles, subjectSpecificPermStore, serverDataPath)
% r,sID, {filterType filterParameters}
% {'dateRange',<dateFromInclusive dateToInclusive>} -- valid input for date num and length==2
% {'lastNTrials', numTrials}
% {'all'}
%
% 9/30/08 - added serverDataPath argument to getTrialRecordsFromPermanentStore call for location of temp.mat file


trialRecords = [];

if isempty(permanentStorePath)
    return
end

% Make the directory all the way down to the subject
if subjectSpecificPermStore
    subjPath = permanentStorePath;
else
    subjPath = fullfile(permanentStorePath,subjectID);
end
if ~isdir(subjPath) %not a problem if this fails due to windows filesharing/networking bug, cuz mkdir just noops with warning if dir exists
    [succ msg msgid]=mkdir(fullfile(permanentStorePath,subjectID)); %9/17/08 - dont need to depend on subjectSpecificPermStore flag cuz it wont happen in that case
    if ~succ
        msg
        msgid
        permanentStorePath
        error('couldn''t access permanent store')
    end
end

if ~trustOsRecordFiles
    %use oracle to get trailRecordFiles

    conn=dbConn();
    fileNames=getTrialRecordFiles(conn,subjectID);
    s = getSubject(conn,subjectID);
    closeConn(conn);

    % Only if the subject is not a test rat should we load files from the permanent store
    if s.test
        'subjectID'
        subjectID
        warning(['Found a test subject not loading trial records']);
        return
    end
else
    %getTrialRecordFiles from the Os... less reliable if server is taxed...
    %but okay on local computer and has less dependency on the oracle db
    if subjectSpecificPermStore
        fullFileNames=getTrialRecordFiles(permanentStorePath);
    else
        fullFileNames=getTrialRecordFiles(fullfile(permanentStorePath,subjectID));
    end
    if ~isempty(fullFileNames)
        for i=1:length(fullFileNames)
            [filePath fileName fileExt]=fileparts(fullFileNames{i});
            fileNames{i,1}=[fileName fileExt];
        end %fileNames are chronological if using OS, but not necessarily if using conn to db... think it's okay because they're sorted in a few lines - pmm 08/06/26
    else
        fileNames=[];
    end
end

if length(fileNames) <= 0
    % Normally this function is never allowed to return empty
    % the only exception is where there are no files listed in the db for
    % this subject
    warning('No records recovered from permanent store');
    return
end


goodRecs=getRangesFromTrialRecordFileNames(fileNames);

% if ~isempty(goodRecs)
%     [garbage sortIndices]=sort([goodRecs.trialStart],2);
%     sortedRecs = goodRecs(sortIndices);
%     if ~all([sortedRecs.trialStart]-[0 sortedRecs(1:end-1).trialStop])
%         [sortedRecs.trialStart; sortedRecs.trialStop]
%         error('ranges don''t follow consecutively')
%     end
% 
%     if sortedRecs(1).trialStart ~= 1
%         [sortedRecs.trialStart; sortedRecs.trialStop]
%         error('first verifiedHistoryFile doesn''t start at 1')
%     end
%     if max(max([sortedRecs.trialStart]),max([sortedRecs.trialStop])) ~= sortedRecs(end).trialStop
%         [sortedRecs.trialStart; sortedRecs.trialStop]
%         error('didn''t find max at bottom right corner of ranges')
%     end
% end

files=applyTrialFilter(goodRecs,filter);
if iscell(filter)
    filterType=filter{1};
else
    error('filter must be a cell array');
end

if length(files) <= 0
    error('Files listed in db, but no records recovered')
end

% Sort the trial record files
[garbage sortIndices]=sort([files.trialStart]);
files = files(sortIndices);


for i=1:length(files)
    %'*****'
    completed=false;
    nAttempts=0;
    while ~completed
        nAttempts = nAttempts+1;
        try
%             tmpFile='C:\temp.mat';
            % 9/29/08 - changed to be cross-platform; use top-level ratrixData folder for temp.mat
            tmpFile = fullfile(fileparts(serverDataPath), 'temp.mat');
            [success message messageid]=copyfile(fullfile(subjPath,files(i).name),tmpFile);
            if ~success
                message
                error('Unable to copy trial records from remote store to local drive')
            end
            tr=load(tmpFile);
            completed=true;
        catch  ex
            % Why are we doing this?  Because we don't want all of the
            % computers to load the file from the remote store at the same
            % time.  To cut down on the chance of this, we are
            % (faux) nondeterministically waiting between loads
            numSecsForLoad=GetSecs();
            numSecsForLoad=fliplr(num2str(numSecsForLoad-floor(numSecsForLoad),'%.9g'));
            % Take 2 off for the '0.' of the str.
            lenSecs=length(numSecsForLoad)-2;
            numSecsForLoad=str2num(numSecsForLoad)/10^lenSecs*10; % Up to 10 seconds between tries
            pause(numSecsForLoad);
            if exist('tr','var')
                tr
            else
                permanentStorePath
                subjectSpecificPermStore
                subjectID
                'I don''t have a tr'
            end
        end

    end
    if ~completed
        ple(ex)
        rethrow(ex)
    end
    %'******'

    switch(filterType)
        case 'dateRange'
            dates = [];
            for j=1:length(tr.trialRecords)
                dates(end+1) = datenum(tr.trialRecords(j).date);
            end
            recIndices=intersect(find(dates>dateStart),find(dates < dateStop));
            newTrialRecords = tr.trialRecords(recIndices);
        case 'lastNTrials'
            % NOTE: I'm only checking start, since once we hit the start
            % value everything higher is included
            if lowestTrialNum > files(i).trialStart
                startIndex=find([tr.trialRecords.trialNumber]==lowestTrialNum)
                if length(startIndex) ~= 1
                    error('trialRecords have multiple trials with the same trialNumber!')
                end
            else
                startIndex = 1;
            end
            newTrialRecords = tr.trialRecords(startIndex:end);
        case 'all'
            newTrialRecords = tr.trialRecords;
        otherwise
            error('Unsupported filter type')
    end
    % Add the trial records


    %
    %         trialRecords
    %         newTrialRecords
    %         class(trialRecords)
    %         class(newTrialRecords)
    %         size(trialRecords)
    %         size(newTrialRecords)
    if ~isempty(trialRecords) && ~isempty(newTrialRecords)
        f = fieldnames(trialRecords);
        newf = fieldnames(newTrialRecords);
        temp = f;
        temp(end+1: end+length(newf)) = newf;
        bothF = unique(temp);

        for i = 1: length(bothF)
            oldHasIt(i)= ismember(bothF(i), f);
            newHasIt(i)= ismember(bothF(i), newf);
        end

        for oldNeedsIt=find(~oldHasIt)
            fprintf(' old records need field: %s\n',bothF{oldNeedsIt})
            [trialRecords(:).(bothF{oldNeedsIt})]=deal([]);
        end

        for newNeedsIt=find(~newHasIt)
            fprintf(' new records need field: %s\n',bothF{newNeedsIt})
            [newTrialRecords(:).(bothF{newNeedsIt})]=deal([]);
        end
    end

    trialRecords = [ trialRecords newTrialRecords];



end
end



