function [trialManager updateTM newSM updateSM stopEarly trialRecords station] ...
    = doTrial(trialManager,station,stimManager,subject,r,rn,trialRecords,sessionNumber)
% This function handles most of the per-trial functionality, including stim creation and display, reward handling, and trialRecord recording.
% Main functions called: calcStim, createStimSpecsFromParams, stimOGL
% INPUTS:
%   trialManager - the trial manager object
%   station - the station object
%   stimManager - the stim manager object
%   subject - the subject object
%   r - the ratrix object
%   rn - the rnet object
%   trialRecords - a vector of the current session's trialRecords (includes some history from prev. session until they get replaced by current session)
%   sessionNumber - the current session number
% OUTPUTS:
%   trialManager - the (potentially modified) trial manager object
%   updateTM - a flag indicating if the trialManager needs to be persisted
%   newSM - a possibly new stimManager object
%   updateSM - a flag indicating if the stimManager needs to be persisted
%   stopEarly - a flag to stop running trials
%   trialRecords - the updated trial records
%   station - the (potentially modified) station object


verbose=1;
updateTM=false;
stopEarly=0;

% verbose - flag for verbose output
% constants - returned from getConstants(rn) if we have a rnet
% trialInd - the index of the current trialRecord
% p - current training protocol
% t - current training step index
% ts - current trainingStep object

