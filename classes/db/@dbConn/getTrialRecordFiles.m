function files = getTrialRecordFiles(conn,subject_id)
files={};

% Get the hidden subject uin for this id
subjectquery=sprintf('select subjects.uin from subjects where LOWER(display_uin)=LOWER(''%s'') ',subject_id);
subjectdata=query(conn,subjectquery);
if isempty(subjectdata)
    subject_id
    warning('Subject is not defined in subject table')
    return
else
    subject_uin=subjectdata{1,1};
end

% Get the file names
% This is the SQL query where all the real work is done
queryStr=sprintf('select file_name from trialrecords where subject_uin = %d ORDER BY file_name',subject_uin);

data = query(conn,queryStr);
if ~isempty(data)
    files=data(:,1);
else
    subject_id
    warning('No files listed for subject');
end
