function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =...
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)
LUTbits
displaySize
[LUT stimulus updateSM]=getLUT(stimulus,LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);
type='phased';

dynamicMode = true; % do things dynamically as in driftdemo2
% dynamicMode=false;

% =====================================================================================================
switch trialManagerClass
    case 'freeDrinks'
%         type='static';
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
%         type='trigger';

        details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
        if ~isempty(trialRecords)
            lastRec=trialRecords(end);
        else
            lastRec=[];
        end
        [targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts);
    case 'autopilot'
        details.pctCorrectionTrials=0;
        targetPorts=[1];
        distractorPorts=[];
    otherwise
        error('unknown trial manager class')
end
% =====================================================================================================

% set up params for computeGabors
height = min(height,getMaxHeight(stimulus));
width = min(width,getMaxWidth(stimulus));
numFrequencies = length(stimulus.pixPerCycs);
numContrasts = length(stimulus.contrasts);
details.spatialFrequencies=stimulus.pixPerCycs; % 1/7/09 - renamed from pixPerCycs to spatialFrequencies (to avoid clashing with compile process)
details.driftfrequencies=stimulus.driftfrequencies;
details.orientations=stimulus.orientations;
details.phases=stimulus.phases;
details.contrasts=stimulus.contrasts;
details.location=stimulus.location;
details.durations=stimulus.durations;
details.radius=stimulus.radius;
% repmat details as necessary
if length(details.driftfrequencies)==1;     details.driftfrequencies=repmat(details.driftfrequencies, [1 numFrequencies]); end
if length(details.orientations)==1;         details.orientations=repmat(details.orientations, [1 numFrequencies]);end
if length(details.phases)==1;               details.phases=repmat(details.phases, [1 numFrequencies]);         end
% % repmat to number of contrasts
% details.spatialFrequencies=repmat(details.spatialFrequencies, [numContrasts 1]);
% details.driftfrequencies=repmat(details.driftfrequencies, [numContrasts 1]);
% details.orientations=repmat(details.orientations, [numContrasts 1]);
% details.phases=repmat(details.phases, [numContrasts 1]);
% % repmat contrasts
% details.contrasts=repmat(details.contrasts, [1 numFrequencies]);
% 1/7/09 - replaced with generateFactorialCombo
retval=generateFactorialCombo({details.spatialFrequencies details.contrasts});
details.spatialFrequencies=retval(1,:);
newContrasts=retval(2,:);
retval=generateFactorialCombo({details.driftfrequencies details.contrasts});
details.driftfrequencies=retval(1,:);
retval=generateFactorialCombo({details.orientations details.contrasts});
details.orientations=retval(1,:);
retval=generateFactorialCombo({details.phases details.contrasts});
details.phases=retval(1,:);
details.contrasts=newContrasts;

% repmat durations into a [MxN] matrix if necessary
if length(details.durations) == 1
    details.durations = repmat(details.durations, [numContrasts numFrequencies]);
elseif size(details.durations) == [1 numFrequencies] % one per frequency
    details.durations = repmat(details.durations, [numContrasts 1]);
elseif size(details.durations) == [numContrasts 1] % one per contrast
    details.durations = repmat(details.durations, [1 numFrequencies]);
elseif size(details.durations) == [numContrasts numFrequencies] % one per freq-contrast pair
    % do nothing
end

% NOTE: all fields in details should be MxN now

% =====================================================================================================

