window=Screen('OpenWindow',0);
%Screen('TextSize',window,11);
%[normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');
Screen('DrawText',window,'hello',100,100);
Screen('Flip',window);
KbWait;
sca