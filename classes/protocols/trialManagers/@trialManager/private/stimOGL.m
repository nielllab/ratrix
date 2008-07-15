function [quit response responseDetails didManual manual didAPause didValves didHumanResponse didStochasticResponse eyeData gaze station]=  stimOGL(tm, ...
    stim, audioStim, LUT, type, metaPixelSize, window, ifi, ...
    responseOptions, requestOptions, finalScreenLuminance, station, manual,allowQPM,timingCheckPct,noPulses,isCorrection,rn,subID,stimID,eyeTracker,doAirpuff)

%note: add a phase which is a movie during which the rat must lick the
%center port to earn n more frames of movie, and the movie has to end in
%order to respond...  (parameters for how much/often to reward that center
%lick and how many ms earned per lick)

%future plan:
% function [responseDetails ... %structure containing record of events that occurred during this trial
%     tm ...                  %the trialManager is returned in case its state updated
%     updateTM ...            %true iff the trialManager state should be persisted (costly remote operation) (what did i mean by remote?)
%     ] = stimOGL( ...
%     tm)                     %this trialManager

%trialManager data members that this method depends on:
% trialManager.station      %the station where this trial is running
% trialManager.window       %pointer to target PTB window (should already be open)
% trialManager.ifi          %inter-frame-interval for PTB window in seconds (measured when window was opened)
% trialManager.manualOn     %allow keyboard responses, quitting, pausing, rewarding, and manual poke indications
% trialManager.timingCheckPct       %percent of allowable frametime error before apparently dropped frame is reported
% trialManager.numFrameDropReports  %number of frame drops to keep detailed records of for this trial
% trialManager.percentCorrectionTrials      %probability that if this trial is incorrect that it will be repeated until correct
%                                            note this needs to be moved
%                                            here from wherever it currently is


%trialManger.stimDetails: a set of parameters stored on the trial manager that specifies everything about this trial
%             it is filled in (selectively overwritten) before every trial by a call to trialManager.calcStim()
%             a trial progresses through a fixed set of PHASES (SESSION->TRIAL->DISCRIMINANDUM->REINFORCEMENT->FINAL)
%             each PHASE has a stimSpec (and some additional phase-specific stuff) which defines the audio and video for that phase
%POSSIBLE FUTURE FEATURE: stimDetails is optinally modified after every frame by a call to trialManager.updateStimDetails()
%                         note, this makes it hard to save records


%stimSpec
% either 'dynamic', in which case stimManager/doDynamicPTBFrame(phaseID) is called on every frame (note this requires thinking about how to save history record), or:
% stimSpec.stimArray        %must be of same type (logical, uint8, single, or double) as and within range of extremeVals
% stimSpec.extremeVals      %[dimmestVal brightestVal] values that would appear in stimArray to specify luminance extremes
%                           note, the linear position of the stimArray
%                           value within the extremeVals is used to
%                           determine the corresponding CLUT entry (depends on CLUT length), which
%                           specifies the actual pixel value
% stimSpec.metaPixelSize    %[height width] in real pixels represented by each stimPixel ([] means scale to full screen)
% stimSpec.frameTimes       %list of integers > 0 for each page in stimArray, indicating number of frames to hold each page
%                            last entry can be 0 to hold it, otherwise the stim loops
% stimSpec.frameSounds      %list of sound names to play during each frame (this is in addition to fixed sounds, such as those caused by licks/pokes)


