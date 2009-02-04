function [trialManager updateTM newSM updateSM stopEarly trialRecords station] ...
    =doTrial(trialManager,station,stimManager,subject,r,rn,trialRecords,sessionNumber)
verbose=1;
updateTM=false;
stopEarly=0;

% if ~isempty(rn)
%     error('rn in phasedTrialManager/doTrial is not empty anymore');
% end

% List of variables used: 
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

        % Get the trial number from the passed in trial records
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
            
            % Initializing
            trialRecords(trialInd).correct = [];
            trialRecords(trialInd).reinforcementManager = [];
            trialRecords(trialInd).reinforcementManagerClass = [];

            stns=getStationsForBoxID(r,getBoxIDForSubjectID(r,getID(subject)));
            for stNum=1:length(stns)
                stationIDsInBox{stNum} = getID(stns(stNum));
            end

            trialRecords(trialInd).subjectsInBox = getSubjectIDsForBoxID(r,getBoxIDForSubjectID(r,getID(subject)));
            trialRecords(trialInd).trialManager = structize(decache(trialManager));
            trialRecords(trialInd).stimManager = structize(decache(stimManager)); %maybe?
            trialRecords(trialInd).stimManagerClass = class(stimManager);
            trialRecords(trialInd).trialManagerClass = class(trialManager);
            trialRecords(trialInd).scheduler = structize(getScheduler(ts));
            trialRecords(trialInd).criterion = structize(getCriterion(ts));
            trialRecords(trialInd).schedulerClass = class(getScheduler(ts));
            trialRecords(trialInd).criterionClass = class(getCriterion(ts));
            

            
            % the stim here is used as input to stimOGL - we need to modify
            % it to be a cell array of stimSpecs, and run stimOGL on this
            % cell array (other record keeping may change too)
            
            % we are assuming that calcStim() is changed to return a cell
            % array of stimSpecs instead of a single stim
            % calcStim() also returns the total length (in frames) of all
            % the stimSpecs added up
            % - target and distractor ports are same for all phases
            % - also need to change details to be a vector of detail
            % objects, one for each phase? or remove since we have stimSpec
            % - removed interTrialLuminance (no longer needed as this is in
            % stimSpec)
%             [newSM, ...
%                 updateSM, ...
%                 stimSpecs, ...                %changed stim to stimSpecs %trialRecords(trialInd).stim, ...
%                 soundTypes, ...               % added this to store the soundTypes for each phase
%                 LUT, ...
%                 stimulusDetails, ... % we need this to track correctionTrial status; this is stored in TrialRecords(index).stimDetails as a struct
%                 scaleFactors, ...
%                 trialRecords(trialInd).targetPorts, ...
%                 trialRecords(trialInd).distractorPorts, ...
%                 isCorrection]= ...
%                 calcStim(stimManager, ... 
%                 class(trialManager), ...
%                 getResponsePorts(trialManager,getNumPorts(station)), ...
%                 getNumPorts(station), ...
%                 getLUTbits(station), ...
%                 trialRecords(1:end-1));


            % 10/17/08 - DO SOMETHING HERE WITH INPUT TRIALDATA before it gets overwritten
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
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
                trialRecords(trialInd).scaleFactor, ... % this scaleFactor is for non-phased stims that call phaseify; phased stims will put the scaleFactor in stim.stimSpecs and ignore this value
                trialRecords(trialInd).type, ...
                trialRecords(trialInd).targetPorts, ...
                trialRecords(trialInd).distractorPorts, ...
                stimulusDetails, ...
                trialRecords(trialInd).interTrialLuminance, ...
                text]= ...
                calcStim(stimManager, ...
                class(trialManager), ...
                resolutions, ...
                getDisplaySize(station), ...
                getLUTbits(station), ...
                getResponsePorts(trialManager,getNumPorts(station)), ...
                getNumPorts(station), ...
                trialRecords(1:end)); % change to trialRecords(1:end) - to support images/calcStim deck handling
            
            % =====================================================================================================
            % use old signature (non-phased), but stuff all phase data into the stim field
            % validate ports, resolution, text
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
            
            % =====================================================================================================
            %UPDATE REWARDS AND PENALTIES BASED ON REWARD MANAGER - pmm 070525 (need to give correct errStim)
            %rewardManager happens to live in trialManager for now... getting it for use
