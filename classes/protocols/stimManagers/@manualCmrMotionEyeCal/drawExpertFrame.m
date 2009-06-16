function [doFramePulse expertCache dynamicDetails textLabel i dontclear indexPulse] = ...
    drawExpertFrame(stimulus,stim,i,phaseStartTime,totalFrameNum,window,textLabel,destRect,filtMode,...
    expertCache,ifi,scheduledFrameNum,dropFrames,dontclear,dynamicDetails)
% 10/31/08 - implementing expert mode for whiteNoise
% this function calculates a expert frame, and then makes and draws the texture; nothing needs to be done in runRealTimeLoop
% this should be a stimManager-specific implementation (if expert mode is supported for the given stimulus)
indexPulse=false;

numSweepsToDo=stimulus.numSweeps;

% increment i
if dropFrames
    i=scheduledFrameNum;
else
    i=i+1;
end
% stimulus = stimManager
doFramePulse=true;

if isempty(dynamicDetails)
    dynamicDetails.recordingIntervalsA=[];
    dynamicDetails.recordingIntervalsB=[];
end
Asize=size(dynamicDetails.recordingIntervalsA,1);
Bsize=size(dynamicDetails.recordingIntervalsB,1);
% ================================================================================

%background
Screen('FillRect', window, stimulus.background*WhiteIndex(window));
% % 11/14/08 - moved the make and draw to stimManager specific getexpertFrame b/c they might draw differently
% % dynTex = Screen('MakeTexture', window, expertFrame,0,0,floatprecision);
% % Screen('DrawTexture', window, dynTex,[],stimLocation,[],filtMode);
% % % clear dynTex from vram
% % Screen('Close',dynTex);

% text options
xTextPos=25;
yTextPos=55;

% calculate the stim logic (what camera position, init, move camera, etc)
% currently allowed states:
%   'initialize'
%   'move camera to A'
%   'recording at A'
%   'move camera to B'
%   'recording at B'
%   'done'

if isempty(expertCache)
    expertCache.state='initialize';
    expertCache.startFrameOfCurrentPosition=totalFrameNum;
    expertCache.numSweepsDone=0;
end
elapsedFrames=totalFrameNum-expertCache.startFrameOfCurrentPosition;
elapsed=elapsedFrames*ifi;
ind=find(strcmp(expertCache.state,stimulus.stateValues));

% check for transition to next state
if elapsed>=stimulus.stateDurationValues(ind)
    if strcmp(expertCache.state,'recording at B')
        % end of a recording interval at B
        dynamicDetails.recordingIntervalsB(Bsize,2)=totalFrameNum-1;
        expertCache.numSweepsDone=expertCache.numSweepsDone+1;
    elseif strcmp(expertCache.state,'recording at A')
        dynamicDetails.recordingIntervalsA(Asize,2)=totalFrameNum-1;
    elseif strcmp(expertCache.state,'done')
        expertCache.numSweepsDone=0;
    end
    if expertCache.numSweepsDone==numSweepsToDo
        expertCache.state='done';
    else
        expertCache.state=stimulus.stateValues{stimulus.stateTransitionValues(ind)};
    end
    elapsed=0;
    ind=find(strcmp(expertCache.state,stimulus.stateValues));
    expertCache.startFrameOfCurrentPosition=totalFrameNum;
end

% logic for storing recording intervals (in terms of frame indices -> eyeDataStimInds)
if expertCache.startFrameOfCurrentPosition==totalFrameNum % that means this frame is the first of a new position
    if strcmp(expertCache.state,'recording at A')
        dynamicDetails.recordingIntervalsA(Asize+1,1)=totalFrameNum;
    elseif strcmp(expertCache.state,'recording at B')
        dynamicDetails.recordingIntervalsB(Bsize+1,1)=totalFrameNum;
    end
end

% show appropriate text
txt=sprintf('%d frames have elapsed (%d remaining) in state %s totalFrameNum:%d',...
    elapsedFrames,floor((stimulus.stateDurationValues(ind)-elapsed)/ifi),expertCache.state,totalFrameNum);
Screen('DrawText',window,txt,xTextPos,yTextPos,100*ones(1,3));
yTextPos=yTextPos+15;
txt=sprintf('numSweepsDone: %d/%d',expertCache.numSweepsDone,numSweepsToDo);
Screen('DrawText',window,txt,xTextPos,yTextPos,100*ones(1,3));

end % end function