function updateTrialRecordsForSubjectID(b,sID,trialRecords,r)
disp(sprintf('saving records for %s (from box)',sID))
startTime=GetSecs();
if isa(r,'ratrix')
    subPath=getBoxPathForSubjectID(b,sID,r);
    loadMakeOrSaveTrialRecords(subPath,trialRecords);
else
    error('need ratrix object')
end
disp(sprintf('done saving records for %s: %g s elapsed',sID,GetSecs()-startTime))