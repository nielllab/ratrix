function [quit response didManualInTrial manual actualReinforcementDurationMSorUL proposedReinforcementDurationMSorUL ... 
      phaseRecords] ...
    = runRealTimeLoop(tm, window, ifi, stimSpecs, phaseData, finalPhase, soundTypes, ...
    targetOptions, distractorOptions, requestOptions, ...
    station, manual,allowQPM,timingCheckPct,noPulses,textLabel,rn,subID,stimID,protocolStr,trialLabel,msAirpuff, ...
    originalPriority, verbose)

  
% need actual versus proposed reward duration (save in phaseRecords per phase)
actualReinforcementDurationMSorUL = 0;
proposedReinforcementDurationMSorUL = 0;
didManualInTrial=false;

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

%    phaseRecords(specInd).proposedSounds = soundTypesToCellArray(soundTypesInPhase); % a cell array of strings
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



[garbage ptbVer]=PsychtoolboxVersion;
ptbVersion=sprintf('%d.%d.%d(%s %s)',ptbVer.major,ptbVer.minor,ptbVer.point,ptbVer.flavor,ptbVer.revstring);
try
[runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
ratrixVersion=sprintf('%s (%d of %d)',url,runningSVNversion,repositorySVNversion);
catch 
    ex=lasterror;
ratrixVersion='no network connection';
end

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


% =====================================================================================================================
% Get ready with various stuff

% For the Windows version of Priority (and Rush), the priority levels set
% are  "process priority levels". There are 3 priority levels available,
% levels 0, 1, and 2. Level 0 is "normal priority level", level 1 is "high
% priority level", and level 2 is "real time priority level". Combined
% with

%Priority(9);
KbCheck; %load mex files into ram
GetSecs;
Screen('Screens');

% set font size correctly
standardFontSize=11; %big was 25
subjectFontSize=35;
oldFontSize = Screen('TextSize',window,standardFontSize);
Screen('Preference', 'TextRenderer', 0);  % consider moving to PTB setup

preSMCacheTime=GetSecs();
[newSM updateSMCache]=cacheSounds(getSoundManager(tm)); % 8/12/08 -8/12/08 - changed to use setter and getter for tm.soundMgr to support new stimOGL/doTrial architecture
disp(sprintf('took %g secs to cache sounds',GetSecs()-preSMCacheTime))
if updateSMCache
    tm = setSoundManager(tm, newSM); % 8/12/08 - changed to use setter and getter for tm.soundMgr to support new stimOGL/doTrial architecture
%    tm.soundMgr=newSM; %hmmm, how does this cache get persisted, we don't return tm...
end
%tm.soundMgr=playSound(tm.soundMgr,'keepGoingSound',.001,station); %get audioplayer into memory (java?)
%tm.soundMgr=playSound(tm.soundMgr,'trySomethingElseSound',.001,station); %get all the clips we'll use cached up

priorityLevel=MaxPriority(window,'GetSecs','KbCheck');

Priority(priorityLevel); % should use Rush to prevent hard crash if script errors, but then everything below is a string, annoying...
if verbose
    disp(sprintf('running at priority %d',priorityLevel));
end



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



% phaseRecords = [];


% =====================================================================================================================
% Draw and flip last frame (finalScreenLuminance)
% function [vbl sos ft lastFrameTime lastI] = drawFirstFrame(tm, window, standardFontSize, texture, lengthOfStim, destRect, filtMode, dontclear)
% [vbl sos ft lastFrameTime lastI] = ...
%     drawFirstFrame(tm, window, standardFontSize, textures(size(stim,3)+1), size(stim,3), destRect, filtMode, dontclear);

% =====================================================================================================================
% ENTERING LOOP

%logwrite('about to enter stimOGL loop');

%any stimulus onset synched actions

startTime=GetSecs();
respStart = 0; % initialize respStart to zero - it won't get set until we get a response through trial logic

audioStimPlaying = false;
response='none'; %initialize

%show stim -- be careful in this realtime loop!
while ~done && ~quit;
    %logwrite('top of stimOGL loop');
    
    % =====================================================================================================================
    % if we are entering a new phase, re-initialize variables
    if updatePhase == 1
        
        i=0;
        frameIndex=0;
        attempt=0;

        frameNum=1;

        stimStarted=isempty(requestOptions); % no use in phased version
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
        didManual=false; %initialize
        
        puffStarted=0;
        puffDone=false;
        
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
        serverValveStates=false;
        potentialStochasticResponse=false;
        didStochasticResponse=false;
        didHumanResponse=false;

        isRequesting=0;
        stimToggledOn=0;



        xOrigTextPos = 10;
        yTextPos = 20;
        yNewTextPos=yTextPos;
        
        
        % load stimSpec and phaseData
        spec = stimSpecs{specInd};
        stim = getStim(spec);
        
        transitionCriterion = getCriterion(spec);
        framesUntilTransition = getFramesUntilTransition(spec);
        % flag for graduation by time (port was autoselected due to graduation by time)
        transitionedByTimeFlag = false;
        transitionedByPortFlag = false;
        % reinforcement
        rewardType = getRewardType(spec);
        rewardDuration = getRewardDuration(spec);
        rewardPorts = 2; % TEMPORARY UNTIL FIGURE OUT HOW TO ASSIGN THIS
        % if there is a reinforcement, then set up for functions that follow trial logic
        if ~isempty(rewardType) && strcmp(rewardType, 'reward')
            requestRewardStarted = true;
            requestRewardPorts = rewardPorts;
            proposedReinforcementDurationMSorUL = proposedReinforcementDurationMSorUL + rewardDuration;
            msRewardOwed = msRewardOwed + rewardDuration;
%         elseif ~isempty(rewardType) && strcmp(rewardType, 'airpuff')
%             msAirpuffOwed = msAirpuffOwed + rewardDuration;
%             doPuff = true;
%             proposedReinforcementDurationMSorUL = proposedReinforcementDurationMSorUL + rewardDuration;
        end
        
        % soundTypes
        soundTypesInPhase = soundTypes{specInd};
        numST = length(soundTypesInPhase);
        stepsInPhase = 0;
        isFinalPhase = finalPhase == specInd; % we set the isFinalPhase flag to true if we are on the last phase
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
        destRect = phase.destRect;
        
        textures = phase.textures;
        numDots = phase.numDots;
        dotX = phase.dotX;
        dotY = phase.dotY;
        dotLocs = phase.dotLocs;
        dotSize = phase.dotSize;
        dotCtr = phase.dotCtr;
        
        
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
        phaseRecords(specInd).responseDetails.toggleStim=toggleStim;
%         
        % Initialize this phaseRecord
        phaseRecords(specInd).proposedReinforcementSizeULorMS = rewardDuration;
        phaseRecords(specInd).proposedReinforcementType = rewardType;
        for stInd=1:length(soundTypesInPhase)
            phaseRecords(specInd).proposedSounds{stInd} = soundTypeToString(soundTypesInPhase{stInd});
        end
        % added 8/18/08 - strategy (loop, static, trigger, cache, dynamic, expert, timeIndexed, or frameIndexed)
        phaseRecords(specInd).loop = loop;
        phaseRecords(specInd).trigger = trigger;
        phaseRecords(specInd).strategy = strategy;
        phaseRecords(specInd).stochasticProbability = stochasticDistribution;
        phaseRecords(specInd).timeoutLengthInFrames = framesUntilTransition;
%         
%     %    phaseRecords(specInd).proposedSounds = soundTypesToCellArray(soundTypesInPhase); % a cell array of strings
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

        % THIS PART IS NOT USED IN PHASES - NO CONCEPT OF "STARTING AUDIO"
%         % If it's not triggered, the audio can just be started
%         if ~trigger
%             if ~isempty(audioStim)
%                 % Play audio
%                 tempSoundMgr = playLoop(getSoundManager(tm),audioStim,station,1); % 8/12/08 - changed to use setter and getter for tm.soundMgr to support new stimOGL/doTrial architecture
%                 tm = setSoundManager(tm, tempSoundMgr);
%                 audioStimPlaying = true;
%             end
%         end
        doFramePulse=~noPulses;
        switch strategy

            % =====================================================================================================================
            % function to determine the frame index using the textureCache strategy


            case 'textureCache'

                % function [tm frameIndex i audioStimPlaying done doFramePulse didPulse] = updateFrameIndexUsingTextureCache(tm, 
                %   frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames, stimSize, isRequesting, audioStimPlaying, audioStim,
                %   station, i, requestFrame, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse)
                [tm frameIndex i audioStimPlaying done doFramePulse didPulse] = updateFrameIndexUsingTextureCache(tm, ...
                frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames, size(stim,3), isRequesting, audioStimPlaying, audioStim, ...
                station, i, requestFrame, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse);

            % =====================================================================================================================
            % function to draw the appropriate texture using the textureCache strategy


                % function drawFrameUsingTextureCache(tm, window, i, frameNum, stimSize, lastI, dontclear, texture, destRect, 
                % filtMode, labelFrames, xOrigTextPos, yNewTextPos)
                drawFrameUsingTextureCache(tm, window, i, frameNum, size(stim,3), lastI, dontclear, textures(i), destRect, ... 
                    filtMode, labelFrames, xOrigTextPos, yNewTextPos);

            % =====================================================================================================================

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


        %logwrite(sprintf('stim is started, i is calculated: %d',i));

        %text commands are supposed to be last for performance reasons

        % =====================================================================================================================
        % function for drawing text
        % function [xTextPos didManual] = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, stimID, protocolStr, 
        %   textLabel, trialLabel, i, frameNum, manual, didManual, didAPause, ptbVersion, ratrixVersion)
        
