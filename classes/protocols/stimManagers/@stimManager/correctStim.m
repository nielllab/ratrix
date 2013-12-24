function [out type startFrame scale numFrames] = correctStim(sm,numFrames,ifi,tm,lastFrame)
%would really like to add flexibility here to do something like blink the
%stim in synchrony with some beeps

%also, we'd rather have the option here to reuse textures already loaded
%onto the gpu back before the trial started, if we don't want to do something based on
%what actually happened in the trial

dur = getReinfAssocSecs(sm);

if dur > 0 % && strcmp(class(tm),'nAFC')
    out        = getStim       (sm.correctStim);
    type       = getStimType   (sm.correctStim);
    startFrame = lastFrame;    
    scale      = getScaleFactor(sm.correctStim);
    numFrames  = ceil(dur/ifi);
    
    %consider adding an itl at the end so that the last stim frame doesn't
    %stay up during indefinitely long calculation of next trial
    
else %old way
    out        = double(getInterTrialLuminance(sm));
    type       = 'static';
    startFrame = 1;
    scale      = 0;
end