if isa(station,'station') && isa(stimManager,'stimManager') && isa(r,'ratrix') && isa(subject,'subject') && ((isempty(rn) && strcmp(getRewardMethod(station),'localTimed')) || isa(rn,'rnet'))
    if stationOKForTrialManager(trialManager,station)
        
        if ~isempty(rn)
            constants = getConstants(rn);
        end
        
        trialInd=length(trialRecords)+1;
        [p t]=getProtocolAndStep(subject);
        ts = getTrainingStep(p,t);
        
        if trialInd>1
            trialRecords(trialInd).trialNumber=trialRecords(trialInd-1).trialNumber+1;
        else
            trialRecords(trialInd).trialNumber=1;
        end
        
        if isa(stimManager,'stimManager')
            trialRecords(trialInd).sessionNumber = sessionNumber;
            trialRecords(trialInd).date = datevec(now);
            trialRecords(trialInd).box = structize(getBoxFromID(r,getBoxIDForSubjectID(r,getID(subject))));
            trialRecords(trialInd).station = structize(station);
            trialRecords(trialInd).protocolName = getName(p);
            trialRecords(trialInd).trainingStepNum = t;
            trialRecords(trialInd).numStepsInProtocol = getNumTrainingSteps(p);
            trialRecords(trialInd).protocolVersion = getProtocolVersion(subject);
            
            trialRecords(trialInd).reinforcementManager = [];
            trialRecords(trialInd).reinforcementManagerClass = [];
            
            stns=getStationsForBoxID(r,getBoxIDForSubjectID(r,getID(subject)));
            for stNum=1:length(stns)
                trialRecords(trialInd).stationIDsInBox{stNum} = getID(stns(stNum));
            end
            
            trialRecords(trialInd).subjectsInBox = getSubjectIDsForBoxID(r,getBoxIDForSubjectID(r,getID(subject)));
            trialRecords(trialInd).trialManager = structize(decache(trialManager));
            trialRecords(trialInd).stimManagerClass = class(stimManager);            
            trialRecords(trialInd).stepName = getStepName(ts);
            trialRecords(trialInd).trialManagerClass = class(trialManager);
            trialRecords(trialInd).scheduler = structize(getScheduler(ts));
            trialRecords(trialInd).criterion = structize(getCriterion(ts));
            trialRecords(trialInd).schedulerClass = class(getScheduler(ts));
            trialRecords(trialInd).criterionClass = class(getCriterion(ts));
            
            trialRecords(trialInd).neuralEvents = [];
            
            switch trialManager.displayMethod
                case 'ptb'
                    resolutions=getResolutions(station);
                case 'LED'
                    resolutions=[];
                otherwise
                    error('shouldn''t happen')
            end
            
			% calcStim should return the following:
			%	newSM - a (possibly) modified stimManager object
			%	updateSM - a flag whether or not to copy newSM to ratrix
			%	resInd - for setting resolution - DO NOT CHANGE
			%	preRequestStim - a struct containing all stim-specifc parameters to create a stimSpec for the pre-request phase
			%	preResponseStim - a struct containing all stim-specific parameters to create a stimSpec for the pre-response phase
			%	discrimStim - a struct containing the parameters to create a stimSpec for the discriminandum phase
			%		the parameters needed are: stimType, stim(actual movie frames), scaleFactor, [phaseLabel], [framesUntilTransition], [startFrame], [phaseType]
			%		note that not all of these may be used, depending on the trialManager's delayManager and responseWindow parameters
			%	LUT - the color lookup table - DO NOT CHANGE now; but eventually this should be a cell array of parameters to get the CLUT from oracle!
			%	trialRecords(trialInd).targetPorts - target ports DO NOT CHANGE
			%	trialRecords9trialInd).distractorPorts - distractor ports DO NOT CHANGE (both port sets are constant across the trial)
			%	stimulusDetails - stimDetails DO NOT CHANGE
			%	trialRecords(trialInd).interTrialLuminance - itl DO NOT CHANGE
			%	text - DO NOT CHANGE
			%	indexPulses - DO NOT CHANGE
			
			% now, we should ALWAYS call createStimSpecsFromParams, which should do the following:
			%	INPUTS: preRequestStim, preResponseStim, discrimStim, targetPorts, distractorPorts, requestPorts,interTrialLuminance,hz,indexPulses
            %	OUTPUTS: stimSpecs, startingStimSpecInd
            %		- should handle creation of default phase setup for nAFC/freeDrinks, and also handle additional phases depending on delayManager and responseWindow
            %		- how then does calcStim return a set of custom phases? - it no longer can, because we are forcing calcstim to return 3 structs...to discuss later?            
            
            [trialRecords(trialInd).targetPorts, trialRecords(trialInd).distractorPorts, stimulusDetails, text] = ...
                assignPorts(trialManager,trialRecords,getResponsePorts(trialManager,getNumPorts(station)));
             if strcmp(class(trialManager), 'goNoGo')
             trialRecords(trialInd).targetPorts = [2];
             end
             
            
             if strcmp(class(trialManager), 'freeGoNoGo') 
                 if getEarlyP(trialManager)
             trialRecords(trialInd).targetPorts = [2];
                 else 
                     trialRecords(trialInd).targetPorts = [];
                 end
             end
             
             
            [newSM, ...
                updateSM, ...
                resInd, ...
                preRequestStim, ...
                preResponseStim, ...
                discrimStim, ...
                LUT, ...
                trialRecords(trialInd).targetPorts, ...
                trialRecords(trialInd).distractorPorts, ...
                stimulusDetails, ...
                trialRecords(trialInd).interTrialLuminance, ...
                text, ...
				indexPulses, ...
                imagingTasks, ...
                sounds] ...
                = calcStim(stimManager, ...
                class(trialManager), ...
                getAllowRepeats(trialManager), ...
                resolutions, ...
                getDisplaySize(station), ...
                getLUTbits(station), ...
                getResponsePorts(trialManager,getNumPorts(station)), ...
                getNumPorts(station), ...
                trialRecords,...
                trialRecords(trialInd).targetPorts, ...
                trialRecords(trialInd).distractorPorts, ...
                stimulusDetails, ...
                text);
            
            
            if strcmp(class(newSM), 'CNM')
            durations = getDurations(newSM); %[duration toneDuration isi]
            %rWMs = [(durations(1) - durations(2)) durations(1)]; %from beginning of last tone to its end
            % rWMs = [(durations(1) - durations(2))/2 (durations(3) + durations(1))/2]; %dividing by 2 makes the timeout happen at the correct time... why?
             rWMs = [0 (durations(1))/2 + durations(3)/4 + durations(2)/2];
             trialManager = setResponseWindow(trialManager, rWMs);
           %trialManager = setResponseWindow(trialManager,[0 2000] );
            end
            
            if strcmp(class(newSM), 'freeCNM')
            durations = getDurations(newSM); %[duration toneDuration isi]
            %rWMs = [(durations(1) - durations(2)) durations(1)]; %from beginning of last tone to its end
            % rWMs = [(durations(1) - durations(2))/2 (durations(3) + durations(1))/2]; %dividing by 2 makes the timeout happen at the correct time... why?
             rWMs = [0 (durations(1))/2 + durations(3)/4];
             trialManager = setResponseWindow(trialManager, rWMs);
           %trialManager = setResponseWindow(trialManager,[0 2000] );
            end
            
