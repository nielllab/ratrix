function [quit response didManualInTrial manual actualReinforcementDurationMSorUL proposedReinforcementDurationMSorUL ... 
      phaseRecords eyeData gaze frameDropCorner] ...
    = runRealTimeLoop(tm, window, ifi, stimSpecs, phaseData, stimManager, msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, ...
    station, manual,allowQPM,timingCheckPct,noPulses,textLabel,rn,subID,stimID,protocolStr,ptbVersion,ratrixVersion,trialLabel,msAirpuff, ...
    originalPriority, verbose, eyeTracker, frameDropCorner)

  
% need actual versus proposed reward duration (save in phaseRecords per phase)
actualReinforcementDurationMSorUL = 0;
proposedReinforcementDurationMSorUL = 0;
didManualInTrial=false;
eyeData=[];
gaze=[];

% We will break this main function into smaller functions also in the trialManager class
% =====================================================================================================================
% =====================================================================================================================
% START pre-loop initialization

% Variables
filtMode = 0;               %How to compute the pixel color values when the texture is drawn scaled
%                           %0 = Nearest neighbour filtering, 1 = Bilinear filtering (default, and BAD)

framesPerUpdate = 1;        %set number of monitor refreshes for each one of your refreshes

labelFrames = 1;            %print a frame ID on each frame (makes frame calculation slow!)
dontclear= 0;
expertCache=[];
ports=0*readPorts(station);
if ismac
    %also not good enough on beige computer w/8600
    %http://psychtoolbox.org/wikka.php?wakka=FaqPerformanceTuning1
    %Screen('DrawText'): This is fast and low-quality on MS-Windows and beautiful but slow on OS/X.

    %Screen('Preference', 'TextAntiAliasing', 0); %not good enough
    %DrawFormattedText() won't be any faster cuz it loops over calls to Screen('DrawText'), tho it would clean this code up a bit.
    labelFrames=0;
end


quit=false;
responseOptions = union(targetOptions, distractorOptions);

%need to move this stuff into stimManager or trialManager
toggleStim=1;
numFramesUntilStopSavingMisses=1000;

%originalPriority=Priority; %done in stimOGL now

% preallocate phaseRecords

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
responseDetails.tries={};
responseDetails.times={};
responseDetails.requestRewardPorts=[];
responseDetails.durs={};
responseDetails.requestRewardStartTime=[];
responseDetails.requestRewardDurationActual=[];


[phaseRecords(1:length(stimSpecs)).responseDetails]= deal(responseDetails);
[phaseRecords(1:length(stimSpecs)).response]=deal('none');



% Initialize this phaseRecord
[phaseRecords(1:length(stimSpecs)).proposedReinforcementSizeULorMS] = deal([]);
[phaseRecords(1:length(stimSpecs)).proposedReinforcementType] = deal([]);
[phaseRecords(1:length(stimSpecs)).proposedSounds] = deal([]);

% added 8/18/08 - strategy (loop, static, trigger, cache, dynamic, expert, timeIndexed, or frameIndexed)
[phaseRecords(1:length(stimSpecs)).loop] = deal([]);
[phaseRecords(1:length(stimSpecs)).trigger] = deal([]);
[phaseRecords(1:length(stimSpecs)).strategy] = deal([]);
[phaseRecords(1:length(stimSpecs)).stochasticProbability] = deal([]);
[phaseRecords(1:length(stimSpecs)).timeoutLengthInFrames] = deal([]);

% pump stuff
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

% manual poking stuff
[phaseRecords(1:length(stimSpecs)).containedManualPokes]= deal([]);
[phaseRecords(1:length(stimSpecs)).leftWithManualPokingOn]= deal([]);

% =====================================================================================================================
% check for constands and rewardMethod
if ~isempty(rn)
    constants = getConstants(rn);
end

if strcmp(getRewardMethod(station),'serverPump')
    if isempty(rn) || ~isa(rn,'rnet')
        error('need an rnet for station with rewardMethod of serverPump')
    end
end

% =====================================================================================================================
% more variables
done=0;
rewardCurrentlyOn=false;
msRewardOwed=0;
lastRewardTime=[];
msAirpuffOwed=0;
airpuffOn=false;
lastAirpuffTime=[];


