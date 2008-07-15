
function duration=saveEyeData(et,eyeData,eyeDataVarNames,gaze,trialNum)
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
gaze(allEmpty,:)=[];

%make struct
eyeTrackerClass=class(et);
eyeTracker=structize(et);

fileName=sprintf('eyeRecords_%d_%s',trialNum,datestr(now,30));
savefile=fullfile(et.eyeDataPath,fileName);

save(savefile,'eyeData','eyeDataVarNames','gaze','eyeTracker','eyeTrackerClass')
duration=getSecs-then;
disp(sprintf('saved %s: took %2.2g sec',fileName,duration))