function removeTrialRecordFile(conn,subject_id,file_name)

% Get the hidden subject uin for this id
subjectquery=sprintf('select subjects.uin from subjects where UPPER(display_uin)=UPPER(''%s'') ',subject_id);
subjectdata=query(conn,subjectquery);
if isempty(subjectdata)
    subject_id
    file_name
    error('File for unknown subject was attempted to be removed')
else
    subject_uin=subjectdata{1,1};
end

% Remove the file name for the given subject
% This is the SQL query where all the real work is done
deleteStr=sprintf('delete from trialrecords where subject_uin=%d and file_name=''%s''',subject_uin,file_name);

rowCount = exec(conn,deleteStr);

