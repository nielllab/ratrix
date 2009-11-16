function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)
% 1/30/09 - trialRecords includes THIS trial now
indexPulses=[];
imagingTasks=[];

LUTbits
displaySize
[LUT stimulus updateSM]=getLUT(stimulus,LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end

type = 'cache';
scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
if ~isempty(trialRecords) && length(trialRecords)>=2
    lastRec=trialRecords(end-1);
else
    lastRec=[];
end
[targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts,trialManagerClass,allowRepeats);

% ================================================================================
% start calculating frames now

height = min(height,getMaxHeight(stimulus));
width = min(width,getMaxWidth(stimulus));
frequencies = stimulus.frequencies;
duration = stimulus.duration;
repetitions = stimulus.repetitions;

% error if requested frequency exceeds monitor refresh rate
% if any(frequencies>hz)
%     error('requested frequency exceeds monitor refresh rate');
% end

% calculate total number of monitor frames to spend in each frequency
numFramesPerFreq = hz * duration; % in frames
numFramesToMake = numFramesPerFreq * length(frequencies) * repetitions;

framesL=[];
framesR=[];


if isa(stimulus.receptiveFieldLocation,'RFestimator')
    if size(trialRecords(end).subjectsInBox,2)==1
        subjectID=char(trialRecords(end).subjectsInBox);
    else
        error('only one subject allowed')
    end
    partition=getCenter(stimulus.receptiveFieldLocation,subjectID,trialRecords);
else
    partition=stimulus.receptiveFieldLocation;
end

% calculate the number of pixels horizontally on each side (reduced using gcd)
leftlength=floor(partition(1)*width);
rightstart=ceil(partition(1)*width);
rightlength=width-rightstart;
sz=gcd(leftlength,rightlength);
numLeftPixels=leftlength/sz;
numRightPixels=rightlength/sz;

% now for each requested frequency, map to the monitor frame rate
for i=1:length(frequencies)
    numSampsAtThisFreq=numFramesPerFreq; % for each frequency, calculate the frames
    samps = [1:numSampsAtThisFreq]*2*pi; % linearly spaced with one extra samp, then throw away last one (2pi)
    % now "stretch" out samps to map to the monitor refresh rate (hz)
    msamps=samps ./ frequencies(i);
    
    framesL = [framesL 0.5*cos(msamps)+0.5];
    framesR = [framesR 0.5*cos(msamps+pi)+0.5];
end

% now repmat to number of reps
framesL = repmat(framesL, [1 repetitions]);
framesR = repmat(framesR, [1 repetitions]);

if length(framesL) ~= length(framesR)
    error('wtf');
end
if length(framesL) ~= numFramesToMake
    numFramesToMake
    length(framesL)
    numFramesPerFreq
    frequencies
    error('uh oh');
end

% stim.frames(1,:) = framesL(:);
% stim.frames(2,:) = framesR(:);

% 11/7/08 - dynamic mode stim is a struct of parameters
% stim = [];
% stim.height = height;
% stim.width = width;
% stim.frames(1,:) = framesL(:);
% stim.frames(2,:) = framesR(:);
% stim.numLeftPixels = numLeftPixels;
% stim.numRightPixels = numRightPixels;

stim=zeros(1,numLeftPixels+numRightPixels,length(framesL));
for i=1:length(framesL)
    stim(1,1:numLeftPixels,i) = framesL(i);
    stim(1,numLeftPixels+1:end,i) = framesR(i);
end

discrimStim=[];
discrimStim.stimulus=stim;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;
discrimStim.autoTrigger=[];
discrimStim.framesUntilTimeout=numFramesToMake;

preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
preRequestStim.autoTrigger=[];
preRequestStim.punishResponses=false;

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;

% return out.stimSpecs, out.scaleFactors for each phase (only one phase for now?)
details.frequencies=frequencies;
details.duration=duration;
details.repetitions=repetitions;
details.partition=partition;
details.numLeftPixels=numLeftPixels;
details.numRightPixels=numRightPixels;
details.stim=stim;

% ================================================================================
if strcmp(trialManagerClass,'nAFC') && details.correctionTrial
    text='correction trial!';
else
    text=sprintf('duration: %g',stimulus.duration);
end

end % end function