%         if window>=0
%             [xTextPos didManual] = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, stimID, protocolStr, ...
%               textLabel, trialLabel, i, frameNum, manual, didManual, didAPause, ptbVersion, ratrixVersion);
%         end
        
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
    
    % function [lastI when vbl sos ft missed] = flipFrameAndDoPulse(tm, window, dontclear, i, vbl, framesPerUpdate, ifi, paused, doFramePulse,station) 
    [lastI when vbl sos ft missed] = flipFrameAndDoPulse(tm, window, dontclear, i, vbl, framesPerUpdate, ifi, paused, doFramePulse,station); 
    
    % =====================================================================================================================
    % function here to save information about missed frames

    % function [responseDetails lastFrameTime] = saveMissedFrameData(tm, responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi)
    [phaseRecords(specInd).responseDetails lastFrameTime] = saveMissedFrameData(tm, phaseRecords(specInd).responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi);
    
    % =====================================================================================================================
    
    
    %logwrite('entering trial logic');

    %all trial logic here

    if ~paused
        ports=readPorts(station);
        % 8/18/08 - added stochastic port hits
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

    doValves=0*ports;
    doPuff=false;



    % =====================================================================================================================
    % function to handle keyboard input
    %     mThisLoop=0;
    %     pThisLoop=0;
    [keyIsDown,secs,keyCode]=KbCheck; % do this check outside of function to save function call overhead
    
    % function [didAPause paused done response doValves ports didValves didHumanResponse manual doPuff pressingM pressingP] = 
    %   handleKeyboard(tm, keyCode, didAPause, paused, done, response, doValves, ports, didValves, didHumanResponse,
    %   manual, doPuff, pressingM, pressingP, allowQPM, originalPriority, priorityLevel)
    if keyIsDown && framesSinceKbInput > 10
         [didAPause paused done phaseRecords(specInd).response doValves ports didValves didHumanResponse manual doPuff pressingM pressingP] = ...
         handleKeyboard(tm, keyCode, didAPause, paused, done, phaseRecords(specInd).response, doValves, ports, didValves, didHumanResponse, ...
         manual, doPuff, pressingM, pressingP, allowQPM, originalPriority, priorityLevel);
        framesSinceKbInput=0;
    end
