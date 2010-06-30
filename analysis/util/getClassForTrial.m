function trialClass = getClassForTrial(path, subjectID, currentTrialNum)
stimRecordsPath = fullfile(path,subjectID,'stimRecords');
stimRecordName = sprintf('stimRecords_%d-*.mat',currentTrialNum);
d = dir(fullfile(stimRecordsPath,stimRecordName));
if length(d)>1
    error('duplicates present.');
end

stimRecordName = d.name;
load(fullfile(stimRecordsPath,stimRecordName),'stimManagerClass')
trialClass = stimManagerClass;
end
