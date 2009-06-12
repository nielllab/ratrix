function [doFramePulse expertCache dynamicDetails textLabel i dontclear indexPulse] = ...
    drawExpertFrame(stimulus,stim,i,phaseStartTime,totalFrameNum,window,textLabel,destRect,filtMode,...
    expertCache,ifi,scheduledFrameNum,dropFrames,dontclear,dynamicDetails)
% 10/31/08 - implementing expert mode for whiteNoise
% this function calculates a expert frame, and then makes and draws the texture; nothing needs to be done in runRealTimeLoop
% this should be a stimManager-specific implementation (if expert mode is supported for the given stimulus)
indexPulse=false;
floatprecision=1;

%initialize first frame
if scheduledFrameNum==1 || i<2
    if stimulus.changeable
        %start with mouse in the center
        [a,b]=WindowCenter(window);
        SetMouse(a,b,window);
        expertCache.positionShift=[0 0];
    end
end

% increment i
if dropFrames
    i=scheduledFrameNum;
else
    i=i+1;
end
% stimulus = stimManager
doFramePulse=true;
% ================================================================================

% start calculating frames now
stimLocation = stimulus.requestedStimLocation;
if stimulus.changeable
    [mouseX, mouseY, buttons]=GetMouse(window);
    if buttons(1) % right click if you want to update the position... only persists this trial!
        [a,b]=WindowCenter(window);
        %shift stimulus away from predefined location by the amount that the mouse is away from center
        expertCache.positionShift=[mouseX-a mouseY-b];
        stimLocation=stimLocation+expertCache.positionShift([1 2 1 2]);

        %only send dynamic details on frames that change positions by mouse down
        dynamicDetails.stimLocation=stimLocation;
        dynamicDetails.sendDuringRealtimeloop=true;
    else
        %sustain the moved stim location regardless of mouse down
        stimLocation=stimLocation+expertCache.positionShift([1 2 1 2]);
    end

end

% set randn/rand to the current frame's precalculated seed value -- 
% make this a method so its always in sync with analysis ... save sha1?
switch stimulus.distribution.type
    case 'gaussian'
        meanLuminance = stimulus.distribution.meanLuminance;
        std = stimulus.distribution.std;
        randn('state',stim.seedValues(i));
        expertFrame = randn(stimulus.spatialDim([2 1]))*1*std+meanLuminance;
        expertFrame(expertFrame<0) = 0;
        expertFrame(expertFrame>1) = 1;
    case 'binary'
        rand('state',stim.seedValues(i));
        lumDiff=stimulus.distribution.hiVal-stimulus.distribution.lowVal;
        expertFrame = stimulus.distribution.lowVal+(double(rand(stimulus.spatialDim([2 1]))<stimulus.distribution.probability)*lumDiff);
    otherwise
        error('bad type')
end

%background
Screen('FillRect', window, stimulus.background*WhiteIndex(window));
% 11/14/08 - moved the make and draw to stimManager specific getexpertFrame b/c they might draw differently
dynTex = Screen('MakeTexture', window, expertFrame,0,0,floatprecision);
Screen('DrawTexture', window, dynTex,[],stimLocation,[],filtMode);
% clear dynTex from vram
Screen('Close',dynTex);

end % end function