function goodRecs=getRangesFromTrialRecordFileNames(fileNames,checkRanges)

if ~exist('checkRanges','var') || isempty(checkRanges)
    checkRanges=true;
end

goodRecs=[];
for i=1:length(fileNames)
    goodRecs(end+1).name=fileNames{i};
    [ranges len]= textscan(goodRecs(end).name,'trialRecords_%d-%d_%15s-%15s.mat');
    if length(goodRecs(end).name)== len && ~isempty(ranges) && length(ranges)==4 && ~any(cellfun(@isempty,ranges))
        goodRecs(end).trialStart = ranges{1};
        goodRecs(end).trialStop = ranges{2};
        goodRecs(end).dateStart = datenumFor30(ranges{3}{1});
        goodRecs(end).dateStop = datenumFor30(ranges{4}{1});
    else
        goodRecs(end).name
        error('can''t parse filename')
    end
end

if ~isempty(goodRecs)
    if checkRanges
        [sorted order]=sort([goodRecs.trialStart]);
        goodRecs=goodRecs(order);
        ranges=[[goodRecs.trialStart];[goodRecs.trialStop]];

        if goodRecs(1).trialStart ~= 1
            ranges
            error('first file doesn''t start at 1')
        end

        if ~all(ranges(1,:)==([1 ranges(2,1:end-1)+1])) || ~all(ranges(2,:)>=ranges(1,:))
            ranges
            ranges(:,find(ranges(1,:)~=([1 ranges(2,1:end-1)+1])))
            error('ranges don''t follow consecutively')
        end
    end
else
    fileNames
    warning('no files?')
end