%trialManager.stimDetails
%   GENERAL
% stimDetails.CLUT                  %CLUT sets the (possibly nonlinear) stimSpec->videoDAC relationship, perhaps to compensate for the videoDAC->photometric CRT output relationship
%                                    see Screen('ReadNormalizedGammaTable'), Screen('LoadNormalizedGammaTable') for proper format (almost always 256 x 3 values from 0 to 1, which is 6k!)
%                                    note stations should store calibration DATA, not CLUTS, which should be COMPUTED (so that a dynamically chosen range of luminances can be linearized, for example)
%                                    would be nice to not save this for every trial!
% stimDetails.showScreenLabel       %print debugging info to screen (eg, rat ID, station ID, session ID, trial ID, isCorrectionTrial, frame number)
% stimDetails.displayText           %additional string to be printed to screen if allowed (eg, state information about this trial's discriminandum)
% stimDetails.responseOptions       %indices of target and distractor ports -- activity on these ports count as responses
% stimDetails.requestOptions        %indices of request ports -- activity on these ports count as requests
%   PHASE: SESSION
% stimDetails.interSessionStim      %stimSpec - non-loop, last frame is state of frame buffer between sessions
%                                    note inter-session stim probably won't be handled here, but in the doTrial loop
%   PHASE: TRIAL
% stimDetails.interTrialStim        %stimSpec - show this til first request (if interTrialStim or requestOptions is empty, go straight to discriminandumStim)
% stimDetails.maxInterTrialSecs     %end the session if this duration is exceeded with no requests (must be positive, or 0 means no limit)
%   PHASE: DISCRIMINANDUM
% stimDetails.discriminandumStim	%stimSpec - n stimSpecs, requests iterate through this list (can implment "toggle" as {discrim, blank})
% stimDetails.maxDiscriminandumSecs %end the trial if this duration is exceeded with no response (must be positive, or 0 means no limit)
% stimDetails.advanceOnRequestEnd   %true iff ending a request advances to the next item in discriminandumStim, otherwise advance occurs at next request ("toggle" vs. "maintain-poke-to-maintain-stim")
% stimDetails.loopDiscriminandum    %true iff should loop to beginning of discriminandumStim list after last item reached
%   PHASE: REINFORCEMENT
% stimDetails.rewardWaitStim        %stimSpec - stim while waiting in reward queue
% stimDetails.maxRewardLatencySecs  %forgo the reward if the latency gets above this maximum (must be positive, or 0 means no limit)
% stimDetails.rewardStim            %stimSpec - stim while reward is delivered (reward size determined by call to getRewardSize(history))
% stimDetails.penaltyStim           %stimSpec - stim after an incorrect (length determined by call to getPenaltyDuration(history))
%   PHASE: FINAL
% stimDetails.finalStim             %stimSpec - non-loop, last frame is final state of frame buffer


%responseDetails includes:
% responseDetails.response
% responseDetails.containedManualPokes      %didManual
% responseDetails.leftWithManualPokingOn	%manual
% responseDetails.containedAPause           %didAPause
% responseDetails.containedForcedRewards    %didValves


% obsolete: maximumNumberStimPresentations,doMask,
%           msResponseTimeLimit,pokeToRequestStim,
%           maintainPokeToMaintainStim,msMaximumStimPresentationDuration,
%           msRewardDuration, msPenalty, msRewardSoundDuration
%           framesPerUpdate


%get textures into memory


% responseDetails.interTrialRecord    = doPhase(tm, 'waitForRequest',          sm, stimDetails.interTrialStim.requestAction,     [],                         stimDetails.requestOptions,  stimDetails.framesPerUpdate, stimDetails.displayText, stimDetails.allowScreenLabel, station, window, ifi, manualOn, timingCheckPct, numFrameDropReports);
% responseDetails.disciminandumRecord = doPhase(tm, 'presentDiscriminandum',   sm, stimDetails.discriminandumStim.requestAction, stimDetails.requestOptions, stimDetails.responseOptions, stimDetails.framesPerUpdate, stimDetails.displayText, stimDetails.allowScreenLabel, station, window, ifi, manualOn, timingCheckPct, numFrameDropReports);
% if
%     responseDetails.reinforcementRecord = doPhase(tm,'performReinforcement', sm, stimDetails.correctReinfStim.requestAction,   [],                         [],                          stimDetails.framesPerUpdate, stimDetails.displayText, stimDetails.allowScreenLabel, station, window, ifi, manualOn, timingCheckPct, numFrameDropReports);
% else
%     responseDetails.reinforcementRecord = doPhase(tm,'performReinforcement', sm, stimDetails.incorrectReinfStim.requestAction, [],                         [],                          stimDetails.framesPerUpdate, stimDetails.displayText, stimDetails.allowScreenLabel, station, window, ifi, manualOn, timingCheckPct, numFrameDropReports);
% end
% responseDetails.finalRecord = doPhase(tm, );

%
%
% dontclear = 2; %2 saves time by not reinitializing the framebuffer -- safe for us cuz we're redrawing everything
% %               don't understand difference between setting this to 1 vs. 2.  if 2 gives blue flashing, try 1?
%
% loop=0;
% trigger=0;
%
%
% dynamic
% list of frame times, last can be 0 to hold, otherwise loops.  request restarts or toggles or does nothing
%
%
% if isinteger(type)
%     if isvector(type) && size(stim,3)==size(type,2) && all(type(1:end-1)>=1) && type(end)>=0 % the timedFrames type
%         strategy = 'textureCache';
%         %dontclear = 1;  %good for saving time, but breaks on lame graphics cards
%     else
%         error('bad vector for timedFrame type: must be a vector of length equal to stim dim 3 of integers > 0 (number or refreshes to display each frame). A zero in the final entry means hold display of last frame.')
%     end
% else
%     switch type
%         case 'static'   %static 1-frame stimulus                                                (like free drinks)
%             strategy = 'textureCache';
%         case 'trigger'   %2 static frames -- if request, show frame 1; else show frame 2        (like most things)
%             strategy = 'textureCache';
%             trigger = 1;
%             %dontclear = 1; %good for saving time, but breaks on lame graphics cards
%             if size(stim,3)~=2
%                 error('trigger type must have stim with exactly 2 frames')
%             end
%         case 'cache'    %dynamic n-frame stimulus (play once)                                   (like error stim)
%             strategy = 'textureCache';
%         case 'loop'     %dynamic n-frame stimulus (loop)                                        (like romo)
%             strategy = 'textureCache';
%             loop = 1;
%         case 'dynamic'  %call moreStim() if more frames desired
%             strategy = 'dynamicDots';
%             error('dynamic ptb not yet implemented')
%         otherwise
%             error('unrecognized stim type, must be ''static'',''cache'' or ''loop'' or ''dynamic'' or, for timedFrame, a vector of length equal to stim dim 3 of integers > 0 (number or refreshes to display each frame). A zero in the final entry means hold display of last frame.')
%     end
% end
%
%
%
%
%
%
%
%
%
%
%
% if isempty(responseOptions)
%     if strcmp(type,'loop')
%         error('can''t loop with no response ports -- would have no way out')
%     end
% end
%
% originalPriority=Priority;
%
% try
%
%
%     filtMode = 0;               %How to compute the pixel color values when the texture is drawn scaled
%     %                           %0 = Nearest neighbour filtering, 1 = Bilinear filtering (default, and BAD)
%
%     framesPerUpdate = 1;        %set number of monitor refreshes for each one of your refreshes
%
%     labelFrames = 1;            %print a frame ID on each frame (makes frame calculation slow!)
%
%     verbose = 1;

%logwrite('entered stimOGL');


if window<0
    error('window must be >=0')
end
HideCursor;
ListenChar(2);
FlushEvents('keyDown');

quit=false;

%need to move this stuff into stimManager or trialManager
toggleStim=1;
numFramesUntilStopSavingMisses=1000;

originalPriority=Priority;

try


    filtMode = 0;               %How to compute the pixel color values when the texture is drawn scaled
    %                           %0 = Nearest neighbour filtering, 1 = Bilinear filtering (default, and BAD)

    framesPerUpdate = 1;        %set number of monitor refreshes for each one of your refreshes

    labelFrames = 1;            %print a frame ID on each frame (makes frame calculation slow!)

    verbose = 1;

    dontclear = 0;              %2 saves time by not reinitializing -- safe for us cuz we're redrawing everything -- but gives blue flashing?
    %some stimulus types set dontclear to 1


    if length(size(stim))>3
        error('stim must be 2 or 3 dims')
    end


    loop=0;
    trigger=0;
    frameIndexed=0; % Whether the stim is indexed with a list of frames
    timeIndexed=0; % Whether the stim is timed with a list of frames
    indexedFrames = []; % List of indices referencing the frames
    %edf:  SWITCH expression must be a scalar or string constant.
    if iscell(type)
        if length(type)~=2
            error('Stim type of cell should be of length 2')
        end
        switch type{1}
            case 'indexedFrames'
                frameIndexed = 1;
                loop=1;
                trigger=0;
                indexedFrames = type{2};
                if isNearInteger(indexedFrames) && isvector(indexedFrames) && all(indexedFrames>0) && all(indexedFrames<=size(stim,3))
                    strategy = 'textureCache';
                else
                    class(indexedFrames)
                    size(indexedFrames)
                    indexedFrames
                    size(stim,3)
                    error('bad vector for indexedFrames type: must be a vector of integer indices into the stim frames (btw 1 and stim dim 3)')
                end
            case 'timedFrames'
                timeIndexed = 1;
                timedFrames = type{2};
                if isinteger(timedFrames) && isvector(timedFrames) && size(stim,3)==length(timedFrames) && all(timedFrames(1:end-1)>=1) && timedFrames(end)>=0 % the timedFrames type
                    strategy = 'textureCache';
                    %dontclear = 1;  %good for saving time, but breaks on lame graphics cards
                else
                    error('bad vector for timedFrames type: must be a vector of length equal to stim dim 3 of integers > 0 (number or refreshes to display each frame). A zero in the final entry means hold display of last frame.')
                end
            otherwise
                error('Unsupported stim type using a cell, either indexedFrames or timedFrames')
        end
    else
        switch type
            case 'static'   %static 1-frame stimulus
                strategy = 'textureCache';
                if size(stim,3)~=1
                    error('static type must have stim with exactly 1 frame')
                end
            case 'trigger'   %2 static frames -- if request, show frame 1; else show frame 2
                strategy = 'textureCache';
                loop = 0;
                trigger = 1;
                %dontclear = 1; %good for saving time, but breaks on lame graphics cards
                if size(stim,3)~=2
                    error('trigger type must have stim with exactly 2 frames')
                end
            case 'cache'    %dynamic n-frame stimulus (play once)
                strategy = 'textureCache';
            case 'loop'     %dynamic n-frame stimulus (loop)
                strategy = 'textureCache';
                loop = 1;
            case 'dynamic'  %call moreStim() if more frames desired
                strategy = 'dynamicDots';
                error('dynamic type not yet implemented')
            case 'expert' %callback moreStim() to call ptb drawing methods, but leave frame labels and 'drawingfinished' to stimOGL
                error('expert type not yet implemented')
            otherwise
                error('unrecognized stim type, must be ''static'', ''cache'', ''loop'', ''dynamic'', ''expert'', {''indexedFrames'' [frameIndices]}, or {''timedFrames'' [frameTimes]}')
        end
    end


    if isempty(responseOptions) && (trigger || loop || (timeIndexed && timedFrames(end)==0) || frameIndexed)
        error('can''t loop with no response ports -- would have no way out')
    end




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if window>=0
        [scrWidth scrHeight]=Screen('WindowSize', window);
    else
        scrWidth=getWidth(station);
        scrHeight=getHeight(station);
    end

    if metaPixelSize == 0
        scaleFactor = [scrHeight scrWidth]./[size(stim,1) size(stim,2)];
    elseif length(metaPixelSize)==2 && all(metaPixelSize)>0
        scaleFactor = metaPixelSize;
    else
        error('bad metaPixelSize argument')
    end
    if any(scaleFactor.*[size(stim,1) size(stim,2)]>[scrHeight scrWidth])
        scaleFactor.*[size(stim,1) size(stim,2)]
        scaleFactor
        size(stim)
        [scrHeight scrWidth]
        error('metaPixelSize argument too big')
    end

    [oldCLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', window);

    %LOAD COLOR LOOK UP TABLE (if it is the right size)
    if isreal(LUT) && all(size(LUT)==[reallutsize 3])
        if any(LUT(:)>1) || any(LUT(:)<0)
            error('LUT values must be normalized values between 0 and 1')
        end
        oldCLUT = Screen('LoadNormalizedGammaTable', window, LUT,0);
        currentCLUT = Screen('ReadNormalizedGammaTable', window);
        %test clut values
        if all(all(currentCLUT-LUT<0.00001))
            if verbose
                disp('LUT is LOADED')
                disp('clut is more or less what you want it to be')
            end
        else
            oldCLUT
            currentCLUT
            LUT             %requested
            currentCLUT-LUT %error
            error('the LUT is not what you think it is')
        end
    else
        reallutsize
        error('LUT must be real reallutsize X 3 matrix')
    end

    maxV=max(currentCLUT(:))
    minV=min(currentCLUT(:))

    if verbose && (minV ~= 0 || maxV ~= 1)
        disp(sprintf('clut has a min of %4.6f and a max of %4.6f',minV,maxV));
    end

    %     %find out relevant clut range -old edf repplaced by pmm 070403
    %     if ~strcmp(computer, 'MAC') && window>-1
    %         clut = Screen('LoadCLUT', window); %supposed to replace with Screen('ReadNormalizedGammaTable',0), which is in range 0-1
    %         maxV = max(max(clut));
    %         minV = min(min(clut));
    %     else
    %         warning('hacking loadclut=(0,255) -- need to figure out how to do this on osx')
    %         minV = 0;
    %         maxV = 255;
    %     end;
    %     if verbose && (minV ~= 0 || maxV ~= 255)
    %         disp(sprintf('clut has a min of %d and a max of %d',minV,maxV));
    %     end



    %SPECIFY COLOR RANGE
    %tell screen what type of textures we will send


    if verbose
        disp(sprintf('stim class is %s',class(stim)));
    end

    floatprecision=0;
    if isreal(stim) && strcmp(class(stim),class(finalScreenLuminance)) && isscalar(finalScreenLuminance)
        switch class(stim)
            case {'double','single'}
                if any([finalScreenLuminance; stim(:)]>1) || any([finalScreenLuminance; stim(:)]<0)
                    error('stimor finalScreenLuminance had elements <0 or >1 ')
                else
                    floatprecision=1;%will tell maketexture to use 0.0-1.0 format with 16bpc precision (2 would do 32bpc)
                    % finalScreenLuminance=round(finalScreenLuminance*intmax('uint8')); what was point of this?
                end
            case 'uint8'
                %do nothing
            case 'uint16'
                stim=single(stim)/intmax('uint16');
                finalScreenLuminance=single(finalScreenLuminance)/intmax('uint16');
                floatprecision=1;
            case 'logical'
                stim=uint8(stim)*intmax('uint8'); %force to 8 bit
                finalScreenLuminance=finalScreenLuminance*intmax('uint8');
            otherwise
                error('unexpected stim variable class; currently stimOGL expects double, single, unit8, uint16, or logical')
        end
    else
        stim
        finalScreenLuminance
        class(stim)
        class(finalScreenLuminance)
        error('stim must be real, and type must match interTrialLuminance, and interTrialLuminance must be scalar')
    end



    % squareSize = 1*[1 1];       %width and height of squares in terms of pixels
    %                             %fastest to make 1x1 squares and scale in the DrawTexture call
    %                             %hrm, seem to get weird crosshatch pattern when size is 1x1 and unscaled
    % screenSize = 40*[5 4];      %width and height of screen in terms of squares
    % if strcmp(strategy,'dynamicDots')
    %     squareLocs = zeros(screenSize(1)*screenSize(2),2);  %squareLocs is a list of x,y coordinates ordered by rows
    %     squareLocs(:,1) = repmat([0:squareSize(1):(screenSize(1)-1)*squareSize(1)]',screenSize(2),1);
    %     squareLocs(:,2) = reshape((repmat([0:squareSize(2):((screenSize(2)-1)*squareSize(2))]',1,screenSize(1)))',screenSize(1)*screenSize(2),1);
    % end

    %show movie following mario's 'ProgrammingTips' for the OpenGL version of PTB
    %http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html

    height = scaleFactor(1)*size(stim,1);
    width = scaleFactor(2)*size(stim,2);

    if window>=0
        scrRect = Screen('Rect', window);
        scrLeft = scrRect(1); %am i retarted?  why isn't [scrLeft scrTop scrRight scrBottom]=Screen('Rect', window); working?  deal doesn't work
        scrTop = scrRect(2);
        scrRight = scrRect(3);
        scrBottom = scrRect(4);
    else
        scrLeft = 0;
        scrTop = 0;
        scrRight = scrWidth;
        scrBottom = scrHeight;
    end

    destRect = round([((scrRight-scrLeft)/2)-(width/2) ((scrBottom-scrTop)/2)-(height/2) ((scrRight-scrLeft)/2)+(width/2) ((scrBottom-scrTop)/2)+(height/2)]); %[left top right bottom]

    tic
    switch strategy
        case 'textureCache'
            %load all frame caches into VRAM

            textures=zeros(1,size(stim,3));
            for i=1:size(stim,3)
                if window>=0
                    textures(i)=Screen('MakeTexture', window, squeeze(stim(:,:,i)),0,0,floatprecision);
                end
            end

        case 'dynamicDots'

            numDots = size(stim,1)*size(stim,2);
            [dotX dotY] = meshgrid(1:size(stim,1),1:size(stim,2));
            dotLocs = [dotX(1:numDots);dotY(1:numDots)];
            dotSize = 1;
            dotCtr = [destRect(3)-destRect(1) destRect(4)-destRect(2)]/2;

        otherwise
            error('unrecognized strategy')
    end

    if window>=0
        textures(size(stim,3)+1)=Screen('MakeTexture', window, finalScreenLuminance,0,0,floatprecision);
        [resident texidresident] = Screen('PreloadTextures', window);

        if resident ~= 1
            disp(sprintf('error: some textures not cached'));
            find(texidresident~=1)
        end
    end
    if verbose
        disp(sprintf('took %g to load textures',toc));
    end

    if ~isempty(rn)
        constants = getConstants(rn);
    end

    if strcmp(getRewardMethod(station),'serverPump')
        if isempty(rn) || ~isa(rn,'rnet')
            error('need an rnet for station with rewardMethod of serverPump')
        end
    end
    
    attempt=0;
    done=0;
    i=0;
    frameIndex=0;

    response='none'; %initialize

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

    responseDetails.toggleStim=toggleStim;

    frameNum=1;

    stimStarted=isempty(requestOptions);
    logIt=0;
    stopListening=0;
    lookForChange=0;
    player=[];
    currSound='';


    ports=0*readPorts(station);
    lastPorts=0*readPorts(station);
    pressingM=0;
    pressingP=0;
    didAPause=0;
    paused=0;
    doFramePulse=0;
    didPulse=0;
    didValves=0;
    didManual=0;

    %used for timed frames stimuli
    if isempty(requestOptions)
        requestFrame=1;
    else
        requestFrame=0;
    end

    currentValveState=verifyValvesClosed(station);
    valveErrorDetails=[];
    requestRewardStarted=false;
    requestRewardStartLogged=false;
    requestRewardDone=false;
    requestRewardPorts=0*readPorts(station);
    requestRewardDurLogged=false;
    requestRewardOpenCmdDone=false;
    serverValveChange=false;
    potentialStochasticResponse=false;
    didStochasticResponse=false;
    didHumanResponse=false;
    requestRewardStartLogged=false;

    isRequesting=0;
    stimToggledOn=0;
    
    puffStarted=0;
    puffDone=false;

    xSubjectTextPos = 25;
    xTextPos = xSubjectTextPos+250;
    yTextPos = 20;
    standardFontSize=15; %big was 25
    subjectFontSize=35;


    % For the Windows version of Priority (and Rush), the priority levels set
    % are  "process priority levels". There are 3 priority levels available,
    % levels 0, 1, and 2. Level 0 is "normal priority level", level 1 is "high
    % priority level", and level 2 is "real time priority level". Combined
    % with

    %Priority(9);
    KbCheck; %load mex files into ram
    GetSecs;
    Screen('Screens');

    preSMCacheTime=GetSecs();
    [newSM updateSMCache]=cacheSounds(tm.soundMgr);
    disp(sprintf('took %g secs to cache sounds',GetSecs()-preSMCacheTime))
    if updateSMCache
        tm.soundMgr=newSM; %hmmm, how does this cache get persisted, we don't return tm...
    end
    %tm.soundMgr=playSound(tm.soundMgr,'keepGoingSound',.001,station); %get audioplayer into memory (java?)
    %tm.soundMgr=playSound(tm.soundMgr,'trySomethingElseSound',.001,station); %get all the clips we'll use cached up

    priorityLevel=MaxPriority(window,'GetSecs','KbCheck');

    Priority(priorityLevel); % should use Rush to prevent hard crash if script errors, but then everything below is a string, annoying...
    if verbose
        disp(sprintf('running at priority %d',priorityLevel));
    end

    if window >= 0
        oldFontSize = Screen('TextSize',window,standardFontSize);
        Screen('Preference', 'TextRenderer', 0);  % consider moving to PTB setup

        Screen('DrawTexture', window, textures(size(stim,3)+1),[],destRect,[],filtMode); %should replace this with new stim architecture
        Screen('DrawingFinished',window,dontclear);
        [vbl sos ft]=Screen('Flip',window);
        lastFrameTime=ft;
        lastI=size(stim,3)+1;
    else
        vbl=GetSecs();
        lastFrameTime=vbl;
    end


    %logwrite('about to enter stimOGL loop');

    %any stimulus onset synched actions

    startTime=GetSecs();

    audioStimPlaying = false;

    %show stim -- be careful in this realtime loop!
    while ~done && ~quit;
        %logwrite('top of stimOGL loop');

        yNewTextPos=yTextPos;

        if ~paused

            if stimStarted
                % If it's not triggered, the audio can just be started
                if ~trigger
                    if ~isempty(audioStim)
                        % Play audio
                        tm.soundMgr = playLoop(tm.soundMgr,audioStim,station,1);
                        audioStimPlaying = true;
                    end
                end
                doFramePulse=~noPulses;
                switch strategy
                    case 'textureCache'
                        if frameIndexed
                            if loop
                                frameIndex = mod(frameIndex,length(indexedFrames)-1)+1;
                            else
                                frameIndex = min(length(indexedFrames),frameIndex+1);
                            end
                            i = indexedFrames(frameIndex);
                        elseif loop
                            i = mod(i,size(stim,3)-1)+1;
                        elseif trigger
                            if isRequesting
                                if ~audioStimPlaying && ~isempty(audioStim)
                                    % Play audio
                                    tm.soundMgr = playLoop(tm.soundMgr,audioStim,station,1);
                                    audioStimPlaying = true;
                                end
                                i=1;
                            else
                                if audioStimPlaying
                                    % Turn off audio
                                    tm.soundMgr = playLoop(tm.soundMgr,'',station,0);
                                    audioStimPlaying = false;
                                end
                                i=2;
                            end

                        elseif timeIndexed %ok, this is where we do the timedFrames type

                            %Function 'cumsum' is not defined for values of class 'int8'.
                            if requestFrame~=0
                                i=min(find((frameNum-requestFrame)<=cumsum(double(timedFrames))));  %find the stim frame number for the number of frames since the request
                            end

                            if isempty(i)  %if we have passed the last stim frame
                                i=length(timedFrames);  %hold the last frame if the last frame duration specified was zero
                                if timedFrames(end)
                                    i=i+1;      %otherwise move on to the finalScreenLuminance blank screen
                                end
                            end

                        else

                            i=min(i+1,size(stim,3));

                            if isempty(responseOptions) && i==size(stim,3)
                                done=1;
                            end

                            if i==size(stim,3) && didPulse
                                doFramePulse=0;
                            end
                            didPulse=1;
                        end


                        %draw to buffer
                        if window>=0
                            if i>0 && i <= size(stim,3)
                                if ~(i==lastI) || (dontclear==0) %only draw if texture different from last one, or if every flip is redrawn
                                    Screen('DrawTexture', window, textures(i),[],destRect,[],filtMode);
                                else
                                    if labelFrames
                                        thisMsg=sprintf('This frame stim index (%d) is staying here without drawing new textures %d',i,frameNum);
                                        Screen('DrawText',window,thisMsg,xTextPos,yNewTextPos-20,100*ones(1,3));
                                    end
                                end
                            else
                                if size(stim,3)==0
                                    %'stim had zeros frames, probably an penalty stim with zero duration'
                                else
                                    i
                                    sprintf('size(stim,3): %d',size(stim,3))
                                    error('request for an unknown frame')
                                end
                            end
                        end


                    case 'dynamicDots'
                        i=i+1;

                        %draw to buffer
                        [dynFrame doFramePulse] =getDynFrame(stim,i); %any advantage to preallocating dynFrame?  would require a stim method to ask how big it will be...
                        if window>=0
                            Screen('DrawDots', window, dotLocs, dotSize ,repmat(dynFrame(1:numDots),3,1), dotCtr,0);
                        end
                    otherwise
                        error('unrecognized strategy')
                end
            else
                if window>=0
                    Screen('DrawTexture', window, textures(size(stim,3)+1),[],destRect,[],filtMode); %should replace this with new stim architecture
                end
            end

            %logwrite(sprintf('stim is started, i is calculated: %d',i));

            %text commands are supposed to be last for performance reasons

            if window>=0
                if labelFrames
                    %junkSize = Screen('TextSize',window,subjectFontSize);
                    [garbage,yTextPosUnused] = Screen('DrawText',window,['ID:' subID ],xSubjectTextPos,yTextPos,100*ones(1,3));
                    %junkSize = Screen('TextSize',window,standardFontSize);
                    [garbage,yNewTextPos] = Screen('DrawText',window,['trialManager:' class(tm) ' stimManager:' stimID],xTextPos,yNewTextPos,100*ones(1,3));
                end
                [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');
                yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);

                if labelFrames
                    [garbage,yNewTextPos] = Screen('DrawText',window,['priority:' num2str(Priority()) ' stim ind:' num2str(i) ' frame ind:' num2str(frameNum) ' isCorrection:' num2str(isCorrection)],xTextPos,yNewTextPos,100*ones(1,3));
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
            end

        else
            %do i need to copy previous screen?
            %Screen('CopyWindow', window, window);
            if window>=0
                Screen('DrawText',window,'paused (k+p to toggle)',xTextPos,yNewTextPos,100*ones(1,3));
            end
        end

        %indicate finished (enhances performance)
        if window>=0
            Screen('DrawingFinished',window,dontclear);
            lastI=i;
        end

        when=vbl+(framesPerUpdate-0.5)*ifi;

        if ~paused && doFramePulse
            framePulse(station);
            framePulse(station);
        end

        %logwrite('frame calculated, waiting for flip');

        %wait for next frame, flip buffer
        if window>=0
            [vbl sos ft missed]=Screen('Flip',window,when,dontclear); %vbl=vertical blanking time, when flip starts executing
            %sos=stimulus onset time -- doc doesn't clarify what this is
            %ft=timestamp from the end of flip's execution
        else
            waitTime=GetSecs()-when;
            if waitTime>0
                WaitSecs(waitTime);
            end
            ft=when;
            vbl=ft;
            missed=0;
        end

        %logwrite('just flipped');

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

        %stop saving miss frame statistics after the relevant period -
        %prevent trial history from getting too big
        %1 day is about 1-2 million misses is about 25 MB
        %consider integers if you want to save more
        %reasonableMaxSize=ones(1,intmax('uint16'),'uint16');%

        if missed>0 && frameNum>=responseDetails.numFramesUntilStopSavingMisses
            responseDetails.numMisses=responseDetails.numMisses+1;
            responseDetails.numUnsavedMisses=responseDetails.numUnsavedMisses+1;
        end

        %logwrite('entering trial logic');

        %all trial logic here


        if doAirpuff && ~puffDone && (puffStarted==0 || GetSecs-puffStarted<=getEyepuffMS(tm)/1000)
            
            setPuff(station,true);
            if puffStarted==0
                puffStarted=GetSecs;
            end
        else
            setPuff(station,false);
            puffDone=true;
        end
        
        if ~paused
            ports=readPorts(station);
        end

        doValves=0*ports;

        mThisLoop=0;
        pThisLoop=0;

        [keyIsDown,secs,keyCode]=KbCheck;
        if keyIsDown
            %logwrite(sprintf('keys are down:',num2str(find(keyCode))));

            asciiOne=49;

            keys=find(keyCode);
            ctrlDown=0; %these don't get reset if keyIsDown fails!
            shiftDown=0;
            kDown=0;
            for keyNum=1:length(keys)
                shiftDown = shiftDown || strcmp(KbName(keys(keyNum)),'shift');
                ctrlDown = ctrlDown || strcmp(KbName(keys(keyNum)),'control');
                kDown= kDown || strcmp(KbName(keys(keyNum)),'k');
            end

            if kDown
                for keyNum=1:length(keys)
                    keyName=KbName(keys(keyNum));

                    if strcmp(keyName,'p')
                        pThisLoop=1;

                        if ~pressingP && allowQPM

                            didAPause=1;
                            paused=~paused;

                            if paused
                                Priority(originalPriority);
                            else
                                Priority(priorityLevel);
                            end

                            pressingP=1;
                        end
                    elseif strcmp(keyName,'q') && ~paused && allowQPM
                        done=1;
                        response='manual kill';

                    elseif ~isempty(keyName) && ismember(keyName(1),char(asciiOne:asciiOne+length(ports)-1))
                        if shiftDown
                            if keyName(1)-asciiOne+1 == 2
                                'WARNING!!!  you just hit shift-2 ("@"), which mario declared a synonym to sca (screen(''closeall'')) -- everything is going to break now'
                                'quitting'
                                done=1;
                                response='shift-2 kill';
                            end
                        end
                        if ctrlDown
                            doValves(keyName(1)-asciiOne+1)=1;
                            didValves=true;
                        else
                            ports(keyName(1)-asciiOne+1)=1;
                            didHumanResponse=true;
                        end
                    elseif strcmp(keyName,'m')
                        mThisLoop=1;

                        if ~pressingM && ~paused && allowQPM

                            manual=~manual;
                            pressingM=1;
                        end
                    end
                end
            end

            if ~mThisLoop && pressingM
                pressingM=0;
            end
            if ~pThisLoop && pressingP
                pressingP=0;
            end
        end

        %logwrite('calculating state');

        if ~paused
            if verbose && any(lastPorts) && any(ports~=lastPorts)
                ports
            end

            %subject is finishing up an attempt -- record the end time
            if lookForChange && any(ports~=lastPorts)
                responseDetails.durs{attempt}=GetSecs()-respStart;
                lookForChange=0;

                tm.soundMgr = playLoop(tm.soundMgr,'',station,0);
            end

            if ~toggleStim
                isRequesting=0;
            end

            %subject is requesting the stim
            if any(ports(requestOptions))

                if ~requestRewardStarted && isa(tm,'nAFC') && getRequestRewardSizeULorMS(tm)>0
                    requestRewardPorts=ports & requestOptions;
                    responseDetails.requestRewardPorts=requestRewardPorts;
                    requestRewardStarted=true;
                end

                if ~stimStarted
                    requestFrame=frameNum;
                end
                stimStarted=1;

                if toggleStim
                    if any(ports~=lastPorts)
                        if stimToggledOn
                            stimToggledOn=0;
                            isRequesting=0;
                        else
                            stimToggledOn=1;
                            isRequesting=1;
                        end
                    end
                else
                    isRequesting=1;
                end

                % Only play if there is no audio stimulus
                if isempty(audioStim)
                    tm.soundMgr = playLoop(tm.soundMgr,'keepGoingSound',station,1);
                end

                if ~lookForChange
                    logIt=1;
                end
                stopListening=1;

            end

            if isa(tm,'freeDrinks') && all(~ports)
                if rand<getFreeDrinkLikelihood(tm)
                    %ports(ceil(rand*length(responseOptions)))=1; %whoops -- bug
                    ports(ceil(rand*getNumPorts(station)))=1;
                    'FREE LICK AT PORT AS FOLLOWS -- NEED TO OFFICIALLY RECORD THIS'
                    potentialStochasticResponse=1; %might not be a viable response option, so don't log didStocasticResponse yet
                else
                    potentialStochasticResponse=0;
                end
            end

            %subject gave a well defined response
            if any(ports(responseOptions)) && stimStarted
                done=1;
                response = ports;
                logIt=1;
                stopListening=1;
                responseDetails.durs{attempt+1}=0;
                if potentialStochasticResponse
                    didStochasticResponse=1;
                end
            end

            %subject gave a response that is neither a stimulus request nor a well defined response
            if any(ports) && ~stopListening
                if isempty(audioStim)
                    tm.soundMgr = playLoop(tm.soundMgr,'trySomethingElseSound',station,1);
                end

                if (attempt==0 || any(ports~=lastPorts))
                    logIt=1;
                end
            end
            stopListening=0;

            if logIt
                if verbose
                    ports
                end
                respStart=GetSecs();
                attempt=attempt+1;
                responseDetails.tries{attempt}=ports;
                responseDetails.times{attempt}=GetSecs()-startTime;
                lookForChange=1;
                logIt=0;
            end

            lastPorts=ports;
            frameNum=frameNum+1;
            %logwrite(sprintf('advancing to frame: %d',frameNum));
        end

        switch  getRewardMethod(station)
            case 'localTimed'
                if requestRewardStarted && requestRewardStartLogged && ~requestRewardDone
                    if 1000*(GetSecs()-responseDetails.requestRewardStartTime) >= getRequestRewardSizeULorMS(tm)
                        requestRewardPorts=0*requestRewardPorts;
                        requestRewardDone=true;
                    end
                end
                newValveState=doValves|requestRewardPorts;

            case 'serverPump'

                if ~isempty(rn)

                    if ~isConnected(rn)
                        done=true;
                    end


                    serverValveStates=currentValveState;

            while commandsAvailable(rn,constants.priorities.IMMEDIATE_PRIORITY) && ~done && ~quit
                %logwrite('handling IMMEDIATE priority command in stimOGL');
                if ~isConnected(rn)
                    done=true;
                end
                com=getNextCommand(rn,constants.priorities.IMMEDIATE_PRIORITY);
                if ~isempty(com)
                    [good cmd args]=validateCommand(rn,com);
                    %logwrite(sprintf('command is %d',cmd));
                    if good
                        switch cmd



                                    case constants.serverToStationCommands.S_SET_VALVES_CMD
                                        isPrime=args{2};
                                        if isPrime
                                            if requestRewardStarted && ~requestRewardDone
                                                quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'stimOGL received priming S_SET_VALVES_CMD while a non-priming request reward was unfinished');
                                            else
                                                timeout=-1;
                                                [quit valveErrorDetails(end+1)]=clientAcceptReward(rn,...
                                                    com,...
                                                    station,...
                                                    timeout,...
                                                    valveStart,...
                                                    requestedValveState,...
                                                    [],...
                                                    isPrime);
                                                if quit
                                                    done=true;
                                                end
                                            end
                                        else
                                            if all(size(ports)==size(args{1}))

                                                serverValveStates=args{1};
                                                serverValveChange=true;

                                                if requestRewardStarted && requestRewardStartLogged && ~requestRewardDone
                                                    if requestRewardOpenCmdDone
                                                        if all(~serverValveStates)
                                                            requestRewardDone=true;
                                                        else
                                                            quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received S_SET_VALVES_CMD for closing request reward but not all valves were indicated to be closed');
                                                        end
                                                    else
                                                        if all(serverValveStates==requestRewardPorts)
                                                            requestRewardOpenCmdDone=true;
                                                        else
                                                            quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received S_SET_VALVES_CMD for opening request reward but wrong valves were indicated to be opened');
                                                        end
                                                    end
                                                else
                                                    quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'stimOGL received unexpected non-priming S_SET_VALVES_CMD');
                                                end
                                            else
                                                quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received inappropriately sized S_SET_VALVES_CMD arg');
                                            end
                                        end


                                    case constants.serverToStationCommands.S_REWARD_COMPLETE_CMD
                                        if requestRewardDone
                                            quit=sendAcknowledge(rn,com);
                                        else
                                            if requestRewardStarted
                                                quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_REWARD_COMPLETE_CMD apparently not preceeded by open and close S_SET_VALVES_CMD''s');
                                            else
                                                quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_REWARD_COMPLETE_CMD not preceeded by C_REWARD_CMD (MID_TRIAL)');
                                            end
                                        end
                                    otherwise
                                        done=clientHandleVerifiedCommand(rn,com,cmd,args,constants.statuses.MID_TRIAL);
                                        if done
                                            response='server kill';
                                        end
                                end
                            end
                        end
                    end
                    newValveState=doValves|serverValveStates;

                else
                    error('need a rnet for serverPump')
                end
                
            case 'localPump'
                
                if requestRewardStarted && ~requestRewardDone && requestRewardStartLogged
                    station=doReward(station,getRequestRewardSizeULorMS(tm)/1000,requestRewardPorts);
                    requestRewardDone=true;
                end
                
                if any(doValves)
                    primeMLsPerSec=1.0;
                    station=doReward(station,primeMLsPerSec*ifi,doValves);
                end
                
                newValveState=0*doValves;
            otherwise
                error('unrecognized rewardmethod')
        end




        [currentValveState valveErrorDetails]=setAndCheckValves(station,newValveState,currentValveState,valveErrorDetails,startTime,'frame cycle valve update');

        if serverValveChange
            quit=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_VALVES_SET_CMD,{currentValveState});
            serverValveChange=false;
        end

        if requestRewardStarted && ~requestRewardStartLogged
            if strcmp(getRewardMethod(station),'serverPump')
                quit=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_REWARD_CMD,{getRequestRewardSizeULorMS(tm),logical(requestRewardPorts)});
            end
            responseDetails.requestRewardStartTime=GetSecs();
            'request reward!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            requestRewardStartLogged=true;
        end

        if  requestRewardDone && ~requestRewardDurLogged
            responseDetails.requestRewardDurationActual=GetSecs()-responseDetails.requestRewardStartTime;
            'request reward stopped!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            requestRewardDurLogged=true;
        end

        %before can end, must make sure any request rewards are done so
        %that the valves will be closed.  this includes server reward
        %requests.  right now there is a bug if the response occurs before
        %the request reward is over.

        %logwrite('end of stimOGL loop');
    end
    %logwrite('stimOGL loop complete');
    currentValveState=verifyValvesClosed(station);

    audioStimPlaying=false;
    tm.soundMgr = playLoop(tm.soundMgr,'',station,0);

    responseDetails.totalFrames=frameNum;
    responseDetails.startTime=startTime;
    responseDetails.valveErrorDetails=valveErrorDetails;

    if window>=0
        Screen('DrawTexture', window, textures(size(stim,3)+1),[],destRect,[],filtMode); %change this for new stim architecture
        Screen('DrawingFinished',window,dontclear);
        when=vbl+(framesPerUpdate-0.5)*ifi;
        [vbl sos ft missed]=Screen('Flip',window,when,dontclear);
        Screen('Close'); %leaving off second argument closes all textures but leaves windows open
    end
    
    if hasAirpuff(station)
        setPuff(station,false);
    end

    Priority(originalPriority);
    ListenChar(0);
    
catch
    ers=lasterror
    ers.message
    ers.stack.file
    ers.stack.name
    ers.stack.line


    Screen('CloseAll');
    Priority(originalPriority);
    ShowCursor(0);
    ListenChar(0);

    if hasAirpuff(station)
        setPuff(station,false);
    end

    response=sprintf('error_in_StimOGL: %s',ers.message);

    rethrow(lasterror);


end
