function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks,sounds] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)

sounds={};

% extend oriented gabors to have time-varying phase and contrast:
% phase = cumsum(randn(1,len))
% contrast = cumsum(randn(1,len))

% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)
% 1/3/0/09 - trialRecords now includes THIS trial
indexPulses=[];
imagingTasks=[];

LUTbits
displaySize
[LUT stimulus updateSM]=getLUT(stimulus,LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end
resolutions(resolutionIndex)



scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case {'freeDrinks' 'autopilot' 'subTrail'}
        type='loop';
    case {'nAFC' 'goNoGo'}
        type={'trigger',true};
    otherwise
        error('unsupported trialManagerClass');
end

numFreqs=length(stimulus.pixPerCycs);
details.pixPerCyc=stimulus.pixPerCycs(ceil(rand*numFreqs));

numTargs=length(stimulus.targetOrientations);
% fixes 1xN versus Nx1 vectors if more than one targetOrientation
if size(stimulus.targetOrientations,1)==1 && size(stimulus.targetOrientations,2)>1
    targetOrientations=stimulus.targetOrientations';
else
    targetOrientations=stimulus.targetOrientations;
end
if size(stimulus.distractorOrientations,1)==1 && size(stimulus.distractorOrientations,2)>1
    distractorOrientations=stimulus.distractorOrientations';
else
    distractorOrientations=stimulus.distractorOrientations;
end
    
details.orientations = targetOrientations(ceil(rand(length(targetPorts),1)*numTargs));

numDistrs=length(stimulus.distractorOrientations);
if numDistrs>0
    numGabors=length(targetPorts)+length(distractorPorts);
    details.orientations = [details.orientations; distractorOrientations(ceil(rand(length(distractorPorts),1)*numDistrs))];
    distractorLocs=distractorPorts;
else
    numGabors=length(targetPorts);
    distractorLocs=[];
end
details.phases=rand(numGabors,1)*2*pi;

xPosPcts = [linspace(0,1,totalPorts+2)]';
xPosPcts = xPosPcts(2:end-1);
details.xPosPcts = xPosPcts([targetPorts'; distractorLocs']);

details.contrast=stimulus.contrasts(ceil(rand*length(stimulus.contrasts))); % pick a random contrast from list

params = [repmat([stimulus.radius details.pixPerCyc],numGabors,1) details.phases details.orientations repmat([details.contrast stimulus.thresh],numGabors,1) details.xPosPcts repmat([stimulus.yPosPct],numGabors,1)];
out(:,:,1)=computeGabors(params,stimulus.mean,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)),stimulus.waveform, stimulus.normalizedSizeMethod,0);
if iscell(type) && strcmp(type{1},'trigger')
    out(:,:,2)=stimulus.mean;
end

text = [text sprintf('pixPerCyc: %g',details.pixPerCyc)];

discrimStim=[];
discrimStim.stimulus=out;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;
%discrimStim.autoTrigger=[];

preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
%preRequestStim.autoTrigger=[];
preRequestStim.punishResponses=false;


preResponseStim=discrimStim;
preResponseStim.punishResponses=false;

end % end function
