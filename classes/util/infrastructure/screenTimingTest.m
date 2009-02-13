function screenTimingTest
clc
close all

logDir=sprintf('%s.logs',mfilename);
warning('off','MATLAB:MKDIR:DirectoryExists')
mkdir(logDir);
warning('on','MATLAB:MKDIR:DirectoryExists')
dstr=datestr(now,30);
diary(fullfile(logDir,sprintf('%s.%s.log',mfilename,dstr)));
graphName=fullfile(logDir,sprintf('%s.%s.png',mfilename,dstr));

scrNum=max(Screen('Screens'));

if IsWin
    Screen('Resolution',scrNum,1024,768,100,32);
end

HideCursor;
ListenChar(2); %if located in try block, all keystrokes dumped to screen at end?
FlushEvents('keyDown');

floatprecision = 1;
filtMode = 0;
dontclear = 0;

timingCheckPct = .02;

sampRate=44100;
latclass=1;
buffsize=1250;

InitializePsychSound(1); %argument seems to do nothing

tryAgainSound=1;
requestSound=2;
responseSound=3;
errorSound=4;

soundDur=.5;
freq=110;
sounds{tryAgainSound}=rand(1,ceil(sampRate*soundDur));
sounds{requestSound} =sin((4/3)*freq*2*pi*(0:ceil(sampRate*soundDur))/sampRate)>0;
sounds{responseSound}=sin(    2*freq*2*pi*(0:ceil(sampRate*soundDur))/sampRate)>0;
sounds{errorSound}   =sin(      freq*2*pi*(0:ceil(sampRate*soundDur))/sampRate)>0;

    function playing=stopAllSounds
        for j=1:length(sounds)
            PsychPortAudio('Stop', players{j},2,0);
        end
        playing=[];
    end

for i=1:length(sounds)
    players{i}= PsychPortAudio('Open',[],[],latclass,sampRate,2,buffsize);
    PsychPortAudio('FillBuffer', players{i}, 2*(repmat(sounds{i},2,1)-.5));
    PsychPortAudio('RunMode', players{i}, 1);
end
PsychPortAudio('Verbosity' ,1);

requestOptions=logical([0 1 0]);
responseOptions=logical([1 0 1]);

