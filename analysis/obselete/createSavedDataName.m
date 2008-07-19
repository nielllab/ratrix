function name=createSavedDataName()

type='smallData'
numTrials=20; % size(trialRecords,2)
subject='rat_102'
tmClass='ifFeatureGoTo'; %trialRecords(1).trialManagerClass;
sessionID=now;
stationID=1;

[y mo d h mn s]=datevec(sessionID); %sessionID is passed in or computed from the fileSourcePath

name=sprintf('%s_%d-%d-%d-%d-%d-%0.2g_trials-%4g_station-%2g_%s',subject,y,mo,d,h,mn,s,numTrials,stationID,tmClass)