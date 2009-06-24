function success=reconcileTrialRecordFileNames(conn, subID, permStore, doUpdate, verbose, doWarn)
% VALIDATED 6/24/09 fli
%   useful in conjunction with fixTrialRecordRanges if a rat is accidentally run under the wrong subject
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

if ~exist('doWarn','var') || isempty(doWarn)
    doWarn = true;
end

resp=getSubject(conn,subID);
if isempty(resp)
    subID
    warning('Skipping directory, does not exist in subject list');
    return
end

inDB = getTrialRecordFiles(conn, subID);


[vHF ranges] = getTrialRecordFiles(permStore,doWarn);

inFS = {};
for j = 1:length(vHF)
    [subdir name ext] = fileparts(vHF{j});
    inFS{end+1} = [name ext];
end

inDBNotInFS = setdiff(inDB,inFS);
inFSNotInDB = setdiff(inFS,inDB);
matches = length(inDB)-length(inDBNotInFS);

fprintf('checking subject %s: ',subID);

if matches~=length(inFS)-length(inFSNotInDB)
    error('bad set math')
end

fprintf('%d good matches\n',matches);

for j = 1:length(inDBNotInFS)
    if doUpdate
        removeTrialRecordFile(conn,subID,inDBNotInFS{j});
        str=' (removed from DB)';
    else
        str='';
    end
    if verbose
        fprintf('\tin DB but not FS: %s%s\n',inDBNotInFS{j},str);
    end
end

for j = 1:length(inFSNotInDB)
    if doUpdate
        addTrialRecordFile(conn,subID,inFSNotInDB{j});
        str=' (added to DB)';
    else
        str='';
    end
    if verbose
        fprintf('\tin FS but not DB: %s%s\n',inFSNotInDB{j},str);
    end
end

if isempty(inDBNotInFS) && isempty(inFSNotInDB)
    success=true;
elseif doUpdate
    success=reconcileTrialRecordFileNames(conn, subID, permStore, false, verbose, doWarn);
    if ~success
        error('failed to reconcile');
    end
else
    success=false;
end
end