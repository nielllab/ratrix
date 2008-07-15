Screen('Preference', 'SkipSyncTests',1);
screenNum=max(Screen('Screens'))
[oldClut, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenNum)
[window winRect]=Screen('OpenWindow',screenNum)
vals=fliplr([0 1 2 3 253 254 255 256 257 258 259 260]);
for i=1:length(vals)
    t(i)=Screen('MakeTexture',window,ones(1,1,3)*vals(i))
end
Screen('PreloadTextures',window)
i=1;
while 1
    vals(i)
    Screen('DrawTexture',window,t(i),winRect)
    Screen('DrawTexture',window,t(1),winRect/2)
    Screen('DrawDots',window,[500 500],50,ones(3,1)*vals(i))
    Screen('DrawingFinished',window)
    Screen('Flip',window)
    i=i+1;
    if i>length(vals)
        i=1;
    end
    pause
end

