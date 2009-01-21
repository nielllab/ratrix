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
masktex=[];
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
KbConstants.atKeys=find(cellfun(@(x) ~isempty(x),strfind(KbConstants.allKeys,'@')));
KbConstants.asciiOne=double('1');
KbConstants.portKeys={};
for i=1:length(ports)
    KbConstants.portKeys{i}=find(strncmp(char(KbConstants.asciiOne+i-1),KbConstants.allKeys,1));
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

        currentValveState=verifyValvesClosed(station);
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
            requestRewardPorts = rewardPorts;
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

            % =====================================================================================================================
            % function to determine the frame index using the textureCache strategy


            case 'textureCache'

                % function [tm frameIndex i done doFramePulse didPulse] = updateFrameIndexUsingTextureCache(tm, 
                %   frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames, stimSize, isRequesting,
                %   i, requestFrame, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse)
                [tm frameIndex i done doFramePulse didPulse] = updateFrameIndexUsingTextureCache(tm, ...
                frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames, size(stim,3), isRequesting, ...
                i, requestFrame, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse);

%             stimSize = size(stim,3);
%             if frameIndexed
%                 if loop
%                     frameIndex = mod(frameIndex,length(indexedFrames)-1)+1;
%                 else
%                     frameIndex = min(length(indexedFrames),frameIndex+1);
%                 end
%                 i = indexedFrames(frameIndex);
%             elseif loop
%             %     i = mod(i,stimSize-1)+1; %this is not correct if stimSize is number of frames and i is the index
%                 % 8/16/08 - changed to index correctly
%             %     i
%                 i = mod(i+1,stimSize);
%                 if i == 0
%                     i = stimSize;
%                 end
%                 % end changed version 8/16/08
%             %     stimSize
%             %     i
% 
%             elseif trigger
%                 if isRequesting
%                     if ~audioStimPlaying && ~isempty(audioStim)
%                         % Play audio
%                         tm.soundMgr = playLoop(tm.soundMgr,audioStim,station,1);
%                         audioStimPlaying = true;
%                     end
%                     i=1;
%                 else
%                     if audioStimPlaying
%                         % Turn off audio
%                         tm.soundMgr = playLoop(tm.soundMgr,'',station,0);
%                         audioStimPlaying = false;
%                     end
%                     i=2;
%                 end
% 
%             elseif timeIndexed %ok, this is where we do the timedFrames type
% 
%                 %Function 'cumsum' is not defined for values of class 'int8'.
%                 if requestFrame~=0
%                     i=min(find((frameNum-requestFrame)<=cumsum(double(timedFrames))));  %find the stim frame number for the number of frames since the request
%                 end
% 
%                 if isempty(i)  %if we have passed the last stim frame
%                     i=length(timedFrames);  %hold the last frame if the last frame duration specified was zero
%                     if timedFrames(end)
%                         i=i+1;      %otherwise move on to the finalScreenLuminance blank screen
%                     end
%                 end
% 
%             else
% 
%                 i=min(i+1,stimSize);
% 
%                 if isempty(responseOptions) && i==stimSize
%                     done=1;
%                 end
% 
%                 if i==stimSize && didPulse
%                     doFramePulse=0;
%                 end
%                 didPulse=1;
%             end
            
            % =====================================================================================================================
            % function to draw the appropriate texture using the textureCache strategy

            time2=GetSecs;
%             function drawFrameUsingTextureCache(tm, window, i, frameNum, stimSize, lastI, dontclear, texture, destRect, 
%             filtMode, labelFrames, xOrigTextPos, yNewTextPos)
            drawFrameUsingTextureCache(tm, window, i, frameNum, size(stim,3), lastI, dontclear, textures(i), destRect, ... 
                filtMode, labelFrames, xOrigTextPos, yNewTextPos);

%             if window>=0
%                 if i>0 && i <= size(stim,3)
%                     if ~(i==lastI) || (dontclear==0) %only draw if texture different from last one, or if every flip is redrawn
%                         Screen('DrawTexture', window, textures(i),[],destRect,[],filtMode);
%                     else
%                         if labelFrames
%                             thisMsg=sprintf('This frame stim index (%d) is staying here without drawing new textures %d',i,frameNum);
%                             Screen('DrawText',window,thisMsg,xOrigTextPos,yNewTextPos-20,100*ones(1,3));
%                         end
%                     end
%                 else
%                     if size(stim,3)==0
%                         'stim had zeros frames, probably an penalty stim with zero duration'
%                     else
%                         i
%                         sprintf('stimSize: %d',size(stim,3))
%                         error('request for an unknown frame')
%                     end
%                 end
%             end

            % =====================================================================================================================

            case 'expert'
                % 10/31/08 - implementing expert mode
                % call a method of the given stimManager that draws the expert frame
                i=i+1; % 11/7/08 - this needs to happen first because i starts at 0
                [doFramePulse masktex] = drawExpertFrame(stimManager,stim,i,window,floatprecision,destRect,filtMode,masktex); 
                %11/7/08 - pass in stim as a struct of parameters

                % 11/9/08 - save window image to phaseRecords(specInd).big
