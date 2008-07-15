function [saveTimes loadTimes]=testEyeData(eyeTracker)
%this is made for rapid testing of the eyeTracking environment
%in order to integrate this into a stimOGL, check promptedNAFC/stimOGL & promptedNAFC/doTrial
%also see calls in doTrials: calibrateEyeTracker(subject) and stopEyeTracking(subject)
%test results:  when saving struct arrays, each 100-frame data file takes
%~.66 seconds to load, so half an hour of trial data might take 2+ mins to
%load


%% general set up

%in protocol setup, before defining the trialManager
eyeTracker = geometricTracker('simple', 2, 3, 12, 0, int16([1280,1024]), [42,28], int16([1024,768]), [400,290], 300, -25, 0, 45, 0);

%on the first trial
eyeTracker=initialize(eyeTracker,'test_xxx',9);
eyeTracker=start(eyeTracker,100); %start then init? why did that work? maybe you can't get the eye until you start...?

%% settings just for this test function
trials=100:200;
saveTimes=[];
loadTimes=[];
loadMiniTimes=[];

%% settings to inialize in stimOGL

framesPerAllocationChunk=100; % 10000?

%% Get some Eye track data

for trial=trials
    
    %pre-allocate
    if isa(eyeTracker,'eyeLinkTracker')
        eyeData=nan(framesPerAllocationChunk,40);
        gaze=nan(framesPerAllocationChunk,2);
    else
        error('no other methods')
    end
    
    for frame=1:1000
        if ~checkRecording(eyeTracker)
            sca
            error('lost tracker connection!')
        end

        if frame>length(eyeData)
            %  allocateMore
            newEnd=length(eyeData)+ framesPerAllocationChunk;
            disp(sprintf('did allocation to eyeTrack data; up to %d samples enabled',newEnd))
            pause(0.5)
            eyeData(end+1:newEnd,:)=nan;
            gaze(end+1:newEnd,:)=nan;
        end

        %if is new sample...
        [gaze(frame,:) eyeData(frame,:) eyeDataVarNames]=getSample(eyeTracker);


        waitSecs(0.01);
    end
    saveTimes(end+1)=saveEyeData(eyeTracker,eyeData,eyeDataVarNames,gaze,trial);
end

%%
stop(eyeTracker)

%%  test load time

%toDo: confirm no duplicate trials here...

d=dir(getEyeDataPath(eyeTracker));
desiredFiles=[];
for i=1:length(d)
    if ~ismember(d(i).name,{'.','..'})
        d(i).name
        [scanned,COUNT,ERRMSG,NEXTINDEX] = sscanf(d(i).name,'eyeRecords_%d_%dT%d.mat',3)
        scanned
        if ~d(i).isdir && ismember(scanned(1),trials)
            
            desiredFiles{end+1}=d(i).name;
            startLoad=getSecs;
            e=load(fullfile(getEyeDataPath(eyeTracker),desiredFiles{end}));
            loadTimes(end+1)=getSecs-startLoad;

            startLoad=getSecs;
            e2=load(fullfile(getEyeDataPath(eyeTracker),desiredFiles{end}),'gaze');
            loadMiniTimes(end+1)=getSecs-startLoad;
            
        end
    end
end

figure
plot(1:length(saveTimes),saveTimes,1:length(loadTimes),loadTimes)
hold on
plot(1:length(loadMiniTimes),loadMiniTimes,'g')
legend({'save','load','loadMini'})


%%

if 0
timeCPU=e.eyeData(:,strcmp(e.eyeDataVarNames,'timeCPU'));
timeEyeLink=e.eyeData(:,strcmp(e.eyeDataVarNames,'timeEyelink'));
figure
plot(timeCPU,timeEyeLink)
figure
plot(e.gaze(:,1),e.gaze(:,1))
end

%% goodies ideas, and add ons

perTrialSyncing=false; %pass this in
if perTrialSyncing && isa(eyeTracker,'eyeLinkTracker')
    status=Eyelink('message','SYNCTIME');
    if status~=0
        error('message error, status: ',status)
    end
end
