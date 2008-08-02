function success=compareTrialRecordFileNames(conn,subject_id,fsFileNames)

dbFileNames=getTrialRecordFiles(conn,subject_id);

%fsFileNames={fileRecs.name};

intersectFileNames = intersect(dbFileNames,fsFileNames);

if length(intersectFileNames) == length(dbFileNames) && length(dbFileNames) == length(fsFileNames)
    success = true;
    fprintf('Subject %s OK (%d good files)\n\n',subject_id,length(intersectFileNames))
else
    fprintf('Filesystem and DB File table do not match for %s!\n',subject_id)
    fprintf('\tgood match on %d file names\n',length(intersectFileNames))
    fprintf('\tdb only:\n');
    
%     'both:'
%     sort(intersectFileNames)
%     
%     'db only:'
%     %dbFileNames{~ismember(dbFileNames,fsFileNames)}
	printAll(sort({dbFileNames{~ismember(dbFileNames,fsFileNames)}}))
    
    %'fs only:'
    %fsFileNames{~ismember(fsFileNames,dbFileNames)}
        fprintf('\tfs only:\n');
	printAll(sort({fsFileNames{~ismember(fsFileNames,dbFileNames)}}))
    fprintf('\n');
    success = false;
end

function printAll(s)
for i=1:length(s)
    fprintf('\t\t%s\n',s{i})
end