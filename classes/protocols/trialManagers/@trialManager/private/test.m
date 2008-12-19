%any of the following will cause frame drops (just on entering new code blocks) on the first subsequent run, but not runs thereafter:
%clear java, clear classes, clear all, clear mex (NOT clear Screen)
%each of these causes the code to be reinterpreted
%note that this is what setupenvironment does!

function test
clc

bits=8;

requestOptions=logical([0 1 0]);
responseOptions=logical([1 0 1]);

stim=rand(50,50,100);
if false
    stim=uint8(floor(2^bits*stim)); interTrialLuminance=uint8((2^bits)/2); floatprecision=0;
else
    interTrialLuminance=.5; floatprecision=1;
end

filtMode = 0;
dontclear = 0;
timingCheckPct = .1;

LUT=repmat(linspace(0,1,2^bits)',1,3);

frameDropCorner.size=[.05 .05];
frameDropCorner.loc=[1 0];
frameDropCorner.ind=1;
frameDropCorner.seq=linspace(1,0,size(LUT,1));
frameDropCorner.on=true;

clear Screen;
clear PsychPortAudio;

sampRate=44100;
InitializePsychSound(1);
player= PsychPortAudio('Open',[],[],4,sampRate,2);
PsychPortAudio('FillBuffer', player, rand(2,sampRate)-.5);

try
    AssertOpenGL;
    Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'VisualDebugLevel', 6);
    Screen('Preference', 'SuppressAllWarnings', 0);
    Screen('Preference', 'Verbosity', 4);

    window = Screen('OpenWindow',max(Screen('Screens')));
    ifi = Screen('GetFlipInterval',window);

    ListenChar(2);
    FlushEvents('keyDown');

    Screen('LoadNormalizedGammaTable', window, LUT,0);

    [scrWidth scrHeight]=Screen('WindowSize', window);

    scaleFactor = [scrHeight scrWidth]./[size(stim,1) size(stim,2)];

    height = scaleFactor(1)*size(stim,1);
    width = scaleFactor(2)*size(stim,2);

    scrRect = Screen('Rect', window);
    scrLeft = scrRect(1);
    scrTop = scrRect(2);
    scrRight = scrRect(3);
    scrBottom = scrRect(4);
    scrWidth= scrRight-scrLeft;
    scrHeight=scrBottom-scrTop;

    destRect = round([(scrWidth/2)-(width/2) (scrHeight/2)-(height/2) (scrWidth/2)+(width/2) (scrHeight/2)+(height/2)]); %[left top right bottom]

    frameDropCorner.left  =scrLeft               + scrWidth *(frameDropCorner.loc(2) - frameDropCorner.size(2)/2);
    frameDropCorner.right =frameDropCorner.left  + scrWidth *frameDropCorner.size(2);
    frameDropCorner.top   =scrTop                + scrHeight*(frameDropCorner.loc(1) - frameDropCorner.size(1)/2);
    frameDropCorner.bottom=frameDropCorner.top   + scrHeight*frameDropCorner.size(1);
    frameDropCorner.rect=[frameDropCorner.left frameDropCorner.top frameDropCorner.right frameDropCorner.bottom];

    textures=zeros(1,size(stim,3));
    for i=1:size(stim,3)
        textures(i)=Screen('MakeTexture', window, squeeze(stim(:,:,i)),0,0,floatprecision);
    end
    textures(size(stim,3)+1)=Screen('MakeTexture', window, interTrialLuminance,0,0,floatprecision);

    [resident texidresident] = Screen('PreloadTextures', window);
    if resident ~= 1
        disp(sprintf('error: some textures not cached'));
        find(texidresident~=1)
    end

    [keyIsDown,secs,keyCode]=KbCheck; %load mex files into ram + preallocate return vars
    GetSecs;

    %KbName('UnifyKeyNames'); %does not appear to choose keynamesosx on windows - KbName('KeyNamesOSX') comes back wrong
    allKeys=KbName('KeyNames');
    allKeys=lower(cellfun(@char,allKeys,'UniformOutput',false));
    asciiOne=double('1');
    portKeys={};
    for i=1:length(responseOptions)
        portKeys{i}=find(strncmp(char(asciiOne+i-1),allKeys,1));
    end

    %preallocate vars that appear in the realtime loop
    attempt=0;
    done=0;
    i=0;

    frameNum=1;

    stimStarted=isempty(requestOptions);
    logIt=0;
    stopListening=0;
    lookForChange=0;

    ports=zeros(1,length(responseOptions));
    lastPorts=ports;

    requestFrame=0;

    lastFrameTime=0;
    lastLoopEnd=0;
    startTime=0;
    vbl=0;
    sos=0;
    when=0;
    whenTime=0;
    ft=0;
    missed=0;
    thisIFI=0;
    thisIFIErrorPct = 0;

    pNum=0;

    time1=0;
    time2=0;
    time3=0;
    time4=0;
    time5=0;
    soundTime=0;
    maxSoundTime=0.002;
    playing=false;

    priorityLevel=MaxPriority(window,'GetSecs','KbCheck');
    Priority(priorityLevel);

    Screen('DrawTexture', window, textures(size(stim,3)+1),[],destRect,[],filtMode);
    [vbl sos startTime]=Screen('Flip',window);

    lastFrameTime=vbl;
    lastLoopEnd=startTime;

    %the realtime loop
    while ~done
        time1=GetSecs;

        if stimStarted
            i = mod(i,size(stim,3)-1)+1;
            Screen('DrawTexture', window, textures(i),[],destRect,[],filtMode);
        else
            Screen('DrawTexture', window, textures(size(stim,3)+1),[],destRect,[],filtMode);
        end
        time2=GetSecs;

        if frameDropCorner.on
            Screen('FillRect', window, round(size(LUT,1)*frameDropCorner.seq(frameDropCorner.ind)), frameDropCorner.rect);

            frameDropCorner.ind=frameDropCorner.ind+1;
            if frameDropCorner.ind>length(frameDropCorner.seq)
                frameDropCorner.ind=1;
            end
        end

        time3=GetSecs;

        Screen('DrawingFinished',window,dontclear);

        time4=GetSecs;
        when=vbl+0.5*ifi;
        whenTime=GetSecs;

        time5=GetSecs;

        [vbl sos ft missed]=Screen('Flip',window,when,dontclear);
        if ft-vbl>.3*ifi
            %this occurs when my osx laptop runs on battery power
            fprintf('long delay inside flip after the swap-- ft-vbl:%.15g%% of ifi, now-vbl:%.15g\n',(ft-vbl)/ifi,GetSecs-vbl)
        end

        if missed>0
            fprintf('missed frame num %d (when=%.15g at %.15g, lastLoopEnd=%.15g, when-last=%.15g [%.15g %.15g %.15g %.15g %.15g])\n',frameNum,when,whenTime,lastLoopEnd,when-lastFrameTime,time1-lastLoopEnd,time2-time1,time3-time2,time4-time3,time5-time4);
        else
            thisIFI=vbl-lastFrameTime;
            thisIFIErrorPct = abs(1-thisIFI/ifi);
            if  thisIFIErrorPct > timingCheckPct
                %seems to happen when thisIFI/ifi is near a whole number
                fprintf('flip missed a timing and appeared not to notice: frame num %d, ifi pct: %g%% (when=%.15g at %.15g, lastLoopEnd=%.15g, when-last=%.15g [%.15g %.15g %.15g %.15g %.15g])\n',frameNum,100*thisIFI/ifi,when,whenTime,lastLoopEnd,when-lastFrameTime,time1-lastLoopEnd,time2-time1,time3-time2,time4-time3,time5-time4);
            end
        end
        lastFrameTime=vbl;

        %all trial logic follows

        [keyIsDown,secs,keyCode]=KbCheck;
        ports=zeros(1,length(portKeys));
        for pNum=1:length(portKeys)
            ports(pNum)=any(keyCode(portKeys{pNum}));
        end

        %subject is finishing up an attempt
        if lookForChange && any(ports~=lastPorts)
            lookForChange=0;
            fprintf('off\n')

            if playing
                soundTime=GetSecs;
                PsychPortAudio('Stop', player);
                soundTime=GetSecs-soundTime;
                if soundTime>maxSoundTime
                    fprintf('%g to ppa(stop)\n',soundTime)
                end
                playing=false;
            end
        end

        %subject is requesting the stim
        if any(ports(requestOptions))
            if ~stimStarted
                requestFrame=frameNum;
            end
            stimStarted=1;

            if ~playing
                soundTime=GetSecs;
                PsychPortAudio('Start', player, 0);
                soundTime=GetSecs-soundTime;
                if soundTime>maxSoundTime
                    fprintf('%g to ppa(start)\n',soundTime)
                end
                playing=true;
            end

            if ~lookForChange
                logIt=1;
            end
            stopListening=1;
        end

        %subject gave a well defined response
        if any(ports(responseOptions)) && stimStarted
            done=1;
            logIt=1;
            stopListening=1;
        end

        %subject gave a response that is neither a stimulus request nor a well defined response
        if any(ports) && ~stopListening

            if ~playing
                soundTime=GetSecs;
                PsychPortAudio('Start', player, 0);
                soundTime=GetSecs-soundTime;
                if soundTime>maxSoundTime
                    fprintf('%g to ppa(start)\n',soundTime)
                end
                playing=true;
            end

            if (attempt==0 || any(ports~=lastPorts))
                logIt=1;
            end
        end
        stopListening=0;

        if logIt
            disp(ports)
            attempt=attempt+1;
            lookForChange=1;
            logIt=0;
        end

        lastPorts=ports;
        frameNum=frameNum+1;

        lastLoopEnd=GetSecs;
    end

    Screen('Close');
    ListenChar(0);
    Screen('CloseAll');
    PsychPortAudio('Close');
    Priority(0);
catch ex
    ListenChar(0);
    Screen('CloseAll');
    PsychPortAudio('Close');
    Priority(0);
    ple(ex)
end