function screenTimingTest
clc
HideCursor;
ListenChar(2);
FlushEvents('keyDown');
KbCheck;
KbName('UnifyKeyNames');

dontclear=0;
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebugLevel', 6);
Screen('Preference', 'SuppressAllWarnings', 0);
Screen('Preference', 'Verbosity', 10); %4 is highest useful for end users
Screen('Preference', 'VBLTimestampingMode', 2); %see help beampositionqueries

w =Screen('OpenWindow',max(Screen('Screens')));

t=floor(255*rand(400));
n=Screen('MakeTexture', w, t);
Screen('PreloadTextures', w);

frameNum=0;
drops=0;
quit=false;
errorPcts=zeros(999999,3);

Priority(MaxPriority(w,'GetSecs','KbCheck'));

ifi=Screen('GetFlipInterval', w);

[vbl sos lastFT]=Screen('Flip', w);
lastVbl=vbl;
startTime=vbl;
while ~quit
    frameNum=1+frameNum;
    Screen('DrawTexture', w, n);
    Screen('DrawText',w,sprintf('priority:%g',Priority),100,100);
    Screen('DrawingFinished',w,dontclear);
    [vbl sos ft missed] = Screen('Flip', w, vbl + 0.5 * ifi,dontclear);

    if missed>0
        drops=drops+1;
        disp(sprintf('drop %d: frame %d at %g',drops,frameNum,GetSecs-startTime));
    end

    errorPcts(frameNum,1) = ((vbl-lastVbl)/ifi)-1;
    lastVbl=vbl;
    errorPcts(frameNum,2) = ((ft-lastFT)/ifi)-1;
    lastFT=ft;
    errorPcts(frameNum,3) = GetSecs;

    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown
        keys=find(keyCode);
        for keyNum=1:length(keys)
            if strcmp(KbName(keys(keyNum)),'q');
                quit=true;
            end
        end
    end
end
Screen('CloseAll');
Priority(0);
ShowCursor
ListenChar(0)
errorPcts(:,3)=[(diff(errorPcts(:,3))/ifi)-1 ; 0];
plot(errorPcts(1:frameNum-1,:));