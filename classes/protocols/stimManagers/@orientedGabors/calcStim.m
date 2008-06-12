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
        type='static';
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
        type='trigger';

        %edf: 11.25.06: copied correction trial logic from hack addition to cuedGoToFeatureWithTwoFlank
        %edf: 11.15.06 realized we didn't have correction trials!
        %changing below...

        details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager

        if ~isempty(trialRecords)
            lastResponse=find(trialRecords(end).response);
            lastCorrect=trialRecords(end).correct;
            if any(strcmp(fields(trialRecords(end).stimDetails),'correctionTrial'))
                lastWasCorrection=trialRecords(end).stimDetails.correctionTrial;
            else
                lastWasCorrection=0;
            end
            if length(lastResponse)>1
                lastResponse=lastResponse(1);
            end
        else
            lastResponse=[];
            lastCorrect=[];
            lastWasCorrection=0;
        end

        %note that this implementation will not show the exact same
        %stimulus for a correction trial, but just have the same side
        %correct.  may want to change...
        if ~isempty(lastCorrect) && ~isempty(lastResponse) && ~lastCorrect && (lastWasCorrection || rand<details.pctCorrectionTrials)
            details.correctionTrial=1;
            'correction trial!'
            targetPorts=trialRecords(end).targetPorts;
            isCorrection=1;
        else
            details.correctionTrial=0;
            targetPorts=responsePorts(ceil(rand*length(responsePorts)));
        end


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

numTargs=length(stimulus.targetOrientations);
details.orientations = stimulus.targetOrientations(ceil(rand(length(targetPorts),1)*numTargs));

numDistrs=length(stimulus.distractorOrientations);
if numDistrs>0
    numGabors=length(targetPorts)+length(distractorPorts);
    details.orientations = [details.orientations; stimulus.distractorOrientations(ceil(rand(length(distractorPorts),1)*numDistrs))];
    distractorLocs=distractorPorts;
else
    numGabors=length(targetPorts);
    distractorLocs=[];
end

details.phases=rand(numGabors,1)*2*pi;

xPosPcts = [linspace(0,1,totalPorts+2)]';
xPosPcts = xPosPcts(2:end-1);
details.xPosPcts = xPosPcts([targetPorts'; distractorLocs']);

params = [repmat([stimulus.radius details.pixPerCyc],numGabors,1) details.phases details.orientations repmat([stimulus.contrast stimulus.thresh],numGabors,1) details.xPosPcts repmat([stimulus.yPosPct],numGabors,1)];
out(:,:,1)=computeGabors(params,stimulus.mean,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)),'square','normalizeDiagonal',0);

%EDF: 02.08.07 -- i think this is only supposed to be for nafc but not sure...
%was causing free drinks stim to only show up for first frame...
if strcmp(trialManagerClass,'nAFC')%pmm also suggests this:  && strcmp(type,'trigger')
    out(:,:,2)=stimulus.mean;
end