% this now happens inside runRealTimeLoop 2/3/09
%             [rm rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] =calcReinforcement(getReinforcementManager(trialManager),trialRecords, subject);
%             updateTM = updateTM || updateRM;
%             
%             if updateRM
%                 trialManager = setReinforcementManager(trialManager, rm);
%             end
            % =====================================================================================================
            % phase-ify if necessary (if trialRecords(trialInd).type is 'phased')
            % - this means we need stimSpecs, soundTypes, scaleFactors, and
            % stimulusDetails to be phase-specific
            if ischar(trialRecords(trialInd).type) && strcmp(trialRecords(trialInd).type,'phased')
                stimSpecs = stim.stimSpecs;
            else
%                 class(trialManager)
%                 error('stop b/c not phased');
%                 phaseify();

%                 size(stim,3)
%                 error('stop');
%                 t = GetSecs();
%                 error('it took %s to phase-ify', GetSecs() - t);
                [stimSpecs] = phaseify(trialManager,stim,stimManager,trialRecords(trialInd).type,...
                    trialRecords(trialInd).targetPorts,trialRecords(trialInd).distractorPorts,trialRecords(trialInd).scaleFactor,...
                    getIFI(station),trialRecords(trialInd).resolution.hz);
            end
            
            % 1/29/09 - go through all stimSpecs and insert any values from rm as flagged
%             for i=1:length(stimSpecs)
%                 % set reward type and duration
%                 if strcmp(getRewardType(stimSpecs{i}),'rewardSizeULorMS')
%                     stimSpecs{i}=setRewardTypeAndDuration(stimSpecs{i},'reward',rewardSizeULorMS);
%                 elseif strcmp(getRewardType(stimSpecs{i}),'msPuff')
%                     stimSpecs{i}=setRewardTypeAndDuration(stimSpecs{i},'airpuff',msPuff);
%                 end
%                 % set time-out (msPenalty)
%                 if ischar(getFramesUntilTransition(stimSpecs{i})) && strcmp(getFramesUntilTransition(stimSpecs{i}),'msPenalty')
%                     stimSpecs{i}=setFramesUntilTransition(stimSpecs{i},ceil((msPenalty/1000)/getIFI(station)));
%                 end
%             end
            
            % we have called calcStim() to successfully return our cell
            % array of stimSpec objects along with target, distractor, and
            % request ports, and other information
            
            
			% NEED TO VALIDATE STIMSPECS HERE
			validateStimSpecs(stimSpecs);

            % ALL STIM STUFF IS DONE NOW 
            % =====================================================================================================
            
            % stimulusDetails is the black box where calcStim can put anything (including movies) for storage
            % currently my version only stores a single field isCorrection
            
            % we are choosing to leave all sound and reinforcement stuff
            % untouched - we will only implement a basic stimSpec with
            % phase-specific visual stimuli for now (testing)
          
            audioStimulus = [];
            if getSoundOn(station) && ismethod(newSM,'getAudioStimulus');
                audioStim = getAudioStimulus(newSM);
                if ~isempty(audioStim)
                    audioStimulus=getName(audioStim);
                    % Add/replace the stimulus sound clip to the list of clips in
                    % the sound manager
%                     trialManager.soundMgr = addSound(trialManager.soundMgr,audioStim);
                    tempSoundMgr = addSound(getSoundManager(trialManager), audioStim); % 8/12/08 - changed to use setter and getter for tm.soundMgr to support new stimOGL/doTrial architecture
                    trialManager = setSoundManager(trialManager, tempSoundMgr);
                end
            end

            % Wait to cache sounds until here because you might get new ones
            [tempSoundMgr updateSndM] = cacheSounds(getSoundManager(trialManager),station); % 8/12/08 - changed to use setter and getter for tm.soundMgr to support new stimOGL/doTrial architecture
            trialManager = setSoundManager(trialManager, tempSoundMgr);
