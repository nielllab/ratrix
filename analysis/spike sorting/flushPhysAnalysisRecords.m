function subIDsFlushed = flushPhysAnalysisRecords(path,subIDs,trialFilter)
% This function removes the selected physAnalysis files (specified by trialFilter [min max]) of the specified subIDs.
% The physAnalysis should be in the directory path/subIDs{i}
% trialFilter can be a two-element array [min max] or the string 'all' (default)

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
    d=dir(fullfile(path,subID,'analysis'));
    if ~isempty(d)
        % this subID exists, so add to list of flushed subjects
        subIDsFlushed{end+1}=subID;
    end
    % now look through all files in the analysis folder and remove any that are in trialFilter
    for j=1:length(d)
        [matches tokens] = regexpi(d(j).name, 'physAnalysis_(\d+)-(.*)\.mat', 'match', 'tokens');
        if length(matches) ~= 1
            % warning('not a physAnalysis');
        else
            physAnalysisTrialNum = str2double(tokens{1}{1});
            physAnalysisTimestamp = tokens{1}{2};
            if (ischar(trialFilter) && strcmp(trialFilter,'all')) || ...
                    (physAnalysisTrialNum>=trialFilter(1) && physAnalysisTrialNum<=trialFilter(2))
                % falls within trialFilter - delete this physAnalysis
                dispStr = sprintf('deleting physAnalysis_%d-%s.mat',physAnalysisTrialNum,physAnalysisTimestamp);
                disp(dispStr);
                delStr = fullfile(path,subID,d(j).name);
                delete(delStr);
            end
        end
    end % end loop through this subID's folder
    
end % end for all subjects loop

end % end function
