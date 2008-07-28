function [verifiedHistoryFiles ranges]=getTrialRecordFiles(permanentStore)
if ~isempty(findstr('\\',permanentStore))
    warning('this function is dangerous when used remotely -- dir can silently fail or return a subset of existing files')
end

historyFiles=dir(fullfile(permanentStore,'trialRecords_*.mat'));

try
fileRecs=getRangesFromTrialRecordFileNames({historyFiles.name});
catch ex
    permanentStore
    rethrow(ex)
end

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