%             [trialManager.soundMgr updateSndM]=cacheSounds(getSoundManager(trialManager));  %update of soundManager was overwritting update of stimulus manager. now fixed pmm 2008/05/02 
            updateTM = updateTM || updateSndM;  %

            % Create soundType objects for stimOGL

            %so that we can display the sessionUpTime - pmm 20080207
            % trialsThisSession=trialRecords(trialRecords.sessionID==trialRecords.sessionID(end));
            trialsThisSession=trialRecords;
            if size(trialsThisSession,2)>1
                sessionStartTime=datenum(trialsThisSession(1).date);
            else
                sessionStartTime=now;
            end


            %trialRecords(trialInd).stimManager = structize(newSM); %edf: removed 11.04.06 -- the timedFrame stim manager is too large (it has a cache).  could call a decache() method...
            % 10/23/08 - changed to only put stimulusDetails in trialRecords if 'big' field isnt defined
            % the physiology stim manager's calcStim will define this field!

            
            stimulusDetails=structize(stimulusDetails); %now its factored so it happens only once
            trialRecords(trialInd).stimManager = structize(decache(newSM));
            trialRecords(trialInd).stimDetails = stimulusDetails;
                
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
            
%             trialRecords(trialInd).proposedRewardDurationMSorUL = 0;
%             % calculate and record expected reward duration
%             for tempInd=1:length(stimSpecs)
%                 if ~isempty(getRewardType(stimSpecs{tempInd}))
%                     trialRecords(trialInd).proposedRewardDurationMSorUL = trialRecords(trialInd).proposedRewardDurationMSorUL + getRewardDuration(stimSpecs{tempInd});
%                 end
%             end
            
            % =====================================================================================================
            % 10/19/08 - setup of eyeTracker (start recording or check that recording is happening each trial)
            eyeTracker=getEyeTracker(trialManager);
            if ~isempty(eyeTracker)
               if isa(eyeTracker,'eyeTracker')
                   if isTracking(eyeTracker)
                       checkRecording(eyeTracker); % check if recording eye data each trial
                   else
                       %figure out where to save eyeTracker data
                       if ~isempty(trialManager.datanet) % only use data net if its there
                           eyeDataPath = fullfile(getStorePath(trialManager.datanet), 'eyeRecords');
                       else
                           %right now its hard coded when no data net is there
                           %maybe put it with trial records in the permanent store?
                           eyeDataPath = fullfile('\\132.239.158.179','datanet_storage', getID(subject), 'eyeRecords');
                       end
                       %start recording eye data
                       eyeTracker=initialize(eyeTracker,eyeDataPath)%,%station.window);
                       eyeTracker=start(eyeTracker,trialRecords(trialInd).trialNumber);
                       trialManager=setEyeTracker(trialManager,eyeTracker);
                       updateTM=true;
                   end
               else
                   error('not an eyeTracker')
               end
            end
            
            % =====================================================================================================
