function trialRecords=getTrialRecordsForSubjectID(r,sID)
disp(sprintf('loading records for %s (from ratrix)',sID))
startTime=GetSecs();
bID=getBoxIDForSubjectID(r,sID);
if bID==0
    subPath=getServerDataPathForSubjectID(r,sID);
    trialRecords=loadMakeOrSaveTrialRecords(subPath);
else
    b=getBoxFromID(r,bID);
    trialRecords=getTrialRecordsForSubjectID(b,sID,r);
end
disp(sprintf('done loading records for %s: %g s elapsed',sID,GetSecs()-startTime))