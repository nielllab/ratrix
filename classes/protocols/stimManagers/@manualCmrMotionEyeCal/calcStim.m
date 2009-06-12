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
discrimStim.framesUntilTimeout=[];

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

% ================================================================================
text='expert manualCmrMotionEyeCal';

end % end function