%             if ~isempty(trialManager.datanet)
%                 % 10/17/08 - start of a datanet trial - timestamp
%                 datanet_constants = getConstants(trialManager.datanet);
%                 commands = [];
%                 commands.cmd = datanet_constants.stimToDataCommands.S_TIMESTAMP_CMD;
%                 [trialData, gotAck] = sendCommandAndWaitForAck(trialManager.datanet, getCon(trialManager.datanet), commands);
%             end
            % =====================================================================================================

            % finished setting up variables and stuff, now we call stimOGL
            % will deal with trialRecords recordkeeping later - just let it
            % record whatever it does for now
               %         audioStimulus, ... %no longer need this since we have stimSpecs
            % replace all the trialRecord stuff with an array (possibly) of phaseRecords
            pStr=[trialRecords(trialInd).protocolName '(' num2str(trialRecords(trialInd).protocolVersion.manualVersion) 'm:' num2str(trialRecords(trialInd).protocolVersion.autoVersion) 'a)' ' step:' num2str(trialRecords(trialInd).trainingStepNum) '/' num2str(trialRecords(trialInd).numStepsInProtocol) ];

            trialLabel=sprintf('session:%d trial:%d (%d)',sessionNumber,sum(trialRecords(trialInd).sessionNumber == [trialRecords.sessionNumber]),trialRecords(trialInd).trialNumber);

            [stopEarly trialRecords(trialInd).response,...
                trialRecords(trialInd).leftWithManualPokingOn,...
                trialRecords(trialInd).containedManualPokes,...
                trialRecords(trialInd).actualReinforcementDurationMSorUL,...
                trialRecords(trialInd).proposedReinforcementDurationMSorUL, ... %pmm added 4/3/08
                eyeData,...
                gaze,...
                station,...
                trialRecords(trialInd).phaseRecords,...
                ratrixSVNInfo,...
                ptbSVNInfo]= ...
                stimOGL( ...
                trialManager, ...
                stimSpecs,  ...  %changed stim to stimSpecs (stimOGL needs to handle a cell array of stimSpecs for this trial)
                newSM, ... %10/13/08 - used to determine what sounds to play at each frame in runRealTimeLoop %1/20/09 - also used to do expert mode
                LUT, ...
                trialRecords(trialInd).targetPorts, ...
                trialRecords(trialInd).distractorPorts, ...
                getRequestPorts(trialManager, getNumPorts(station)), ...
                trialRecords(trialInd).interTrialLuminance, ...
                station, ...
                manualOn, ...
                1, ...
                .1, ... % 10% should be ~1 ms of acceptable frametime error
                0,text,rn,getID(subject),class(newSM),pStr,trialLabel,trialManager.eyeTracker,0,trialRecords);

            if ~isempty(trialManager.eyeTracker)
                [junk junk eyeDataVarNames]=getSample(trialManager.eyeTracker); %throws out a sample in order to get variable names... dirty
                saveEyeData(trialManager.eyeTracker,eyeData,eyeDataVarNames,gaze,trialRecords(trialInd).trialNumber)
            end

            % ============================================================
            % 12/5/08 - add trainingStep.generateStepName() here to store name of the training step for this trial
            % assembles a name by calling a getNameFragment() method on its trialMgr, stimMgr, rewadrMgr, and scheduler,
            % together with the actual svnRev and ptbRev for that trial 
            % (which should be added to the trialRecord in trialManager.doTrial() anyway --
            %   return ptbVersion and ratrixVersion from stimOGL). 
            % the base class inherited implementation for each getNameFragment() could just return 
            % an abbreviated class name, but could be overridden by subclasses to include important parameter values.
            trialRecords(trialInd).trainingStepName = generateStepName(ts,ratrixSVNInfo,ptbSVNInfo);
            
            % END additions
            % ============================================================

            if stopEarly
                'got stopEarly 1'
            end

            currentValveStates=verifyValvesClosed(station);

            resp=find(trialRecords(trialInd).response);
            if ~ischar(trialRecords(trialInd).response)
                if length(resp)==1
                    trialRecords(trialInd).correct = ismember(resp,trialRecords(trialInd).targetPorts);