if ~dynamicMode % precache'
    % 1/5/09 - dont bother with cached mode - can't hold enough frames anyways!
    % =====================================================================================================
    params=[];
    out=[];
    out.stimSpecs={};
    out.scaleFactors={};

    % loop through each frequency
    for i=1:numFrequencies
        phase = details.phases(i);
        timedFrames=[];

        % compute mask only once per frequency
        maskParams=[details.radius Inf phase details.orientations(i)...
        2.0 stimulus.thresh details.location(1) details.location(2)]; %11/12/08 - for some reason mask contrast must be 2.0 to get correct result
        % now calculate mask for this grating - we need to pass a mean of 0 to correctly make a mask
        mask(:,:,1)=computeGabors(maskParams,0,min(width,getMaxWidth(stimulus)),min(height,getMaxHeight(stimulus)),...
            stimulus.waveform, stimulus.normalizationMethod,0);

        % loop through each contrast
        for k=1:numContrasts
            % movie for this freq-contrast pair
            movie=zeros(height,width,details.numPhases(i));
            % params for this grating
            params=[Inf details.spatialFrequencies(i) phase details.orientations(i)...
                details.contrasts(k) stimulus.thresh details.location(1) details.location(2)];

            % now calculate each phase and multiply with mask
            for j=1:details.numPhases(i)
                frame(:,:,1)=computeGabors(params,0,min(width,getMaxWidth(stimulus)),...
                    min(height,getMaxHeight(stimulus)),stimulus.waveform, stimulus.normalizationMethod,0,false);

                masked = stimulus.mean+mask(:,:,1).*frame(:,:,1); % 11/12/08 - add mean to the dot-mult of mask and frame (so mask still works, but has mean lum)
                masked(masked<0) = 0;
                masked(masked>1) = 1;
                movie(:,:,j) = masked;

                % increment phase
                phase = phase + details.velocities(i);
                params(3) = phase;
            end

            % build timedFrames according to the duration for this freq-contrast pair
            numFramesInThisFreqContrast = details.numPhases(i); % number of phases in this (i,k) pair
            durationOfThisFreqContrast = details.durations(k,i); % specified by (contrast, freq) indices from [MxN] matrix
            timedFrames = uint8(ones(1,numFramesInThisFreqContrast))*durationOfThisFreqContrast;        
            % now return the stimSpec (one per freq-contrast pair)
            out.stimSpecs{end+1} = stimSpec(movie,{[] length(out.stimSpecs)+2},{'timedFrames',timedFrames},[],1,sum(timedFrames),[],0); % regular mode - timedFrames strategy
            out.scaleFactors{end+1} = scaleFactor;

        end % end numContrasts loop
    end % end numFrequencies loop

    % final phase
    out.stimSpecs{end+1} = stimSpec(interTrialLuminance, {[] 1}, 'cache',[],1,1,[],1);
    out.scaleFactors{end+1} = 0;
    % =====================================================================================================
else
    % =====================================================================================================
    % dynamic mode
    % for now we will attempt to calculate each frame on-the-fly, 
    % but we might need to precache all contrast/orientation/pixPerCycs pairs and then rotate phase dynamically
    % still pass out stimSpecs as in cache mode, but the 'stim' is a struct of parameters
    % stim.pixPerCycs - frequency of the grating (how wide the bars are)
    % stim.orientations - angle of the grating
    % stim.velocities - frequency of the phase (how quickly we go through a 0:2*pi cycle of the sine curve)
    % stim.location - where to center each grating (modifies destRect)
    % stim.contrasts - contrast of the grating
    % stim.durations - duration of each grating (in frames)
    % stim.mask - the mask to be used (empty if unmasked)
    stim=[];
    stim.height=height;
    stim.width=width;
    stim.floatprecision=1;
    
    stim.pixPerCycs=details.spatialFrequencies;
    stim.orientations=details.orientations;
    stim.driftfrequencies=details.driftfrequencies;
    stim.phases=details.phases; %starting phases in radians
    stim.location=details.location;
    stim.contrasts=details.contrasts;
    stim.durations=round(details.durations*hz); % CONVERTED FROM seconds to frames
    
%     stim.pixPerCycs
%     stim.orientations
%     stim.driftfrequencies
%     stim.phases
%     stim.contrasts
%     stim.durations
%     error('stop')
    
    % compute mask only once if radius is not infinite
    if details.radius==Inf
        stim.mask=[];
    else
        maskParams=[details.radius 999 0 0 ...
        1.0 stimulus.thresh details.location(1) details.location(2)]; %11/12/08 - for some reason mask contrast must be 2.0 to get correct result
        % now calculate mask for this grating - we need to pass a mean of 0 to correctly make a mask
        stim.mask(:,:,1)=ones(height,width,1)*stimulus.mean;
        stim.mask(:,:,2)=computeGabors(maskParams,0,width,height,...
            'none', stimulus.normalizationMethod,0,0);

        % necessary to make use of PTB alpha blending
        stim.mask(:,:,2) = 1 - stim.mask(:,:,2); % 0 = transparent, 255=opaque (opposite of our mask)
    end
    
    % now create stimSpecs
    out.stimSpecs{1} = stimSpec(stim,{[] 2},'expert',[],1,[],[],0); % expert mode
    out.scaleFactors{1} = scaleFactor;

    % final phase
    out.stimSpecs{2} = stimSpec(interTrialLuminance,{[] 1},'loop',[],1,1,[],1);
    out.scaleFactors{2} = 0;
    
end

% =====================================================================================================
% return out.stimSpecs, out.scaleFactors for each phase (only one phase for now?)
% details.big = out; % store in 'big' so it gets written to file % 1/6/09 - unnecessary since we will no longer use cached mode
details.stimManagerClass = class(stimulus);
details.trialManagerClass = trialManagerClass;

if strcmp(trialManagerClass,'nAFC') && details.correctionTrial
    text='correction trial!';
else
    text=sprintf('thresh: %g',stimulus.thresh);
end