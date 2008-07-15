function success=compareTrialRecordFileNames(conn,subject_id,fsFileNames)

dbFileNames=getTrialRecordFiles(conn,subject_id);

%fsFileNames={fileRecs.name};

intersectFileNames = intersect(dbFileNames,fsFileNames);

if length(intersectFileNames) == length(dbFileNames) && length(dbFileNames) == length(fsFileNames)
    success = true;
else
    fprintf('Filesystem and DB File table do not match for %s!\n',subject_id)
    
    'both:'
    sort(intersectFileNames)
    
    'db only:'
    %dbFileNames{~ismember(dbFileNames,fsFileNames)}
	sort({dbFileNames{~ismember(dbFileNames,fsFileNames)}})
    
    'fs only:'
    %fsFileNames{~ismember(fsFileNames,dbFileNames)}
	sort({fsFileNames{~ismember(fsFileNames,dbFileNames)}})
    
    success = false;
end