%                 elseif length(resp)>1
%                     % triggered two or more ports at same time
%                     trialRecords(trialInd).response
%                     trialRecords(trialInd).correct=0;
%                     fprintf('setting stopEarly because multiple ports blocked\n')
%                     stopEarly=1;
                else
                    trialRecords(trialInd).correct = 0;                   
                end
            elseif ischar(trialRecords(trialInd).response) && strcmp(trialRecords(trialInd).response, 'none')
                % temporarily continue doing trials if response = 'none'
                trialRecords(trialInd).correct = 0;
            elseif ischar(trialRecords(trialInd).response) && strcmp(trialRecords(trialInd).response, 'manual flushPorts')
                trialRecords(trialInd).correct = 0;
                % call flushPorts here
                flushPorts(.05,5,.5,station);
                stopEarly=false; % reset stopEarly/quit to be false, so continue doing trials
            else
                trialRecords(trialInd).correct = 0;
                trialRecords(trialInd).response
                fprintf('setting stopEarly\n')
                stopEarly = 1;
            end
            
            
            % 11/9/08 - moved here from after calcStim - save 'big' if necessary and remove from stimDetails
            % gives stimOGL a chance to store dynamic mode stuff in phaseRecords
            % rewrote so saving bigs is only if datanet is defined -pmm
            
            if ~isempty(trialManager.datanet) % only use data net if its there
                
                % save this stim details to subject-specific place (with neural and eye data)
                % this includes all normal details as well as big stuff, example: large random noise movie 
                stim_path = fullfile(getStorePath(trialManager.datanet), 'stimRecords');
                stim_filename = fullfile(stim_path, sprintf('stimRecords_%d-%s',trialRecords(trialInd).trialNumber,datestr(trialRecords(trialInd).date, 30)));
                
                %also maybe include something from the phased records?
                % maybe if ~isempty(phaseRecords{i}.responseDetails.expertDetails)
                %for phaseInd=1:length(trialRecords(trialInd).phaseRecords)
                %    if isfield(trialRecords(trialInd).phaseRecords(phaseInd),'responseDetails' ..etc) 
                %        stimulusDetails.dynRecords{phaseInd}=phaseRecords{i}.responseDetails.expertDetails
                %    end
                %end   
                
                %save class as well
                stimManagerClass=trialRecords(trialInd).stimManagerClass;
                
                try
                    save(stim_filename, 'stimulusDetails','stimManagerClass');
                catch
                    warningStr('unable to save to %s',stim_path);
                    error(warningStr);
                end     
            end
            
            if isstruct(stimulusDetails) && isfield(stimulusDetails, 'big')
                % remove 'big' from stimDetails (so we don't overwhelm trialRecords)
                %the only way these can be accessed is if a datanet saved
                %them per-trial
                 stimulusDetails = rmfield(stimulusDetails, 'big');  
                 %also, maybe one day these exist and need removing: 
                 % phaseRecords{i}.responseDetails.expertDetails.big
            end
            
            % =====================================================================================================
            % 10/19/08 - get eyeTracker data after trial run
            if ~isempty(eyeTracker)
                [junk junk eyeDataVarNames]=getSample(eyeTracker);
                %throws out a sample in order to get variable names... dirty

                saveEyeData(eyeTracker,eyeData,eyeDataVarNames,gaze,trialRecords(trialInd).trialNumber)
                %not currently saving data from any other phase besides disciminandum
            end
            % =====================================================================================================
            % 10/17/08 - get trial's worth of data from datanet (neural data)
            if ~isempty(trialManager.datanet)
                datanet_constants = getConstants(trialManager.datanet);
                commands = [];
                commands.cmd = datanet_constants.stimToDataCommands.S_SAVE_DATA_CMD;
                commands.arg = sprintf('neuralRecords_%d-%s.mat',trialRecords(trialInd).trialNumber, datestr(trialRecords(trialInd).date, 30));
                [trialData, gotAck] = sendCommandAndWaitForAck(trialManager.datanet, getCon(trialManager.datanet), commands);
                % now try to load this file and store into trialData to be used next trial
%                 try
%                     trialData = load(fullfile(getStorePath(trialManager.datanet), commands.arg), 'trialData', 'times');
%                 catch ex
%                     error('failed to load from tempfile.mat for neural data');
%                 end
            end
            % 10/19/08 - need to decide what to do with trialData - do we pass back to doTrials?
            % =====================================================================================================
            % 12/5/08 - add trainingStep.generateStepName() here to store name of the training step for this trial
            % assembles a name by calling a getNameFragment() method on its trialMgr, stimMgr, rewadrMgr, and scheduler,
            % together with the actual svnRev and ptbRev for that trial 
            % (which should be added to the trialRecord in trialManager.doTrial() anyway --
            %   return ptbVersion and ratrixVersion from stimOGL). 
            % the base class inherited implementation for each getNameFragment() could just return 
            % an abbreviated class name, but could be overridden by subclasses to include important parameter values.
            trialRecords(trialInd).trainingStepName = generateStepName(ts,ratrixSVNInfo,ptbSVNInfo);
            
            % END additions
            % =====================================================================================================

            %if slow rewards check, here or the calc reinforcement are likely implicated
            trialRecords(trialInd).reinforcementManager = structize(trialManager.reinforcementManager);
            trialRecords(trialInd).reinforcementManagerClass = class(trialManager.reinforcementManager);
%             trialRecords(trialInd).proposedRewardSizeULorMS=rewardSizeULorMS;
%             trialRecords(trialInd).proposedMsPenalty=msPenalty;
%             trialRecords(trialInd).proposedMsRewardSound=msRewardSound;
%             trialRecords(trialInd).proposedMsPenaltySound=msPenaltySound;
%             trialRecords(trialInd).proposedMsPuff=msPuff;

%             %UPDATE REWARDS AND PENALTIES BASED ON REWARD MANAGER - pmm 070525
%             %rewardManager happens to live in trialManager for now... getting it for use
%             [rm rewardSizeULorMS msPenalty msRewardSound msPenaltySound updateRM] =calcReinforcement(getReinforcementManager(trialManager),trialRecords, subject);
%             updateTM = updateTM || updateRM;
% 
%             if updateRM
%                 trialManager = setReinforcementManager(trialManager, rm);
%             end
% 
%             %if slow rewards check, here or the calc reinforcement are likely implicated
%             trialRecords(trialInd).reinforcementManager = structize(trialManager.reinforcementManager);
%             trialRecords(trialInd).reinforcementManagerClass = class(trialManager.reinforcementManager);
% %             trialRecords(trialInd).proposedRewardSizeULorMS=rewardSizeULorMS;
% %             trialRecords(trialInd).proposedMsPenalty=msPenalty;
% %             trialRecords(trialInd).proposedMsRewardSound=msRewardSound;
% %             trialRecords(trialInd).proposedMsPenaltySound=msPenaltySound;

%             if ~stopEarly
% 
%                 if trialRecords(trialInd).correct
% 
%                     rewardValves=zeros(1,getNumPorts(station));
%                     rewardValves(resp)=1;
%                     rewardValves=logical(rewardValves);
%                     allClosed=logical(zeros(1,getNumPorts(station)));
% 
%                     switch getRewardMethod(station)
% 
%                         case 'localTimed'
%                             trialManager.soundMgr=playSound(trialManager.soundMgr,'correctSound',msRewardSound/1000.0,station);
% 
%                             %OPEN VALVE
%                             %setValves(station, rewardValves)
%                             %expectedValveState=zeros(1,getNumPorts(station));
%                             [currentValveStates trialRecords(trialInd).responseDetails.valveErrorDetails]=...
%                                 setAndCheckValves(station,rewardValves,currentValveStates,...
%                                 trialRecords(trialInd).responseDetails.valveErrorDetails,...
%                                 trialRecords(trialInd).responseDetails.startTime,'correct reward open');
%                             valveStart=GetSecs();
% 
%                             WaitSecs(rewardSizeULorMS/1000); %%pause(rewardSizeULorMS/1000)
% 
%                             %CLOSE VALVE
%                             %setValves(station,zeros(1,getNumPorts(station)));
%                             %expectedValveState=rewardValves;
%                             [currentValveStates trialRecords(trialInd).responseDetails.valveErrorDetails]=...
%                                 setAndCheckValves(station,zeros(1,getNumPorts(station)),currentValveStates,...
%                                 trialRecords(trialInd).responseDetails.valveErrorDetails,...
%                                 trialRecords(trialInd).responseDetails.startTime,'correct reward close');
%                             trialRecords(trialInd).actualRewardDuration = GetSecs()-valveStart;
% 
%                             if verbose
%                                 trialRecords(trialInd).actualRewardDuration
%                             end
%                             pctRewardOff=abs(1.0-(trialRecords(trialInd).actualRewardDuration/(rewardSizeULorMS/1000.0)));
%                             if pctRewardOff>.05
%                                 warning('reward duration was off by %g',pctRewardOff)
%                             end
% 
%                         case 'serverPump'
%                             valveStart=GetSecs();
%                             timeout=-5.0;
%                             trialManager.soundMgr = playLoop(trialManager.soundMgr,'correctSound',station,1);
% 
%                             sprintf('*****should be no output between here *****')
% 
%                             stopEarly=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_REWARD_CMD,{rewardSizeULorMS,logical(rewardValves)});
%                             rewardDone=false;
%                             if ~stopEarly
%                                 trialRecords(trialInd).primingValveErrorDetails=[];
%                                 trialRecords(trialInd).latencyToOpenPrimingValves=[];
%                                 trialRecords(trialInd).latencyToClosePrimingValveRecd=[];
%                                 trialRecords(trialInd).latencyToClosePrimingValves=[];
%                                 trialRecords(trialInd).actualPrimingDuration=[];
%                             end
%                             while ~rewardDone && ~stopEarly
%                                 [stopEarly openValveCom openValveCmd openValveCmdArgs]=waitForSpecificCommand(rn,[],constants.serverToStationCommands.S_SET_VALVES_CMD,timeout,'waiting for server open valve response to C_REWARD_CMD',constants.statuses.MID_TRIAL);
% 
% 
%                                 if stopEarly
%                                     'got stopEarly 2'
%                                 end
% 
% 
%                                 if ~stopEarly
% 
%                                     if any([isempty(openValveCom) isempty(openValveCmd) isempty(openValveCmdArgs)])
%                                         error('waitforspecificcommand acted like it got a stop early even though it says it didn''t')
%                                     end
% 
%                                     requestedValveState=openValveCmdArgs{1};
%                                     isPrime=openValveCmdArgs{2};
% 
% 
% 
%                                     if ~isPrime
%                                         rewardDone=true;
%                                         trialRecords(trialInd).latencyToOpenValveRecd=GetSecs()-valveStart;
% 
%                                         [stopEarly trialRecords(trialInd).valveErrorDetails,...
%                                             trialRecords(trialInd).latencyToOpenValves,...
%                                             trialRecords(trialInd).latencyToCloseValveRecd,...
%                                             trialRecords(trialInd).latencyToCloseValves,...
%                                             trialRecords(trialInd).actualRewardDuration,...
%                                             trialRecords(trialInd).latencyToRewardCompleted,...
%                                             trialRecords(trialInd).latencyToRewardCompletelyDone]...
%                                             =clientAcceptReward(...
%                                             rn,...
%                                             openValveCom,...
%                                             station,...
%                                             timeout,...
%                                             valveStart,...
%                                             requestedValveState,...
%                                             rewardValves,...
%                                             isPrime);
% 
%                                         if stopEarly
%                                             'got stopEarly 3'
%                                         end
% 
%                                     else
% 
%                                         [stopEarly trialRecords(trialInd).primingValveErrorDetails(end+1),...
%                                             trialRecords(trialInd).latencyToOpenPrimingValves(end+1),...
%                                             trialRecords(trialInd).latencyToClosePrimingValveRecd(end+1),...
%                                             trialRecords(trialInd).latencyToClosePrimingValves(end+1),...
%                                             trialRecords(trialInd).actualPrimingDuration(end+1),...
%                                             garbage,...
%                                             garbage]...
%                                             =clientAcceptReward(...
%                                             rn,...
%                                             openValveCom,...
%                                             station,...
%                                             timeout,...
%                                             valveStart,...
%                                             requestedValveState,...
%                                             [],...
%                                             isPrime);
% 
%                                         if stopEarly
%                                             'got stopEarly 4'
%                                         end
%                                     end
%                                 end
% 
%                             end
% 
%                             sprintf('*****and here *****')
% 
%                             trialManager.soundMgr = playLoop(trialManager.soundMgr,'',station,0);
%                         otherwise
%                             error('unrecognized reward method')
%                     end
% 
%                 % we can probably remove this part - this handles the wrong
%                 % response case - this is a phase now
%                 elseif ~ischar(trialRecords(trialInd).response)
%                     trialManager.soundMgr=playSound(trialManager.soundMgr,'wrongSound',msPenaltySound/1000,station);
%                     numErrorFrames=ceil((msPenalty/1000)/ifi);
%                     [errStim errorScale] = errorStim(stimManager,numErrorFrames);
%                     errAudioStim = [];
% 
%                     [stopEarly,...
%                         errorRecords(trialInd).response,...
%                         errorRecords(trialInd).responseDetails,...
%                         errorRecords(trialInd).containedManualPokes,...
%                         errorRecords(trialInd).leftWithManualPokingOn,...
%                         errorRecords(trialInd).containedAPause,...
%                         errorRecords(trialInd).containedForcedRewards, ...
%                         errorRecords(trialInd).didHumanResponse, ... 
%                         errorRecords(trialInd).didStochasticResponse] ...
%                         =stimOGL( ...
%                         trialManager, ...
%                         errStim, ...
%                         errAudioStim, ...
%                         LUT, ...
%                         'cache', ...
%                         errorScale, ...
%                         window, ...
%                         ifi, ...
%                         [], ...
%                         [], ...
%                         trialRecords(trialInd).interTrialLuminance, ...
%                         station,0,0,.5,1,0,rn,getID(subject),trialRecords(trialInd).stimManagerClass);
% 
%                     trialRecords(trialInd).errorRecords=errorRecords(trialInd);
% 
%                     if stopEarly
%                         'got stopEarly 6'
%                     end
%                     
%                 % END REMOVE
%                 % ==================================================
%                 
%                 else
%                     trialRecords(trialInd).response
%                     stopEarly=1;
% 
%                     if stopEarly
%                         'setting stopEarly '
%                     end
%                 end
%             end

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
                                        =clientAcceptReward(...
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



%             if verbose
%                 trialRecords(trialInd)
%                 trialRecords(trialInd).stimDetails
%                 trialRecords(trialInd).responseDetails
%             end
            if stopEarly
                uninit(trialManager.soundMgr,station);
            end

            if stopEarly
                uninit(trialManager.soundMgr,station);
            end

        else
            error('need a stimManager')
        end
    else
        error('station not ok for trialManager')
    end
else

    sca

'****'
    isa(station,'station')
    isa(stimManager,'stimManager')
    isa(subject,'subject')
    isa(r,'ratrix')
    stimManager
    isa(stimManager,'stimManager')
    isa(stimManager,'examplePhased')
    rn
    getRewardMethod(station)
'****'
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NESTED FUNCTION
% this function checks each stimSpec and makes sure that the parameters are valid
% only used inside this file TM/doTrial
function validateStimSpecs(stimSpecs)

    % check that if the transition criterion is 'none', that a transition timeout is defined (framesUntilTransition)
    for i=1:length(stimSpecs)
        spec = stimSpecs{i};
        cr = getCriterion(spec);
        fr = getFramesUntilTransition(spec);

        if strcmp(cr{1}, 'none') && (isempty(fr) || (isscalar(fr) && fr<=0))
            error('must have a transition port set or a transition by timeout');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