%              if strcmp(class(newSM), 'CNMafc')
%             durations = getDurations(newSM); %[duration toneDuration isi]
%             %rWMs = [(durations(1) - durations(2)) durations(1)]; %from beginning of last tone to its end
%             % rWMs = [(durations(1) - durations(2))/2 (durations(3) + durations(1))/2]; %dividing by 2 makes the timeout happen at the correct time... why?
%              rWMs = [0 10001];
%              trialManager = setResponseWindow(trialManager, rWMs);
%            %trialManager = setResponseWindow(trialManager,[0 2000] );
%             end
            
            
            % test must a single string now - dont bother w/ complicated stuff here
			if ~ischar(text)
				error('text must be a string');
            end            
            
            switch trialManager.displayMethod
                case 'ptb'
                    if ~isnan(resInd)
                        newRes=resolutions(resInd);
                    else
                        newRes=[];
                    end
                    [station trialRecords(trialInd).resolution trialRecords(trialInd).imagingTasks]=setResolutionAndPipeline(station,newRes,imagingTasks);
                case 'LED'
                    trialRecords(trialInd).resolution.width=uint8(1);
                    trialRecords(trialInd).resolution.height=uint8(1);
                    trialRecords(trialInd).resolution.pixelSize=uint8(16); %should set using 2nd output of openNidaqForAnalogOutput
                    trialRecords(trialInd).resolution.hz=resInd;
                otherwise
                    error('shouldn''t happen')
            end
            
            [newSM, updateSM, stimulusDetails]=postScreenResetCheckAndOrCache(newSM,updateSM,stimulusDetails); %enables SM to check or cache their tex's if they control that
            
            trialRecords(trialInd).station = structize(station); %wait til now to record, so we get an updated ifi measurement in the station object
            
            refreshRate=1/getIFI(station); %resolution.hz is 0 on OSX
            
            % check port logic (depends on trialManager class)
            if (isempty(trialRecords(trialInd).targetPorts) || isvector(trialRecords(trialInd).targetPorts))...
                    && (isempty(trialRecords(trialInd).distractorPorts) || isvector(trialRecords(trialInd).distractorPorts))
                
                portUnion=[trialRecords(trialInd).targetPorts trialRecords(trialInd).distractorPorts];
                if length(unique(portUnion))~=length(portUnion) ||...
                        any(~ismember(portUnion, getResponsePorts(trialManager,getNumPorts(station))))
                    
                    trialRecords(trialInd).targetPorts
                    trialRecords(trialInd).distractorPorts
                    getResponsePorts(trialManager,getNumPorts(station))
                    trialRecords(trialInd).targetPorts
                    trialRecords(trialInd).distractorPorts
                    getResponsePorts(trialManager,getNumPorts(station))
                    error('targetPorts and distractorPorts must be disjoint, contain no duplicates, and subsets of responsePorts')
                end
            else
                trialRecords(trialInd).targetPorts
                trialRecords(trialInd).distractorPorts
                error('targetPorts and distractorPorts must be row vectors')
            end
            
            checkPorts(trialManager,trialRecords(trialInd).targetPorts,trialRecords(trialInd).distractorPorts);
            
            [stimSpecs startingStimSpecInd sm] = createStimSpecsFromParams(trialManager,preRequestStim,preResponseStim,discrimStim,...
				trialRecords(trialInd).targetPorts,trialRecords(trialInd).distractorPorts,getRequestPorts(trialManager,getNumPorts(station)),...
				trialRecords(trialInd).interTrialLuminance,refreshRate,indexPulses, newSM);

            validateStimSpecs(stimSpecs);

            [tempSoundMgr updateSndM] = cacheSounds(getSoundManager(trialManager),station,sounds);
            trialManager = setSoundManager(trialManager, tempSoundMgr);
            updateTM = updateTM || updateSndM;
            
            trialRecords(trialInd).stimManager = structize(decache(newSM)); %many rouge stimManagers have a LUT cached in them and aren't decaching it -- hopefully will be fixed by the LUT fixing... (http://132.239.158.177/trac/rlab_hardware/ticket/224)
            stimulusDetails=structize(stimulusDetails);
            
            manualOn=0;
            if length(trialRecords)>1
                if ~(trialRecords(trialInd-1).leftWithManualPokingOn)
                    manualOn=0;
                elseif trialRecords(trialInd-1).containedManualPokes
                    manualOn=1;
                else
                    error('should never happen')
                end
            end
            
            %             [rm updateRM] =cache(getReinforcementManager(trialManager),trialRecords, subject);
            %             updateTM = updateTM || updateRM;
            
            drawnow;
            currentValveStates=verifyValvesClosed(station);
            
            pStr=[trialRecords(trialInd).protocolName '(' num2str(trialRecords(trialInd).protocolVersion.manualVersion) 'm:' num2str(trialRecords(trialInd).protocolVersion.autoVersion) 'a)' ' step:' num2str(trialRecords(trialInd).trainingStepNum) '/' num2str(trialRecords(trialInd).numStepsInProtocol) ];
            
            thisSession=trialRecords(trialInd).sessionNumber == [trialRecords.sessionNumber];
            nPerf=uint8(50);
            [~, ~, pct] = checkCriterion(performanceCriterion(1,nPerf),subject,ts,trialRecords,false);
            trialLabel=sprintf('%d%%(%d) trial:%d(%d)(%d) session:%d',round(100*pct),nPerf,sum([trialRecords(thisSession).trainingStepNum]==trialRecords(trialInd).trainingStepNum),sum(thisSession),trialRecords(trialInd).trialNumber,sessionNumber);
            
            if ~isempty(getDatanet(station))
				% 4/11/09 - also save the stimRecord here, before trial starts (but just the stimManagerClass)
				% also send over the filename of the neuralRecords file (so we can create it on the phys side, and then append every 30 secs)
                datanet_constants = getConstants(getDatanet(station));
                if ~isempty(getDatanet(station))
                    [garbage stopEarly] = handleCommands(getDatanet(station),[]);
                end
                if ~stopEarly
                    commands=[];
                    commands.cmd = datanet_constants.stimToDataCommands.S_TRIAL_START_EVENT_CMD;
                    cparams=[];
                    cparams.neuralFilename = sprintf('neuralRecords_%d-%s.mat',trialRecords(trialInd).trialNumber,datestr(trialRecords(trialInd).date,30));
                    cparams.stimFilename = sprintf('stimRecords_%d-%s.mat',trialRecords(trialInd).trialNumber,datestr(trialRecords(trialInd).date, 30));
                    cparams.time=datenum(trialRecords(trialInd).date);
                    cparams.trialNumber=trialRecords(trialInd).trialNumber;
                    cparams.stimManagerClass=trialRecords(trialInd).stimManagerClass;
                    cparams.stepName=getStepName(ts);
                    cparams.stepNumber=t;
                    commands.arg=cparams;
                    [gotAck] = sendCommandAndWaitForAck(getDatanet(station), commands);

                    ratID=getID(subject);
                    trialStartTime=datestr(trialRecords(trialInd).date, 30);
                    trialNum=trialRecords(trialInd).trialNumber;
                    stimManagerClass=trialRecords(trialInd).stimManagerClass;
                    stepName=trialRecords(trialInd).stepName;
                    frameDropCorner=trialManager.frameDropCorner;

                    try
                        stim_path = fullfile(getStorePath(getDatanet(station)), 'stimRecords');
                        save(fullfile(stim_path,cparams.stimFilename),'ratID','trialStartTime','trialNum','stimManagerClass','stimulusDetails','frameDropCorner','refreshRate','stepName');
                    catch ex
                        warningStr=sprintf('unable to save to %s',stim_path);
                        error(warningStr);
                    end
                end
            end
            
            if isfield(stimulusDetails, 'big') % edf: why did this used to also test for isstruct(stimulusDetails) ?
                stimulusDetails = rmfield(stimulusDetails, 'big');

                %also, maybe one day these exist and need removing:
                % phaseRecords{i}.responseDetails.expertDetails.big
            end
            
            trialRecords(trialInd).stimDetails = stimulusDetails;
            
            % stopEarly could potentially be set by the datanet's handleCommands (if server tells this client to shutdown
            % while we are in doTrial)
            if ~stopEarly
                [trialManager stopEarly,...
                    trialRecords,...
                    eyeData,...
                    eyeDataFrameInds,...
                    gaze,...
                    station,...
                    ratrixSVNInfo,...
                    ptbSVNInfo] ...
                    = stimOGL( ...
                    trialManager, ...
                    stimSpecs,  ...
                    startingStimSpecInd, ...
                    newSM, ...
                    LUT, ...
                    trialRecords(trialInd).targetPorts, ...
                    trialRecords(trialInd).distractorPorts, ...
                    getRequestPorts(trialManager, getNumPorts(station)), ...
                    trialRecords(trialInd).interTrialLuminance, ...
                    station, ...
                    manualOn, ...
                    .1, ... % 10% should be ~1 ms of acceptable frametime error
                    text,rn,getID(subject),class(newSM),pStr,trialLabel,getEyeTracker(station),0,trialRecords);
            end

            if ~isempty(getEyeTracker(station))
                %[junk junk eyeDataVarNames]=getSample(getEyeTracker(station)); %throws out a sample in order to get variable names... dirty
                saveEyeData(getEyeTracker(station),eyeData,eyeDataFrameInds,getEyeDataVarNames(getEyeTracker(station)),gaze,trialRecords(trialInd).trialNumber,trialRecords(trialInd).date)
            end
            
            trialRecords(trialInd).trainingStepName = generateStepName(ts,ratrixSVNInfo,ptbSVNInfo);
            
            if stopEarly
                'got stopEarly 1'
            end
            
            currentValveStates=verifyValvesClosed(station);
            
            if ~ischar(trialRecords(trialInd).result)