%         %logwrite(sprintf('keys are down:',num2str(find(keyCode))));
    
    % =====================================================================================================================
    % large function here that handles trial logic (what state are we in - did we have a request, response, should we give reward, etc)
    
    % function [tm responseDetails lookForChange respStart isRequesting requestRewardPorts requestRewardStarted requestFrame
    %   stimStarted stimToggledOn lastPorts frameNum didStochasticResponse attempt stopListening] = 
    %   handleTrialLogic(tm, responseDetails, paused, verbose, lastPorts,
    %   ports, lookForChange, respStart, isRequesting, station, toggleStim, stimToggledOn, requestOptions, responseOptions,
    %   requestRewardPorts, requestRewardStarted, stimStarted, frameNum, didStochasticResponse, audioStim, startTime, attempt, done,
    %   response, stopListening, logIt)
    
   % error('got to trial logic in phased runRealTimeLoop');
    
    % rewrite trial logic for phased

    % if phaseRecords(specInd).response got set by keyboard, duplicate response on trial level
    if ~strcmp('none', phaseRecords(specInd).response)
        response = phaseRecords(specInd).response;
    end
    
    [tm phaseRecords(specInd).responseDetails done newSpecInd specInd updatePhase transitionedByTimeFlag ...
        transitionedByPortFlag stepsInPhase phaseRecords(specInd).response response isRequesting] = ... 
        handlePhasedTrialLogic(tm, phaseRecords(specInd).responseDetails, done, ...
        ports, station, specInd, updatePhase, transitionCriterion, framesUntilTransition, stepsInPhase, isFinalPhase, ... 
        phaseRecords(specInd).response, response, ...
        soundTypesInPhase, targetOptions, distractorOptions, requestOptions, isRequesting);
    
