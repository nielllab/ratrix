
conn = dbConn();

permanentStorePath='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects';
subDirs = dir(permanentStorePath);



for i=1:length(subDirs)
    if strcmp(subDirs(i).name,'.') || strcmp(subDirs(i).name,'..') || ~subDirs(i).isdir
        continue
    end
    subName = subDirs(i).name;
    subQuery=sprintf('SELECT UIN FROM SUBJECTS WHERE DISPLAY_UIN=UPPER(''%s'')',subName);
    resp = query(conn,subQuery);
    if isempty(resp)
        subName
        warning('Skipping directory, does not exist in subject list');
        continue
    end
    subId = resp{1,1};
    subPath = fullfile(permanentStorePath,subDirs(i).name,'trialRecords_*-*_*-*.mat');
    % Get the db list of file names
    dbFileNames=getTrialRecordFiles(conn,subName);
    %dbFileNames=dbFileNames';
    % Now get all of the files for this subject
    recFiles = dir(subPath);
    fsFileNames = {recFiles.name};
    intersectFileNames = intersect(dbFileNames,fsFileNames);
    if length(intersectFileNames) == length(dbFileNames) && length(dbFileNames) == length(fsFileNames)
        success = true;
    else
        'Filesystem and DB File table do not match!'
        dbFileNames
        fsFileNames
        closeConn(conn);
        error('Out of synch')
    end
end


closeConn(conn);