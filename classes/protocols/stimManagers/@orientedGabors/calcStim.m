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

displaySize
[LUT stimulus updateSM]=getLUT(stimulus,LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60 59],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case {'freeDrinks' 'autopilot' 'subTrail'}
        type='loop';
    case {'nAFC' 'goNoGo'}
        %type={'trigger',true};
        type ='static';
    otherwise
        error('unsupported trialManagerClass');
end

    function out=pickN(in,n)
        out=in(ceil(rand(1,n)*length(in)));
    end

if strcmp(stimulus.distractorOrientations,'abstract') && iscell(stimulus.targetOrientations) && length(targetPorts)==1
    details.orientations = pickN(stimulus.targetOrientations{targetPorts},1)';
    details.xPosPcts=.5;
    numGabors=1;
else
    details.orientations = pickN(stimulus.targetOrientations,length(targetPorts))';
    numGabors=length(targetPorts);
    distractorLocs=[];
    
    if ~isempty(stimulus.distractorOrientations)
        numGabors=numGabors+length(distractorPorts);
        if true %parameterize matchOrientations flag
            details.orientations = [details.orientations; stimulus.distractorOrientations(find(stimulus.targetOrientations==details.orientations))'];
        else    
            details.orientations = [details.orientations; pickN(stimulus.distractorOrientations,length(distractorPorts))'];
        end
        distractorLocs=distractorPorts;
    end
    
    xPosPcts = linspace(0,1,totalPorts+4)';
    xPosPcts = xPosPcts(3:end-2);
    details.xPosPcts = xPosPcts([targetPorts'; distractorLocs']);
end

details.pixPerCyc=pickN(stimulus.pixPerCycs,1);
details.phases=rand(numGabors,1)*2*pi;
details.contrast=pickN(stimulus.contrasts,1);

shift = repmat(.5,2,numGabors);
rot = [cos(stimulus.axis) -sin(stimulus.axis); sin(stimulus.axis) cos(stimulus.axis)];
pos = rot*([details.xPosPcts'; repmat(pickN(stimulus.pos,1),1,numGabors)] - shift) + shift;

details.xPosPcts = pos(1,:)';
details.yPosPcts = pos(2,:)';

params = [repmat([stimulus.radius details.pixPerCyc],numGabors,1) details.phases details.orientations repmat([details.contrast stimulus.thresh],numGabors,1) details.xPosPcts details.yPosPcts];
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