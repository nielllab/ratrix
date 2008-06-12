function [weights dates thresholds] = getBodyWeightHistory(conn,subject_id)
weights={};
thresholds={};
dates={};


if nargout<3
    usethresholds=false;
else
    usethresholds=true;
end

% Get the hidden subject uin for this id and species
subjectquery=sprintf('select subjects.uin from subjects where display_uin=''%s'' ',subject_id);
subjectdata=query(conn,subjectquery);
if isempty(subjectdata)
    'No subject'
    return
else
    subject_uin=subjectdata{1,1};
end
   
if usethresholds
    % Get the weights, thresholds, and dates for this subject uin
    % This is the SQL query where all the real work is done
    queryStr=sprintf('select to_char(observation_date,''DD-MON-YYYY''), to_number(value), to_number(threshold) from combinedthreshold where ((threshold_date,uin) in (select max(threshold_date),uin from combinedthreshold where threshold_date <= observation_date group by uin) or threshold_date is null) and subject_uin= %d and observationtype_uin=1 ORDER BY observation_date',subject_uin);
    
    data = query(conn,queryStr);
    if ~isempty(data)
        dates=data(:,1);
        weights=data(:,2);
        thresholds=data(:,3);
    end
else
    % Get the weights and dates for this subject uin
    % This is the SQL query where all the real work is done
    queryStr=sprintf('select to_char(observation_date,''DD-MON-YYYY''), to_number(value) from observations where subject_uin= %d and observationtype_uin=1 ORDER BY observation_date',subject_uin);
    
    data = query(conn,queryStr);
    if ~isempty(data)
        dates=data(:,1);
        weights=data(:,2);
    end
end

dates=datenum(dates); % Turn the dates into datenums, this produces a mat
weights=cell2mat(weights);
thresholds=cell2mat(thresholds);