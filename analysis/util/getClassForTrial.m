function trialClass = getClassForTrial(path, subjectID, currentTrialNum)
if ~exist('subjectID','var') && ~exist('currentTrialNum','var')
    stimRecordFile = path;    
else
    stimRecordsPath = fullfile(path,subjectID,'stimRecords');
    stimRecordName = sprintf('stimRecords_%d-*.mat',currentTrialNum);
    d = dir(fullfile(stimRecordsPath,stimRecordName));
    if length(d)>1
        error('duplicates present.');
    end    
    stimRecordName = d.name;
    stimRecordfile = fullfile(stimRecordsPath,stimRecordName);
end
load(stimRecordFile,'stimManagerClass')
trialClass = stimManagerClass;
end
