function compareTrialRecordFileNames(permanentStorePath,doUpdate,verbose)
if ~exist('doUpdate','var') || isempty(doUpdate)
    doUpdate = false;
end

if ~exist('verbose','var') || isempty(verbose)
    verbose = true;
end


subDirs = dir(permanentStorePath);

conn = dbConn;

for i=1:length(subDirs)
    if strcmp(subDirs(i).name,'.') || strcmp(subDirs(i).name,'..') || ~subDirs(i).isdir
        continue
    end
    subName = subDirs(i).name;

    reconcileTrialRecordFileNames(conn, subName, fullfile(permanentStorePath,subDirs(i).name), doUpdate, verbose)
    
end
    closeConn(conn);
end

