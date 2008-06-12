function updateTrialRecordsForSubjectID(r,sID,trialRecords)
disp(sprintf('saving records for %s (from ratrix)',sID))
startTime=GetSecs();
bID=getBoxIDForSubjectID(r,sID);
if bID==0
    subPath=getServerDataPathForSubjectID(r,sID);
    loadMakeOrSaveTrialRecords(subPath,trialRecords);
else
    b=getBoxFromID(r,bID);
    updateTrialRecordsForSubjectID(b,sID,trialRecords,r);
end
disp(sprintf('done saving records for %s: %g s elapsed',sID,GetSecs()-startTime))