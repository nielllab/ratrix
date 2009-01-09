function [image details]= sampleStimFrame(stimManager,trialManagerClass,forceStimDetails,responsePorts,height,width)
%returns a single image from calc stim movie

if ~exist('trialManagerClass','var') || isempty(trialManagerClass)
    trialManagerClass='nAFC'
end

if ~exist('forceStimDetails','var') || isempty(forceStimDetails)
    doForce=0;
else
    doForce=1;
end

if ~exist('responsePorts') || isempty(responsePorts)
    responsePorts=[3];
end

if ~exist('height') || isempty(height)
    height=getMaxHeight(stimManager);
end

if ~exist('width') || isempty(width)
    width=getMaxWidth(stimManager);
end

    %defaults
    totalPorts=[3];
    trialRecords=[];
    %trialManagerClass = 'nAFC'
    frameRate = [];
    frame=1;
    displaySize=[]; % to fix 1/8/09
    LUTbits=[]; % to fix 1/8/09
    resolutions=[]; % to fix 1/8/09
    % also note that this function doesn't actually use PTB - so why do the resInd stuff? - we really shouldnt

    if ~doForce
        %basic calcstim
        [t updateTM resInd out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance text] =...
            calcStim(stimManager,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords);
    else
        if canForceStimDetails(stimManager,forceStimDetails)
            [t updateTM resInd out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance text] =...
                calcStim(stimManager,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,forceStimDetails);
        else
            class(stimManager)
            error('can''t force these stim details')
        end
    end

image = reshape(out(:, :, frame), size(out,1), size(out,2));
