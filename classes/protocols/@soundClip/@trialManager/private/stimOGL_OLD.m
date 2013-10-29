function [quit response manual containedManualPokes actualRewardDurationMSorUL proposedRewardDurationMSorUL ...
    eyeData gaze station phaseRecords]=  ...
    stimOGL(tm, stimSpecs, soundTypes, LUT, scaleFactors, targetOptions, distractorOptions, requestOptions, ...
    station, manual,allowQPM,timingCheckPct, ...
    noPulses,textLabel,rn,subID,stimID,protocolStr,trialLabel,eyeTracker,msAirpuff)

% function [quit response manual containedManualPokes actualRewardDurationMSorUL proposedRewardDurationMSorUL phaseRecords] = ...
% stimOGL(tm,stimSpecs,finalPhase,soundTypes,LUT,scaleFactors,targetOptions,distractorOptions,requestOptions, ...
%                station, manual,allowQPM,timingCheckPct,noPulses,isCorrection,rn,subID,stimID)

eyeData=[];
gaze=[];

% old trialRecords variables - move to phaseRecords per phase
% response responseDetails didManual manual didAPause didValves didHumanResponse didStochasticResponse

% THINGS TO DO:
% fill in responseDetails when appropriate - they are saved as a field in phaseRecord
% pump stuff - fill in and implement


% Version 0.9
% Full implementation except for server commands

% This version is an almost-complete implementation of the original stimOGL functionality customized for the phased stimulus framework.
% All features except for server commands are handled.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial setup of variables and error-checking for presence of response ports
window=getPTBWindow(station);
ifi=getIFI(station);
if window<0
   % window = Screen('OpenWindow',0,0);
   error('window must be >=0')
end

HideCursor;
ListenChar(2);
FlushEvents('keyDown');
quit=false;
%need to move this stuff into stimManager or trialManager
toggleStim=1;
numFramesUntilStopSavingMisses=1000;

responseOptions = union(targetOptions, distractorOptions);
if isempty(responseOptions)
    if strcmp(type,'loop')
        error('can''t loop with no response ports -- would have no way out')
    end
end

originalPriority=Priority;

