function success=copyAndAddTrialRecordFile(conn,subject_id,file_name,oldLocation,newLocation)

% Get the hidden subject uin for this id
subjectquery=sprintf('select subjects.uin from subjects where LOWER(display_uin)=LOWER(''%s'') ',subject_id);
subjectdata=query(conn,subjectquery);
if isempty(subjectdata)
    subject_id
    file_name
    error('File for unknown subject was attempted to be added')
else
    subject_uin=subjectdata{1,1};
end

% Add the file name for the given subject
% This is the SQL query where all the real work is done
insertStr=sprintf('insert into trialrecords values( %d, ''%s'')',subject_uin,file_name);

% Copy the file first                        
[success messageC messageIDC]=copyfile(oldLocation,newLocation);
if ~success
    messageC
    messageIDC
    error('couldn''t copy file')
else
    % Copy succeeded, so hopefully we can get this in real fast
    rowCount = exec(conn,insertStr);
    if rowCount ~= 1
        error('Unable to insert trial record file into database')
    end
end
