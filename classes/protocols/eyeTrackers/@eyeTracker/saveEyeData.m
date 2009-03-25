
function duration=saveEyeData(et,eyeData,eyeDataFrameInds,eyeDataVarNames,gaze,trialNum,trialStartTime)
%save the eye data where it belongs, tell you how long it took

then=getSecs;

if isempty(et.eyeDataPath)
    path=et.eyeDataPath
    isTracking=et.isTracking
    error('needs a path.. should have happened in initialize')
end

%prune pre-allocated nans
allEmpty=sum(isnan(eyeData'))==size(eyeData,2);
eyeData(allEmpty,:)=[];
eyeDataFrameInds(allEmpty,:)=[];
gaze(allEmpty,:)=[];

%make struct
eyeTrackerClass=class(et);
eyeTracker=structize(et);

fileName=sprintf('eyeRecords_%d_%s',trialNum,datestr(trialStartTime,30));
savefile=fullfile(et.eyeDataPath,fileName);

[version, versionString] = Eyelink('GetTrackerVersion');

save(savefile,'eyeData','eyeDataFrameInds','eyeDataVarNames','gaze','eyeTracker','eyeTrackerClass','version','versionString')
duration=GetSecs-then;
disp(sprintf('saved %s: took %2.2g sec',fileName,duration))