% =====================================================================================================================
% Get ready with various stuff

% For the Windows version of Priority (and Rush), the priority levels set
% are  "process priority levels". There are 3 priority levels available,
% levels 0, 1, and 2. Level 0 is "normal priority level", level 1 is "high
% priority level", and level 2 is "real time priority level". Combined
% with

%Priority(9);
[keyIsDown,secs,keyCode]=KbCheck; %load mex files into ram + preallocate return vars
GetSecs;
Screen('Screens');

% set font size correctly
standardFontSize=11; %big was 25
subjectFontSize=35;
oldFontSize = Screen('TextSize',window,standardFontSize);
Screen('Preference', 'TextRenderer', 0);  % consider moving to PTB setup
[normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');

%KbName('UnifyKeyNames'); %does not appear to choose keynamesosx on windows - KbName('KeyNamesOSX') comes back wrong
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

priorityLevel=MaxPriority(window,'GetSecs','KbCheck');

Priority(priorityLevel); % should use Rush to prevent hard crash if script errors, but then everything below is a string, annoying...
if verbose
    disp(sprintf('running at priority %d',priorityLevel));
end

% =====================================================================================================================
% 10/19/08 - initialize eyeTracker
if ~isempty(eyeTracker)
   perTrialSyncing=false; %could pass this in if we ever decide to use it; now we don't
   if perTrialSyncing && isa(eyeTracker,'eyeLinkTracker')
       status=Eyelink('message','SYNCTIME');
       if status~=0
           error('message error, status: ',status)
       end
   end

   framesPerAllocationChunk=getFramesPerAllocationChunk(eyeTracker);

   if isa(eyeTracker,'eyeLinkTracker')
       eyeData=nan(framesPerAllocationChunk,40);
       gaze=nan(framesPerAllocationChunk,2);
   else
       error('no other methods')
   end
end
% =====================================================================================================================

% END pre-loop initialization

% =====================================================================================================================
% =====================================================================================================================
% Pre-phase initialization (cont.)

specInd = 1; % which phase we are on (index for stimSpecs and phaseData)
updatePhase = 1; % are we starting a new phase?
audioStim = []; % this variable isn't used to play sounds - will be handled differently
lastI = 0; % variables to be generated by Flip command
vbl = 0;
sos = 0;
ft = 0;
lastFrameTime = 0;
framesSinceKbInput = 0;
lastSoundsPlayed={};
totalFrameNum=1;
doFramePulse=1;

audioStimPlaying = false;
lastLoopEnd=0;
startTime=0;
yNewTextPos=0;
txtLabel='';
manTxt='';
when=0;
whenTime=0;
ft=0;
missed=0;
thisIFI=0;
thisIFIErrorPct = 0;

doValves=0*ports;
newValveState=doValves;
doPuff=false;
mThisLoop=0;
pThisLoop=0;


shiftDown=false;
ctrlDown=false;
atDown=false;
kDown=false;
portsDown=false(1,length(ports));
pNum=0;


time1=0;
time2=0;
time3=0;
time4=0;
time5=0;
time6=0;
time7=0;
soundTime=0;
maxSoundTime=0.002;
soundName='';
somethingElseOn=false;
keepGoingOn=false;

numDrops=0;
numApparentDrops=0;
barebones=false;

% phaseRecords = [];


% =====================================================================================================================
% Draw and flip last frame (finalScreenLuminance)
% function [vbl sos ft lastFrameTime lastI] = drawFirstFrame(tm, window, standardFontSize, texture, lengthOfStim, destRect, filtMode, dontclear)
% [vbl sos ft lastFrameTime lastI] = ...
%     drawFirstFrame(tm, window, standardFontSize, textures(size(stim,3)+1), size(stim,3), destRect, filtMode, dontclear);

% =====================================================================================================================
% ENTERING LOOP

%logwrite('about to enter stimOGL loop');

doLED=false;
if doLED
    [ao bits]=openNidaqForAnalogOutput(sampRate,range);
    putdata(ao,data);
    start(ao);
end


%any stimulus onset synched actions

startTime=GetSecs();
respStart = 0; % initialize respStart to zero - it won't get set until we get a response through trial logic

audioStimPlaying = false;
response='none'; %initialize

[vbl sos startTime]=Screen('Flip',window);  %make sure everything after this point is preallocated

if ~isempty(tm.datanet)
    % 10/17/08 - start of a datanet trial - timestamp
    datanet_constants = getConstants(tm.datanet);
    commands = [];
    commands.cmd = datanet_constants.stimToDataCommands.S_TIMESTAMP_CMD;
    [trialData, gotAck] = sendCommandAndWaitForAck(tm.datanet, getCon(tm.datanet), commands);
end

%show stim -- be careful in this realtime loop!
while ~done && ~quit;
    %logwrite('top of stimOGL loop');
    time1=GetSecs;
    % moved from inside if updatePhase to every time this loop runs (b/c we moved from function to inside runRealTimeLoop)
    xOrigTextPos = 10;
    xTextPos=xOrigTextPos;
    yTextPos = 20;
    yNewTextPos=yTextPos;
    
    % =====================================================================================================================
    % if we are entering a new phase, re-initialize variables
    if updatePhase == 1
        
        i=0;
        frameIndex=0;
%         attempt=0;

        frameNum=1;
        phaseStartTime=GetSecs;


%         logIt=0;
%         stopListening=0;
%         lookForChange=0;
%         player=[];
%         currSound='';


%         lastPorts=0*readPorts(station);
        pressingM=0;
        pressingP=0;
        didAPause=0;
        paused=0;
        didPulse=0;
        didValves=0;
        didManual=false; %initialize
        arrowKeyDown=false; %1/9/09 - for phil's stuff
        
%         puffStarted=0;
%         puffDone=false;
        
        %used for timed frames stimuli
        if isempty(requestOptions)
            requestFrame=1;
        else
            requestFrame=0;
        end

        currentValveState=getValves(station); % cant do verifyClosed here because it might be open from a reward from previous phase
%         valveErrorDetails=[];
        requestRewardStarted=false;
        requestRewardStartLogged=false;
        requestRewardDone=false;
        requestRewardPorts=0*readPorts(station);
        requestRewardDurLogged=false;
        requestRewardOpenCmdDone=false;
        serverValveChange=false;
        serverValveStates=false;
%         potentialStochasticResponse=false;
        didStochasticResponse=false;
        didHumanResponse=false;

        isRequesting=0;
%         stimToggledOn=0;


        
        % load stimSpec and phaseData
        spec = stimSpecs{specInd};
        stim = getStim(spec);
        
        transitionCriterion = getCriterion(spec);
        framesUntilTransition = getFramesUntilTransition(spec);
        % flag for graduation by time (port was autoselected due to graduation by time)
%         transitionedByTimeFlag = false;
%         transitionedByPortFlag = false;
        % reinforcement
        rewardType = getRewardType(spec);
        rewardDuration = getRewardDuration(spec);
        rewardPorts = 2; % TEMPORARY UNTIL FIGURE OUT HOW TO ASSIGN THIS
        % if there is a reinforcement, then set up for functions that follow trial logic
        if ~isempty(rewardType) && strcmp(rewardType, 'reward')
            requestRewardStarted = true;
            requestRewardPorts=zeros(1,getNumPorts(station));
            requestRewardPorts(rewardPorts) = 1;
            proposedReinforcementDurationMSorUL = proposedReinforcementDurationMSorUL + rewardDuration;
            msRewardOwed = msRewardOwed + rewardDuration;
        elseif ~isempty(rewardType) && strcmp(rewardType, 'airpuff')
            msAirpuffOwed = msAirpuffOwed + rewardDuration;
%             doPuff = true;
            proposedReinforcementDurationMSorUL = proposedReinforcementDurationMSorUL + rewardDuration;
        end
        
        stepsInPhase = 0;
        isFinalPhase = getIsFinalPhase(spec); % we set the isFinalPhase flag to true if we are on the last phase
        stochasticDistribution = getStochasticDistribution(spec);
        
        phase = phaseData{specInd};
  
        floatprecision = phase.floatprecision;
        frameIndexed = phase.frameIndexed;
        loop = phase.loop;
        trigger = phase.trigger;
        timeIndexed = phase.timeIndexed;
        indexedFrames = phase.indexedFrames;
        timedFrames = phase.timedFrames;
        
        strategy = phase.strategy;
        % 11/9/08 - if dynamic strategy, then create a big field
%         if strcmp(strategy, 'dynamic')
%             numDynamicFrames = length(stim.seedValues);
% %             phaseRecords(specInd).big=zeros(stim.height,stim.width,numDynamicFrames);
%         end
        destRect = phase.destRect;
        
        textures = phase.textures;
        numDots = phase.numDots;
        dotX = phase.dotX;
        dotY = phase.dotY;
        dotLocs = phase.dotLocs;
        dotSize = phase.dotSize;
        dotCtr = phase.dotCtr;
        
        currentCLUT = phase.CLUT;
        
        % Initialize this phaseRecord
%         phaseRecords(specInd).response='none';
%         phaseRecords(specInd).responseDetails.numMisses=0;
%         phaseRecords(specInd).responseDetails.misses=[];
%         phaseRecords(specInd).responseDetails.afterMissTimes=[];
% 
%         phaseRecords(specInd).responseDetails.numApparentMisses=0;
%         phaseRecords(specInd).responseDetails.apparentMisses=[];
%         phaseRecords(specInd).responseDetails.afterApparentMissTimes=[];
%         phaseRecords(specInd).responseDetails.apparentMissIFIs=[];
%         phaseRecords(specInd).responseDetails.numFramesUntilStopSavingMisses=numFramesUntilStopSavingMisses;
%         phaseRecords(specInd).responseDetails.numUnsavedMisses=0;
%         phaseRecords(specInd).responseDetails.nominalIFI=ifi;
% 
        phaseRecords(specInd).dynamicDetails={};
        phaseRecords(specInd).responseDetails.toggleStim=toggleStim;
%         
        % Initialize this phaseRecord
        phaseRecords(specInd).proposedReinforcementSizeULorMS = rewardDuration;
        phaseRecords(specInd).proposedReinforcementType = rewardType;
        
        % added 8/18/08 - strategy (loop, static, trigger, cache, dynamic, expert, timeIndexed, or frameIndexed)
        phaseRecords(specInd).loop = loop;
        phaseRecords(specInd).trigger = trigger;
        phaseRecords(specInd).strategy = strategy;
        phaseRecords(specInd).stochasticProbability = stochasticDistribution;
        phaseRecords(specInd).timeoutLengthInFrames = framesUntilTransition;
%         
%         % pump stuff
%         phaseRecords(specInd).valveErrorDetails=[];
%         phaseRecords(specInd).latencyToOpenValves=[];
%         phaseRecords(specInd).latencyToCloseValveRecd=[];
%         phaseRecords(specInd).latencyToCloseValves=[];
%         phaseRecords(specInd).latencyToRewardCompleted=[];
%         phaseRecords(specInd).latencyToRewardCompletelyDone=[];
%         phaseRecords(specInd).primingValveErrorDetails=[];
%         phaseRecords(specInd).latencyToOpenPrimingValves=[];
%         phaseRecords(specInd).latencyToClosePrimingValveRecd=[];
%         phaseRecords(specInd).latencyToClosePrimingValves=[];
%         phaseRecords(specInd).actualPrimingDuration=[];
%         
%         % manual poking stuff
%         phaseRecords(specInd).containedManualPokes=[];
%         phaseRecords(specInd).leftWithManualPokingOn=[];
                
        updatePhase = 0;
        
    end
    
    % =====================================================================================================================
    if ~paused

        doFramePulse=~noPulses;
        switch strategy

            % ====================================================================================================================
            case 'textureCache'
                % function to determine the frame index using the textureCache strategy
                [tm frameIndex i done doFramePulse didPulse] = updateFrameIndexUsingTextureCache(tm, ...
                frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames, size(stim,3), isRequesting, ...
                i, requestFrame, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse);
            
                % =====================================================================================================================
                % function to draw the appropriate texture using the textureCache strategy
                time2=GetSecs;
                drawFrameUsingTextureCache(tm, window, i, frameNum, size(stim,3), lastI, dontclear, textures(i), destRect, ...
                    filtMode, labelFrames, xOrigTextPos, yNewTextPos);
                
            % =====================================================================================================================
            case 'expert'
                % 10/31/08 - implementing expert mode
                % call a method of the given stimManager that draws the expert frame
                i=i+1; % 11/7/08 - this needs to happen first because i starts at 0
                [doFramePulse expertCache dynamicDetails textLabel] = ...
                    drawExpertFrame(stimManager,stim,i,phaseStartTime,window,textLabel,floatprecision,destRect,filtMode,expertCache);
                if ~isempty(dynamicDetails)
                    phaseRecords(specInd).dynamicDetails{end+1}=dynamicDetails; % dynamicDetails better specify what frame it is b/c the record will not save empty details
                end
            otherwise
                error('unrecognized strategy')
        end

        time3=GetSecs;
        %logwrite(sprintf('stim is started, i is calculated: %d',i));
        
        if frameDropCorner.on
            Screen('FillRect', window, round(size(currentCLUT,1)*frameDropCorner.seq(frameDropCorner.ind)), frameDropCorner.rect);

            frameDropCorner.ind=frameDropCorner.ind+1;
            if frameDropCorner.ind>length(frameDropCorner.seq)
                frameDropCorner.ind=1;
            end
        end

        %text commands are supposed to be last for performance reasons

        % =====================================================================================================================
        % function for drawing text
        if manual
            didManual=1;
        end
        if window>=0
            xTextPos = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, normBoundsRect, stimID, protocolStr, ...
              textLabel, trialLabel, i, frameNum, manual, didAPause, ptbVersion, ratrixVersion);
        end
        time4=GetSecs;
        
        % =====================================================================================================================
    else
        %do i need to copy previous screen?
        %Screen('CopyWindow', window, window);
        if window>=0
            Screen('DrawText',window,'paused (k+p to toggle)',xTextPos,yNewTextPos,100*ones(1,3));
        end
    end

    % =====================================================================================================================
    % function here to do flip and other Screen stuff
    time5=GetSecs;
    [lastI when vbl sos ft missed time6 time7 whenTime] = ...
        flipFrameAndDoPulse(tm, window, dontclear, i, vbl, framesPerUpdate, ifi, paused, doFramePulse,station); 
    
    % =====================================================================================================================
    % function here to save information about missed frames
    [phaseRecords(specInd).responseDetails lastFrameTime numDrops numApparentDrops] = ...
        saveMissedFrameData(tm, phaseRecords(specInd).responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi, numDrops,numApparentDrops,...
        when,whenTime,lastLoopEnd,time1,time2,time3,time4,time5,time6,time7,barebones,vbl);
    
    % =====================================================================================================================
    % =====================================================================================================================
    % 10/19/08 - get eyeTracker sample
    % immediately after the frame pulse is ideal, not before the frame pulse (which is more important)
    if ~isempty(eyeTracker)
       if ~checkRecording(eyeTracker)
           sca
           error('lost tracker connection!')
       end

       if totalFrameNum>length(eyeData)
           %  allocateMore
           newEnd=length(eyeData)+ framesPerAllocationChunk;
           disp(sprintf('did allocation to eyeTrack data; up to %d samples enabled',newEnd))
           eyeData(end+1:newEnd,:)=nan;
           gaze(end+1:newEnd,:)=nan;
       end

       [gaze(totalFrameNum,:) eyeData(totalFrameNum,:)]=getSample(eyeTracker);

    end

    % =====================================================================================================================
    %logwrite('entering trial logic');
    %all trial logic here
    if ~paused
        ports=readPorts(station);
    end
    doValves=0*ports;
    doPuff=false;
    
    % =====================================================================================================================
    % function to handle keyboard input
    %     mThisLoop=0;
    %     pThisLoop=0;
    [keyIsDown,secs,keyCode]=KbCheck; % do this check outside of function to save function call overhead
    if keyIsDown && framesSinceKbInput > -1
         [didAPause paused done phaseRecords(specInd).response doValves ports didValves didHumanResponse manual doPuff pressingM pressingP] = ...
         handleKeyboard(tm, keyCode, didAPause, paused, done, phaseRecords(specInd).response, doValves, ports, didValves, didHumanResponse, ...
         manual, doPuff, pressingM, pressingP, allowQPM, originalPriority, priorityLevel, KbConstants);
        framesSinceKbInput=0;
    end

    % =====================================================================================================================
    % Handle stochastic port hits (has to be after keyboard so that wont happen if another port already triggered)
    % 8/18/08 - added stochastic port hits
    if ~paused
        if ~isempty(stochasticDistribution) && isempty(find(ports))
            for j=1:2:length(stochasticDistribution)
                if rand<stochasticDistribution{j} % if we meet this probability - go to the corresponding port
                    ports(stochasticDistribution{j+1}) = 1;
                    break;
                end
            end
            didStochasticResponse=true;
        end
    end
    
    % 1/21/09 - how should we handle tries? - do we count attempts that occur during a phase w/ no port transitions (ie timeout only)?
    if any(ports)
        phaseRecords(specInd).responseDetails.tries{end+1} = ports;
        phaseRecords(specInd).responseDetails.times{end+1} = GetSecs() - startTime;
    end
    
    % =====================================================================================================================
    % large function here that handles trial logic (what state are we in - did we have a request, response, should we give reward, etc)
    % if phaseRecords(specInd).response got set by keyboard, duplicate response on trial level
    if ~strcmp('none', phaseRecords(specInd).response)
        response = phaseRecords(specInd).response;
    end
    
    [tm done newSpecInd specInd updatePhase transitionedByTimeFlag ...
        transitionedByPortFlag phaseRecords(specInd).response response isRequesting lastSoundsPlayed] = ... 
        handlePhasedTrialLogic(tm, done, ...
        ports, station, specInd, transitionCriterion, framesUntilTransition, stepsInPhase, isFinalPhase, ... 
        phaseRecords(specInd).response, response, ...
        stimManager, msRewardSound, msPenaltySound, targetOptions, distractorOptions, requestOptions, isRequesting, lastSoundsPlayed);
    
    stepsInPhase = stepsInPhase + 1; %10/16/08 - moved from handlePhasedTrialLogic to prevent COW
 
    % =====================================================================================================================
    % reward stuff copied from old phased stimOGL
    % update reward owed and elapsed time
    if ~isempty(lastRewardTime) && rewardCurrentlyOn
        elapsedTime = getSecs() - lastRewardTime;
        if strcmp(getRewardMethod(station),'localTimed')
            msRewardOwed = msRewardOwed - elapsedTime*1000.0;
       % error('elapsed time was %d and msRewardOwed is now %d', elapsedTime, msRewardOwed);
            actualReinforcementDurationMSorUL = actualReinforcementDurationMSorUL + elapsedTime*1000.0;
        elseif strcmp(getRewardMethod(station),'localPump')
            % in localPump mode, msRewardOwed gets zeroed out after the call to station/doReward
            % no need to update here
        end
    end
    lastRewardTime = getSecs();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % start/stop as necessary
    start = msRewardOwed > 0.0 && ~rewardCurrentlyOn;
    stop = msRewardOwed <= 0.0 && rewardCurrentlyOn;
    
    
    if start || stop
        % get current state of valves and what to change
        currentValveStates=getValves(station);
        rewardValves=zeros(1,getNumPorts(station));
        % we give the reward at whatever port is specified by the current phase (weird...fix later?)
        % the default if the current phase does not have a criterion port is the requestOptions (input to stimOGL)
        % 1/29/09 - fix, but for now rewardValves is jsut wahtever the current port triggered is (this works for now..)
        rewardValves(ports)=1;
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
                % handle start and stop cases
                if start
                    'turning on localTimed reward'
                    rewardCurrentlyOn = true;
                    %OPEN VALVE
                    [currentValveStates phaseRecords(specInd).valveErrorDetails]=...
                    setAndCheckValves(station,rewardValves,currentValveStates,...
                        phaseRecords(specInd).valveErrorDetails,...
                        lastRewardTime,'correct reward open');
                    rewardValves
                    disp('opening valves')
                    GetSecs
                elseif stop
                    'turning off reward'
                    rewardCurrentlyOn = false;
                    %CLOSE VALVE
                    [currentValveStates phaseRecords(specInd).valveErrorDetails]=...
                    setAndCheckValves(station,zeros(1,getNumPorts(station)),currentValveStates,...
                        phaseRecords(specInd).valveErrorDetails,...
                        lastRewardTime,'correct reward close');
                    newValveState=doValves|requestRewardPorts;
                    disp('closing valves')
                    GetSecs
                else
                    error('has to be either start or stop - should not be here');
                end
            case 'localPump'
                % localPump method copied from merge stimOGL (non-phased)
                if start
                    'turning on localPump reward'
                    rewardCurrentlyOn=true;
                    station=doReward(station,msRewardOwed/1000,requestRewardPorts);
                    actualReinforcementDurationMSorUL = actualReinforcementDurationMSorUL + msRewardOwed;
                    msRewardOwed=0;
                    requestRewardDone=true;
                elseif stop
                    rewardCurrentlyOn=false;
                end
                % there is nothing to do in the stop case, because the doReward method is already timed to msRewardOwed
                if any(doValves)
                    primeMLsPerSec=1.0;
                    station=doReward(station,primeMLsPerSec*ifi,doValves,true);
                end
                newValveState=0*doValves;
            case 'serverPump'
                % handle serverPump method
                
                
                % =====================================================================================================================
                % function here to handle serverValveChange and set up serverPump reward method
                [currentValveState phaseRecords(specInd).valveErrorDetails quit serverValveChange phaseRecords(specInd).responseDetails ...
                    requestRewardStartLogged requestRewardDurLogged] = ...
                 setupServerPumpRewards(tm, rn, station, newValveState, currentValveState, phaseRecords(specInd).valveErrorDetails, ...
                 startTime, serverValveChange, requestRewardStarted, requestRewardStartLogged, requestRewardPorts, requestRewardDone, ...
                 requestRewardDurLogged, phaseRecords(specInd).responseDetails, quit);
                
                % =====================================================================================================================
                % actually carry out serverPump rewards
                % copied from merge code doTrial
                valveStart=GetSecs();
                timeout=-5.0;
               % trialManager.soundMgr = playLoop(trialManager.soundMgr,'correctSound',station,1); % dont need to play sound (handled by phases)

                sprintf('*****should be no output between here *****')

                stopEarly=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_REWARD_CMD,{rewardSizeULorMS,logical(rewardValves)});
                rewardDone=false;
                while ~rewardDone && ~stopEarly
                    [stopEarly openValveCom openValveCmd openValveCmdArgs]=waitForSpecificCommand(rn,[],constants.serverToStationCommands.S_SET_VALVES_CMD,timeout,'waiting for server open valve response to C_REWARD_CMD',constants.statuses.MID_TRIAL);


                    if stopEarly
                        'got stopEarly 2'
                    end


                    if ~stopEarly

                        if any([isempty(openValveCom) isempty(openValveCmd) isempty(openValveCmdArgs)])
                            error('waitforspecificcommand acted like it got a stop early even though it says it didn''t')
                        end

                        requestedValveState=openValveCmdArgs{1};
                        isPrime=openValveCmdArgs{2};



                        if ~isPrime
                            rewardDone=true;
                            phaseRecords(specInd).latencyToOpenValveRecd=GetSecs()-valveStart;

                            [stopEarly phaseRecords(specInd).valveErrorDetails,...
                                phaseRecords(specInd).latencyToOpenValves,...
                                phaseRecords(specInd).latencyToCloseValveRecd,...
                                phaseRecords(specInd).latencyToCloseValves,...
                                phaseRecords(specInd).actualRewardDuration,...
                                phaseRecords(specInd).latencyToRewardCompleted,...
                                phaseRecords(specInd).latencyToRewardCompletelyDone]...
                                =clientAcceptReward(...
                                rn,...
                                openValveCom,...
                                station,...
                                timeout,...
                                valveStart,...
                                requestedValveState,...
                                rewardValves,...
                                isPrime);

                            if stopEarly
                                'got stopEarly 3'
                            end

                        else

                            [stopEarly phaseRecords(specInd).primingValveErrorDetails(end+1),...
                                phaseRecords(specInd).latencyToOpenPrimingValves(end+1),...
                                phaseRecords(specInd).latencyToClosePrimingValveRecd(end+1),...
                                phaseRecords(specInd).latencyToClosePrimingValves(end+1),...
                                phaseRecords(specInd).actualPrimingDuration(end+1),...
                                garbage,...
                                garbage]...
                                =clientAcceptReward(...
                                rn,...
                                openValveCom,...
                                station,...
                                timeout,...
                                valveStart,...
                                requestedValveState,...
                                [],...
                                isPrime);

                            if stopEarly
                                'got stopEarly 4'
                            end
                        end
                    end

                end

                sprintf('*****and here *****')
            otherwise
                error('unsupported rewardMethod');
        end
    end
    % end reward stuff
    % =====================================================================================================================
    % =====================================================================================================================
    % make function to handle server stuff
    if ~isempty(rn) || strcmp(getRewardMethod(station),'serverPump')
        [done quit phaseRecords(specInd).valveErrorDetails serverValveStates serverValveChange ...
            response newValveState requestRewardDone requestRewardOpenCmdDone] ...
         = handleServerCommands(tm, rn, done, quit, requestRewardStarted, requestRewardStartLogged, requestRewardOpenCmdDone, ...
              requestRewardDone, station, ports, serverValveStates, doValves, response);
    elseif isempty(rn) && strcmp(getRewardMethod(station),'serverPump')
        error('need a rnet for serverPump')
    end
    
    % =====================================================================================================================
    %before can end, must make sure any request rewards are done so
    %that the valves will be closed.  this includes server reward
    %requests.  right now there is a bug if the response occurs before
    %the request reward is over.

    % airpuff stuff
    if ~isempty(lastAirpuffTime) && airpuffOn
        % if airpuff was on from last loop, then subtract from debt
        elapsedTime = GetSecs() - lastAirpuffTime;
        msAirpuffOwed = msAirpuffOwed - elapsedTime*1000.0;
        actualReinforcementDurationMSorUL = actualReinforcementDurationMSorUL + elapsedTime*1000.0;
    end
    
    start = msAirpuffOwed > 0 && ~airpuffOn;
    stop = msAirpuffOwed <= 0 && airpuffOn;
    if start || doPuff
        setPuff(station, true);
        airpuffOn = true;
    elseif stop
        doPuff = false;
        airpuffOn = false;
        setPuff(station, false);
    end
    lastAirpuffTime = GetSecs();

    % record some information to phaseRecords if we are transitioning to a new phase
    if updatePhase
        phaseRecords(specInd).transitionedByPortResponse = transitionedByPortFlag;
        phaseRecords(specInd).transitionedByTimeout = transitionedByTimeFlag;
        phaseRecords(specInd).containedManualPokes = didManual;
        phaseRecords(specInd).leftWithManualPokingOn = manual;
        if didManual %if any phase does a manual poke, then the trialRecord should reflect this
            didManualInTrial=true;
        end
        phaseRecords(specInd).didStochasticResponse = didStochasticResponse;
        
        % how do we only clear the textures from THIS phase (since all textures for all phases are precached....)
        % close all textures from this phase if in non-expert mode
