function updateDatabase(subID, rackNum, verbose)

if ~exist('subIDs','var') || isempty(subIDs)
    error('please enter valid subID');
end

if ~exist('rackNum','var') || isempty(rackNum)
    error('please enter valid rackNum');
end

if ~exist('verbose','var') || isempty(verbose)
    verbose = true;
elseif ~islogical(verbose) || verbose~=0
    verbose = true
end

subID
rackNum

if verbose
    display('getting store path and collecting files');
end

permStore = fullfile(getSubDirForRack(rackNum),char(subID));
[vHF ranges] = getTrialRecordFiles(permStore);

inFS = {};
for j = 1:length(vHF)
    [subdir name ext] = fileparts(vHF{j});
    inFS{end+1} = [name ext];
end

if verbose
    display('done');
end

conn=dbConn;
inDB = getTrialRecordFiles(conn, char(subID));

inDBNotInFS = setdiff(inDB,inFS);
inFSNotInDB = setdiff(inFS,inDB);

if ~isempty(inDBNotInFS)
    if verbose
        display('deleting files from DB to adhere to FS');
    end
    for j = 1:length(inDBNotInFS)
        if verbose
            display(['removing file named' inDBNotInFS{j}]);
        end
        removeTrialRecordFile(conn,char(subID),inDNNotInFS{j});
    end
    if verbose
        display('done');
    end
end

if ~isempty(inFSNotInDB)
    if verbose
        display('adding files in FS to DB');
    end
    for j = 1:length(inFSNotInDB)
        if verbose
            display(['adding file named' inFSNotInDB{j}]);
        end
        addTrialRecordFile(conn,char(subID),inDNNotInFS{j});
    end
    if verbose
        display('done');
    end
end

success = compareTrialRecordFileNames(conn, char(subID), inFS)
display(['reconciling done for subID ' char(subID)]);
closeConn(conn)
end

    
        
