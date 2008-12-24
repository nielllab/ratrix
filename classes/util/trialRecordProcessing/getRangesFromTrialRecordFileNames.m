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
        % 2006b on osx ppc can't do: [ranges len]= textscan('3-9','%d-%d') - it misses the 9
        [a1 b1 c1 d1]=sscanf(goodRecs(end).name','%[trialRecords_]%*d%[-]%*d%[_]%*15s%[-]%*15s%[.mat]');
        [a2 b2 c2 d2]=sscanf(goodRecs(end).name','%*[trialRecords_]%d%*[-]%d%*[_]%*15s%*[-]%*15s%*[.mat]');
        [a3 b3 c3 d3]=sscanf(goodRecs(end).name','%*[trialRecords_]%*d%*[-]%*d%*[_]%15s%*[-]%*15s%*[.mat]');
        [a4 b4 c4 d4]=sscanf(goodRecs(end).name','%*[trialRecords_]%*d%*[-]%*d%*[_]%*15s%*[-]%15s%*[.mat]');
        if strcmp(char(a1)','trialRecords_-_-.mat') && length(a2)==2 && length(a3)==15 && length(a4)==15 && all(1+length(goodRecs(end).name)==[d1 d2 d3 d4]) &&...
                all(cellfun(@isempty,{c1 c2 c3 c4})) && all([b1 b2 b3 b4]==[5 2 1 1])
            goodRecs(end).trialStart = a2(1);
            goodRecs(end).trialStop = a2(2);
            goodRecs(end).dateStart = datenumFor30(char(a3)');
            goodRecs(end).dateStop = datenumFor30(char(a4)');
        else
            goodRecs(end).name
            ranges
            len
            error('can''t parse filename')
        end
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