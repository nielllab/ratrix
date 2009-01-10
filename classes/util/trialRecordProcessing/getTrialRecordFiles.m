function [verifiedHistoryFiles ranges]=getTrialRecordFiles(permanentStore, doWarn)

if ~exist('doWarn','var') || isempty(doWarn)
    doWarn = true;
end

if ~isempty(findstr('\\',permanentStore)) && doWarn
    warning('this function is dangerous when used remotely -- dir can silently fail or return a subset of existing files')
end

%this needs to trust the FS in standalone conditions, but consider relying
%solely on oracle for this listing when possible
%consider merging with getTrialRecordsFromPermanentStore (using the trustOsRecordFiles flag)
historyFiles=dir(fullfile(permanentStore,'trialRecords_*.mat'));

try
fileRecs=getRangesFromTrialRecordFileNames({historyFiles.name},true);
catch
    ex=lasterror
    permanentStore;
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