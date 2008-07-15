
permanentStorePath='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects';
%permanentStorePath='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\subjects';

db=dbConn();

if ~isdir(permanentStorePath)
    permanentStorePath
    error('Unknown permanent store path')
end

subDirs = dir(permanentStorePath);

for i=1:length(subDirs)
    fprintf('Processing %s %d of %d \n',subDirs(i).name,i,length(subDirs));
    if strcmp(subDirs(i).name,'.') || strcmp(subDirs(i).name,'..') || ~subDirs(i).isdir
        continue
    end
    subName = subDirs(i).name;
    subQuery=sprintf('SELECT UIN FROM SUBJECTS WHERE DISPLAY_UIN=UPPER(''%s'')',subName);
    resp = query(db,subQuery);
    if isempty(resp)
        subName
        warning('Skipping directory, does not exist in subject list');
        continue
    end
    subId = resp{1,1};
    subPath = fullfile(permanentStorePath,subDirs(i).name,'trialRecords_*-*_*-*.mat');

    % First, delete any file entries that already exist for this subject
    deleteStr=sprintf('DELETE FROM trialrecords WHERE subject_uin=%d',subId);
    rowCount=exec(db,deleteStr);
    fprintf(' Deleted: %d\n',rowCount);
    % Now add all of the files that were found for this subject
    recFiles = dir(subPath);
    for j=1:length(recFiles)
        insertStr=sprintf('INSERT INTO trialrecords VALUES (%d, ''%s'')',subId,recFiles(j).name);
        rowCount=exec(db,insertStr);
        if rowCount ~= 1
            warning('Number of added rows should always be 1');
        end
    end
end

db=closeConn(db);