function [stimulus updateSM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance isCorrection] =...
    calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords)

bits=8;
ramp=linspace(0,1,2^bits);
LUT= [ramp;ramp;ramp]';

updateSM=0;
isCorrection=0;

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = uint8(intmax('uint8')*getInterTrialLuminance(stimulus));%uint8(getInterTrialLuminance(stimulus));

type='trigger';

%edf: 11.25.06: copied correction trial logic from hack addition to cuedGoToFeatureWithTwoFlank
%edf: 11.15.06 realized we didn't have correction trials!
%changing below...

details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager

if ~isempty(trialRecords)
    lastResponse=find(trialRecords(end).response);
    lastCorrect=trialRecords(end).correct;
    lastWasCorrection=trialRecords(end).stimDetails.correctionTrial;
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

dups=false;
backgroundcolor=uint8(intmax('uint8')*stimulus.background);
[stimulus updateSM ims]=checkImages(stimulus,length(responsePorts),dups,backgroundcolor);

if length(targetPorts)==1 %correct response is to go to lowest numbered image -- distractors randomly assigned after that
    pics=cell(totalPorts,3);
    pics(targetPorts,:)={ims{1,:}}; %note the ROUND parens -- ugly!

    inds=2:length(responsePorts);
    [garbage order]=sort(rand(1,length(responsePorts)-1));
    inds=inds(order);

    for i=1:length(distractorPorts)
        dp=distractorPorts(i);
        pics(dp,:)={ims{inds(end),:}};
        inds=inds(1:end-1);
    end
else
    error('images stimManger only works for singleton target ports')
end

details.imageDetails={pics{:,2}};

out(:,:,1) = [pics{:,1}];

%EDF: 02.08.07 -- i think this is only supposed to be for nafc but not
%sure...
%was causing free drinks stim to only show up for first frame...
if strcmp(trialManagerClass,'nAFC')%pmm also suggests this:  && strcmp(type,'trigger')
    out(:,:,2)=backgroundcolor; % affects the stim shown between toggles of stimulus
end
