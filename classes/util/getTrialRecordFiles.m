function [verifiedHistoryFiles ranges]=getTrialRecordFiles(permanentStore)

historyFiles=dir(fullfile(permanentStore,'trialRecords_*.mat'));

fileRecs=getRangesFromTrialRecordFileNames({historyFiles.name});

if ~isempty(fileRecs)
    ranges=[[fileRecs.trialStart];[fileRecs.trialStop]];

    verifiedHistoryFiles={};
    for i=1:length(fileRecs)
        verifiedHistoryFiles{end+1}=fullfile(permanentStore,fileRecs(i).name);
    end
else
    permanentStore
    ranges=[];
    verifiedHistoryFiles={};
    warning('no filenames')
end