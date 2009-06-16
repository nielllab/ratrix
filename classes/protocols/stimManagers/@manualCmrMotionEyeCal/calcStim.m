function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)
% 1/3/0/09 - trialRecords now includes THIS trial
indexPulses=[];
imagingTasks=[];
LUTbits
displaySize
[LUT stimulus updateSM]=getLUT(stimulus,LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));
% [resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[ 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end

toggleStim=true;
type = 'expert';
scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

details=[];
if ~isempty(trialRecords) && length(trialRecords)>=2
    lastRec=trialRecords(end-1);
else
    lastRec=[];
end
[targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts,trialManagerClass,allowRepeats);

% ================================================================================
background = stimulus.background;

% 10/31/08 - dynamic mode stim is a struct of parameters
stim = [];
stim.height = min(height,getMaxHeight(stimulus));
stim.width = min(width,getMaxWidth(stimulus));
stim.background=background;

discrimStim=[];
discrimStim.stimulus=stim;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;
discrimStim.autoTrigger=[];
onlyOnce=find(ismember(stimulus.stateValues,{'initialize','done'}));
discrimStim.framesUntilTimeout=hz*...
    (sum(double(stimulus.stateDurationValues(setdiff(1:length(stimulus.stateDurationValues),onlyOnce))))...
    *double(stimulus.numSweeps)+sum(double(stimulus.stateDurationValues(onlyOnce))));
preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
preRequestStim.autoTrigger=[];
preRequestStim.punishResponses=false;

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;

% details.big = {'expert', stim.seedValues}; % store in 'big' so it gets written to file
% variables to be stored for recalculation of stimulus from seed value for rand generator
details.strategy='expert';
details.height=stim.height;
details.width=stim.width;
% =============================
% do a bunch of stuff to get the correct frame indices for the recording intervals (so physAnalysis can access these values in the stimRecord)
details.recordingIntervalsA=[];
details.recordingIntervalsB=[];

Aind=find(strcmp(stimulus.stateValues,'recording at A'));
Bind=find(strcmp(stimulus.stateValues,'recording at B'));
Agap=hz*stimulus.stateDurationValues(Aind);
Atransition=stimulus.stateTransitionValues(Aind);
while Atransition~=Aind
    Agap=Agap+stimulus.stateDurationValues(Atransition)*hz;
    Atransition=stimulus.stateTransitionValues(Atransition);
end
Bgap=hz*stimulus.stateDurationValues(Bind);
Btransition=stimulus.stateTransitionValues(Bind);
while Btransition~=Bind
    Bgap=Bgap+stimulus.stateDurationValues(Btransition)*hz;
    Btransition=stimulus.stateTransitionValues(Btransition);
end
    
for i=1:stimulus.numSweeps
    details.recordingIntervalsA(i,1)=hz*sum(stimulus.stateDurationValues(1:Aind-1))+1+(i-1)*Agap;
    details.recordingIntervalsA(i,2)=hz*sum(stimulus.stateDurationValues(1:Aind))+(i-1)*Agap;
    details.recordingIntervalsB(i,1)=hz*sum(stimulus.stateDurationValues(1:Bind-1))+1+(i-1)*Bgap;
    details.recordingIntervalsB(i,2)=hz*sum(stimulus.stateDurationValues(1:Bind))+(i-1)*Bgap;
end


% ================================================================================
text='expert manualCmrMotionEyeCal';

end % end function