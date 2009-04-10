function fixTrialRecordRanges(source,destination,subjectID,newStartingTrialNum,modifyOracle)
% This is a tool used to modify existing trialRecord files. Renumber trial records and save new files with updated names.
% For now, only creates new files (does not delete existing files) to limit danger of operation.
% INPUTS:
%   source - directory of source trialRecord files
%   destination - directory where new trialRecord files will be written
%   subjectID - id of the subject whose trialRecords are being modified - as a char array
%   newStartingTrialNum - first trialRecord number of new numbering system (all subsequent trials will be sequential from this number)
%   modifyOracle - if flagged, also delete old entries from oracle and insert new entries

% error-checking
if ~isdir(destination)
    error('destination must be a valid directory path');
end
if ~isdir(source)
    error('source must be a valid directory path');
end
if ~isscalar(newStartingTrialNum)
    error('newStartingTrialNum must be a scalar');
end


% call dir on the source directory and get a list of trialRecord files
d=dir(fullfile(source,'trialRecords_*.mat')); %unreliable if remote
goodFiles = [];

% first sort the neuralRecords by trial number
for i=1:length(d)
    [matches tokens] = regexpi(d(i).name, 'trialRecords_(\d+)-(\d+)_(.*)\.mat', 'match', 'tokens');
    if length(matches) ~= 1
        %         warning('not a trialRecords file name');
    else
        goodFiles(end+1).trialStartNum = str2double(tokens{1}{1});
        goodFiles(end).trialEndNum = str2double(tokens{1}{2});
        goodFiles(end).timestamp = tokens{1}{3};
        goodFiles(end).fileName = matches{1};
    end
end
[sorted order]=sort([goodFiles.trialStartNum]);
goodFiles=goodFiles(order);

% now, for each trialRecords file, renumber it, save it to the new filename, and advance the newStartingTrialNum counter
for i=1:length(goodFiles)
    load(fullfile(source,goodFiles(i).fileName));
    % loop through each element of the trialRecords struct that was loaded, and reset the trialNumber field
    numRecordsInThisFile = length(trialRecords);
    for j=1:numRecordsInThisFile
        trialRecords(j).trialNumber = newStartingTrialNum+j-1;
    end
    % save new file
    newTrialEndNum = newStartingTrialNum + numRecordsInThisFile - 1;
    newFileName = sprintf('trialRecords_%d-%d_%s.mat',newStartingTrialNum,newTrialEndNum,goodFiles(i).timestamp);
    save(fullfile(destination,newFileName),'trialRecords','sessionLUT','fieldsInLUT');
    
    printStr=sprintf('replaced %s trials %d to %d with %d to %d',subjectID,goodFiles(i).trialStartNum,goodFiles(i).trialEndNum,newStartingTrialNum,newTrialEndNum);
    disp(printStr);
    
    % increment newStartingTrialNum counter
    newStartingTrialNum = newStartingTrialNum + numRecordsInThisFile;
    
    % if modifyOracle is flagged
    if modifyOracle
        conn=dbConn();
        % Get the hidden subject uin for this id
        subjectquery=sprintf('select subjects.uin from subjects where UPPER(display_uin)=UPPER(''%s'') ',subjectID);
        subjectdata=query(conn,subjectquery);
        if isempty(subjectdata)
            subject_id
            file_name
            error('File for unknown subject was attempted to be removed')
        else
            subject_uin=subjectdata{1,1};
        end
        % delete old entry
        deleteStr=sprintf('delete from trialrecords where subject_uin=%d and file_name=''%s''',subject_uin,goodFiles(i).fileName);
        rowCount = exec(conn,deleteStr);
        % insert new entry
        insertStr=sprintf('insert into trialrecords values( %d, ''%s'')',subject_uin,newFileName);
        rowCount = exec(conn,insertStr);
        closeConn(conn);
    end
    

    
end

    
    
    
    
        