%                  phaseRecords(specInd).big(:,:,i) = Screen('GetImage',window,destRect,[],floatprecision,1);
%                 %draw to buffer
%                 [dynFrame doFramePulse] =getDynFrame(stim,i); %any advantage to preallocating dynFrame?  would require a stim method to ask how big it will be...
%                 if window>=0
%                     Screen('DrawDots', window, dotLocs, dotSize ,repmat(dynFrame(1:numDots),3,1), dotCtr,0);
%                 end
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
        % function [xTextPos didManual] = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, stimID, protocolStr, 
        %   textLabel, trialLabel, i, frameNum, manual, didManual, didAPause, ptbVersion, ratrixVersion)
        if manual
            didManual=1;
        end
        
        % =====================
        % 12/1/08 - this drawText function call is causing frame drops in rig room testing
        % REMOVED for now
        if window>=0
            xTextPos = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, normBoundsRect, stimID, protocolStr, ...
              textLabel, trialLabel, i, frameNum, manual, didAPause, ptbVersion, ratrixVersion);
        end
        time4=GetSecs;
        % =====================

%         if window>=0
%             if labelFrames
%                 %junkSize = Screen('TextSize',window,subjectFontSize);
%                 [xTextPos,yTextPosUnused] = Screen('DrawText',window,['ID:' subID ],xOrigTextPos,yTextPos,100*ones(1,3));
%                 xTextPos=xTextPos+50;
%                 %junkSize = Screen('TextSize',window,standardFontSize);
%                 [garbage,yNewTextPos] = Screen('DrawText',window,['trlMgr:' class(tm) ' stmMgr:' stimID  ' prtcl:' protocolStr ],xTextPos,yNewTextPos,100*ones(1,3));
%             end
%             [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');
%             yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
% 
%             if labelFrames
%                 if iscell(textLabel)
%                     txtLabel=textLabel{i};
%                 else
%                     txtLabel=textLabel;
%                 end
%                 [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('priority:%g %s stimInd:%d frame:%d stim:%s',Priority(),trialLabel,i,frameNum,txtLabel),xTextPos,yNewTextPos,100*ones(1,3));
%                 yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
% 
% %                 [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('ptb:%s',ptbVersion),xTextPos,yNewTextPos,100*ones(1,3));
% %                 yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
% % 
% %                 [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('ratrix:%s',ratrixVersion),xTextPos,yNewTextPos,100*ones(1,3));
% %                 yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
%             end
% 
%             if manual
%                 didManual=1;
%                 manTxt='on';
%             else
%                 manTxt='off';
%             end
%             if didManual
%                 [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('trial record will indicate manual poking on this trial (k+m to toggle for next trial: %s)',manTxt),xTextPos,yNewTextPos,100*ones(1,3));
%                 yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
%             end
% 
%             if didAPause
%                 [garbage,yNewTextPos] = Screen('DrawText',window,'trial record will indicate a pause occurred on this trial',xTextPos,yNewTextPos,100*ones(1,3));
%                 yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
%             end
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
    time5=GetSecs;
%     function [lastI when vbl sos ft missed] = flipFrameAndDoPulse(tm, window, dontclear, i, vbl, framesPerUpdate, ifi, paused, doFramePulse,station) 
    [lastI when vbl sos ft missed time6 time7 whenTime] = ...
        flipFrameAndDoPulse(tm, window, dontclear, i, vbl, framesPerUpdate, ifi, paused, doFramePulse,station); 
    

%     %indicate finished (enhances performance)
%     if window>=0
%         Screen('DrawingFinished',window,dontclear);
%         lastI=i;
%     end
% 
%     when=vbl+(framesPerUpdate-0.5)*ifi;
% 
% %     if ~paused && doFramePulse
% %         framePulse(station);
% %         framePulse(station);
% %     end
% 
%     %logwrite('frame calculated, waiting for flip');
% 
%     %wait for next frame, flip buffer
%     if window>=0
%         [vbl sos ft missed]=Screen('Flip',window,when,dontclear); %vbl=vertical blanking time, when flip starts executing
%         %sos=stimulus onset time -- doc doesn't clarify what this is
%         %ft=timestamp from the end of flip's execution
%     else
%         waitTime=GetSecs()-when;
%         if waitTime>0
%             WaitSecs(waitTime);
%         end
%         ft=when;
%         vbl=ft;
%         missed=0;
%     end
% 
%     %logwrite('just flipped');
% 
%     if ~paused
%         if doFramePulse
%             framePulse(station);
%         end
%     end
%     
    
    % =====================================================================================================================
    % function here to save information about missed frames

    % function [responseDetails lastFrameTime] = saveMissedFrameData(tm, responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi)
    [phaseRecords(specInd).responseDetails lastFrameTime numDrops numApparentDrops] = ...
        saveMissedFrameData(tm, phaseRecords(specInd).responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi, numDrops,numApparentDrops,...
        when,whenTime,lastLoopEnd,time1,time2,time3,time4,time5,time6,time7,barebones,vbl);
    
%     %save facts about missed frames
%     if missed>0 && frameNum<phaseRecords(specInd).responseDetails.numFramesUntilStopSavingMisses
%         disp(sprintf('warning: missed frame num %d',frameNum));
%         phaseRecords(specInd).responseDetails.numMisses=phaseRecords(specInd).responseDetails.numMisses+1;
%         phaseRecords(specInd).responseDetails.misses(phaseRecords(specInd).responseDetails.numMisses)=frameNum;
%         phaseRecords(specInd).responseDetails.afterMissTimes(phaseRecords(specInd).responseDetails.numMisses)=GetSecs();
%     else
%         thisIFI=ft-lastFrameTime;
%         thisIFIErrorPct = abs(1-thisIFI/ifi);
%         if  thisIFIErrorPct > timingCheckPct
%             disp(sprintf('warning: flip missed a timing and appeared not to notice: frame num %d, ifi error: %g',frameNum,thisIFIErrorPct));
%             phaseRecords(specInd).responseDetails.numApparentMisses=responseDetails.numApparentMisses+1;
%             phaseRecords(specInd).responseDetails.apparentMisses(phaseRecords(specInd).responseDetails.numApparentMisses)=frameNum;
%             phaseRecords(specInd).responseDetails.afterApparentMissTimes(phaseRecords(specInd).responseDetails.numApparentMisses)=GetSecs();
%             phaseRecords(specInd).responseDetails.apparentMissIFIs(phaseRecords(specInd).responseDetails.numApparentMisses)=thisIFI;
%         end
%     end
%     lastFrameTime=ft;
% 
%     %stop saving miss frame statistics after the relevant period -
%     %prevent trial history from getting too big
%     %1 day is about 1-2 million misses is about 25 MB
%     %consider integers if you want to save more
%     %reasonableMaxSize=ones(1,intmax('uint16'),'uint16');%
% 
%     if missed>0 && frameNum>=phaseRecords(specInd).responseDetails.numFramesUntilStopSavingMisses
%         phaseRecords(specInd).responseDetails.numMisses=phaseRecords(specInd).responseDetails.numMisses+1;
%         phaseRecords(specInd).responseDetails.numUnsavedMisses=phaseRecords(specInd).responseDetails.numUnsavedMisses+1;
%     end
    
    
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
    
    % function [didAPause paused done response doValves ports didValves didHumanResponse manual doPuff pressingM pressingP] = 
    %   handleKeyboard(tm, keyCode, didAPause, paused, done, response, doValves, ports, didValves, didHumanResponse,
    %   manual, doPuff, pressingM, pressingP, allowQPM, originalPriority, priorityLevel)
    if keyIsDown && framesSinceKbInput > -1
         [didAPause paused done phaseRecords(specInd).response doValves ports didValves didHumanResponse manual doPuff pressingM pressingP] = ...
         handleKeyboard(tm, keyCode, didAPause, paused, done, phaseRecords(specInd).response, doValves, ports, didValves, didHumanResponse, ...
         manual, doPuff, pressingM, pressingP, allowQPM, originalPriority, priorityLevel, KbConstants);
        framesSinceKbInput=0;
    end
        %logwrite(sprintf('keys are down:',num2str(find(keyCode))));
%     if keyIsDown && framesSinceKbInput > 5
%         mThisLoop = 0;
%         pThisLoop = 0;
%         asciiOne=49;
% 
%         keys=find(keyCode);
%         ctrlDown=0; %these don't get reset if keyIsDown fails!
%         shiftDown=0;
%         kDown=0;
%         for keyNum=1:length(keys)
%             shiftDown = shiftDown || strcmp(KbName(keys(keyNum)),'shift');
%             ctrlDown = ctrlDown || strcmp(KbName(keys(keyNum)),'control');
%             kDown= kDown || strcmp(KbName(keys(keyNum)),'k');
%         end
% 
%         if kDown
%             for keyNum=1:length(keys)
%                 keyName=KbName(keys(keyNum));
% 
%                 if strcmp(keyName,'p')
%                     pThisLoop=1;
% 
%                     if ~pressingP && allowQPM
% 
%                         didAPause=1;
%                         paused=~paused;
% 
%                         if paused
%                             Priority(originalPriority);
%                         else
%                             Priority(priorityLevel);
%                         end
% 
%                         pressingP=1;
%                     end
%                 elseif strcmp(keyName,'q') && ~paused && allowQPM
%                     done=1;
%                     phaseRecords(specInd).response='manual kill';
% 
%                 elseif ~isempty(keyName) && ismember(keyName(1),char(asciiOne:asciiOne+length(ports)-1))
%                     if shiftDown
%                         if keyName(1)-asciiOne+1 == 2
%                             'WARNING!!!  you just hit shift-2 ("@"), which mario declared a synonym to sca (screen(''closeall'')) -- everything is going to break now'
%                             'quitting'
%                             done=1;
%                             phaseRecords(specInd).response='shift-2 kill';
%                         end
%                     end
%                     if ctrlDown
%                         doValves(keyName(1)-asciiOne+1)=1;
%                         didValves=true;
%                     else
%                         ports(keyName(1)-asciiOne+1)=1;
%                         didHumanResponse=true;
%                     end
%                 elseif strcmp(keyName,'m')
%                     mThisLoop=1;
% 
%                     if ~pressingM && ~paused && allowQPM
% 
%                         manual=~manual;
%                         pressingM=1;
%                     end
%                 elseif strcmp(keyName,'a') % check for airpuff
%                     doPuff=true;
%                 end
%             end
%         end
% 
%         if ~mThisLoop && pressingM
%             pressingM=0;
%         end
%         if ~pThisLoop && pressingP
%             pressingP=0;
%         end
%         framesSinceKbInput=0;
%     end
% 


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
    
    % =====================================================================================================================
    [tm done newSpecInd specInd updatePhase transitionedByTimeFlag ...
        transitionedByPortFlag phaseRecords(specInd).response response isRequesting lastSoundsPlayed] = ... 
        handlePhasedTrialLogic(tm, done, ...
        ports, station, specInd, transitionCriterion, framesUntilTransition, stepsInPhase, isFinalPhase, ... 
        phaseRecords(specInd).response, response, ...
        stimManager, msRewardSound, msPenaltySound, targetOptions, distractorOptions, requestOptions, isRequesting, lastSoundsPlayed);
    
    stepsInPhase = stepsInPhase + 1; %10/16/08 - moved from handlePhasedTrialLogic to prevent COW

    
    % =====================================================================================================================
    % Handle sounds by port-triggered mode
%     if usePortTriggeredSoundMode
%         if isa(tm, 'nAFC')
%             if stimStarted && any(ports(requestOptions))
%                 % if we are showing stim and get a request - play the keepGoing sound
%                 tm.soundMgr = playLoop(tm.soundMgr,'keepGoingSound',station,1);
%             elseif ~stimStarted && any(ports(responseOptions))
%                 % if we waiting for a request and get response - play white noise
%                 tm.soundMgr = playLoop(tm.soundMgr,'trySomethingElseSound',station,1);
%             else
%                 tm.soundMgr = playLoop(tm.soundMgr,'',station,0);
%             end
%         elseif isa(tm, 'freeDrinks')
%             if any(ports(requestOptions))
%                 tm.soundMgr = playLoop(tm.soundMgr,'trySomethingElseSound',station,1);
%             else
%                 tm.soundMgr = playLoop(tm.soundMgr,'',station,0);
%             end
%         end
%     end

    
    % =====================================================================================================================

    
    
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
              requestRewardDone, station, ports, serverValveStates, doValves, response);
    elseif isempty(rn) && strcmp(getRewardMethod(station),'serverPump')
        error('need a rnet for serverPump')
    end
    


    % =====================================================================================================================
    
    %before can end, must make sure any request rewards are done so
    %that the valves will be closed.  this includes server reward
    %requests.  right now there is a bug if the response occurs before
    %the request reward is over.
% do airpuff stuff
%     if msAirpuff>0 && ~puffDone && (puffStarted==0 || GetSecs-puffStarted<=msAirpuff/1000)
% 
%         setPuff(station,true);
%         if puffStarted==0
%             puffStarted=GetSecs;
%         end
%     elseif ~doPuff
%         setPuff(station,false);
%         puffDone=true;
%     else
%         setPuff(station,true);
%     end
    
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