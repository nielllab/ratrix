function subIDsFlushed = flushSpikeRecords(path,subIDs,trialFilter)
% This function removes the selected spikeRecords (specified by trialFilter [min max]) of the specified subIDs.
% The spikeRecords should be in the directory path/subIDs{i}
% trialFilter can be a two-element array [min max] or the string 'all' (default)
% ids=flushSpikeRecords('\\132.239.158.179\datanet_storage',{'303'})


error('this method needs to be upated to the format in which everything is in ''analysis'' ... why not just use the OS to delete?')
if ~exist('trialFilter','var')
    trialFilter='all';
end

if ~isdir(path)
    error('path must be a valid directory');
end
subIDsFlushed={};

% for each subject
for i=1:length(subIDs)
    subID=subIDs{i};
    d=dir(fullfile(path,subID,'spikeRecords'));
    if ~isempty(d)
        % this subID exists, so add to list of flushed subjects
        subIDsFlushed{end+1}=subID;
    end
    % now look through all files in the spikeRecords folder and remove any that are in trialFilter
    for j=1:length(d)
        [matches tokens] = regexpi(d(j).name, 'spikeRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
        if length(matches) ~= 1
            % warning('not a spikeRecord');
        else
            spikeRecordTrialNum = str2double(tokens{1}{1});
            spikeRecordTimestamp = tokens{1}{2};
            if (ischar(trialFilter) && strcmp(trialFilter,'all')) || ...
                    (spikeRecordTrialNum>=trialFilter(1) && spikeRecordTrialNum<=trialFilter(2))
                % falls within trialFilter - delete this spikeRecord
                dispStr = sprintf('deleting spikeRecords_%d-%s.mat',spikeRecordTrialNum,spikeRecordTimestamp);
                disp(dispStr);
                delStr = fullfile(path,subID,d(j).name);
                delete(delStr);
            end
        end
    end % end loop through this subID's folder
    
end % end for all subjects loop

end % end function
