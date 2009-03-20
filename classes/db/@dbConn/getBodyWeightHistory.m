function [weights dates thresholds thresholds_90pct ages] = getBodyWeightHistory(conn,subject_id)
% 10/20/08 - the thresholds returned are from the weightthreshold table in oracle, and are already scaled to 85% of mean weights
% DO NOT RESCALE THEM in analysis
weights={};
thresholds={};
dates={};
thresholds_90pct={};

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
    
    %dan changed this to the following, but it breaks:
%    queryStr=sprintf('select         observation_date,                  to_number(value), to_number(threshold) from combinedthreshold where ((threshold_date,uin) in (select max(threshold_date),uin from combinedthreshold where threshold_date <= observation_date group by uin) or threshold_date is null) and subject_uin= %d and observationtype_uin=1 ORDER BY observation_date',subject_uin);
%     queryStr=sprintf('select to_char(observation_date,''DD-MON-YYYY''), to_number(value), to_number(threshold) from combinedthreshold where ((threshold_date,uin) in (select max(threshold_date),uin from combinedthreshold where threshold_date <= observation_date group by uin) or threshold_date is null) and subject_uin= %d and observationtype_uin=1 and value is not null ORDER BY observation_date',subject_uin);
% 10/3/08 - changed to use the view "thresholdcurve_nocalc" instead of "combinedthreshold" to skip the 85% calc
% thresholdcurve_nocalc just correlates the weightthreshold table with observations according to age (does no other calcs)
% queryStr=sprintf('select to_char(observation_date,''DD-MON-YYYY''), to_number(value), to_number(threshold) from thresholdcurve_nocalc where ((threshold_date,uin) in (select max(threshold_date),uin from thresholdcurve_nocalc where threshold_date <= observation_date group by uin) or threshold_date is null) and subject_uin= %d and observationtype_uin=1 and value is not null ORDER BY observation_date',subject_uin);
% 
% ========================================================================================================
    % 10/7/08 - do not use oracle views (because they are recomputed at every call and thus still slow)
    queryStr = sprintf('select to_char(dob, ''DD-MON-YYYY''), gender, strain_uin from subjects where subjects.display_uin=''%s''', subject_id);
    data = query(conn, queryStr);
    if ~isempty(data)
        dob = datenum(data{1});
        gender = data{2};
        strain_uin = data{3};
    end

    queryStr = sprintf('select to_char(observation_date, ''DD-MON-YYYY''), to_number(observations.value) FROM observations,subjects WHERE observations.subject_uin=subjects.uin AND value is not null AND subjects.display_uin=''%s'' order by observation_date', subject_id);
    data = query(conn, queryStr);
    if ~isempty(data)
        dates=data(:,1);
        weights=data(:,2);
        ages= datenum(dates) - dob;
    end
    % we have dates/values - now get thresholds
    queryStr = sprintf('select age, weight, threshold_90pct from weightthreshold where strain_uin=%d AND gender=''%s'' order by age', strain_uin, gender);
    data = query(conn, queryStr);
    if ~isempty(data)
        % get thresholds
        all_threshold_ages = cell2mat(data(:,1));
        all_thresholds=cell2mat(data(:,2));
        all_thresholds_90pct=cell2mat(data(:,3));
    end

    % now align all_thresholds with the provided ages according to all_threshold_ages
    thresholds = zeros(length(ages),1);
    thresholds_90pct = zeros(length(ages),1);
    % 11/6/08 - changed to return threshold of 0 if rat is so old that there is no threshold data available
    for i=1:length(ages)
        all_thresholds_index = find(all_threshold_ages == ages(i));
        if ~isempty(all_thresholds_index)
            thresholds(i) = all_thresholds(all_thresholds_index);
            thresholds_90pct(i) = all_thresholds_90pct(all_thresholds_index);
        else
            thresholds(i) = 0;
            thresholds_90pct(i) = 0;
        end
    end

% =========================================================================================================
% unchanged - fast query
else
    % Get the weights and dates for this subject uin
    % This is the SQL query where all the real work is done

    %dan changed this to the following, but it breaks:    
%    queryStr=sprintf('select         observation_date,                  to_number(value) from observations where subject_uin= %d and observationtype_uin=1 ORDER BY observation_date',subject_uin);
    queryStr=sprintf('select to_char(observation_date,''DD-MON-YYYY''), to_number(value) from observations where subject_uin= %d and observationtype_uin=1 and value is not null ORDER BY observation_date',subject_uin);


    
    data = query(conn,queryStr);
    if ~isempty(data)
        dates=data(:,1);
        weights=data(:,2);
    end
    
end

%dates=cell2mat(dates); %dan's new file uses this, but it breaks
dates=datenum(dates); % Turn the dates into datenums, this produces a mat
weights=cell2mat(weights);
% thresholds=cell2mat(thresholds); % 10/7/08 - already done above
