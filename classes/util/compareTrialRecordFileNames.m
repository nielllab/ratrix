function success=compareTrialRecordFileNames(permanentStorePath)
%permanentStorePath=
%'\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects'; 
%'\\132.239.158.181\rlab\Rodent-Data\ratrixAdmin\subjects';

subDirs = dir(permanentStorePath);

success=true;
conn = dbConn();

for i=1:length(subDirs)
    if strcmp(subDirs(i).name,'.') || strcmp(subDirs(i).name,'..') || ~subDirs(i).isdir
        continue
    end
    subName = subDirs(i).name;

    resp=getSubject(conn,subName);
    if isempty(resp)
        subName
        warning('Skipping directory, does not exist in subject list');
        continue
    end
    
    dbFileNames=getTrialRecordFiles(conn,subName);
    
    fsFileNames={};
    [verifiedHistoryFiles ranges]=getTrialRecordFiles(fullfile(permanentStorePath,subName));
    for fn=1:length(verifiedHistoryFiles)
        [pth,nme,ext,ver]=fileParts(verifiedHistoryFiles{fn});
        fsFileNames{end+1}=[nme ext];
    end
    fsFileNames=fsFileNames';
    
    %subPath = fullfile(permanentStorePath,subDirs(i).name,'trialRecords_*-*_*-*.mat');
    %recFiles = dir(subPath);
    %fsFileNames = {recFiles.name};
    
    intersectFileNames = intersect(dbFileNames,fsFileNames);
    if length(intersectFileNames) == length(dbFileNames) && length(dbFileNames) == length(fsFileNames)
        fprintf('%s ok\n',subName)
    else
        warning('Filesystem and DB File table do not match!')
        subName
        dbFileNames
        fsFileNames
        %closeConn(conn);
        %error('Out of synch')
        success=false;
    end
end

closeConn(conn);