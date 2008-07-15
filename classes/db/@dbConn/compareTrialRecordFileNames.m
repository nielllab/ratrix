function success=compareTrialRecordFileNames(conn,subject_id,fileRecs)

dbFileNames=getTrialRecordFiles(conn,subject_id);

fsFileNames={fileRecs.name};

intersectFileNames = intersect(dbFileNames,fsFileNames);

if length(intersectFileNames) == length(dbFileNames) && length(dbFileNames) == length(fsFileNames)
    success = true;
else
    'Filesystem and DB File table do not match!'
    dbFileNames
    fsFileNames
    success = false;
end