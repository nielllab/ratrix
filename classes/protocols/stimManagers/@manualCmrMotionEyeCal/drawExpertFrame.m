function [doFramePulse expertCache dynamicDetails textLabel i dontclear indexPulse] = ...
    drawExpertFrame(stimulus,stim,i,phaseStartTime,window,textLabel,destRect,filtMode,...
    expertCache,ifi,scheduledFrameNum,dropFrames,dontclear)
% 10/31/08 - implementing expert mode for whiteNoise
% this function calculates a expert frame, and then makes and draws the texture; nothing needs to be done in runRealTimeLoop
% this should be a stimManager-specific implementation (if expert mode is supported for the given stimulus)
indexPulse=false;

numSweepsToDo=1;

% increment i
if dropFrames
    i=scheduledFrameNum;
else
    i=i+1;
end
% stimulus = stimManager
doFramePulse=true;
dynamicDetails=[];
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
% here are the values as a faked LUT
stateValues={'initialize','move camera to A','recording at A','move camera to B','recording at B','done'};
stateTransitionValues=[2 3 4 5 2 1];
stateDurationValues=[10 10 5 10 5 10]; % in seconds
if isempty(expertCache)
    expertCache.state='initialize';
    expertCache.startTimeOfCurrentPosition=GetSecs;
    expertCache.numSweepsDone=0;
end
elapsed=GetSecs-expertCache.startTimeOfCurrentPosition;
ind=find(strcmp(expertCache.state,stateValues));
if elapsed>=stateDurationValues(ind)
    if strcmp(expertCache.state,'recording at B')
        expertCache.numSweepsDone=expertCache.numSweepsDone+1;
    elseif strcmp(expertCache.state,'done')
        expertCache.numSweepsDone=0;
    end
    if expertCache.numSweepsDone==numSweepsToDo
        expertCache.state='done';
    else
        expertCache.state=stateValues{stateTransitionValues(ind)};
    end
    elapsed=0;
    ind=find(strcmp(expertCache.state,stateValues));
    expertCache.startTimeOfCurrentPosition=GetSecs;
end

% show appropriate text
txt=sprintf('%1.0f seconds have elapsed (%1.0f remaining) in state %s',elapsed,stateDurationValues(ind)-elapsed,expertCache.state);
Screen('DrawText',window,txt,xTextPos,yTextPos,100*ones(1,3));

end % end function