function [stimulus updateSM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance isCorrection] = calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords)

%LUT = Screen('LoadCLUT', 0);
%LUT=LUT/max(LUT(:));

LUTBitDepth=8;
numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
ramp=[0:fraction:1];
LUT= [ramp;ramp;ramp]';


updateSM=0;
isCorrection=0;

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case 'freeDrinks'
        type='loop';%int32([10 10]); % This is 'timedFrames'
        if ~isempty(trialRecords)
            lastResponse=find(trialRecords(end).response);
            if length(lastResponse)>1
                lastResponse=lastResponse(1);
            end
        else
            lastResponse=[];
        end

        targetPorts=setdiff(responsePorts,lastResponse);
        distractorPorts=[];

    case 'nAFC'
        type='loop';%int32([10 10]); % This is 'timedFrames'

        %edf: 11.25.06: copied correction trial logic from hack addition to cuedGoToFeatureWithTwoFlank
        %edf: 11.15.06 realized we didn't have correction trials!
        %changing below...

        % dfp: 12.07.07: correction trial code removed from here.  Thought
        % to be handled outside of calcStim eventually per Erik

        lastResponse=[];
        lastCorrect=[];
        lastWasCorrection=0;
        details.correctionTrial=0;
        targetPorts=responsePorts(ceil(rand*length(responsePorts)));

        distractorPorts=setdiff(responsePorts,targetPorts);
        targetPorts

        %edf: 11.25.06: original:
        %targetPorts=responsePorts(ceil(rand*length(responsePorts)));
        %distractorPorts=setdiff(responsePorts,targetPorts);

    otherwise
        error('unknown trial manager class')
end

numFreqs=length(stimulus.pixPerCycs);
details.pixPerCyc=stimulus.pixPerCycs(ceil(rand*numFreqs));

numTargs=length(stimulus.targetContrasts);
details.contrasts = stimulus.targetContrasts(ceil(rand(length(targetPorts),1)*numTargs));

numDistrs=length(stimulus.distractorContrasts);
if numDistrs>0
    numFields=length(targetPorts)+length(distractorPorts);
    details.contrasts = [details.contrasts; stimulus.distractorContrasts(ceil(rand(length(distractorPorts),1)*numDistrs))];
    distractorLocs=distractorPorts;
else
    numFields=length(targetPorts);
    distractorLocs=[];
end


xPosPcts = [linspace(0,1,totalPorts+2)]';
xPosPcts = xPosPcts(2:end-1);
details.xPosPcts = xPosPcts([targetPorts'; distractorLocs']);

params = [repmat([stimulus.fieldWidthPct stimulus.fieldHeightPct details.pixPerCyc],numFields,1) details.contrasts repmat([stimulus.thresh],numFields,1) details.xPosPcts repmat([stimulus.yPosPct],numFields,1)];
out(:,:,1:2)=computeFlickerFields(params,stimulus.flickerType,stimulus.mean,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)),0);

%EDF: 02.08.07 -- i think this is only supposed to be for nafc but not sure...
%was causing free drinks stim to only show up for first frame...
%if strcmp(trialManagerClass,'nAFC')%pmm also suggests this:  && strcmp(type,'trigger')
%    out(:,:,3)=stimulus.mean;
%end
%DFP: 01.04.08 -- I needed this for both freeDrinks and nAFC, because the
%index doesn't rotate without an empty stimulus at the end
out(:,:,3)=stimulus.mean;