%     [tm responseDetails lookForChange respStart isRequesting requestRewardPorts requestRewardStarted requestFrame ...
%       stimStarted stimToggledOn lastPorts frameNum potentialStochasticResponse didStochasticResponse attempt done response stopListening] = ... 
%       handleTrialLogic(tm, responseDetails, paused, verbose, lastPorts, ...
%       ports, lookForChange, respStart, isRequesting, station, toggleStim, stimToggledOn, requestOptions, responseOptions, ...
%       requestRewardPorts, requestRewardStarted, requestFrame, stimStarted, frameNum, potentialStochasticResponse, didStochasticResponse, ...
%       audioStim, startTime, attempt, done, response, stopListening, logIt); 
% 
%     %logwrite('calculating state');
%     
    % =====================================================================================================================
    % function here to handle localTimed and localPump reward methods
    
%     % function [requestRewardPorts requestRewardDone newValveState station] = setupLocalTimedAndLocalPumpRewards(tm, requestRewardStarted,
%     %   requestRewardStartLogged, requestRewardDone, responseDetails, requestRewardPorts, doValves,
%     %   station, ifi)
%     
%     [requestRewardPorts requestRewardDone newValveState station] = setupLocalTimedAndLocalPumpRewards(tm, requestRewardStarted, ...
%       requestRewardStartLogged, requestRewardDone, phaseRecords(specInd).responseDetails, requestRewardPorts, doValves, ...
%       station, ifi);
  
