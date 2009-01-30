function [vbl sos ft lastFrameTime lastI] = drawFirstFrame(tm, window, standardFontSize, texture, lengthOfStim, destRect, filtMode, dontclear)
% This function draws the intertrial period texture (finalScreenLuminance) at the beginning of the stimOGL real-time loop.
% Part of stimOGL rewrite.
% INPUT: window, standardFontSize, texture, lengthOfStim, destRect, filtMode, dontclear
% OUTPUT: vbl, sos, ft, lastFrameTime, lastI

error('no one calls')

sos=[];
ft=[];
lastI=[];

if window >= 0
    oldFontSize = Screen('TextSize',window,standardFontSize);
    Screen('Preference', 'TextRenderer', 0);  % consider moving to PTB setup

    Screen('DrawTexture', window, texture,[],destRect,[],filtMode); %should replace this with new stim architecture
    Screen('DrawingFinished',window,dontclear);
    [vbl sos ft]=Screen('Flip',window);
    lastFrameTime=ft;
    lastI=lengthOfStim+1;
else
    vbl=GetSecs();
    lastFrameTime=vbl;
end

end %end function