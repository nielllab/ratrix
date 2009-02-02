function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =...
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)
% 1/3/0/09 - trialRecords now includes THIS trial
LUTbits
displaySize
[LUT stimulus updateSM]=getLUT(stimulus,LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));
hz

if isnan(resolutionIndex)
    resolutionIndex=1;
end

type = 'phased';
scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case 'freeDrinks'
%         type='static';
        if ~isempty(trialRecords) && length(trialRecords)>=2
            lastResponse=find(trialRecords(end-1).response);
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
        if ~isempty(trialRecords) && length(trialRecords)>=2
            lastRec=trialRecords(end-1);
        else
            lastRec=[];
        end
        [targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts);
    case 'autopilot'
        details.pctCorrectionTrials=0;
        details.correctionTrial=0;
        targetPorts=[1];
        distractorPorts=[];
    otherwise
        error('unknown trial manager class')
end

% ================================================================================
% start calculating frames now

height = min(height,getMaxHeight(stimulus));
width = min(width,getMaxWidth(stimulus));
frequencies = stimulus.frequencies;
duration = stimulus.duration;
repetitions = stimulus.repetitions;

% error if requested frequency exceeds half the monitor refresh rate (degenerate case)
% if any(frequencies>(hz/2))
%     error('requested frequency exceeds half the monitor refresh rate');
% end

% calculate total number of monitor frames to spend in each frequency
numFramesPerFreq = hz * duration; % in frames
numFramesToMake = numFramesPerFreq * length(frequencies) * repetitions;

frames=[];

% now for each requested frequency, map to the monitor frame rate
for i=1:length(frequencies)
    
    numSampsAtThisFreq=numFramesPerFreq; % for each frequency, calculate the frames
    samps = [1:numSampsAtThisFreq]*2*pi; % linearly spaced with one extra samp, then throw away last one (2pi)
    % now "stretch" out samps to map to the monitor refresh rate (hz)
    msamps=samps ./ frequencies(i);
%     msamps=samps;
    
    frames = [frames stimulus.contrast*0.5*cos(msamps)+0.5];
end

% now repmat to number of reps
frames = repmat(frames, [1 repetitions]);

if length(frames) ~= numFramesToMake
    numFramesToMake
    length(frames)
    numFramesPerFreq
    frequencies
    error('uh oh');
end

stim=zeros(1,1,length(frames));
for i=1:length(frames)
    stim(1,1,i) = frames(i);
end

% now return the stimSpec
out.stimSpecs{1} = stimSpec(stim,{[] 2},'cache',[],1,numFramesToMake,[],0,0); % cache mode
% final phase
out.stimSpecs{2} = stimSpec(interTrialLuminance,{[] 1},'loop',[],1,1,[],0,1);

% return out.stimSpecs, out.scaleFactors for each phase (only one phase for now?)
details.stim = stim; % store in 'big' so it gets written to file
details.frequencies=frequencies;
details.duration=duration;
details.repetitions=repetitions;

% ================================================================================
if strcmp(trialManagerClass,'nAFC') && details.correctionTrial
    text='correction trial!';
else
    text=sprintf('duration: %g',stimulus.duration);
end

end % end function