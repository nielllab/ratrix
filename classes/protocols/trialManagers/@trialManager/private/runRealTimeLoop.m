function [tm quit trialRecords eyeData eyeDataFrameInds gaze frameDropCorner station] ...
    = runRealTimeLoop(tm, window, ifi, stimSpecs, startingStimSpecInd, phaseData, stimManager, ...
    targetOptions, distractorOptions, requestOptions, interTrialLuminance, interTrialPrecision, ...
    station, manual,timingCheckPct,textLabel,rn,subID,stimID,protocolStr,ptbVersion,ratrixVersion,trialLabel,msAirpuff, ...
    originalPriority, verbose, eyeTracker, frameDropCorner,trialRecords,currentCLUT)
% This function does the real-time looping for stimulus presentation. The rough order of events per loop:
%   - (possibly) update phase-specific information
%   - call updateTrialState to set correctness and determine rewards
%   - update stim frame index and draw new frame as needed
%   - (possibly) get eyeTracker data
%   - check for keyboard input
%   - check for port input
%   - carry out logic (whether we need to transition phases, what responses we got, what sounds to play)
%   - carry out rewards
%   - check for server and datanet commands
%   - carry out airpuffs

securePins(station);

% =====================================================================================================================
%   show movie following mario's 'ProgrammingTips' for the OpenGL version of PTB
%   http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html
%   except we drop frames (~1 per 45mins at 100Hz) if we preload all textures as he recommends, so we make and load them each frame

% high level important settings -- should move all to stimManager
filtMode = 0;               %how to compute the pixel values when the texture is drawn scaled
%                           %0 = Nearest neighbour filtering, 1 = Bilinear filtering (default, and BAD)

framesPerUpdate = 1;        %set number of monitor refreshes for each one of your refreshes

labelFrames = 1;            %print a frame ID on each frame (makes frame calculation slow!)
textType = getShowText(tm);
showText = ~strcmp(textType,'off'); %whether or not to call draw text to print any text on screen

% consider moving all this text stuff to station.startPTB

if ~IsLinux %|| true %for some reason causes trouble finding font, even though supposed to be OS-specific faster method (seems to be fixed now)
    Screen('Preference', 'TextRenderer', 0);  % consider moving to station.startPTB
end
Screen('Preference', 'TextAntiAliasing', 0); 
Screen('Preference', 'TextAlphaBlending', 0);

