function [out type startFrame scale numFrames] = correctStim(sm,numFrames,ifi,tm)
%would really like to add flexibility here to do something like blink the
%stim in synchrony with some beeps

%also, we'd rather have the option here to reuse textures already loaded
%onto the gpu back before the trial started, if we don't want to do something based on
%what actually happened in the trial

switch class(tm)
    case 'nAFC'
        dur =   getReinfAssocSecs(sm);
        if dur>0
            out        = getStim       (sm.correctStim);
        type       = getStimType   (sm.correctStim);
        startFrame = getStartFrame (sm.correctStim);
        scale      = getScaleFactor(sm.correctStim);
        numFrames  = ceil(getReinfAssocSecs(sm)/ifi);
        else
                  out        = double(getInterTrialLuminance(sm));
        type       = 'static';
        startFrame = 1;
        scale      = 0;
        end
    otherwise %old way
        out        = double(getInterTrialLuminance(sm));
        type       = 'static';
        startFrame = 1;
        scale      = 0;
end