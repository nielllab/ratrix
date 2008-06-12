function [verifiedHistoryFiles ranges]=getTrialRecordFiles(permanentStore)

historyFiles=dir(permanentStore);

verifiedHistoryFiles={};
ranges=[];
if length(historyFiles)>0
    for i=1:length(historyFiles)
        if ~ismember(historyFiles(i).name,{'..','.'})
            if isempty(findstr('old',historyFiles(i).name))
            [rng num er]=sscanf(historyFiles(i).name,'trialRecords.%d-%d.mat',2);
            if num~=2
                historyFiles(i).name
                er
            else
                verifiedHistoryFiles{end+1}=fullfile(permanentStore,historyFiles(i).name);
                ranges(:,end+1)=rng;
            end
            end
        end
    end
else
    error('couldn''t dir recordDir for that subject')
end

%verifiedHistoryFiles
if ~isempty(verifiedHistoryFiles)
    [sorted order]=sort(ranges(1,:));
    ranges=ranges(:,order);
    verifiedHistoryFiles=verifiedHistoryFiles(order);
    for i=1:size(ranges,2)
        if i==1
            if ranges(1,i)~=1
                ranges
                error('first verifiedHistoryFile doesn''t start at 1')
            end
        else
            if ranges(1,i)~=ranges(2,i-1)+1
                permanentStore
                ranges
                error('ranges don''t follow consecutively')
            end
        end
    end
    if max(ranges(:)) ~= ranges(2,end)
        ranges
        error('didn''t find max at bottom right corner of ranges')
    end
else
    permanentStore
    error('no records found')
end