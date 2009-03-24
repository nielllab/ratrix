function [trialManager updateTM newSM updateSM stopEarly trialRecords station] ...
    = doTrial(trialManager,station,stimManager,subject,r,rn,trialRecords,sessionNumber)
verbose=1;
updateTM=false;
stopEarly=0;

% verbose - flag for verbose output
% updateTM - output flag if we need to update TM
% stopEarly - flag to stop running
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
            trialRecords(trialInd).trialManagerClass = class(trialManager);
            trialRecords(trialInd).scheduler = structize(getScheduler(ts));
            trialRecords(trialInd).criterion = structize(getCriterion(ts));
            trialRecords(trialInd).schedulerClass = class(getScheduler(ts));
            trialRecords(trialInd).criterionClass = class(getCriterion(ts));
            
            % 10/17/08 - DO SOMETHING HERE WITH INPUT TRIALDATA before it gets overwritten
            % edf: what does this comment mean?
            % fli: data that might get sent over from the nidaq/physiology event viewer
            % currently, we don't do this, but it might want to get stored in trialRecords or passed to calcStim
            
            trialRecords(trialInd).neuralEvents = [];
            
            switch trialManager.displayMethod
                case 'ptb'
                    resolutions=getResolutions(station);
                case 'LED'
                    resolutions=[];
                otherwise
                    error('shouldn''t happen')
            end
            
            [newSM, ...
                updateSM, ...
                resInd, ...
                stim, ...           %not recorded in trial record
                LUT, ...            %not recorded in trial record
                trialRecords(trialInd).scaleFactor, ... % this scaleFactor is for non-phased stims that call phaseify; phased stims will put the scaleFactor in stimSpecs and ignore this value
                trialRecords(trialInd).type, ...
                trialRecords(trialInd).targetPorts, ...
                trialRecords(trialInd).distractorPorts, ...
                stimulusDetails, ...
                trialRecords(trialInd).interTrialLuminance, ...
                text] ...
                = calcStim(stimManager, ...
                class(trialManager), ...
                resolutions, ...
                getDisplaySize(station), ...
                getLUTbits(station), ...
                getResponsePorts(trialManager,getNumPorts(station)), ...
                getNumPorts(station), ...
                trialRecords);
            
            if isvector(text)
                if ~((iscell(text) && length(text)==size(stim,3) && all(cellfun(@ischar,text))) || ischar(text))
                    error('frame label must be cell vector with same length as size(stim,3), or a char vector')
                end
            else
                error('frame label must be vector')
            end
            
            switch trialManager.displayMethod
                case 'ptb'
                    [station trialRecords(trialInd).resolution]=setResolution(station,resolutions(resInd));
                case 'LED'
                    trialRecords(trialInd).resolution.width=uint8(1);
                    trialRecords(trialInd).resolution.height=uint8(1);
                    trialRecords(trialInd).resolution.pixelSize=uint8(16); %should set using 2nd output of openNidaqForAnalogOutput
                    trialRecords(trialInd).resolution.hz=resInd;
                otherwise
                    error('shouldn''t happen')
            end
            
            trialRecords(trialInd).station = structize(station); %wait til now to record, so we get an updated ifi measurement in the station object
            
            
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
            
            if ischar(trialRecords(trialInd).type) && strcmp(trialRecords(trialInd).type,'phased')
                stimSpecs = stim;
                startingStimSpecInd = 1;
            else
                
                % we pass the trialRecords(trialInd).interTrialLuminance even though we have access to interTrialLuminance because
                % calcStim might have changed the class of the ITL!
                % edf: what did you mean by this?  how do we have access to a member on stimManager?
                % by calling stimManager.getInterTrialLuminance()?  i wish that were a protected method.
                % fli: yeah, i mean we have access to the method - this was just a note to myself that
                % calcStim could change the class of the ITL and return it as trialRecords(trialInd).interTrialLuminance,
                % so we want to use this value from calcStim, not the stimManager's original value
                
                [stimSpecs startingStimSpecInd] ...
                    = phaseify(trialManager,stim,trialRecords(trialInd).type,...
                    trialRecords(trialInd).targetPorts,trialRecords(trialInd).distractorPorts,getRequestPorts(trialManager,getNumPorts(station)),...
                    trialRecords(trialInd).scaleFactor,trialRecords(trialInd).interTrialLuminance,trialRecords(trialInd).resolution.hz);
            end
            
            validateStimSpecs(stimSpecs);

            [tempSoundMgr updateSndM] = cacheSounds(getSoundManager(trialManager),station);
            trialManager = setSoundManager(trialManager, tempSoundMgr);
            updateTM = updateTM || updateSndM;
            
            trialRecords(trialInd).stimManager = structize(decache(newSM)); %many rouge stimManagers have a LUT cached in them and aren't decaching it -- hopefully will be fixed by the LUT fixing... (http://132.239.158.177/trac/rlab_hardware/ticket/224)
            stimulusDetails=structize(stimulusDetails); %don't add to trialRecords til later cuz datanet might remove a .big field
            
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
            
            trialLabel=sprintf('session:%d trial:%d (%d)',sessionNumber,sum(trialRecords(trialInd).sessionNumber == [trialRecords.sessionNumber]),trialRecords(trialInd).trialNumber);
            
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

            if ~isempty(getEyeTracker(station))
                [junk junk eyeDataVarNames]=getSample(getEyeTracker(station)); %throws out a sample in order to get variable names... dirty
                saveEyeData(getEyeTracker(station),eyeData,eyeDataFrameInds,eyeDataVarNames,gaze,trialRecords(trialInd).trialNumber,trialRecords(trialInd).date)
            end
            
            trialRecords(trialInd).trainingStepName = generateStepName(ts,ratrixSVNInfo,ptbSVNInfo);
            
            if stopEarly
                'got stopEarly 1'
            end
            
            currentValveStates=verifyValvesClosed(station);
            
            
            % set correct=0 if it was not set during real-time loop
            % we need correct to be empty at the start of the loop so that we know that it needs to be set by updateTrialState,
            % but an empty correct field causes problems for compiling b/c it is not scalar
