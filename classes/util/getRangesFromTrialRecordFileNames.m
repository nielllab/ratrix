function goodRecs=getRangesFromTrialRecordFileNames(fileNames)

allRecs=[];
goodRecs=[];
for i=1:length(fileNames)
    allRecs(i).name=fileNames{i};
    [ranges l]= textscan(allRecs(i).name,'trialRecords_%d-%d_%15s-%15s.mat');
    if length(allRecs(i).name)== l
        allRecs(i).trialStart = ranges{1};
        allRecs(i).trialStop = ranges{2};
        allRecs(i).dateStart = datenumFor30(ranges{3}{1});
        allRecs(i).dateStop = datenumFor30(ranges{4}{1});
        if isempty(goodRecs)
            goodRecs = allRecs(i);
        else
            goodRecs(end+1) = allRecs(i);
        end
        
    end
end