%         if ~strcmp(strategy,'expert')
%             Screen('Close');
%         else
%             expertCleanUp(stimManager);
%         end
    end

    % increment counters as necessary
    specInd = newSpecInd; % update specInd if necessary
    frameNum = frameNum + 1;
    totalFrameNum = totalFrameNum + 1; % 10/19/08 - for eyeTracker indexing
    framesSinceKbInput = framesSinceKbInput + 1;

    lastLoopEnd=GetSecs;
    %logwrite('end of stimOGL loop');
end

% =====================================================================================================================
% function here to do closing stuff after real time loop

% 10/28/08 - add three more frame pulses (to determine end of last frame)
if doFramePulse
    % do 3 pulses b/c the analysis expects a 2-pulse signal followed by a single-pulse signal
    framePulse(station);
    framePulse(station);
    framePulse(station);
end

Screen('Close'); %leaving off second argument closes all textures but leaves windows open
Priority(originalPriority);
ListenChar(0);

% function [tm responseDetails] = closeRealTimeLoop(tm, responseDetails, station, frameNum, startTime, valveErrorDetails, window, texture,
%   destRect, filtMode, dontclear, vbl, framesPerUpdate, ifi, originalPriority)
% [tm responseDetails] = closeRealTimeLoop(tm, responseDetails, station, frameNum, startTime, valveErrorDetails, window, textures(size(stim,3)+1), ...
%   destRect, filtMode, dontclear, vbl, framesPerUpdate, ifi, originalPriority);

% =====================================================================================================================
end % end function