%                 resp=find(trialRecords(trialInd).result);
%                 if length(resp)==1
%                     trialRecords(trialInd).correct = ismember(resp,trialRecords(trialInd).targetPorts);
%                 end
%             elseif ischar(trialRecords(trialInd).result) && strcmp(trialRecords(trialInd).result, 'multiple ports')
                % keep doing trials if response was 'multiple ports'
%             elseif ischar(trialRecords(trialInd).result) && strcmp(trialRecords(trialInd).result, 'none')
                % temporarily continue doing trials if response = 'none'
                % edf: how would stimOGL exit while leaving response as 'none'?  passive viewing?  (empty responseOptions)
                % if so, why do you say 'temporarily'?  also, should verify that this really was a passive viewing.
                %
                % i think response is also 'none' if there is a bad error in stimOGL, 
                % like an rnet error, in which case we should not continue trials
                % we need to flag any error with a special response so we know what's going on and don't continue
            elseif ischar(trialRecords(trialInd).result) && strcmp(trialRecords(trialInd).result, 'manual flushPorts')
                type='flushPorts';
                typeParams=[];
                validInputs={};
                validInputs{1}=0:getNumPorts(station);
                validInputs{2}=[1 100];
                validInputs{3}=[0 10];
                validInputs{4}=[0 60];
                fpVars = userPrompt(getPTBWindow(station),validInputs,type,typeParams);
                portsToFlush=fpVars(1);
                if portsToFlush==0 % 0 is a special flag that means do all ports (for calibration, we need interleaved ports)
                    portsToFlush=1:getNumPorts(station);
                end
                flushPorts(station,fpVars(3),fpVars(2),fpVars(4),portsToFlush);
                stopEarly=false; % reset stopEarly/quit to be false, so continue doing trials
            elseif ischar(trialRecords(trialInd).result) && (strcmp(trialRecords(trialInd).result, 'nominal') || ...
                    strcmp(trialRecords(trialInd).result, 'multiple ports') || strcmp(trialRecords(trialInd).result,'timedout'))
                % keep doing trials
            else
                trialRecords(trialInd).result
                if strcmp(trialRecords(trialInd).result,'manual training step')
                    updateTM=true; % to make sure that soundMgr gets decached and passed back to the subject/doTrial where the k+t happens
                end