try
    AssertOpenGL;
    Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'VisualDebugLevel', 6);
    Screen('Preference', 'SuppressAllWarnings', 0);
    Screen('Preference', 'Verbosity', 4);
    % Screen('Preference', 'VBLTimestampingMode', 2); %see help beampositionqueries

    window = Screen('OpenWindow',scrNum);
    ifi = Screen('GetFlipInterval',window);

    Screen('Preference', 'TextRenderer', 0); %if text drawing comes before this stuff on windows, subsequent text will not appear until restart screen...
    Screen('Preference', 'TextAlphaBlending',0);
    Screen('Preference', 'TextAntiAliasing', 0);
    [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');

    numHrs=.03; %if > ~.05, make textures on the fly, otherwise drawtexture has to swap VRAM with system memory and is slow
    dims=50;
    records=nan*zeros(1,round(1/ifi)*60*60*numHrs);
    recordNum=0;

    stim=rand(dims,dims,round(numHrs*60*60/ifi));
    interTrialLuminance = .5;

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

    textures=zeros(1,size(stim,3));
    lastSecs=0;
    for i=1:size(stim,3)
        textures(i)=Screen('MakeTexture', window, squeeze(stim(:,:,i)),0,0,floatprecision);
        if GetSecs-lastSecs>.5
            Screen('DrawText',window,sprintf('%d of %d textures made (%g%%)',i,size(stim,3),100*i/size(stim,3)),100,100);
            Screen('Flip',window);
            lastSecs=GetSecs;
        end
    end
    textures(size(stim,3)+1)=Screen('MakeTexture', window, interTrialLuminance,0,0,floatprecision);

    Screen('DrawText',window,'preloading textures',100,100);
    Screen('Flip',window);

    [resident texidresident] = Screen('PreloadTextures', window); %takes forever if lots of textures, can crash osx
    if resident ~= 1
        disp(sprintf('error: some textures not cached'));
        find(texidresident~=1)
    end

    Screen('DrawText',window,'textures preloaded',100,100);
    Screen('Flip',window);

    [keyIsDown,secs,keyCode]=KbCheck; %load mex files into ram + preallocate return vars
    GetSecs;

    priorityLevel=MaxPriority(window,'GetSecs','KbCheck');
    Priority(priorityLevel);

    %KbName('UnifyKeyNames'); %does not appear to choose keynamesosx on windows - KbName('KeyNamesOSX') comes back wrong
    allKeys=KbName('KeyNames');
    allKeys=lower(cellfun(@char,allKeys,'UniformOutput',false));
    asciiOne=double('1');
    portKeys=[];
    for i=1:length(responseOptions)
        portKeys(i)=find(strncmp(char(asciiOne+i-1),allKeys,1),1);
    end
    qKey=find(strcmpi(allKeys,'q'),1);

    rqStr='';
    rqs=find(requestOptions);
    for i=1:length(rqs)
        rqStr=[rqStr ' ' num2str(rqs(i))];
    end

    rspStr='';
    rsps=find(responseOptions);
    for i=1:length(rsps)
        rspStr=[rspStr ' ' num2str(rsps(i))];
    end

    doText=IsWin;
    yTxtPos=100;
    xTxtPos=100;
    txtCol=1;

    numDrops=0;
    numUncaughtDrops=0;
    trialNum=0;

    diffs=[];
    theseDiffs=[];

    stars='';
    limit=.5;
    theFlip='time in flip til vbl';
    timeLabels={...
        'last timing checked',...
        'last kbd checked',...
        'last attempt checked',...
        'last request checked',...
        'last response checked',...
        'last logic done',...
        'last logging done',...
        'bottom to top of loop',...
        'texture drawn',...
        'text drawn',...
        'drawing finished',...
        theFlip,...
        'remaining time in flip'...
        };

    flipInd=find(strcmp(theFlip,timeLabels));

    quit=false;
    while ~quit
        attempt=0;
        done=0;
        i=0;

        trialNum=trialNum+1;
        fprintf('trialNum: %g\n',trialNum)
        frameNum=1;

        stimStarted=isempty(find(requestOptions));
        logIt=0;
        stopListening=0;
        lookForChange=0;

        ports=zeros(1,length(responseOptions));
        lastPorts=ports;

        requestFrame=0;

        sos=0;
        when=0;
        missed=0;

        thisIFI=0;

        timestamps.lastVBL        =0;
        timestamps.bottomOfLoop   =0;
        timestamps.topOfLoop      =0;
        timestamps.textureDrawn   =0;
        timestamps.textDone       =0;
        timestamps.drawingFinished=0;
        timestamps.VBL            =0;
        timestamps.frameTime      =0;

        timestamps.timingChecked  =0;
        timestamps.kbChecked      =0;
        timestamps.attemptDone    =0;
        timestamps.requestDone    =0;
        timestamps.responseDone   =0;
        timestamps.logicDone      =0;
        timestamps.lastFrameTime  =0;

        pNum=0;

        playing=[];

        Screen('DrawTexture', window, textures(size(stim,3)+1),[],destRect,[],filtMode);
        [timestamps.lastVBL sos timestamps.bottomOfLoop]=Screen('Flip',window);

        timestamps.timingChecked=timestamps.bottomOfLoop;
        timestamps.kbChecked    =timestamps.bottomOfLoop;
        timestamps.attemptDone  =timestamps.bottomOfLoop;
        timestamps.requestDone  =timestamps.bottomOfLoop;
        timestamps.responseDone =timestamps.bottomOfLoop;
        timestamps.logicDone    =timestamps.bottomOfLoop;
        timestamps.lastFrameTime=timestamps.bottomOfLoop;

        %the realtime loop
        while ~done && ~quit
            timestamps.topOfLoop=GetSecs;

            if stimStarted
                i = mod(i,size(stim,3)-1)+1;
                Screen('DrawTexture', window, textures(i),[],destRect,[],filtMode);
            else
                Screen('DrawTexture', window, textures(size(stim,3)+1),[],destRect,[],filtMode);
            end
            timestamps.textureDrawn=GetSecs;

            if doText
                [newX newY]=Screen('DrawText',window,sprintf('trialNum:%g stimInd:%g frameNum:%g numDrops:%g(%g)',trialNum, i,frameNum,numDrops,numUncaughtDrops),xTxtPos,yTxtPos,txtCol);
                if ~isempty(rqStr)
                    [newX newY]=Screen('DrawText',window,sprintf('hit%s to start trial',rqStr),xTxtPos,newY+normBoundsRect(4),txtCol);
                end
                [newX newY]=Screen('DrawText',window,sprintf('hit one of [%s ] to respond',rspStr),xTxtPos,newY+normBoundsRect(4),txtCol);
                [newX newY]=Screen('DrawText',window,'hit q to quit',xTxtPos,newY+normBoundsRect(4),txtCol);
            end
            timestamps.textDone=GetSecs;

            Screen('DrawingFinished',window,dontclear);
            when=timestamps.lastVBL +0.2*ifi; %mario uses 0.5 here -- i get lots of drops if i use 0.8.  why aren't all 0<x<1 equivalent?
            timestamps.drawingFinished=GetSecs;

            [timestamps.VBL sos timestamps.frameTime missed]=Screen('Flip',window,when,dontclear);

            if timestamps.frameTime-timestamps.VBL>.3*ifi
                %this occurs when my osx laptop runs on battery power
                fprintf('frameNum %g: long delay inside flip after the swap-- ft-vbl:%g%% of ifi, now-vbl:%g\n',frameNum,100*(timestamps.frameTime-timestamps.VBL)/ifi,GetSecs-timestamps.VBL)
            end

            thisIFI = timestamps.VBL - timestamps.lastVBL;
            if missed>0 || abs(thisIFI/ifi-1)>timingCheckPct
                if missed>0
                    numDrops=numDrops+1;
                else
                    numUncaughtDrops=numUncaughtDrops+1;
                end

                fprintf('missed frame num %d: ifi:%g (%g%% late) caught=%d\n',frameNum,1000*thisIFI,100*(thisIFI/ifi-1),missed>0)

                times=1000*[ ...
                    timestamps.lastFrameTime,...
                    timestamps.timingChecked,...
                    timestamps.kbChecked,...
                    timestamps.attemptDone,...
                    timestamps.requestDone,...
                    timestamps.responseDone,...
                    timestamps.logicDone,...
                    timestamps.bottomOfLoop,...
                    timestamps.topOfLoop,...
                    timestamps.textureDrawn,...
                    timestamps.textDone,...
                    timestamps.drawingFinished,...
                    timestamps.VBL,...
                    timestamps.frameTime...
                    ];

                if isempty(diffs)
                    diffs=zeros(1,length(times)-1);
                end
                theseDiffs=diff(times);
                diffs=diffs+(theseDiffs>limit);

                for d=1:length(timeLabels)
                    if theseDiffs(d)>limit
                        stars='***';
                    else
                        stars='';
                    end
                    fprintf('\t%s%s:\t%g\n',stars,timeLabels{d},theseDiffs(d));
                end

                if ~length(theseDiffs)==d
                    error('bad theseDiffs')
                end
            end

            recordNum=recordNum+1;
            if recordNum<=length(records)
                records(recordNum)=1000*(timestamps.lastVBL + ifi - timestamps.drawingFinished);
            elseif recordNum==length(records)+1
                fprintf('got to end of records\n')
                %quit=true;
            end

            timestamps.lastVBL=timestamps.VBL;
            timestamps.lastFrameTime=timestamps.frameTime;
            timestamps.timingChecked=GetSecs;

            %all trial logic follows

            [keyIsDown,secs,keyCode]=KbCheck;
            ports=keyCode(portKeys);
            if keyCode(qKey)
                fprintf('got quit key\n')
                quit = true;
            end
            timestamps.kbChecked=GetSecs;

            %subject is finishing up an attempt
            if lookForChange && any(ports~=lastPorts)
                lookForChange=0;
                playing=stopAllSounds();
            end

            timestamps.attemptDone=GetSecs;

            %subject is requesting the stim
            if any(ports(requestOptions))
                if ~stimStarted
                    requestFrame=frameNum;
                end
                stimStarted=1;

                if ~ismember(requestSound,playing)
                    PsychPortAudio('Start', players{requestSound}, 0);
                    playing(end+1)=requestSound;
                end

                if ~lookForChange
                    logIt=1;
                end
                stopListening=1;
            end

            timestamps.requestDone=GetSecs;

            %subject gave a well defined response
            if any(ports(responseOptions)) && stimStarted
                done=1;
                logIt=1;
                stopListening=1;
                playing=stopAllSounds;
                if length(find(ports))==1
                    PsychPortAudio('Start', players{responseSound}, 1);
                    playing(end+1)=responseSound;
                else
                    PsychPortAudio('Start', players{errorSound}, 1);
                    playing(end+1)=errorSound;
                end
            end

            timestamps.responseDone=GetSecs;

            %subject gave a response that is neither a stimulus request nor a well defined response
            if any(ports) && ~stopListening

                if ~ismember(tryAgainSound,playing)
                    PsychPortAudio('Start', players{tryAgainSound}, 0);
                    playing(end+1)=tryAgainSound;
                end

                if (attempt==0 || any(ports~=lastPorts))
                    logIt=1;
                end
            end
            stopListening=0;

            timestamps.logicDone=GetSecs;

            if logIt
                disp(ports)
                attempt=attempt+1;
                lookForChange=1;
                logIt=0;
            end

            lastPorts=ports;
            frameNum=frameNum+1;

            timestamps.bottomOfLoop=GetSecs;
        end

        while ~isempty(playing) || KbCheck
            for pNum=1:length(playing)
                s=PsychPortAudio('GetStatus',players{playing(pNum)}); %after the first time we play a sound with reps set to 1, .Active stays *false* (first time it is true until the sound finishes)
                if ~s.Active
                    playing=setdiff(playing,playing(pNum));
                end
            end
            Screen('DrawText',window,sprintf('waiting for %d sounds to finish all all keys to be released',length(playing)),100,100);
            Screen('Flip',window);
        end
    end

    cleanup(window);
    fprintf('preparing graphs...\n')

    records=records(~isnan(records));
    if ~isempty(diffs)
        subplot(2,1,1)
    end
    hist(records,100)
    title('called flip with ms headroom')
    hold on
    plot(repmat(ifi*1000,1,2),[0 max(ylim)],'k')
    xlim([min(0,min(records)) max(max(records),1000*ifi*1.2)]);

    if ~isempty(diffs)
        subplot(2,1,2)
        inds=true(1,length(diffs));
        inds(flipInd)=false;
        bar(diffs(inds))
        title(sprintf('occurances > %g ms',limit))
        set(gca,'XTick',1:length(diffs)-1)
        set(gca,'XTickLabel',{timeLabels{inds}})
    end
    saveas(gcf,graphName);
catch ex
    cleanup(window);
    ple(ex)
end
end

function cleanup(window)
Screen('DrawText',window,'closing...',100,100);
Screen('Flip',window);
Screen('CloseAll');
PsychPortAudio('Close');
ListenChar(0);
ShowCursor;
Priority(0);
diary off
end