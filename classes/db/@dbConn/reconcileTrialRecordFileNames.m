function reconcileTrialRecordFileNames(conn, subID, permStore, doUpdate, verbose)

if ~exist('subID','var') || isempty(subID)
    error('please enter valid subID');
end

if ~exist('permStore','var') || isempty(permStore)
    error('please enter valid permStore');
end

if ~exist('verbose','var') || isempty(verbose)
    verbose = true;
elseif ~islogical(verbose) || verbose~=0
    verbose = true;
end

if ~exist('doUpdate','var') || isempty(doUpdate)
    doUpdate = false;
end

%permStore = fullfile(getSubDirForRack(rackNum),subID);
doWarn = false;
[vHF ranges] = getTrialRecordFiles(permStore,doWarn);

inFS = {};
for j = 1:length(vHF)
    [subdir name ext] = fileparts(vHF{j});
    inFS{end+1} = [name ext];
end

resp=getSubject(conn,subID);
if isempty(resp)
    subID
    warning('Skipping directory, does not exist in subject list');
    return
end

inDB = getTrialRecordFiles(conn, subID);

inDBNotInFS = setdiff(inDB,inFS);
inFSNotInDB = setdiff(inFS,inDB);
if doUpdate
    if ~isempty(inDBNotInFS)
        if verbose
            display(['deleting files from DB to adhere to FS for subject ' subID]);
        end
        for j = 1:length(inDBNotInFS)
            if verbose
                display(['     removing file named ' inDBNotInFS{j}]);
            end
            removeTrialRecordFile(conn,subID,inDBNotInFS{j});
        end
    end

    if ~isempty(inFSNotInDB)
        if verbose
            display(['adding files in FS to DB for subject ' subID]);
        end
        for j = 1:length(inFSNotInDB)
            if verbose
                display(['     adding file named ' inFSNotInDB{j}]);
            end
            addTrialRecordFile(conn,subID,inFSNotInDB{j});
        end
    end
end

success = compareTrialRecordFileNames(conn, subID, inFS);

if doUpdate && ~success
    error('failed to reconcile. coming out of loop');
end
end

    
        