%                 sca
%                 keyboard
                fprintf('setting stopEarly\n')
                stopEarly = 1;
            end
            
            if ~isempty(getDatanet(station)) %&& ~stopEarly
                [garbage garbage] = handleCommands(getDatanet(station),[]);
                datanet_constants = getConstants(getDatanet(station));
                commands=[];
                commands.cmd = datanet_constants.stimToDataCommands.S_TRIAL_END_EVENT_CMD;
                cparams=[];
                cparams.time = now;
                commands.arg=cparams;
                [gotAck] = sendCommandAndWaitForAck(getDatanet(station), commands);
            end
            
            trialRecords(trialInd).reinforcementManager = structize(trialManager.reinforcementManager);
            trialRecords(trialInd).reinforcementManagerClass = class(trialManager.reinforcementManager);
            
            currentValveStates=verifyValvesClosed(station);
            
            while ~isempty(rn) && commandsAvailable(rn,constants.priorities.AFTER_TRIAL_PRIORITY) && ~stopEarly
                if ~isConnected(r)
                    stopEarly=true;
                end
                com=getNextCommand(rn,constants.priorities.AFTER_TRIAL_PRIORITY);
                if ~isempty(com)
                    [good cmd args]=validateCommand(rn,com);
                    if good
                        switch cmd
                            case constants.serverToStationCommands.S_SET_VALVES_CMD
                                requestedValveState=args{1};
                                isPrime=args{2};
                                if isPrime
                                    
                                    timeout=-5;
                                    
                                    [stopEarly trialRecords(trialInd).primingValveErrorDetails(end+1),...
                                        trialRecords(trialInd).latencyToOpenPrimingValves(end+1),...
                                        trialRecords(trialInd).latencyToClosePrimingValveRecd(end+1),...
                                        trialRecords(trialInd).latencyToClosePrimingValves(end+1),...
                                        trialRecords(trialInd).actualPrimingDuration(end+1),...
                                        garbage,...
                                        garbage]...
                                        = clientAcceptReward(...
                                        rn,...
                                        com,...
                                        station,...
                                        timeout,...
                                        valveStart,...
                                        requestedValveState,...
                                        [],...
                                        isPrime);
                                    
                                    if stopEarly
                                        'got stopEarly 7'
                                    end
                                    
                                    currentValveStates=verifyValvesClosed(station);
                                else
                                    sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received non-priming S_SET_VALVES_CMD outside of a trial');
                                end
                            otherwise
                                stopEarly=clientHandleVerifiedCommand(rn,com,cmd,args,constants.statuses.IN_SESSION_BETWEEN_TRIALS);
                                
                                if stopEarly
                                    'got stopEarly 8'
                                end
                        end
                    end
                end
            end
            
            currentValveStates=verifyValvesClosed(station);
            
            if stopEarly
                trialManager.soundMgr=uninit(trialManager.soundMgr,station);
            end
            
            if stopEarly
                trialManager.soundMgr=uninit(trialManager.soundMgr,station);
            end
            
        else
            error('need a stimManager')
        end
    else
        error('station not ok for trialManager')
    end
