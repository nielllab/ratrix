function [stimulus updateSM resolutionIndex preRequestStim preResponseStim discrimStim LUT targetPorts distractorPorts ...
    details interTrialLuminance text indexPulses imagingTasks] = ...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)

indexPulses=[];
imagingTasks=[];

LUT=makeStandardLUT(LUTbits);
updateSM=true;

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

if ~isempty(trialRecords) && length(trialRecords)>=2
    lastRec=trialRecords(end-1);
else
    lastRec=[];
end
stimulus.initialPos=[width height]'/2;
details.track=[stimulus.initialPos nan(2,60*60)];

if isLinux
    error('not yet written')
    
    [a,b,c]=GetMouseIndices; %use this to get non-virtual slave indices (http://tech.groups.yahoo.com/group/psychtoolbox/message/13259)
    stimulus.mouseIndices=nan;
end

mouse(stimulus);

[targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts,trialManagerClass,allowRepeats);

type='dynamic';
out=zeros([height width]./scaleFactor); %destrect is set to stretch this to the screen, so dynamic generated stims should be the same size

discrimStim=[];
discrimStim.stimulus=out;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;

preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
preRequestStim.punishResponses=false;

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;

text='';