if window>0
    Screen('TextStyle', window, 1); % for bold -- otherwise illegible on windows
    
    standardFontSize=11;
    oldFontSize = Screen('TextSize',window,standardFontSize);
    if IsLinux
        Screen('TextStyle', window, 0); %otherwise defaults to bold italic!?!
        
        font = 'nimbus mono l';
        font = 'palladio';
        font = 'fixed';
        font = '-urw-nimbus mono l-bold-o-normal--0-0-0-0-p-0-iso8859-1';
        % font = '-*-fixed-*-*-*-*-*-*-*-*-*-*-*-*';
        Screen('TextFont',window,font); %otherwise we get Couldn't select the requested font with the requested font settings from X11 system!
        
        Screen('TextStyle', window, 0); %otherwise defaults to bold italic!?!   only works if textrender 1?
    end
    [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');
end

if ismac
    %http://psychtoolbox.org/wikka.php?wakka=FaqPerformanceTuning1
    %Screen('DrawText'): This is fast and low-quality on MS-Windows and beautiful but slow on OS/X.
    %also not good enough on asus mobo w/8600
    
    %setting textrenderer and textantialiasing to 0 not good enough
    labelFrames=0;
end

dontclear = 2;              %will be passed to flip
%                           %0 = flip will set framebuffer to background (slow, but other options fail on some gfx cards, like the integrated gfx on our asus mobos?)
%                           %1 = flip will leave the buffer as is ("incremental drawing" - but unclear if it copies the buffer just drawn into the buffer you're about to draw to, or if it is from a frame before that...)
%                           %2 = flip does nothing, buffer state undefined (you must draw into each pixel if you care) - fastest
% =====================================================================================================================

trialInd=length(trialRecords);
expertCache=[];
ports=logical(0*readPorts(station));
lastPorts=ports;
lastRequestPorts=ports;
playRequestSoundLoop=false;

requestRewardStarted=false;
requestRewardStartLogged=false;
requestRewardDone=false;
requestRewardDurLogged=false;
requestRewardOpenCmdDone=false;

rewardCurrentlyOn=false;
msRewardOwed=0;
msRequestRewardOwed=0;
msAirpuffOwed=0;
airpuffOn=false;
lastAirpuffTime=[];
msRewardSound=0;
msPenaltySound=0;
lastRewardTime=[];
thisRewardPhaseNum=[];
thisAirpuffPhaseNum=[];

quit=false;
responseOptions = union(targetOptions, distractorOptions);
done=0;
containedExpertPhase=0;
eyeData=[];
eyeDataFrameInds=[];
gaze=[];
soundNames=getSoundNames(getSoundManager(tm));

phaseInd = startingStimSpecInd; % which phase we are on (index for stimSpecs and phaseData)
phaseNum = 0; % increasing counter for each phase that we visit (may not match phaseInd if we repeat phases) - start at 0 b/c we increment during updatePhase
updatePhase = 1; % are we starting a new phase?

lastI = 0;
isRequesting=0;

lastSoundsLooped={};
totalFrameNum=1; % for eyetracker
totalEyeDataInd=1;
doFramePulse=1;

doValves=0*ports;
newValveState=doValves;
doPuff=false;

% =========================================================================

timestamps.loopStart=0;
timestamps.phaseUpdated=0;
timestamps.trialStateUpdated=0;
timestamps.frameDrawn=0;
timestamps.frameDropCornerDrawn=0;
timestamps.textDrawn=0;
timestamps.drawingFinished=0;
timestamps.when=0;
timestamps.prePulses=0;
timestamps.postFlipPulse=0;
timestamps.missesRecorded=0;
timestamps.eyeTrackerDone=0;
timestamps.kbCheckDone=0;
timestamps.keyboardDone=0;
timestamps.enteringPhaseLogic=0;
timestamps.phaseLogicDone=0;
timestamps.rewardDone=0;
timestamps.serverCommDone=0;
timestamps.phaseRecordsDone=0;
timestamps.loopEnd=0;
timestamps.prevPostFlipPulse=0;
timestamps.vbl=0;
timestamps.ft=0;
timestamps.missed=0;
timestamps.lastFrameTime=0;

timestamps.logicGotSounds=0;
timestamps.logicSoundsDone=0;
timestamps.logicFramesDone=0;
timestamps.logicPortsDone=0;
timestamps.logicRequestingDone=0;

timestamps.kbOverhead=0;
timestamps.kbInit=0;
timestamps.kbKDown=0;

% =========================================================================

responseDetails.numMisses=0;
responseDetails.numApparentMisses=0;

responseDetails.numUnsavedMisses=0;
responseDetails.numUnsavedApparentMisses=0;

responseDetails.misses=[];
responseDetails.apparentMisses=[];

responseDetails.afterMissTimes=[];
responseDetails.afterApparentMissTimes=[];

responseDetails.missIFIs=[];
responseDetails.apparentMissIFIs=[];

responseDetails.missTimestamps=timestamps;
responseDetails.apparentMissTimestamps=timestamps;

responseDetails.numDetailedDrops=1000;

responseDetails.nominalIFI=ifi;
responseDetails.tries={};
responseDetails.times={};
responseDetails.durs={};
% responseDetails.requestRewardDone=false;
responseDetails.requestRewardPorts={};
responseDetails.requestRewardStartTime={};
responseDetails.requestRewardDurationActual={};

responseDetails.startTime=[];

% =========================================================================

phaseRecordAllocChunkSize = 1;
[phaseRecords(1:length(stimSpecs)).responseDetails]= deal(responseDetails);

[phaseRecords(1:length(stimSpecs)).proposedRewardDurationMSorUL] = deal(0);
[phaseRecords(1:length(stimSpecs)).proposedAirpuffDuration] = deal(0);
[phaseRecords(1:length(stimSpecs)).proposedPenaltyDurationMSorUL] = deal(0);
[phaseRecords(1:length(stimSpecs)).actualRewardDurationMSorUL] = deal(0);
[phaseRecords(1:length(stimSpecs)).actualAirpuffDuration] = deal(0);

[phaseRecords(1:length(stimSpecs)).valveErrorDetails]=deal([]);
[phaseRecords(1:length(stimSpecs)).latencyToOpenValves]= deal([]);
[phaseRecords(1:length(stimSpecs)).latencyToCloseValveRecd]= deal([]);
[phaseRecords(1:length(stimSpecs)).latencyToCloseValves]= deal([]);
[phaseRecords(1:length(stimSpecs)).latencyToRewardCompleted]= deal([]);
[phaseRecords(1:length(stimSpecs)).latencyToRewardCompletelyDone]= deal([]);
[phaseRecords(1:length(stimSpecs)).primingValveErrorDetails]= deal([]);
[phaseRecords(1:length(stimSpecs)).latencyToOpenPrimingValves]= deal([]);
[phaseRecords(1:length(stimSpecs)).latencyToClosePrimingValveRecd]= deal([]);
[phaseRecords(1:length(stimSpecs)).latencyToClosePrimingValves]= deal([]);
[phaseRecords(1:length(stimSpecs)).actualPrimingDuration]= deal([]);

[phaseRecords(1:length(stimSpecs)).containedManualPokes]= deal([]);
[phaseRecords(1:length(stimSpecs)).leftWithManualPokingOn]= deal([]);
[phaseRecords(1:length(stimSpecs)).containedAPause]= deal([]);
[phaseRecords(1:length(stimSpecs)).didHumanResponse]= deal([]);
[phaseRecords(1:length(stimSpecs)).containedForcedRewards]= deal([]);
[phaseRecords(1:length(stimSpecs)).didStochasticResponse]= deal([]);

% =========================================================================

headroom=nan(1,responseDetails.numDetailedDrops);

if ~isempty(rn)
    constants = getConstants(rn);
end

if strcmp(getRewardMethod(station),'serverPump')
    if isempty(rn) || ~isa(rn,'rnet')
        error('need an rnet for station with rewardMethod of serverPump')
    end
end

[keyIsDown,secs,keyCode]=KbCheck; %load mex files into ram + preallocate return vars
GetSecs;
Screen('Screens');

KbName('UnifyKeyNames'); %does not appear to choose keynamesosx on windows - KbName('KeyNamesOSX') comes back wrong

%consider using RestrictKeysForKbCheck for speedup of KbCheck

KbConstants.allKeys=KbName('KeyNames');
KbConstants.allKeys=lower(cellfun(@char,KbConstants.allKeys,'UniformOutput',false));
KbConstants.controlKeys=find(cellfun(@(x) ~isempty(x),strfind(KbConstants.allKeys,'control')));
KbConstants.shiftKeys=find(cellfun(@(x) ~isempty(x),strfind(KbConstants.allKeys,'shift')));
KbConstants.kKey=KbName('k');
KbConstants.pKey=KbName('p');
KbConstants.qKey=KbName('q');
KbConstants.mKey=KbName('m');
KbConstants.aKey=KbName('a');
KbConstants.rKey=KbName('r');
KbConstants.tKey=KbName('t');
KbConstants.fKey=KbName('f');
KbConstants.eKey=KbName('e');
KbConstants.atKeys=find(cellfun(@(x) ~isempty(x),strfind(KbConstants.allKeys,'@')));
KbConstants.asciiOne=double('1');
KbConstants.portKeys={};
for i=1:length(ports)
    KbConstants.portKeys{i}=find(strncmp(char(KbConstants.asciiOne+i-1),KbConstants.allKeys,1));
end
KbConstants.numKeys={};
for i=1:10
    KbConstants.numKeys{i}=find(strncmp(char(KbConstants.asciiOne+i-1),KbConstants.allKeys,1));
end

priorityLevel=MaxPriority('GetSecs','KbCheck');

Priority(priorityLevel);

% =========================================================================

if ~isempty(eyeTracker)
    perTrialSyncing=false; %could pass this in if we ever decide to use it; now we don't
    if perTrialSyncing && isa(eyeTracker,'eyeLinkTracker')
        status=Eyelink('message','SYNCTIME');
        if status~=0
            error('message error, status: %g',status)
        end
    end
    
    framesPerAllocationChunk=getFramesPerAllocationChunk(eyeTracker);
    
    
    if isa(eyeTracker,'eyeLinkTracker')
        eyeData=nan(framesPerAllocationChunk,length(getEyeDataVarNames(eyeTracker)));
        eyeDataFrameInds=nan(framesPerAllocationChunk,1);
        gaze=nan(framesPerAllocationChunk,2);
    else
        error('no other methods')
    end
end

% =========================================================================

didAPause=0;
didManual=false;
paused=0;
pressingM=0;
pressingP=0;
framesSinceKbInput = 0;
shiftDown=false;
ctrlDown=false;
atDown=false;
kDown=false;
portsDown=false(1,length(ports));
pNum=0;

trialRecords(trialInd).result=[]; %initialize
trialRecords(trialInd).correct=[]; %who sets this?
analogOutput=[];
startTime=0;
logIt=true;
lookForChange=false;
punishResponses=[];

if window>0
    if false %record movie of trial
        movieFile = sprintf('%s%s.%d.%s.%s.%s.%s',[fullfile(fileparts(fileparts(getPath(station))),'PermanentTrialRecordStore',subID) filesep],subID,trialRecords(end).trialNumber,trialRecords(end).protocolName,trialRecords(end).trialManagerClass,stimID,datestr(trialRecords(end).date,'ddd-mmm-dd-yyyy-HH-MM-SS'));
        
        % C:\Users\nlab\Desktop\ratrixData\PermanentTrialRecordStore\demo1\demo1.1.mouse.ball.trail.Tue-Mar-20-2012-22-23-56
        % in win, showing up in cwd at:
        % UsersnlabDesktopratrixDataPermanentTrialRecordStoredemo1demo1.2.mouse.ball.trail.Tue-Mar-20-2012-22-24-07
        %on osx, this is getting cut off to demo1.12.mouse.ball.trail.Fri#0
        
        %default is h.264 - what extension should we use?
        %note ImagingStereoDemo demos .avi, .mov, .flv...  ask mario for ref...
        
        %for dynamic stims, this will be faster
        %but for preallocated stims, use writeAVI
        if IsWin
            str=[]; %works on win, not too slow!
        else
            str=['EncodingQuality=' num2str(.01)]; %works on osx, but 1.0 very slow
            %still too slow on osx at .01 -- trying 800x500 at 8bit color
        end
        moviePtr = Screen('CreateMovie', window, movieFile, [], [], 1/ifi, str);
        
        %looks like C:\Users\nlab\Desktop\ptb src\PsychSourceGL\Source\Common\Screen\ScreenPreferenceState.c
        %doesn't check for 64 vs. 32 bit win
        %docs make it sound like qt is still default for 32bit win, but i
        %couldn't get qt to work at all until i had gstreamer installed?
        % todo, try again w/qt - am i misremembering?
        
        %we should also record sound
        %can use http://docs.psychtoolbox.org/OpenSlave with kPortAudioIsOutputCapture
        %see http://tech.groups.yahoo.com/group/psychtoolbox/message/13249
        % then add it as audio track to the movie...
        %Screen('AddAudioBufferToMovie', moviePtr, audioBuffer); %not supported on osx..
        %note, to do this, must add option string to createmovie:
        % Add a sound track to the movie: 2 channel stereo, 48 kHz:
        %        movie = Screen('CreateMovie', windowPtr, ['MyTestMovie.mov'], 512, 512, 30, ':CodecSettings=AddAudioTrack=2@48000');
        %'audioBuffer' must be 'numChannels' rows by 'numSamples' columns double matrix
        %Sample values must lie in the range between -1.0 and +1.0.
        %The audio buffer is converted into a movie specific sound format and then
        %appended to the audio samples already stored in the audio track.
        
    else
        moviePtr = [];
    end
    
    % =========================================================================
    % do first frame and  any stimulus onset synched actions
    % make sure everything after this point is preallocated
    % efficiency is crticial from now on
    
    % draw interTrialLuminance first
    if true  % trunk should always leave this true, only false for a local test
        interTrialTex=Screen('MakeTexture', window, interTrialLuminance,0,0,interTrialPrecision); %need floatprecision=0 for remotedesktop
        Screen('DrawTexture', window, interTrialTex,phaseData{end}.destRect, [], filtMode);
        [timestamps.vbl sos startTime]=Screen('Flip',window);
    else
        % %to find out properties of the interTrialTex
        %     allWindows=Screen('Windows');
        %     texIDsThere=allWindows(find(Screen(allWindows,'WindowKind')==-1))
        %     tx=screen('getImage',interTrialTex,[],[],2);
        %     tx(:)
        %     interTrialTex
        %     sca
        %     keyboard
    end
end

timestamps.lastFrameTime=GetSecs;
timestamps.missesRecorded       = timestamps.lastFrameTime;
timestamps.eyeTrackerDone       = timestamps.lastFrameTime;
timestamps.kbCheckDone          = timestamps.lastFrameTime;
timestamps.keyboardDone         = timestamps.lastFrameTime;
timestamps.enteringPhaseLogic   = timestamps.lastFrameTime;
timestamps.phaseLogicDone       = timestamps.lastFrameTime;
timestamps.rewardDone           = timestamps.lastFrameTime;
timestamps.serverCommDone       = timestamps.lastFrameTime;
timestamps.phaseRecordsDone     = timestamps.lastFrameTime;
timestamps.loopEnd              = timestamps.lastFrameTime;
timestamps.prevPostFlipPulse    = timestamps.lastFrameTime;

doProfile = false;
if doProfile
    blah=profile('status');
    if strcmp(blah.ProfilerStatus,'on')
        sca
        profile viewer
        keyboard
    end
end

%show stim -- be careful in this realtime loop!
while ~done && ~quit;
    timestamps.loopStart=GetSecs;
    
    xOrigTextPos = 10;
    xTextPos=xOrigTextPos;
    yTextPos = 20;
    
    if updatePhase == 1
        setStatePins(station,'stim',false);
        setStatePins(station,'phase',true);
        
        startTime=GetSecs(); % startTime is now per-phase instead of per trial, since corresponding times in responseDetails are also per-phase
        phaseNum=phaseNum+1;
        if phaseNum>length(phaseRecords)
            
            nextPhaseRecordNum=length(phaseRecords)+1;
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).responseDetails]= deal(responseDetails);
            
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).proposedRewardDurationMSorUL] = deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).proposedAirpuffDuration] = deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).proposedPenaltyDurationMSorUL] = deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).actualRewardDurationMSorUL] = deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).actualAirpuffDuration] = deal([]);
            
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).valveErrorDetails]=deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).latencyToOpenValves]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).latencyToCloseValveRecd]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).latencyToCloseValves]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).latencyToRewardCompleted]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).latencyToRewardCompletelyDone]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).primingValveErrorDetails]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).latencyToOpenPrimingValves]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).latencyToClosePrimingValveRecd]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).latencyToClosePrimingValves]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).actualPrimingDuration]= deal([]);
            
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).containedManualPokes]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).leftWithManualPokingOn]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).containedAPause]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).didHumanResponse]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).containedForcedRewards]= deal([]);
            [phaseRecords(nextPhaseRecordNum:nextPhaseRecordNum+phaseRecordAllocChunkSize).didStochasticResponse]= deal([]);
        end
        
        finish=false;
        i=0;
        frameIndex=0;
        frameNum=1;
        phaseStartTime=GetSecs;
        firstVBLofPhase=timestamps.vbl;
        
        didPulse=0;
        didValves=0;
        arrowKeyDown=false;
        
        %         puffStarted=0;
        %         puffDone=false;
        
        currentValveState=getValves(station); % if valve reward is still going from previous phase, we force it closed. in other words, make sure your phases are long enough for the rewards that happen in them!
        serverValveChange=false;
        serverValveStates=false;
        didStochasticResponse=false;
        didHumanResponse=false;
        
        % =========================================================================
        phase = phaseData{phaseInd};
        floatprecision = phase.floatprecision;
        frameIndexed = phase.frameIndexed;
        loop = phase.loop;
        trigger = phase.trigger;
        timeIndexed = phase.timeIndexed;
        indexedFrames = phase.indexedFrames;
        timedFrames = phase.timedFrames;
        strategy = phase.strategy;
        toggleStim = phase.toggleStim; %lickometer % now passed in from calcStim
        phaseRecords(phaseNum).toggleStim=toggleStim; % flag for whether the end of a beam break ends the request state
        destRect = phase.destRect;
        textures = phase.textures;
        
        % =========================================================================
        spec = stimSpecs{phaseInd};
        stim = getStim(spec);
        transitionCriterion = getTransitions(spec);
        framesUntilTransition = getFramesUntilTransition(spec);
        phaseType = getPhaseType(spec);
        punishLastResponse=punishResponses;
        punishResponses = getPunishResponses(spec);
        
        % =========================================================================
        
        framesInPhase = 0;
        
        if ischar(strategy) && strcmp(strategy,'cache')
            if ~isempty(getStartFrame(spec)) %would like to get rid of this -- note we have to redo it below to catch correctStim
                i=getStartFrame(spec);
                framesInPhase=i; %wtf?
            end
            error('this looks wrong -- should be size(stim,3)?')
            numFramesInStim = size(stim)-i;
        elseif timeIndexed
            if timedFrames(end)==0
                numFramesInStim = Inf; % hold last frame, so even in 'cache' mode we are okay
            else
                numFramesInStim = sum(timedFrames);
            end
        else
            numFramesInStim = Inf;
        end
        
        isFinalPhase = getIsFinalPhase(spec);
        autoTrigger = getAutoTrigger(spec);
        
        % =========================================================================
        
        phaseRecords(phaseNum).dynamicDetails=[];
        phaseRecords(phaseNum).loop = loop;
        phaseRecords(phaseNum).trigger = trigger;
        phaseRecords(phaseNum).strategy = strategy;
        phaseRecords(phaseNum).autoTrigger = autoTrigger;
        phaseRecords(phaseNum).timeoutLengthInFrames = framesUntilTransition;
        phaseRecords(phaseNum).floatprecision = floatprecision;
        phaseRecords(phaseNum).phaseType = phaseType;
        phaseRecords(phaseNum).phaseLabel = getPhaseLabel(spec);
        
        phaseRecords(phaseNum).responseDetails.startTime = startTime;
        
        updatePhase = 0;
        
        % =========================================================================
        
        setStatePins(station,'phase',false);
        if isStim(spec)
            setStatePins(station,'stim',true);
        end
        
        if strcmp(tm.displayMethod,'LED')
            station=stopPTB(station); %should handle this better -- LED setting is trialManager specific, so other training steps will expect ptb to still exist
            %would prefer to never startPTB until a trialManager needs it,and then start it at the proper res the first time
            %trialManager.doTrial should startPTB if it wants one and there isn't one, and stop it if there is one and it doesn't want it
            %note that ifi is not coming in empty on the first trial and the leftover value from the screen is misleading, need to fix...
            
            didLEDphase=false;
        end
    end % fininshed with phaseUpdate
    
    timestamps.phaseUpdated=GetSecs;
    doFramePulse=true;
    
    if ~paused
        % here should be the function that also checks to see if we should assign trialRecords.correct
        % and trialRecords.response, and also does tm-specific reward checks (nAFC should check to update reward/airpuff
        % if first frame of a 'reinforced' phase)
        [tm trialRecords(trialInd).trialDetails trialRecords(trialInd).result spec ...
            rewardSizeULorMS requestRewardSizeULorMS ...
            msPuff msRewardSound msPenalty msPenaltySound floatprecision textures destRect] = ...
            updateTrialState(tm, stimManager, trialRecords(trialInd).result, spec, ports, lastPorts, ...
            targetOptions, requestOptions, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
            floatprecision, textures, destRect, ...
            requestRewardDone, punishLastResponse,[], lastI);
        
        if rewardSizeULorMS~=0
            doRequestReward=false;
            msRewardOwed=msRewardOwed+rewardSizeULorMS;
            phaseRecords(phaseNum).proposedRewardDurationMSorUL = rewardSizeULorMS;
        elseif msPenalty~=0
            doRequestReward=false;
            msAirpuffOwed=msAirpuffOwed+msPuff;
            phaseRecords(phaseNum).proposedAirpuffDuration = msPuff;
            phaseRecords(phaseNum).proposedPenaltyDurationMSorUL = msPenalty;
        end
        framesUntilTransition=getFramesUntilTransition(spec);
        stim=getStim(spec);
        scaleFactor=getScaleFactor(spec);
        if strcmp(getStimType(spec),'expert')
            strategy=getStimType(spec);
        end
        
        if framesInPhase==0 %needs rearchitecting!
            if ~isempty(getStartFrame(spec))
                i=getStartFrame(spec);
                % framesInPhase=i; %what was this for?
            end
        end
        %[framesUntilTransition i framesInPhase phaseNum]
        
        if requestRewardSizeULorMS~=0
            doRequestReward=true;
            msRequestRewardOwed=msRequestRewardOwed+requestRewardSizeULorMS;
            phaseRecords(phaseNum).responseDetails.requestRewardPorts{end+1}=ports;
            phaseRecords(phaseNum).responseDetails.requestRewardStartTime{end+1}=GetSecs();
            phaseRecords(phaseNum).responseDetails.requestRewardDurationActual{end+1}=0;
            
            lastRequestPorts=ports;
            playRequestSoundLoop=true;
            requestRewardDone=true;
        end
        
        lastPorts=ports;
        
        if strcmp(tm.displayMethod,'LED') && ~didLEDphase
            [phaseRecords analogOutput outputsamplesOK numSamps] = LEDphase(tm,phaseInd,analogOutput,phaseRecords,spec,interTrialLuminance,stim,frameIndexed,indexedFrames,loop,trigger,timeIndexed,timedFrames,station);
            didLEDphase=true;
        end
    end
    
    timestamps.trialStateUpdated=GetSecs;
    
    if window>0
        if ~isempty(moviePtr)
            sca
            keyboard
            Screen('AddFrameToMovie', window, [], [], moviePtr, 1);
        end
        
        if ~paused
            scheduledFrameNum=ceil((GetSecs-firstVBLofPhase)/(framesPerUpdate*ifi)); %could include pessimism about the time it will take to get from here to the flip and how much advance notice flip needs
            % this will surely have drift errors...
            % note this does not take pausing into account -- edf thinks we should get rid of pausing
            
            dynamicSounds={};
            switch strategy
                case {'textureCache','noCache','dynamic'}
                    if ~strcmp(strategy,'dynamic')
                        [tm frameIndex i done doFramePulse didPulse] ...
                            = updateFrameIndexUsingTextureCache(tm, frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames, size(stim,3), isRequesting, ...
                            i, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse, scheduledFrameNum);
                        
                        try
                            indexPulse=getIndexPulse(spec,i);
                        catch
                            sca
                            i
                            warning('indexPulse problem because i=0... seems to be more of a problem during reinforcement... does this depend on timeouts?');
                            keyboard
                        end
                    end
                    
                    switch strategy
                        case 'textureCache'
                            thisFrame=textures(i);
                        case 'noCache'
                            thisFrame=squeeze(stim(:,:,i));
                        case 'dynamic'
                            [thisFrame doFramePulse expertCache phaseRecords(phaseNum).dynamicDetails textLabel i indexPulse dynamicSounds finish]=moreStim(stimManager,stim,i,textLabel,destRect,expertCache,scheduledFrameNum,tm.dropFrames,phaseRecords(phaseNum).dynamicDetails,trialRecords);
                            [floatprecision2 thisFrame] = determineColorPrecision(tm, thisFrame, strategy);
                            if floatprecision~=floatprecision2
                                error('dynamic floatprecision records will be inaccurate')
                            end
                            if ~ismember(ndims(thisFrame),[2 3])
                                error('moreStim should return a single monochrome or RGB frame') %will add rgba, just haven't tested...
                            end
                        otherwise
                            error('huh?')
                    end
                    drawFrameUsingTextureCache(tm, window, i, frameNum, size(stim,3), lastI, dontclear, thisFrame, destRect, ...
                        filtMode, labelFrames, xOrigTextPos, yTextPos,strategy,floatprecision);
                case 'expert'
                    [doFramePulse expertCache phaseRecords(phaseNum).dynamicDetails textLabel i dontclear indexPulse dynamicSounds finish] ...
                        = drawExpertFrame(stimManager,stim,i,phaseStartTime,totalFrameNum,window,textLabel,...
                        destRect,filtMode,expertCache,ifi,scheduledFrameNum,tm.dropFrames,dontclear,...
                        phaseRecords(phaseNum).dynamicDetails,trialRecords,currentCLUT,phaseRecords,phaseNum,tm);
                otherwise
                    strategy
                    error('unrecognized strategy')
            end
            
            if finish
                if isinf(numFramesInStim)
                    numFramesInStim = framesInPhase; %causes handlePhasedTrialLogic to transition to next phase
                    
                    switch phaseType %hmmm, how else do this?  trialManager shouldn't know about this stuff...
                        case 'pre-request'
                            %do request reward
                        case 'discrim'
                            if isempty(trialRecords(trialInd).trialDetails.correct)
                                trialRecords(trialInd).trialDetails.correct = strcmp(phaseRecords(phaseNum).dynamicDetails.result,'correct'); %causes updateTrialState to do reward
                            else
                                error('huh')
                            end
                            if isempty(trialRecords(trialInd).result)
                                trialRecords(trialInd).result = phaseRecords(phaseNum).dynamicDetails.result; %causes handlePhasedTrialLogic to propogate nominal result
                                if ismember(trialRecords(trialInd).result,{'correct','timedout','incorrect','tooEarly'})
                                    trialRecords(trialInd).result='nominal';
                                end
                            else
                                error('huh')
                            end
                        otherwise
                            error('huh')
                    end
                else
                    error('huh')
                end
            end
            
            setStatePins(station,'index',indexPulse);
            
            timestamps.frameDrawn=GetSecs;
            
            if frameDropCorner.on
                Screen('FillRect', window, frameDropCorner.seq(frameDropCorner.ind), frameDropCorner.rect);
                frameDropCorner.ind=frameDropCorner.ind+1;
                if frameDropCorner.ind>length(frameDropCorner.seq)
                    frameDropCorner.ind=1;
                end
            end
            
            timestamps.frameDropCornerDrawn=GetSecs;
            
            %text commands are supposed to be last for performance reasons
            if manual
                didManual=1;
            end
            if window>=0 && showText
                xTextPos = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, normBoundsRect, stimID, protocolStr, ...
                    textLabel, trialLabel, i, frameNum, manual, didManual, didAPause, ptbVersion, ratrixVersion,phaseRecords(phaseNum).responseDetails.numMisses, phaseRecords(phaseNum).responseDetails.numApparentMisses, phaseInd, getStimType(spec),textType,ports);
            end
            
            timestamps.textDrawn=GetSecs;
            
        else
            %do we need to copy previous screen?
            %Screen('CopyWindow', window, window);
            if window>=0
                Screen('FillRect',window)
                Screen('DrawText',window,'paused (k+p to toggle)',xTextPos,yTextPos,100*ones(1,3));
            end
        end
        
        % whoops -- see https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/FAQ%3A-Performance-Tuning#optimal-code-structure
        % don't know how i missed this before, but all non gfx logic should go here
        % to take advantage of background rendering on gpu
        
        [timestamps headroom(totalFrameNum)] = flipFrameAndDoPulse(tm, window, dontclear, framesPerUpdate, ifi, paused, doFramePulse,station,timestamps);
        lastI=i;
        
        [phaseRecords(phaseNum).responseDetails timestamps] = ...
            saveMissedFrameData(tm, phaseRecords(phaseNum).responseDetails, frameNum, timingCheckPct, ifi, timestamps);
        
        timestamps.missesRecorded=GetSecs;
    else
        
        if ~isempty(analogOutput) || window<=0 || strcmp(tm.displayMethod,'LED')
            phaseRecords(phaseNum).LEDintermediateTimestamp=GetSecs; %need to preallocate
            phaseRecords(phaseNum).intermediateSampsOutput=get(analogOutput,'SamplesOutput'); %need to preallocate
            
            if ~isempty(framesUntilTransition)
                %framesUntilTransition is calculated off of the screen's ifi which is not correct when using LED
                framesUntilTransition=framesInPhase+2; %prevent handlePhasedTrialLogic from tripping to next phase
            end
            
            %note this logic is related to updateFrameIndexUsingTextureCache
            if ~loop && (get(analogOutput,'SamplesOutput')>=numSamps || ~outputsamplesOK)
                if isempty(responseOptions)
                    done=1;
                end
                if ~isempty(framesUntilTransition)
                    framesUntilTransition=framesInPhase+1; %cause handlePhasedTrialLogic to trip to next phase
                end
            end
        end
        
    end
    
    % =========================================================================
        
    if ~isempty(eyeTracker)
        if ~checkRecording(eyeTracker)
            sca
            error('lost tracker connection!')
        end
        [gazeEstimates samples] = getSamples(eyeTracker);
        % gazeEstimates should be a Nx2 matrix, samples should be Nx43 matrix, totalFrameNum is the frame number we are on
        numEyeTrackerSamples = size(samples,1);
        
        if (totalEyeDataInd+numEyeTrackerSamples)>length(eyeData) %if samples from this frame make us exceed size of eyeData
            
            %edf notes that this method is more expensive than necessary -- by expanding the matrix in this way, the old matrix still has to be copied in
            %instead, consider using a cell array and adding your new allocation chunk as an {end+1} cell with your matrix of nans, then no copying will be necessary
            %then you can concat all your cells at the end of the trial
            
            %  allocateMore
            newEnd=length(eyeData)+ framesPerAllocationChunk;
            %             disp(sprintf('did allocation to eyeTrack data; up to %d samples enabled',newEnd))
            eyeData(end+1:newEnd,:)=nan;
            eyeDataFrameInds(end+1:newEnd,:)=nan;
            gaze(end+1:newEnd,:)=nan;
        end
        
        if ~isempty(gazeEstimates) && ~isempty(samples)
            gaze(totalEyeDataInd:totalEyeDataInd+numEyeTrackerSamples-1,:) = gazeEstimates;
            eyeData(totalEyeDataInd:totalEyeDataInd+numEyeTrackerSamples-1,:) = samples;
            eyeDataFrameInds(totalEyeDataInd:totalEyeDataInd+numEyeTrackerSamples-1,:) = totalFrameNum;
            totalEyeDataInd = totalEyeDataInd + numEyeTrackerSamples;
        end
    end
    
    timestamps.eyeTrackerDone=GetSecs;
    
    % =========================================================================
    % all trial logic follows
    
    if ~paused && msRewardOwed+msRequestRewardOwed<=0
        ports=readPorts(station);
    end
    doValves=0*ports;
    doPuff=false;
    
    [keyIsDown,secs,keyCode]=KbCheck; % do this check outside of function to save function call overhead
    timestamps.kbCheckDone=GetSecs;
    
    if keyIsDown %bug: by overwriting ports here, you will overwrite any stochastic reward
        [didAPause paused done trialRecords(trialInd).result doValves ports didValves didHumanResponse manual ...
            doPuff pressingM pressingP,timestamps.kbOverhead,timestamps.kbInit,timestamps.kbKDown] ...
            = handleKeyboard(tm, keyCode, didAPause, paused, done, trialRecords(trialInd).result, doValves, ports, didValves, didHumanResponse, ...
            manual, doPuff, pressingM, pressingP, originalPriority, priorityLevel, KbConstants);
    end
    
    timestamps.keyboardDone=GetSecs;
    
    % do stochastic port hits after keyboard so that wont happen if another port already triggered
    if ~paused
        if ~isempty(autoTrigger) && ~any(ports)
            for j=1:2:length(autoTrigger)
                if rand<autoTrigger{j}
                    winner = randi(length(autoTrigger{j+1})); %no one verifies these are legit port numbers :(
                    ports(autoTrigger{j+1}(winner)) = 1;
                    didStochasticResponse=true; %edf: shouldn't this only be if one was tripped?
                    break;
                end
            end
        end
    end
    
    if ~paused
        % end of a response
        if lookForChange && any(ports~=lastPorts) % end of a response
            phaseRecords(thisResponsePhaseNum).responseDetails.durs{end+1} = GetSecs() - respStart;
            lookForChange=false;
            logIt=true;
            if ~toggleStim % beambreak mode (once request ends, stop showing stim)
                isRequesting=~isRequesting;
            end
            
            % 1/21/09 - how should we handle tries? - do we count attempts that occur during a phase w/ no port transitions (ie timeout only)?
            % start of a response
        elseif any(ports~=lastPorts) && logIt
            phaseRecords(phaseNum).responseDetails.tries{end+1} = ports;
            phaseRecords(phaseNum).responseDetails.times{end+1} = GetSecs() - startTime;
            respStart = GetSecs();
            playRequestSoundLoop = false;
            logIt=false;
            lookForChange=true;
            thisResponsePhaseNum=phaseNum;
        end
    end
    
    timestamps.enteringPhaseLogic=GetSecs;
    
    if ~paused
        [tm done newSpecInd phaseInd updatePhase transitionedByTimeFlag ...
            transitionedByPortFlag trialRecords(trialInd).result isRequesting lastSoundsLooped ...
            timestamps.logicGotSounds timestamps.logicSoundsDone timestamps.logicFramesDone ...
            timestamps.logicPortsDone timestamps.logicRequestingDone goDirectlyToError trialRecords(trialInd).stimDetails] ...
            = handlePhasedTrialLogic(tm, done, ...
            ports, lastPorts, station, phaseInd, phaseType, transitionCriterion, framesUntilTransition, numFramesInStim, framesInPhase, isFinalPhase, ...
            trialRecords(trialInd).trialDetails, trialRecords(trialInd).stimDetails, trialRecords(trialInd).result, ...
            stimManager, msRewardSound, msPenaltySound, targetOptions, distractorOptions, requestOptions, ...
            playRequestSoundLoop, isRequesting, soundNames, lastSoundsLooped, dynamicSounds);
        
        % if goDirectlyToError, then reset newSpecInd to the first error phase in stimSpecs
        if goDirectlyToError
            newSpecInd=find(strcmp(cellfun(@getPhaseType,stimSpecs,'UniformOutput',false),'reinforced'));
        end
        
        
    end
    timestamps.phaseLogicDone=GetSecs;
    
    % =========================================================================
    
    
    
    % =========================================================================
    % reward handling
    % calculate elapsed time since last loop, and decide whether to start/stop reward
    if isempty(thisRewardPhaseNum)
        % default to this phase's phaseRecord, but we will hard-set this during a rStart, so that
        % the last loop of a reward gets added to the correct N-th phaseRecord, instead of the (N+1)th
        % this happens b/c the phaseNum gets updated before reward stuff...
        thisRewardPhaseNum = phaseNum;
    end
    
    if ~isempty(lastRewardTime) && rewardCurrentlyOn
        rewardCheckTime = GetSecs();
        elapsedTime = rewardCheckTime - lastRewardTime;
        if strcmp(getRewardMethod(station),'localTimed')
            if ~doRequestReward % this was a normal reward, log it
                msRewardOwed = msRewardOwed - elapsedTime*1000.0;
                phaseRecords(thisRewardPhaseNum).actualRewardDurationMSorUL = phaseRecords(thisRewardPhaseNum).actualRewardDurationMSorUL + elapsedTime*1000.0;
            else % this was a request reward, dont log it
                msRequestRewardOwed = msRequestRewardOwed - elapsedTime*1000.0;
                phaseRecords(thisRewardPhaseNum).responseDetails.requestRewardDurationActual{end}=phaseRecords(thisRewardPhaseNum).responseDetails.requestRewardDurationActual{end}+elapsedTime*1000.0;
            end
        elseif strcmp(getRewardMethod(station),'localPump')
            % in localPump mode, msRewardOwed gets zeroed out after the call to station/doReward
        end
    end
    lastRewardTime = GetSecs();
    
    rStart = msRewardOwed+msRequestRewardOwed > 0.0 && ~rewardCurrentlyOn;
    rStop = msRewardOwed+msRequestRewardOwed <= 0.0 && rewardCurrentlyOn;
    
    if rStart
        thisRewardPhaseNum=phaseNum;
        % used to properly put reward logging data in their respective phaseRecords
        % default is current phase, but will set after rStart
    end
    
    if rStop % if stop, then reset owed time to zero
        msRewardOwed=0;
        msRequestRewardOwed=0;
    end
    currentValveStates=getValves(station);
    
    % =========================================================================
    % if any doValves, override this stuff
    % newValveState will be used to keep track of doValves stuff - figure out server-based use later
    if any(doValves~=newValveState)
        switch getRewardMethod(station)
            case 'localTimed'
                [newValveState phaseRecords(phaseNum).valveErrorDetails]=...
                    setAndCheckValves(station,doValves,currentValveStates,phaseRecords(phaseNum).valveErrorDetails,GetSecs,'doValves');
            case 'localPump'
                if any(doValves)
                    if window<=0 || strcmp(tm.displayMethod,'LED')
                        ifi
                        error('ifi will not be appropriate here when using LED')
                    else
                        error('edf asks when this condition occurs?  shouldn''t all pump reward happen below in rStart?  primeMLsPerSec looks concerningly arbitrary.  is it for k+r (pump priming)?  in that case we need not be concerned about blocking/framedrops -- and the trial should be aborted with a flag that this happened.')
                        % 3/3/09 - error for now if not in 'static' mode b/c doReward blocks real-time loop
                        stimType=getStimType(spec);
                        if ~ischar(stimType) || ~strcmp(stimType,'static')
                            error('localPump only supported with a static stimulus until blocking is resolved');
                        end
                        primeMLsPerSec=1.0;
                        station=doReward(station,primeMLsPerSec*ifi,doValves,true);
                    end
                end
                newValveState=0*doValves; % set newValveStates to 0 because localPump locks the loop while calling doReward
            otherwise
                error('unsupported rewardMethod');
        end
        
    else
        if rStart || rStop
            rewardValves=zeros(1,getNumPorts(station));
            % we give the reward at whatever port is specified by the current phase (weird...fix later?)
            % the default if the current phase does not have a transition port is the requestOptions (input to stimOGL)
            % 1/29/09 - fix, but for now rewardValves is jsut wahtever the current port triggered is (this works for now..)
            if strcmp(class(ports),'double') %happens on osx, why?
                ports=logical(ports);
            end
            
            if ~isa(tm,'ball')
                rewardValves(ports)=1;
            else
                rewardValves(:)=1; %where put this?
            end
            
            %         if isempty(rewardPorts)
            %             rewardValves(requestOptions) = 1;
            %         else
            %             rewardValves(rewardPorts)=1;
            %         end
            rewardValves=logical(rewardValves);
            
            if length(rewardValves) ~= 3
                error('rewardValves has %d and currentValveStates has %d with port = %d', length(rewardValves), length(currentValveStates), port);
            end
            
            switch getRewardMethod(station)
                case 'localTimed'
                    if rStart
                        rewardCurrentlyOn = true;
                        [currentValveStates phaseRecords(thisRewardPhaseNum).valveErrorDetails]=...
                            setAndCheckValves(station,rewardValves,currentValveStates,phaseRecords(thisRewardPhaseNum).valveErrorDetails,lastRewardTime,'correct reward open');
                    elseif rStop
                        rewardCurrentlyOn = false;
                        [currentValveStates phaseRecords(thisRewardPhaseNum).valveErrorDetails]=...
                            setAndCheckValves(station,zeros(1,getNumPorts(station)),currentValveStates,phaseRecords(thisRewardPhaseNum).valveErrorDetails,lastRewardTime,'correct reward close');
                        % also add the additional time that reward was on from rewardCheckTime to now
                        rewardCheckToValveCloseTime = GetSecs() - rewardCheckTime;
                        %                         rewardCheckToValveCloseTime
                        if ~doRequestReward
                            phaseRecords(thisRewardPhaseNum).actualRewardDurationMSorUL = phaseRecords(thisRewardPhaseNum).actualRewardDurationMSorUL + rewardCheckToValveCloseTime*1000.0;
                            %                             phaseRecords(thisRewardPhaseNum).actualRewardDurationMSorUL
                            %                             'stopping normal reward'
                        else
                            phaseRecords(thisRewardPhaseNum).responseDetails.requestRewardDurationActual{end}=phaseRecords(thisRewardPhaseNum).responseDetails.requestRewardDurationActual{end}+rewardCheckToValveCloseTime*1000.0;
                            %                             'stopping request reward'
                        end
                        % newValveState=doValves|rewardValves; % this shouldnt be used for now...figure out later...
                    else
                        error('has to be either start or stop - should not be here');
                    end
                case 'localPump'
                    if rStart
                        rewardCurrentlyOn=true;
                        % 3/3/09 - error for now if not in 'static' mode b/c doReward blocks real-time loop
                        stimType=getStimType(spec);
                        if ~ischar(stimType) || ~strcmp(stimType,'static')
                            error('localPump only supported with a static stimulus until blocking is resolved');
                        end
                        station=doReward(station,(msRewardOwed+msRequestRewardOwed)/1000,rewardValves);
                        phaseRecords(thisRewardPhaseNum).actualRewardDurationMSorUL = phaseRecords(thisRewardPhaseNum).actualRewardDurationMSorUL + msRewardOwed;
                        msRewardOwed=0;
                        msRequestRewardOwed=0;
                        requestRewardDone=true;
                    elseif rStop
                        rewardCurrentlyOn=false;
                    end
                case 'serverPump'
                    
                    [currentValveState phaseRecords(thisRewardPhaseNum).valveErrorDetails quit serverValveChange phaseRecords(thisRewardPhaseNum).responseDetails ...
                        requestRewardStartLogged requestRewardDurLogged phaseRecords(thisRewardPhaseNum)] ...
                        = serverPumpRewards(tm, rn, station, newValveState, currentValveState, phaseRecords(thisRewardPhaseNum).valveErrorDetails, ...
                        startTime, serverValveChange, requestRewardStarted, ...
                        requestRewardStartLogged, rewardValves, requestRewardDone, ...
                        requestRewardDurLogged, phaseRecords(thisRewardPhaseNum).responseDetails, quit, phaseRecords(thisRewardPhaseNum));
                    
                otherwise
                    error('unsupported rewardMethod');
            end
        end
        
    end % end valves
    
    timestamps.rewardDone=GetSecs;
    
    if ~isempty(rn) || strcmp(getRewardMethod(station),'serverPump')
        [done quit phaseRecords(thisRewardPhaseNum).valveErrorDetails serverValveStates serverValveChange ...
            trialRecords(trialInd).result newValveState ...
            requestRewardDone requestRewardOpenCmdDone] ...
            = handleServerCommands(tm, rn, done, quit, requestRewardStarted, ...
            requestRewardStartLogged, requestRewardOpenCmdDone, ...
            requestRewardDone, station, ports, serverValveStates, doValves, ...
            trialRecords(trialInd).result);
    elseif isempty(rn) && strcmp(getRewardMethod(station),'serverPump')
        error('need a rnet for serverPump')
    end
    
    % also do datanet handling here
    % this should only handle 'server quit' commands for now.... (other stuff is caught by doTrial/bootstrap)
    if ~isempty(getDatanet(station))
        [garbage quit] = handleCommands(getDatanet(station),[]);
    end
    
    timestamps.serverCommDone=GetSecs;
    
    % =========================================================================
    % airpuff
    if isempty(thisAirpuffPhaseNum)
        thisAirpuffPhaseNum=phaseNum;
    end
    
    if ~isempty(lastAirpuffTime) && airpuffOn
        airpuffCheckTime = GetSecs();
        elapsedTime = airpuffCheckTime - lastAirpuffTime;
        msAirpuffOwed = msAirpuffOwed - elapsedTime*1000.0;
        phaseRecords(thisAirpuffPhaseNum).actualAirpuffDuration = phaseRecords(thisAirpuffPhaseNum).actualAirpuffDuration + elapsedTime*1000.0;
    end
    
    aStart = msAirpuffOwed > 0 && ~airpuffOn;
    aStop = msAirpuffOwed <= 0 && airpuffOn; % msAirpuffOwed<=0 also catches doPuff==false, and will stop airpuff when k+a is lifted
    if aStart || doPuff
        thisAirpuffPhaseNum = phaseNum; % set default airpuff phase num
        setPuff(station, true);
        airpuffOn = true;
    elseif aStop
        doPuff = false;
        airpuffOn = false;
        setPuff(station, false);
        airpuffCheckToSetPuffTime = GetSecs() - airpuffCheckTime; % time from the airpuff check to after setPuff returns
        % increase actualAirpuffDuration by this 'lag' time...
        phaseRecords(thisAirpuffPhaseNum).actualAirpuffDuration = phaseRecords(thisAirpuffPhaseNum).actualAirpuffDuration + airpuffCheckToSetPuffTime*1000.0;
    end
    lastAirpuffTime = GetSecs();
    
    % =========================================================================
    
    if isfield(trialRecords(trialInd),'pco')
        trialRecords(trialInd).pco = exec(trialRecords(trialInd).pco);
    end
    
    if updatePhase
        phaseRecords(phaseNum).transitionedByPortResponse = transitionedByPortFlag;
        phaseRecords(phaseNum).transitionedByTimeout = transitionedByTimeFlag;
        phaseRecords(phaseNum).containedManualPokes = didManual;
        phaseRecords(phaseNum).leftWithManualPokingOn = manual;
        phaseRecords(phaseNum).containedAPause = didAPause;
        phaseRecords(phaseNum).containedForcedRewards = didValves;
        phaseRecords(phaseNum).didHumanResponse = didHumanResponse;
        phaseRecords(phaseNum).didStochasticResponse = didStochasticResponse;
        
        phaseRecords(phaseNum).responseDetails.totalFrames = frameNum;
        % how do we only clear the textures from THIS phase (since all textures for all phases are precached....)
        % close all textures from this phase if in non-expert mode
        %         if ~strcmp(strategy,'expert')
        %             Screen('Close');
        %         else
        %             expertCleanUp(stimManager);
        %         end
        containedExpertPhase=strcmp(strategy,'expert') || containedExpertPhase;
    end
    
    timestamps.phaseRecordsDone=GetSecs;
    
    if ~paused
        framesInPhase = framesInPhase + 1; % moved from handlePhasedTrialLogic to prevent copy on write
        
        phaseInd = newSpecInd;
        frameNum = frameNum + 1;
        totalFrameNum = totalFrameNum + 1;
        framesSinceKbInput = framesSinceKbInput + 1;
    end
    
    timestamps.loopEnd=GetSecs;
end

if doProfile
    profile on
end

securePins(station);

if ~isempty(moviePtr)
    Screen('FinalizeMovie', moviePtr);
end

trialRecords(trialInd).phaseRecords=phaseRecords;
% per-trial records, collected from per-phase stuff
trialRecords(trialInd).containedAPause=any([phaseRecords.containedAPause]);
trialRecords(trialInd).didHumanResponse=any([phaseRecords.didHumanResponse]);
trialRecords(trialInd).containedForcedRewards=any([phaseRecords.containedForcedRewards]);
trialRecords(trialInd).didStochasticResponse=any([phaseRecords.didStochasticResponse]);
trialRecords(trialInd).containedManualPokes=didManual;
trialRecords(trialInd).leftWithManualPokingOn=manual;

if ~isempty(analogOutput)
    evts=showdaqevents(analogOutput);
    if ~isempty(evts)
        evts
    end
    
    stop(analogOutput);
    delete(analogOutput); %should pass back to caller and preserve for next trial so intertrial works and can avoid contruction costs
end

if ~containedExpertPhase
    Screen('Close'); %leaving off second argument closes all textures but leaves windows open
else
    %maybe once this was per phase, but now its per trial
    expertPostTrialCleanUp(stimManager);
end

Priority(originalPriority);

plotHeadroom=false;
if plotHeadroom
    headroomfig=figure;
    plot(headroom)
    title('headroom')
end

plotGaze=false;
if plotGaze
    gazefig=figure;
    subplot(2,1,1)
    plot(gaze)
    title('gaze')
    legend({'gaze_x','gaze_y'})
    subplot(2,1,2)
    plot(eyeData(:,27:30))
    legend({'raw_pupil_x','raw_pupil_y','raw_cr_x','raw_cr_y'})
end

if plotGaze || plotHeadroom
    fprintf('hit a key to close headroom and/or gaze figures')
    pause
    if plotHeadroom
        close(headroomfig)
    end
    if plotGaze
        close(gazefig)
    end
end

end % end function