else
    
    sca
    
    if ~isa(station,'station')
        error('no station')
    end
    if ~isa(stimManager, 'stimManager')
        error('no stimManager')
    end
    if ~isa(subject, 'subject')
        error('no subject')
    end
    if ~isa(r, 'ratrix')
        error('no ratrix')
    end
    if ~isa(rn, 'rnet') && isempty(rn)
        error('no rnet %s', getRewardMethod(station))
    end
    if ~isa(rn, 'rnet')
        error('non-empty rnet %s', getRewardMethod(station))
    end
    
    error('need station, stimManager, subject, ratrix, and rnet objects')
end

end

function validateStimSpecs(stimSpecs)
for i=1:length(stimSpecs)
    spec = stimSpecs{i};
    cr = getTransitions(spec);
    fr = getFramesUntilTransition(spec);
    stimType = getStimType(spec);
    
    % if expert mode, check that the stim is a struct with the following fields:
    %   floatprecision
    %   height
    %   width
    if ischar(stimType) && strcmp(stimType,'expert')
        s=getStim(spec);
        if isstruct(s) && isfield(s,'height') && isfield(s,'width')
            % pass
        else
            error('in ''expert'' mode, stim must be a struct with fields ''height'' and ''width''');
        end
    end
    
    if strcmp(cr{1}, 'none') && (isempty(fr) || (isscalar(fr) && fr<=0))
        error('must have a transition port set or a transition by timeout');
    end
end
end
