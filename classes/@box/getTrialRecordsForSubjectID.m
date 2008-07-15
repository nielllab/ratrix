function trialRecords=getTrialRecordsForSubjectID(b,sID,r)
disp(sprintf('loading records for %s (from box)',sID))
startTime=GetSecs();
if isa(r,'ratrix')
    subPath=getBoxPathForSubjectID(b,sID,r);
    trialRecords=loadMakeOrSaveTrialRecords(subPath);
else
    error('need ratrix object')
end
disp(sprintf('done loading records for %s: %g s elapsed',sID,GetSecs()-startTime))


