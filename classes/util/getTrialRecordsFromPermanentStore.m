function trialRecords = getTrialRecordsFromPermanentStore(permanentStorePath, subjectID, filter, trustOsRecordFiles)
% r,sID, {filterType filterParameters}
% {'dateRange',<dateFromInclusive dateToInclusive>} -- valid input for date num and length==2
% {'lastNTrials', numTrials}
% {'all'}
%
trialRecords = [];

if isempty(permanentStorePath)
    return
end

% Make the directory all the way down to the subject
subjPath = fullfile(permanentStorePath,subjectID);
if ~isDirRemote(subjPath)
    [succ msg msgid]=mkdir(fullfile(permanentStorePath,subjectID));
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
    fullFileNames=getTrialRecordFiles(fullfile(permanentStorePath,subjectID));
    if ~isempty(fullFileNames)
        for i=1:length(fullFileNames)
            [filePath fileName fileExt]=fileParts(fullFileNames{i});
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

if ~isempty(goodRecs)
    [garbage sortIndices]=sort([goodRecs.trialStart],2);
    sortedRecs = goodRecs(sortIndices);
    if ~all([sortedRecs.trialStart]-[0 sortedRecs(1:end-1).trialStop])
        [sortedRecs.trialStart; sortedRecs.trialStop]
        error('ranges don''t follow consecutively')
    end

    if sortedRecs(1).trialStart ~= 1
        [sortedRecs.trialStart; sortedRecs.trialStop]
        error('first verifiedHistoryFile doesn''t start at 1')
    end
    if max(max([sortedRecs.trialStart]),max([sortedRecs.trialStop])) ~= sortedRecs(end).trialStop
        [sortedRecs.trialStart; sortedRecs.trialStop]
        error('didn''t find max at bottom right corner of ranges')
    end
end

if ~exist('filter') ||  isempty(filter)
    filter = {'all'};
else
    if ~iscell(filter) || ~isvector(filter)
        error('Filter invalid')
    end
end
filterType = filter{1};
switch(filterType)
    case 'dateRange'
        if length(filter) ~= 2 || length(filter{2}) ~= 2
            error('Invalid filter parameters for dateRange')
        end
        dateRange = datenum(filter{2});
        dateRange = sort(dateRange);
        dateStart = dateRange(1);
        dateStop = dateRange(end);
        files = [];
        for i=1:length(goodRecs)
            if goodRecs(i).dateStart<=dateStop && goodRecs(i).dateStop>=dateStart
                if isempty(files)
                    files = goodRecs(i);
                else
                    files(end+1)=goodRecs(i);
                end
            end
        end

    case 'lastNTrials'
        if length(filter) ~= 2 || ~isinteger(filter{2}) || ~isscalar(filter{2}) || filter{2} < 0
            error('Invalid filter parameters for lastNTrials')
        end
        lastNTrials = filter{2};
        files = [];
        [garbage sortIndices]=sort([goodRecs.trialStart],2,'descend');
        goodRecs = goodRecs(sortIndices);
        highestTrialNum = goodRecs(1).trialStop;
        lowestTrialNum = highestTrialNum-lastNTrials;
        for i=1:length(goodRecs)
            if highestTrialNum-goodRecs(i).trialStop>=lastNTrials
                break;
            end
            if isempty(files)
                files = goodRecs(i);
            else
                files(end+1)=goodRecs(i);
            end
        end

    case 'all'
        files = goodRecs;
    otherwise
        error('Unsupported filter type')
end

if length(files) <= 0
    error('Files listed in db, but no records recovered')
end

% Sort the trial record files
[garbage sortIndices]=sort([files.trialStart]);
files = files(sortIndices);


for i=1:length(files)
    '*****'
    completed=false;
    nAttempts=0;
    while ~completed
        nAttempts = nAttempts+1;
        try
            tmpFile='C:\temp.mat';
            success=copyfile(fullfile(subjPath,files(i).name),tmpFile);
            if ~success
                error('Unable to copy trial records from remote store to local drive')
            end
            tr=load(tmpFile);
            completed=true;
        catch
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
                'I don''t have a tr'
            end
        end

    end
    if ~completed
        lasterror
        rethrow(lasterror)
    end
    '******'

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



