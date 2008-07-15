function [verifiedHistoryFiles ranges]=getTrialRecordFiles(permanentStore)

historyFiles=dir(permanentStore);

verifiedHistoryFiles={};
ranges=[];
if length(historyFiles)>0
    for i=1:length(historyFiles)
        if ~ismember(historyFiles(i).name,{'..','.'})
            rng=textscan(historyFiles(i).name,'trialRecords_%d-%d_%15s-%15s.mat');
            if ~isempty(rng) && length(rng)==4 && ~isempty(rng{1}) && ~isempty(rng{2})
                disp(historyFiles(i).name)
                newRng = [rng{1} rng{2}];
                verifiedHistoryFiles{end+1}=fullfile(permanentStore,historyFiles(i).name);
                ranges(:,end+1)=newRng;
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
    if ranges(1,1) ~= 1
        ranges
        error('first verifiedHistoryFile doesn''t start at 1')
    end
    diffedRange=diff(reshape(ranges,1,size(ranges,1)*size(ranges,2)));
    if ~all(diffedRange(2:2:end))
        permanentStore
        ranges
        
        error('ranges don''t follow consecutively')
    end
%     for i=1:size(ranges,2)
%         if i==1
%             if ranges(1,i)~=1
%                 ranges
%                 error('first verifiedHistoryFile doesn''t start at 1')
%             end
%         else
%             if ranges(1,i)~=ranges(2,i-1)+1
%                 ranges
%                 error('ranges don''t follow consecutively')
%             end
%         end
%     end
    if max(ranges(:)) ~= ranges(2,end)
        ranges
        error('didn''t find max at bottom right corner of ranges')
    end
else
    warning('no files found for subject')
end