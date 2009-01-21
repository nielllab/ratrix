function cleanUpStimRecords(datanet_path)
% this function removes stimRecords that do not have a corresponding neuralRecord in the specified path
% necessary because stimRecords are written every trial in fan dev, but neuralRecords only when datanet is not empty
% datanet_path is typically \\132.239.158.179\datanet_storage\demo1
%
% Look in datanet_path for two subfolders 'stimRecords' and 'neuralRecords'

if ~isdir(datanet_path) || ~isdir(fullfile(datanet_path,'stimRecords')) || ~isdir(fullfile(datanet_path,'neuralRecords'))
    error('specified datanet_path is not a directory or does not contain ''stimRecords'' and ''neuralRecords'' subfolders');
end

% get list of good trial numbers and timestamps from neuralRecords folder
d=dir(fullfile(datanet_path,'neuralRecords'));
goodFiles=[];
for i=1:length(d)
    [matches tokens] = regexpi(d(i).name, 'neuralRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
    if length(matches) ~= 1
        %         warning('not a neuralRecord file name');
    else
        goodFiles(end+1).trialNum = str2double(tokens{1}{1});
        goodFiles(end).timestamp = tokens{1}{2};
    end
end
[sorted order]=sort([goodFiles.trialNum]);
goodFiles=goodFiles(order);

% now go through the list of stimRecords and delete any that do not correspond to a goodFiles entry
d=dir(fullfile(datanet_path,'stimRecords'));
stimRecordTrialNum=[];
stimRecordTimestamp=[];
for i=1:length(d)
    [matches tokens] = regexpi(d(i).name, 'stimRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
    if length(matches) ~= 1
        % warning('not a stimRecord');
    else
        stimRecordTrialNum = str2double(tokens{1}{1});
        stimRecordTimestamp = tokens{1}{2};
        % check to see if this stimRecord exists in goodFiles
        matchesNeuralRecord = false;
        for j=1:length(goodFiles)
            if (stimRecordTrialNum == goodFiles(j).trialNum) && (strcmp(stimRecordTimestamp, goodFiles(j).timestamp))
                matchesNeuralRecord = true;
                break;
            end
        end
        
        % if no match, then delete this stimRecord
        if ~matchesNeuralRecord
            dispStr = sprintf('deleting stimRecords_%d-%s.mat',stimRecordTrialNum,stimRecordTimestamp);
            disp(dispStr);
            delStr = fullfile(datanet_path,'stimRecords',sprintf('stimRecords_%d-%s.mat',stimRecordTrialNum,stimRecordTimestamp));
            delete(delStr);
        end
        
    end % end if regexp matches
end % end stimRecords loop