%             if isempty(trialRecords(trialInd).correct)
%                 trialRecords(trialInd).correct = 0;
%             end
            
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
                validInputs{1}=1:getNumPorts(station);
                validInputs{2}=[1 100];
                validInputs{3}=[0 10];
                validInputs{4}=[0 60];
                fpVars = userPrompt(getPTBWindow(station),validInputs,type,typeParams);
                flushPorts(station,fpVars(3),fpVars(2),fpVars(4),fpVars(1));
                stopEarly=false; % reset stopEarly/quit to be false, so continue doing trials
            elseif ischar(trialRecords(trialInd).result) && (strcmp(trialRecords(trialInd).result, 'nominal') || ...
                    strcmp(trialRecords(trialInd).result, 'multiple ports'))
                % keep doing trials
            else
                trialRecords(trialInd).result
                if strcmp(trialRecords(trialInd).result,'manual training step')
                    updateTM=true; % to make sure that soundMgr gets decached and passed back to the subject/doTrial where the k+t happens
                end
                fprintf('setting stopEarly\n')
                stopEarly = 1;
            end
            
            if ~isempty(getDatanet(station))
                datanet_constants = getConstants(getDatanet(station));
                
                commands = [];
                commands.cmd = datanet_constants.stimToDataCommands.S_SAVE_DATA_CMD;
                commands.arg = sprintf('neuralRecords_%d-%s.mat',trialRecords(trialInd).trialNumber, datestr(trialRecords(trialInd).date, 30));
                [junk, gotAck] = sendCommandAndWaitForAck(getDatanet(station), getCon(getDatanet(station)), commands);
                
                commands=[];
                commands.cmd = datanet_constants.stimToDataCommands.S_SEND_EVENT_DATA_CMD;
                [physiologyEvents, gotAck] = sendCommandAndWaitForAck(getDatanet(station), getCon(getDatanet(station)), commands);
                trialRecords(trialInd).physiologyEvents = physiologyEvents;
                
                commands=[];
                commands.cmd = datanet_constants.stimToDataCommands.S_ACK_EVENT_DATA_CMD;
                [junk, gotAck] = sendCommandAndWaitForAck(getDatanet(station), getCon(getDatanet(station)), commands);
                
                stim_path = fullfile(getStorePath(getDatanet(station)), 'stimRecords');
                stim_filename = fullfile(stim_path, sprintf('stimRecords_%d-%s',trialRecords(trialInd).trialNumber,datestr(trialRecords(trialInd).date, 30)));
                
                %also maybe include something from the phased records?
                % maybe if ~isempty(phaseRecords{i}.responseDetails.expertDetails)
                %for phaseInd=1:length(trialRecords(trialInd).phaseRecords)
                %    if isfield(trialRecords(trialInd).phaseRecords(phaseInd),'responseDetails' ..etc)
                %        stimulusDetails.dynRecords{phaseInd}=phaseRecords{i}.responseDetails.expertDetails
                %    end
                %end
                
                stimManagerClass=trialRecords(trialInd).stimManagerClass;
                
                try
                    save(stim_filename, 'stimulusDetails','stimManagerClass','physiologyEvents');
                catch
                    warningStr('unable to save to %s',stim_path);
                    error(warningStr);
                end
            end
            
            if isfield(stimulusDetails, 'big') % edf: why did this used to also test for isstruct(stimulusDetails) ?
                stimulusDetails = rmfield(stimulusDetails, 'big');
                
                %also, maybe one day these exist and need removing:
                % phaseRecords{i}.responseDetails.expertDetails.big
            end
            
            trialRecords(trialInd).stimDetails = stimulusDetails;
            
            % need to decide what to do with trialData - do we pass back to doTrials?
            % edf: do you mean trialRecords?
            % fli: no, trialData is some data that may or may not be passed from the data collection side (ie nidaq)
            % the decision is whether or not any of it belongs in trialRecords, or if it will be stored independently
            
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