%     if strcmp(getRewardMethod(station),'localTimed')       
%         if requestRewardStarted && requestRewardStartLogged && ~requestRewardDone
%             if 1000*(GetSecs()-phaseRecords(specInd).responseDetails.requestRewardStartTime) >= rewardDuration
%                 requestRewardPorts=0*requestRewardPorts;
%                 requestRewardDone=true;
%             end
%         end
%         newValveState=doValves|requestRewardPorts;
%     elseif strcmp(getRewardMethod(station),'localPump')
% 
%         if requestRewardStarted && ~requestRewardDone && requestRewardStartLogged
%             station=doReward(station,rewardDuration/1000,requestRewardPorts);
%             requestRewardDone=true;
%         end
% 
%         if any(doValves)
%             primeMLsPerSec=1.0;
%             station=doReward(station,primeMLsPerSec*ifi,doValves,true);
%         end
% 
%         newValveState=0*doValves;
%     end

    % =====================================================================================================================
    % reward stuff copied from old phased stimOGL
    % update reward owed and elapsed time
    if ~isempty(lastRewardTime) && rewardCurrentlyOn
        elapsedTime = getSecs() - lastRewardTime;
        msRewardOwed = msRewardOwed - elapsedTime*1000.0;
       % error('elapsed time was %d and msRewardOwed is now %d', elapsedTime, msRewardOwed);
        actualReinforcementDurationMSorUL = actualReinforcementDurationMSorUL + elapsedTime*1000.0;
    end
    lastRewardTime = getSecs();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % start/stop as necessary
    start = msRewardOwed > 0.0 && ~rewardCurrentlyOn;
    stop = msRewardOwed <= 0.0 && rewardCurrentlyOn;
    
    
    if start || stop
        % get current state of valves and what to change
        currentValveStates=verifyValvesClosed(station);
        rewardValves=zeros(1,getNumPorts(station));
        % we give the reward at whatever port is specified by the current phase (weird...fix later?)
        % the default if the current phase does not have a criterion port is the requestOptions (input to stimOGL)
        if isempty(rewardPorts)
            rewardValves(requestOptions) = 1;
        else
            rewardValves(rewardPorts)=1;
        end
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
                elseif stop
                    'turning off reward'
                    rewardCurrentlyOn = false;
                    %CLOSE VALVE
                    [currentValveStates phaseRecords(specInd).valveErrorDetails]=...
                    setAndCheckValves(station,zeros(1,getNumPorts(station)),currentValveStates,...
                        phaseRecords(specInd).valveErrorDetails,...
                        lastRewardTime,'correct reward close');
                    newValveState=doValves|requestRewardPorts;
                else
                    error('has to be either start or stop - should not be here');
                end
            case 'localPump'
                % localPump method copied from merge stimOGL (non-phased)
                if start
                    'turning on localPump reward'
                    station=doReward(station,msRewardOwed/1000,requestRewardPorts);
                    requestRewardDone=true;
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

                % function [currentValveState valveErrorDetails quit serverValveChange responseDetails requestRewardStartLogged requestRewardDurLogged] = 
                %   setupServerPumpRewards(tm, rn, station, newValveState, currentValveState, valveErrorDetails, startTime, serverValveChange,
                %   requestRewardStarted, requestRewardStartLogged, requestRewardPorts, requestRewardDone, requestRewardDurLogged, responseDetails,
                %   quit)

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
    % function [done quit valveErrorDetail serverValveStates serverValveChange response newValveState requestRewardDone requestRewardOpenCmdDone] ...
    %   = handleServerCommands(tm, rn, constants, done, quit, requestRewardStarted, requestRewardStartLogged, requestRewardOpenCmdDone
    %       requestRewardDone, station, ports, serverValveStates, doValves, response, newValveState)
    if ~isempty(rn) || strcmp(getRewardMethod(station),'serverPump')
        [done quit phaseRecords(specInd).valveErrorDetails(end+1) serverValveStates serverValveChange ...
            response newValveState requestRewardDone requestRewardOpenCmdDone] ...
         = handleServerCommands(tm, rn, done, quit, requestRewardStarted, requestRewardStartLogged, requestRewardOpenCmdDone, ...
              requestRewardDone, station, ports, serverValveStates, doValves, response, newValveState);
    elseif isempty(rn) && strcmp(getRewardMethod(station),'serverPump')
        error('need a rnet for serverPump')
    end
    


    % =====================================================================================================================
    
    %before can end, must make sure any request rewards are done so
    %that the valves will be closed.  this includes server reward
    %requests.  right now there is a bug if the response occurs before
    %the request reward is over.
% 
    if msAirpuff>0 && ~puffDone && (puffStarted==0 || GetSecs-puffStarted<=msAirpuff/1000)

        setPuff(station,true);
        if puffStarted==0
            puffStarted=GetSecs;
        end
    elseif ~doPuff
        setPuff(station,false);
        puffDone=true;
    else
        setPuff(station,true);
    end


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
    end

    % increment counters as necessary
    specInd = newSpecInd; % update specInd if necessary
    frameNum = frameNum + 1;
    framesSinceKbInput = framesSinceKbInput + 1;

    %logwrite('end of stimOGL loop');
end

% =====================================================================================================================
% function here to do closing stuff after real time loop

Screen('Close'); %leaving off second argument closes all textures but leaves windows open
Priority(originalPriority);
ListenChar(0);

% function [tm responseDetails] = closeRealTimeLoop(tm, responseDetails, station, frameNum, startTime, valveErrorDetails, window, texture,
%   destRect, filtMode, dontclear, vbl, framesPerUpdate, ifi, originalPriority)
% [tm responseDetails] = closeRealTimeLoop(tm, responseDetails, station, frameNum, startTime, valveErrorDetails, window, textures(size(stim,3)+1), ...
%   destRect, filtMode, dontclear, vbl, framesPerUpdate, ifi, originalPriority);

% =====================================================================================================================
end % end function