% ===================================================
% This stuff is in determineScreenParametersAndLUT
[garbage ptbVer]=PsychtoolboxVersion;
ptbVersion=sprintf('%d.%d.%d(%s %s)',ptbVer.major,ptbVer.minor,ptbVer.point,ptbVer.flavor,ptbVer.revstring);
try
[runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
ratrixVersion=sprintf('%s (%d of %d)',url,runningSVNversion,repositorySVNversion);
catch ex
    ex
ratrixVersion='no network connection';
end
% ===================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start main try statement (catch errors)

try

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Setup more variables
    filtMode = 0;               %How to compute the pixel color values when the texture is drawn scaled
    %                           %0 = Nearest neighbour filtering, 1 = Bilinear filtering (default, and BAD)

    framesPerUpdate = 1;        %set number of monitor refreshes for each one of your refreshes

    labelFrames = 1;            %print a frame ID on each frame (makes frame calculation slow!)

    verbose = 1;

    dontclear = 0;              %2 saves time by not reinitializing -- safe for us cuz we're redrawing everything -- but gives blue flashing?
    %some stimulus types set dontclear to 1
    loop=0;
    trigger=0;
    frameIndexed=0; % Whether the stim is indexed with a list of frames
    timeIndexed=0; % Whether the stim is timed with a list of frames
    indexedFrames = []; % List of indices referencing the frames
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Determine type of stimulus (indexedFrames or timedFrames, different strategies)
    % for now, type can only be 'trigger' and we only want to use the 'textureCache' strategy
    % apparently frameIndexed and timeIndexed are not variables we use for the textureCache strat?
    loop = 0;
    trigger = 1;
    strategy = 'textureCache';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set up PTB screen
    if window>=0
        [scrWidth scrHeight]=Screen('WindowSize', window);
    else
        scrWidth=getWidth(station);
        scrHeight=getHeight(station);
    end

    % get a sample stimSpec to size correctly
     stim = getStim(stimSpecs{1});
%     if metaPixelSize == 0
%         scaleFactor = [scrHeight scrWidth]./[size(stim,1) size(stim,2)];
%     elseif length(metaPixelSize)==2
%         scaleFactor = metaPixelSize;
%     else
%         error('bad metaPixelSize argument')
%     end
%     if any(scaleFactor.*[size(stim,1) size(stim,2)]>[scrHeight scrWidth])
%         error('metaPixelSize argument too big')
%     end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load and error-check color LUT table
    if size(LUT,1)>1 && size(LUT,2)==3
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
    end

    currentCLUT = Screen('ReadNormalizedGammaTable', window);	% already done? why do we reload currentCLUT?
    maxV=max(currentCLUT(:))
    minV=min(currentCLUT(:))

    if verbose && (minV ~= 0 || maxV ~= 1)
        disp(sprintf('clut has a min of %4.6f and a max of %4.6f',minV,maxV));
    end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine color range (type of LUT table - double, single, uint8, uint16, or logical)
    % tell screen what type of textures we will send
    if verbose
        disp(sprintf('stim class is %s',class(stim)));
    end

    floatprecision=0; % this is the case for uint8, uint16, logical
	% we need to set floatprecision=1 if we use single or double apparently
    % check that all the stims are real
	for i=1:length(stimSpecs)
		stim = getStim(stimSpecs{i});
		if isreal(stim)
			% if stim is real, check to see if it is double or single
			if strcmp(class(stim), 'double') || strcmp(class(stim), 'single')
				floatprecision=1;
			end
		else
			% stim is not real, error out
			error('stim must be real')
		end	
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% check that we have an rnet for the given station with rewardMethod of serverPump
%     if ~isempty(rn)
%         constants = getConstants(rn);
%     end
%     
%     if strcmp(getRewardMethod(station),'serverPump')
%         if isempty(rn) || ~isa(rn,'rnet')
%             error('need an rnet for station with rewardMethod of serverPump')
%         end
%     end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% now we need to enter a PHASES loop to preload all textures into a cell array of movies (one movie per phase)
    % first preallocate our TexArray
    TexArray = cell(length(stimSpecs));
	for i=1:length(stimSpecs)
		spec = stimSpecs{i};
		stim = getStim(spec);
	
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% set up screen dimensions
        scaleFactor = scaleFactors{i};
        if scaleFactor == 0
            scaleFactor = [scrHeight scrWidth] ./ [size(stim,1) size(stim,2)];
        elseif length(scaleFactor)~=2
            error('bad scaleFactor argument');
        end
        if any(scaleFactor.*[size(stim,1) size(stim,2)] > [scrHeight scrWidth])
            error('scaleFactor argument too big');
        end
        

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
%         destRect = round([((scrRight-scrLeft)/2)-(width/4) ((scrBottom-scrTop)/2)-(height/4) ((scrRight-scrLeft)/2)+(width/4) ((scrBottom-scrTop)/2)+(height/4)]);
        
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Make stimulus textures and load into VRAM using Screen('MakeTexture')
		% PreloadTextures as well (to save processing time)
	    tic
	    switch strategy
	        case 'textureCache'
	            %load all frame caches into VRAM

	            textures=zeros(1,size(stim,3));
	            for j=1:size(stim,3)
	                if window>=0
                        'hi';
	                    textures(j)=Screen('MakeTexture', window, squeeze(stim(:,:,j)),0,0,floatprecision);
	                end
	            end
				[resident texidresident] = Screen('PreloadTextures', window);
	        otherwise
	            error('unrecognized strategy')
	    end
		
		% check that all textures were cached
		if resident ~= 1
			disp(sprintf('error: some textures were not cached'));
			find(texidresident~=1)
		end
		if verbose
			disp(sprintf('took %g to load textures', toc));
		end
		
		% store the current textures array into the TexArray cell array corresponding to its stimSpec
		TexArray{i} = textures;
		% end of this PHASES loop to cache textures
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set up some final preferences for Screen before our real-time loop
    standardFontSize=15; %hacked
	oldFontSize = Screen('TextSize',window,standardFontSize); 
	Screen('Preference', 'TextRenderer', 0);  % consider moving to PTB setup
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Cache Sounds 
    preSMCacheTime=GetSecs();
    [newSM updateSMCache]=cacheSounds(getSoundManager(tm));
    disp(sprintf('took %g secs to cache sounds',GetSecs()-preSMCacheTime))
    if updateSMCache
        tm = setSoundManager(tm, newSM); % 8/12/08 -changed to use setter and getter for tm.soundMgr to support new stimOGL/doTrial architecture
%         tm.soundMgr=newSM; %hmmm, how does this cache get persisted, we don't return tm...
    end

 %   Screen('CloseAll');
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set priorityLevel w/o using Rush
    priorityLevel=MaxPriority(window,'GetSecs','KbCheck');

    Priority(priorityLevel); % should use Rush to prevent hard crash if script errors, but then everything below is a string, annoying...
    if verbose
        disp(sprintf('running at priority %d',priorityLevel));
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Enter another PHASES loop here in REAL-TIME
	% we need two separate loops because we cannot drop frames between phases, so we need to cache all frames BEFORE running this loop
	
	% use a while loop to keep looping until we run out of stimSpecs
    response=[]; %initialize 
	done = 0;
	specInd = 1;
    newSpecInd = 1;
	updatePhase = 1;
    % trial-wide variables for reinforcement
    msRewardOwed = 0;
    msAirpuffOwed = 0;
    rewardCurrentlyOn = 0;
    airpuffCurrentlyOn = 0;
    lastRewardTime = [];
    actualRewardDurationMSorUL = 0;
    proposedRewardDurationMSorUL = 0;
    
 %   stepsInPhase = 1;
  %  port = 0; % initialize to no port selected
  %  stimInd = 1;
  


    % entering loop
	while ~done
	%for i=1:length(stimSpecs)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % reset port response
        port = 0;
        FlushEvents('keyDown'); %necessary because we cant hit just one 'tic' of keyboard input
        % For the Windows version of Priority (and Rush), the priority levels set
        % are  "process priority levels". There are 3 priority levels available,
        % levels 0, 1, and 2. Level 0 is "normal priority level", level 1 is "high
        % priority level", and level 2 is "real time priority level". Combined
        % with

        %Priority(9);
        KbCheck; %load mex files into ram
        GetSecs;
        Screen('Screens');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% retrieve current phase (if necessary)
		if updatePhase
            % update index of phase
            specInd = newSpecInd;
            % objects and our useful information
			spec = stimSpecs{specInd};
			stim = getStim(spec);
			textures = TexArray{specInd};
            % phase transition
			transitionCriterion = getCriterion(spec);
            framesUntilTransition = getFramesUntilTransition(spec);
            isFinalPhase = getIsFinalPhase(spec);
            % flag for graduation by time (port was autoselected due to graduation by time)
            transitionedByTimeFlag = 0;
            transitionedByPortFlag = 0;
            % reinforcement
            rewardType = getRewardType(spec);
            rewardDuration = getRewardDuration(spec);
            rewardPorts = transitionCriterion{1};
            % soundTypes
            soundTypesInPhase = soundTypes{specInd};
            numST = length(soundTypesInPhase);
            % counter
            stepsInPhase = 1;
            % variables to handle frame indexing
            stimInd = 1; % reset to first frame of new stim
            stimType = getStimType(spec); % tells how to play the movie for this phase - use to calculate stimInd
            %toggle = 1; % for the toggle stimType - default to first frame
			% if timeIndexed, initialize frameTimes as a vector of the number of frames to hold each frame of the stim
			% also initialize timeElapsed in current frame = 0
			if iscell(stimType) && strcmp(stimType{1}, 'timeIndexed')
				timeElapsed = 0; % for the timeIndexed stimType
				frameTimes = stimType{2}; % a vector of the number of frames to hold each frame of the stim
			end
            % if frameIndexed, then initialize stimInd to correct value
            if iscell(stimType) && strcmp(stimType{1}, 'frameIndexed')
                frameVectorIndex = 1; %for the frameIndexed stimType
                frameVector = stimType{2};
                stimInd = frameVector(frameVectorIndex);
            end
            % stochasticDistribution
            stoD = getStochasticDistribution(spec);
            stochasticCriterion = [];
            stochasticPort = [];
            if ~isempty(stoD)
                stochasticCriterion = stoD{1};
                stochasticPort = stoD{2};
            end
            pickedFromStochasticDistribution = 0; %reset this flag
            
            % variables to control keyboard input
            pressingM=0;
            pressingP=0;
            didAPause=0;
            paused=0;
            doFramePulse=0;
            didPulse=0;
            didValves=0;
           % didManual=0; %replaced by containedManualPokes
            manual=0;
            requestFrame=0;  %used for timed frames stimuli
            framesSinceKbInput=0; %used to throw away keyboard port input b/c we can't press the key for only one frame (too short)
            pickedFromStochasticDistribution=0; %keeps track of if we had a stochastic auto-response
            
            
            
            % reset flags
            % response related flags to be recorded on phase transition
            containedManualPokes=false;
            leftWithManualPokingOn=false;
            containedAPause=false;
            containedForcedRewards=false;
            didHumanResponse=false;
            didStochasticResponse=false;
            
            
            % response and responseDetails
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

            % random stuff that might be used in loop?
            frameNum=1;
            stimStarted=isempty(requestOptions);
            logIt=0;
            stopListening=0;
            lookForChange=0;
            player=[];
            currSound='';
    %	    ports=0*readPorts(station);
    %	    lastPorts=0*readPorts(station);
    %	    currentValveState=verifyValvesClosed(station);
            valveErrorDetails=[];
            requestRewardStarted=false;
            requestRewardDone=false;
    %	    requestRewardPorts=0*readPorts(station);
            requestRewardDurLogged=false;
            requestRewardOpenCmdDone=false;
            serverValveChange=false;  
            isRequesting=0;
            stimToggledOn=0;
           
            
            % Initialize this phaseRecord
            phaseRecords(specInd).proposedReinforcementSizeULorMS = getRewardDuration(spec);
            phaseRecords(specInd).proposedReinforcementType = getRewardType(spec);
            for stInd=1:length(soundTypesInPhase)
                phaseRecords(specInd).proposedSounds{stInd} = soundTypeToString(soundTypesInPhase{stInd});
            end
        %    phaseRecords(specInd).proposedSounds = soundTypesToCellArray(soundTypesInPhase); % a cell array of strings
            % pump stuff
            phaseRecords(specInd).valveErrorDetails=[];
            phaseRecords(specInd).latencyToOpenValves=[];
            phaseRecords(specInd).latencyToCloseValveRecd=[];
            phaseRecords(specInd).latencyToCloseValves=[];
            phaseRecords(specInd).latencyToRewardCompleted=[];
            phaseRecords(specInd).latencyToRewardCompletelyDone=[];
            phaseRecords(specInd).primingValveErrorDetails=[];
            phaseRecords(specInd).latencyToOpenPrimingValves=[];
            phaseRecords(specInd).latencyToClosePrimingValveRecd=[];
            phaseRecords(specInd).latencyToClosePrimingValves=[];
            phaseRecords(specInd).actualPrimingDuration=[];
            % scaleFactor
            phaseRecords(specInd).scaleFactor = scaleFactors{specInd};
           
            % check for rewards present in this phase
            if ~isempty(rewardType)
                switch rewardType
                    case 'reward'
                        msRewardOwed = msRewardOwed + rewardDuration;
                        proposedRewardDurationMSorUL = proposedRewardDurationMSorUL + rewardDuration;
                        %error('msRewardOwed started at %d in phase %d', msRewardOwed, specInd);
                    case 'airpuff'
                        msAirpuffOwed = msAirpuffOwed + rewardDuration;
                    otherwise
                        error('invalid rewardType - we should never reach here!');
                end
            end    
            
        end % end updatePhase
        
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% pick a random port according to stochasticDistribution 
        if ~isempty(stoD) && (rand>stochasticCriterion)
          port = stochasticPort;
          pickedFromStochasticDistribution = 1;
          phaseRecords(specInd).pickedFromStochasticDistribution = 1; %for the record
        end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Setup some variables - get ready to run real-time loop
	    % text drawing variables
        xSubjectTextPos = 25;
        xTextPos = xSubjectTextPos; % + 250
        yTextPos = 20;
        yNewTextPos = yTextPos;
        standardFontSize=15; %big was 25
        subjectFontSize=35; 
	%    i=0;
	%    frameIndex=0;
	    


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Draw frame at given stimInd for the given phase (loaded into textures)
	    if window >= 0
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % if not paused, draw textures
            
            for repeat=1:1
                msg = sprintf('we are in phase %d and selected port %d at frame %d with transition at %d', specInd, port, stepsInPhase, framesUntilTransition);
                Screen('DrawTexture',window,textures(stimInd),[],destRect,[],filtMode);
             %       Screen('DrawTexture',window,textures(stimInd));
                Screen('DrawText', window,msg,xTextPos,yTextPos,100*ones(1,3));
                [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');
                
                yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
                msg = sprintf('current reward duration is %d', actualRewardDurationMSorUL);
                Screen('DrawText',window,msg,xTextPos,yNewTextPos,100*ones(1,3));
            end

            % if port was auto-selected from stochasticDistribution, say so
            if pickedFromStochasticDistribution
                yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
                Screen('DrawText',window,'picked from stochastic distribution',xTextPos,yNewTextPos,100*ones(1,3));
            end
            
            % if manual is one, say so
            if containedManualPokes
                yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
                Screen('DrawText',window,'contained manual pokes',xTextPos,yNewTextPos,100*ones(1,3));
            end
            
            % paused, so also write pause message to screen
            if paused
                yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
        %        Screen('CopyWindow', window, window);
                Screen('DrawText',window,'paused (k+p to toggle)',xTextPos,yNewTextPos,100*ones(1,3));
            end
            
            % print out transition criterion
            yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
            msg = sprintf('transition criterion is %d ', cell2mat(transitionCriterion(1:2:end)));
            Screen('DrawText',window,msg,xTextPos,yNewTextPos,100*ones(1,3));
            
            % FLIP WINDOW HERE
            Screen('Flip',window);

		else
			% if window < 0?
            error('failed');
            waitTime=GetSecs()-when;
            if waitTime>0
                WaitSecs(waitTime);
            end
            ft=when;
            vbl=ft;
            missed=0;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Handle keyboard input (allows for pauses and human port selection)
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

                            containedAPause=1;
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

                    elseif ~isempty(keyName) && ismember(keyName(1),char(asciiOne:asciiOne+length(union(responseOptions, requestOptions))-1))
                        if shiftDown
                            if keyName(1)-asciiOne+1 == 2
                                'WARNING!!!  you just hit shift-2 ("@"), which mario declared a synonym to sca (screen(''closeall'')) -- everything is going to break now'
                                'quitting'
                                done=1;
                                error('should not be here shift-2 kill');
                                response='shift-2 kill';
                            end
                        end
                        if ctrlDown
                            doValves(keyName(1)-asciiOne+1)=1;
                            didValves=true;
                        else
                            %ports(keyName(1)-asciiOne+1)=1;
                            if framesSinceKbInput > 10
                                % this makes sure that we ignore k+(port) if mistakenly pressed for too long
                                port = keyName(1)-asciiOne+1;
                                didHumanResponse=true;
                                % reset framesSinceKbInput if we accept new input
                                framesSinceKbInput = 0;
                            end
                        end
                    elseif strcmp(keyName,'m')
                        mThisLoop=1;
                        containedManualPokes=1;

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
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % update stimInd (track what frame of the stimulus we are on)
        % for now, just increment mod # frames in the stim (ie loop)
        % depends on the stimType - switch on {loop, toggle, once, timeIndexed, frameIndexed}
        if ~paused
            if ischar(stimType) % this handles the loop, toggle, and once cases
                switch stimType
                    case 'loop'
                        stimInd = mod(stimInd, size(stim,3)) + 1;
                    case 'cache'
                        stimInd = stimInd + 1;
                    case 'trigger'
                        % for now, switch toggle (stimInd) whenever you have any response (port)
                        if port
                            if stimInd == 1
                                stimInd = 2;
                            else
                                stimInd = 1;
                            end
                        end

                    otherwise
                        error('unsupported stimType - this should never happen b/c we error-check in stimSpec.m');
                end
            elseif iscell(stimType) % this handles the time and frame indexed cases
                switch stimType{1}
                    case 'timeIndexed'
                        timeElapsed = timeElapsed + 1; %increment timeElapsed

                        % if we have reached the time limit for this frame, move onto next one
                        % if we are already on last frame, just hold it
                        if timeElapsed == frameTimes(stimInd)
                            % update stimInd
                            if stimInd ~= size(stim, 3)
                                stimInd = stimInd + 1;
                                timeElapsed = 0; %reset timeElapsed since we went to next frame
                            end
                        end
                    case 'frameIndexed'
                        % here, we just assign stimInd to the next value in the vector of frame indices
                        % if we are on the last element of the vector, just hold it
                        if frameVectorIndex < length(frameVector)
                            frameVectorIndex = frameVectorIndex + 1;
                            stimInd = frameVector(frameVectorIndex); %update stimInd as necessary (if we are not on last index)
                        end
                    otherwise
                        error('unsupported stimType - this should never happen b/c we error-check in stimSpec.m');
                end
            else
                error('unsupported stimType - this shouldnt happen!!!!');
            end
                    
            % Check against framesUntilTransition - Transition BY TIME
            % if we are at grad by time, then manually set port to the correct one
            % note that we will need to flag that this was done as "auto-request"
            if ~isempty(framesUntilTransition) && stepsInPhase == framesUntilTransition
                %port = transitionCriterion{1}(1);
                newSpecInd = transitionCriterion{2};
                updatePhase = 1;
                if isFinalPhase %if final phase, we are done
                    done = 1;
                end
                %error('transitioned by time in phase %d', specInd);
                transitionedByTimeFlag = 1;
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check for sounds to play
            % look at each element of soundTypesInPhase and use the shouldWePlay method
            if ~isempty(soundTypesInPhase)
                for stInd=1:length(soundTypesInPhase)
                    st = soundTypesInPhase{stInd};
                    % decide what portSet to send to shouldWePlay
                    if find(targetOptions == port)
                        portSet = 'target';
                    elseif find(distractorOptions == port)
                        portSet = 'distractor';
                    elseif find(requestOptions == port)
                        % request
                        portSet = 'request';
                    else
                        % no response, this is a frame indexed sound stimulus
                        portSet = '';
                    end

                    if shouldWePlay(st,portSet, stepsInPhase)
                        tempSoundMgr = playSound(getSoundManager(tm),getName(st),getDuration(st)/1000.0,station);
                        tm = setSoundManager(tm, tempSoundMgr);
%                         tm.soundMgr = playLoop(tm.soundMgr,getName(st),station,getReps(st));
                    end
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Decide if we are done or not

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check phase transitions 
            % Now decide whether or not to go to next phase (ie increment specInd or not)
            % Also check to see if this trial is done (if we graduate from last phase)
            % normally this is done by calling readPorts(station) and checking these against the request and response ports
            % for now, lets just make stuff up - assume that port is the port selected by the subject
            
            % Check port against transitionCriterion - TRANSITION BY RESPONSE
            updatePhase = 0;
       %     oldSpecInd = specInd; % needed to record phaseRecords at the correct index (recordkeep at old index)
            for gcInd=1:2:length(transitionCriterion)-1
                if ~isempty(transitionCriterion{gcInd}) && any(find(transitionCriterion{gcInd} == port))
                    % we found port in this port set
                    % first check if we are done with this trial, in which case we do nothing except set done to 1
                    if isFinalPhase
                        done = 1;
                        updatePhase = 1;
          %              'we are done with this trial'
          %              specInd
                    else
                        % move to the next phase as specified by graduationCriterion
                  %      specInd = transitionCriterion{gcInd+1};
                        newSpecInd = transitionCriterion{gcInd+1};
                        if (specInd == newSpecInd)
                            error('same indices at %d', specInd);
                        end
                        updatePhase = 1;
                    end
                    transitionedByPortFlag = 1;
                    
                    % check for correctness
                    if (find(targetOptions == port)) % this means we are transitioning a phase on a target port - ie correct!
                        ports=[0 0 0];
                        ports(port) = 1;
                        response = ports;
                    elseif (find(distractorOptions == port)) % this means we transitioned on a distractor port - ie wrong!
                        ports=[0 0 0];
                        ports(port) = 1;
                        response = ports;
                    end                
                end
            end
            
            if transitionedByTimeFlag || transitionedByPortFlag
                updatePhase = 1;
                % update phaseRecord for this phase we are about to leave
                phaseRecords(specInd).containedManualPokes = containedManualPokes;
                phaseRecords(specInd).leftWithManualPokingOn = manual;
                phaseRecords(specInd).containedAPause = containedAPause;
                % phaseRecords(oldSpecInd).containedForcedRewards = []; %not set up yet
                phaseRecords(specInd).didHumanResponse = didHumanResponse;
                phaseRecords(specInd).transitionedByTimeFlag = transitionedByTimeFlag;
                phaseRecords(specInd).responseDetails = responseDetails;
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % check for rewards/airpuffs (handle all reinforcement logic here)
            % this is done independent of phase transitions
            % handle rewards

            % update reward owed and elapsed time
            if ~isempty(lastRewardTime) && rewardCurrentlyOn
                elapsedTime = GetSecs() - lastRewardTime;
                msRewardOwed = msRewardOwed - elapsedTime*1000.0;
               % error('elapsed time was %d and msRewardOwed is now %d', elapsedTime, msRewardOwed);
                actualRewardDurationMSorUL = actualRewardDurationMSorUL + elapsedTime*1000.0;
            end
            lastRewardTime = GetSecs();
            
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
                
                switch getRewardMethod(station)
                    case 'localTimed'
                        % handle start and stop cases
                        if start
                            'turning on reward'
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
                        else
                            error('has to be either start or stop - should not be here');
                        end
                    case 'serverPump'
                        'blah'
                    otherwise
                        error('unsupported rewardMethod');
                end
            end
            % end reward stuff
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % wrap-up increments and other recordkeeping for this frame of the phase
            stepsInPhase = stepsInPhase + 1; % increment counter of how long we've been in this phase
            framesSinceKbInput = framesSinceKbInput + 1;
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% end PHASES real-time loop
	end
	% close screen and reset priority
    %response = 'finished';
	Screen('Close');
	Priority(originalPriority);
    ShowCursor(0);
    ListenChar(0);
    

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% catch any exceptions thrown in stimOGL loop
catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])


    Screen('CloseAll');
    Priority(originalPriority);
    ShowCursor(0);
    ListenChar(0);
    response=sprintf('error_in_StimOGL: %s',ers.message);
    rethrow(ex);
    

end