function [keepWorking secsRemainingTilStateFlip updateScheduler scheduler] = checkSchedule (scheduler, subject, trainingStep, trialRecords, sessionNumber)

%find the trials of this session
%
if ~isempty(trialRecords)
    trialsThisSession=trialRecords([trialRecords.sessionNumber]==sessionNumber);
else
    trialsThisSession=trialRecords;
end

if size(trialsThisSession,2)>1

    startTime=datenum(trialsThisSession(1).date);
else
    startTime=now;
end

if (now-startTime)*(24*60)>scheduler.minutes
    keepWorking=0;
else
    keepWorking=1;
end

secsRemainingTilStateFlip=(now-startTime)*24*60*60;
updateScheduler=0;
