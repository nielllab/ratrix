function [weights dates thresholds] = getBodyWeightHistory(idstring,server_ip,port)
weights={};
thresholds={};
dates={};
if ~exist('host')
    host = '132.239.158.177';
end
if ~exist('port')
    port = 1521; % Default oracle port
end
if nargout<3
    usethresholds=false;
else
    usethresholds=true;
end
% Turn port into a string
port=sprintf('%d',port);
driver='oracle.jdbc.driver.OracleDriver';
service = 'XE';
user='dparks';
password='pac3111';
url=['jdbc:oracle:thin:/' user '/' password '@//' host ':' port '/' service];
name=''; % This must be left blank!


% Break id string into the species and id
index=find(idstring=='_');
if isempty(index)
%     warning('lacks expected ''_'' in string')
    species='rat'; %if unspecified assume species is rat
    id=idstring;
else
    species = idstring(1:index-1);
    id = idstring(index+1:end);
end



%species convention in database is first letter cap
%species(1)=upper(species(1));  not anymore!

% This timeout must be set or the function will hang forever on a bad
% connection
logintimeout('oracle.jdbc.driver.OracleDriver',10);
conn=database(name,user,password,driver,url);
setdbprefs('DataReturnFormat','cellarray');

% Get the hidden subject uin for this id and species
subjectquery=sprintf('select subjects.uin from subjects,strains,subjecttypes where display_uin=''%s'' and subjecttypes.name=''%s'' and subjects.strain_uin=strains.uin and strains.subjecttype_uin=subjecttypes.uin ',id,species);
subjectdata=fetch(conn,subjectquery);
if isempty(subjectdata)
    % If it's empty, check if the subject is present, but the species is incorrect
    subjectquery=sprintf('select subjects.uin from subjects where display_uin=''%s''',id);
    subjectdata=fetch(conn,subjectquery);
    close(conn);
    if ~isempty(subjectdata)
        error('Subject Id exists, but the species does not match')
    end
   return
else
    subject_uin=subjectdata{1,1};
end
   
if usethresholds
    % Get the weights, thresholds, and dates for this subject uin
    % This is the SQL query where all the real work is done
    query=sprintf('select to_char(observation_date,''DD-MON-YYYY''), to_number(value), to_number(threshold) from combinedthreshold where ((threshold_date,uin) in (select max(threshold_date),uin from combinedthreshold where threshold_date <= observation_date group by uin) or threshold_date is null) and subject_uin= %d and observationtype_uin=1 ORDER BY observation_date',subject_uin);
    
    data = fetch(conn,query);
    if ~isempty(data)
        dates=data(:,1);
        weights=data(:,2);
        thresholds=data(:,3);
    end
else
    % Get the weights and dates for this subject uin
    % This is the SQL query where all the real work is done
    query=sprintf('select to_char(observation_date,''DD-MON-YYYY''), to_number(value) from observations where subject_uin= %d and observationtype_uin=1 ORDER BY observation_date',subject_uin);
    
    data = fetch(conn,query);
    if ~isempty(data)
        dates=data(:,1);
        weights=data(:,2);
    end
end

dates=datenum(dates); % Turn the dates into datenums, this produces a mat
weights=cell2mat(weights);
thresholds=cell2mat(thresholds);
close(conn);