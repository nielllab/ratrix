% phase (quittable,pauseable,manualable, ends on a condition) -- intersession,reward,penalty,final
%         -methods: doOneFrame, getInput(keys and pokes)

function responseDetails = run(p)

logwrite(sprintf('entered phase %s',phase));

%set some global options
dontclear = 2; %2 saves time by not reinitializing the framebuffer -- safe for us cuz we're redrawing everything
%               don't understand difference between setting this to 1 vs. 2.  if 2 gives blue flashing (breaks on old gfx hardware), try 1?

filtMode = 0;               %How to compute the pixel color values when the texture is drawn scaled
%                           %0 = Nearest neighbour filtering, 1 = Bilinear filtering (default, and BAD)

verbose = 1;


%set a bunch of state
done=0;

quit=false;

% attempt=0;

% i=0;

responseDetails.numMisses=0;
responseDetails.misses=[];
responseDetails.afterMissTimes=[];

responseDetails.numApparentMisses=0;
responseDetails.apparentMisses=[];
responseDetails.afterApparentMissTimes=[];
responseDetails.apparentMissIFIs=[];
responseDetails.numFramesUntilStopSavingMisses=numFramesUntilStopSavingMisses;
responseDetails.numUnsavedMisses=0;
responseDetails.nominalIFI=ifi;

frameNum=1;

% logIt=0;
% stopListening=0;
% lookForChange=0;
player=[];
currSound='';

ports=0*readPorts(station);
% lastPorts=0*readPorts(station);
% pressingM=0;
% pressingP=0;
% didAPause=0;
paused=0;
% doFramePulse=0;
% didPulse=0;
% didValves=0;
% didManual=0;
% requestFrame=0;  %used for timed frames stimuli

currentValveState=verifyValvesClosed(station);
valveErrorDetails=[];

xTextPos = 25;
yTextPos = 100;

oldFontSize = Screen('TextSize',window,25);

%show movie following mario's 'ProgrammingTips' for the OpenGL version of PTB
%http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html

logwrite('about to enter realtime stim loop');

lastI=1;
Screen('DrawTexture',tm.window, stim(lastI),[],destRect,[],filtMode);
Screen('DrawingFinished',tm.window,dontclear);
[vbl sos ft]=Screen('Flip',tm.window);
lastFrameTime=ft;

%any stimulus onset synched actions

startTime=GetSecs();

%show stim -- be careful in this realtime loop!
while ~done && ~quit
    logwrite('top of realtime stim loop');

    i=chooseFrame(p,state);



    if ~paused


        %draw to buffer
        if ~(i==lastI) || (dontclear==0) %only draw if texture different from last one, or if every flip is redrawn
            Screen('DrawTexture', tm.window, stim(i),[],destRect,[],filtMode);
        end
        lastI=i;

        %text commands are supposed to be last for performance reasons
        yNewTextPos=yTextPos;
        if labelFrames
            [garbage,yNewTextPos] = Screen('DrawText',window,['subject:' subID ' trialManager:' class(tm) ' stimManager:' stimID],xTextPos,yNewTextPos,100*ones(1,3));
        end
        [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');
        yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);

        if labelFrames
            [garbage,yNewTextPos] = Screen('DrawText',window,['priority:' num2str(Priority()) ' phase:' phase ' stim ind:' num2str(i) ' frame ind:' num2str(frameNum) ' isCorrection:' num2str(isCorrection)],xTextPos,yNewTextPos,100*ones(1,3));
            yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
        end

        if manual
            didManual=1;
            manTxt='on';
        else
            manTxt='off';
        end
        if didManual
            [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('trial record will indicate manual poking on this trial (k+m to toggle for next trial: %s)',manTxt),xTextPos,yNewTextPos,100*ones(1,3));
            yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
        end

        if didAPause
            [garbage,yNewTextPos] = Screen('DrawText',window,'trial record will indicate a pause occurred on this trial',xTextPos,yNewTextPos,100*ones(1,3));
            yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
        end
    else
        Screen('DrawText',window,'paused (k+p to toggle)',xTextPos,yNewTextPos,100*ones(1,3));
    end

    Screen('DrawingFinished',window,dontclear);    %indicate finished (enhances performance)
    when=vbl+(framesPerUpdate-0.5)*ifi;

    if ~paused && doFramePulse
        framePulse(station);
        framePulse(station);
    end

    logwrite('frame calculated, waiting for flip');

    %wait for next frame, flip buffer

    [vbl sos ft missed]=Screen('Flip',window,when,dontclear); %vbl=vertical blanking time, when flip starts executing
    %sos=stimulus onset time -- doc doesn't clarify what this is
    %ft=timestamp from the end of flip's execution

    logwrite('just flipped');

    if ~paused
        if doFramePulse
            framePulse(station);
        end
    end

    %save facts about missed frames
    if missed>0 && frameNum<responseDetails.numFramesUntilStopSavingMisses
        disp(sprintf('warning: missed frame num %d',frameNum));
        responseDetails.numMisses=responseDetails.numMisses+1;
        responseDetails.misses(responseDetails.numMisses)=frameNum;
        responseDetails.afterMissTimes(responseDetails.numMisses)=GetSecs();
    else
        thisIFI=ft-lastFrameTime;
        thisIFIErrorPct = abs(1-thisIFI/ifi);
        if  thisIFIErrorPct > timingCheckPct
            disp(sprintf('warning: flip missed a timing and appeared not to notice: frame num %d, ifi error: %g',frameNum,thisIFIErrorPct));
            responseDetails.numApparentMisses=responseDetails.numApparentMisses+1;
            responseDetails.apparentMisses(responseDetails.numApparentMisses)=frameNum;
            responseDetails.afterApparentMissTimes(responseDetails.numApparentMisses)=GetSecs();
            responseDetails.apparentMissIFIs(responseDetails.numApparentMisses)=thisIFI;
        end
    end
    lastFrameTime=ft;

    if missed>0 && frameNum>=responseDetails.numFramesUntilStopSavingMisses
        responseDetails.numMisses=responseDetails.numMisses+1;
        responseDetails.numUnsavedMisses=responseDetails.numUnsavedMisses+1;
    end

    if ~paused
        logwrite('entering trial logic');
        %all trial logic here
        state=calcState(p,i,state);

        frameNum=frameNum+1;

        logwrite(sprintf('advancing to frame: %d',frameNum));

    end

    logwrite('end of realtime stim loop');
end
logwrite('realtime loop complete');
currentValveState=verifyValvesClosed(station);

tm.soundMgr = playLoop(tm.soundMgr,'',station,0);

responseDetails.totalFrames=frameNum;
responseDetails.startTime=startTime;
responseDetails.valveErrorDetails=valveErrorDetails;

end