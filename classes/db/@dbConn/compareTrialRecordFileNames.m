function success=compareTrialRecordFileNames(conn,subject_id,fsFileNames)

dbFileNames=getTrialRecordFiles(conn,subject_id);

%fsFileNames={fileRecs.name};

intersectFileNames = intersect(dbFileNames,fsFileNames);

if length(intersectFileNames) == length(dbFileNames) && length(dbFileNames) == length(fsFileNames)
    success = true;
else
    fprintf('Filesystem and DB File table do not match for %s!\n',subject_id)
    fprintf('good match on %d file names\n',length(intersectFileNames))
    fprintf('db only:\n');
    
%     'both:'
%     sort(intersectFileNames)
%     
%     'db only:'
%     %dbFileNames{~ismember(dbFileNames,fsFileNames)}
	printAll(sort({dbFileNames{~ismember(dbFileNames,fsFileNames)}}))
    
    %'fs only:'
    %fsFileNames{~ismember(fsFileNames,dbFileNames)}
        fprintf('fs only:\n');
	printAll(sort({fsFileNames{~ismember(fsFileNames,dbFileNames)}}))
    
    success = false;
end

function printAll(s)
for i=1:length(s)
    fprintf('\t%s\n',s{i})
end