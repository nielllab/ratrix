function saveLog=initializeSaveLogIndToEmpty(saveLog,saveLogInd,sessionID)

if isempty(saveLog)&& isempty(saveLogInd)
    %initialize the whole saveLog
    saveLog.sessionID=[];
    saveLog.stationID=[];
    saveLog.subjectID={};
    saveLog.saveDate=[];
    saveLog.conversionDate=[];
    saveLog.largeExists=[];
    saveLog.smallExists=[];
else
    %initialize a single index for a new sessionID
    saveLog.sessionID(saveLogInd)=sessionID;
    saveLog.stationID(saveLogInd)=nan;
    saveLog.subjectID{saveLogInd}=nan;
    saveLog.saveDate(saveLogInd)=nan;
    saveLog.conversionDate(saveLogInd)=nan;
    saveLog.largeExists(saveLogInd)=nan;
    saveLog.smallExists(saveLogInd)=nan;
end
