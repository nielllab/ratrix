function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =... 
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% 1/3/0/09 - trialRecords now includes THIS trial
%LUT = Screen('LoadCLUT', 0);
%LUT=LUT/max(LUT(:));
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

LUTBitDepth=8;
numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
ramp=[0:fraction:1];
LUT= [ramp;ramp;ramp]';

text='hemifield';
updateSM=0;
correctionTrial=0;

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
if ~isempty(trialRecords) && length(trialRecords)>=2
    lastRec=trialRecords(end-1);
else
    lastRec=[];
end
[targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts,trialManagerClass);
switch trialManagerClass
    case 'freeDrinks'
        type={'indexedFrames',[]};%int32([10 10]); % This is 'timedFrames'
    case 'nAFC'
        type={'indexedFrames',[]};%int32([10 10]); % This is 'timedFrames'
    otherwise
        error('unsupported trialManagerClass');
end

numTargs=length(stimulus.targetContrasts);
details.contrasts = stimulus.targetContrasts(ceil(rand(length(targetPorts),1)*numTargs));
details.correctionTrial=correctionTrial;

numDistrs=length(stimulus.distractorContrasts);
if numDistrs>0
    numFields=length(targetPorts)+length(distractorPorts);
    details.contrasts = [details.contrasts; stimulus.distractorContrasts(ceil(rand(length(distractorPorts),1)*numDistrs))];
    distractorLocs=distractorPorts;
else
    numFields=length(targetPorts);
    distractorLocs=[];
end
% Set the randomly calculated frame indices
type{2} = round(rand(stimulus.numCalcIndices,1)*(2^numFields-1)+1); 

xPosPcts = [linspace(0,1,totalPorts+2)]';
xPosPcts = xPosPcts(2:end-1);
details.xPosPcts = xPosPcts([targetPorts'; distractorLocs']);

params = [repmat([stimulus.fieldWidthPct stimulus.fieldHeightPct],numFields,1) details.contrasts repmat([stimulus.thresh],numFields,1) details.xPosPcts repmat([stimulus.yPosPct],numFields,1)];
out(:,:,1:2^numFields)=computeFlickerFields(params,stimulus.flickerType,stimulus.mean,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)),0);

%EDF: 02.08.07 -- i think this is only supposed to be for nafc but not sure...
%was causing free drinks stim to only show up for first frame...
%if strcmp(trialManagerClass,'nAFC')%pmm also suggests this:  && strcmp(type,'trigger')
%    out(:,:,3)=stimulus.mean;
%end
%DFP: 01.04.08 -- I needed this for both freeDrinks and nAFC, because the
%index doesn't rotate without an empty stimulus at the end
out(:,:,3)=stimulus.mean;