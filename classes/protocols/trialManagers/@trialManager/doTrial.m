function [trialManager updateTM newSM updateSM stopEarly trialRecords station]=doTrial(trialManager,station,stimManager,subject,r,rn,trialRecords,sessionNumber)
verbose=1;
updateTM=false;
stopEarly=0;

if isa(station,'station') && isa(stimManager,'stimManager') && isa(r,'ratrix') && isa(subject,'subject') && ((isempty(rn) && ismember(getRewardMethod(station),{'localTimed','localPump'})) || isa(rn,'rnet'))
    if stationOKForTrialManager(trialManager,station)

        if ~isempty(rn)
            constants = getConstants(rn);
        end

        %         %if isempty(trialRecords)
        %         trialRecords = getTrialRecordsForSubjectID(r,getID(subject));
        %         %end
        %         trialRecords
        %         class(trialRecords)

        trialInd=length(trialRecords)+1;
        [p t]=getProtocolAndStep(subject);
        ts = getTrainingStep(p,t);

        % Get the trial number from the passed in trial records
        if trialInd>1
            trialRecords(trialInd).trialNumber=trialRecords(trialInd-1).trialNumber+1;
        else
            trialRecords(trialInd).trialNumber=1;
        end


        %the doTrial that matters in eyeDev is the one in promptedNAFC

        if isa(stimManager,'stimManager')
            trialRecords(trialInd).sessionNumber = sessionNumber;
            trialRecords(trialInd).date = datevec(now);
            trialRecords(trialInd).box = structize(getBoxFromID(r,getBoxIDForSubjectID(r,getID(subject))));
            trialRecords(trialInd).protocolName = getName(p);
            trialRecords(trialInd).trainingStepNum = t;
            trialRecords(trialInd).numStepsInProtocol = getNumTrainingSteps(p);
            trialRecords(trialInd).protocolVersion = getProtocolVersion(subject);

            % Initializing
            trialRecords(trialInd).correct = [];
            trialRecords(trialInd).reinforcementManager = [];
            trialRecords(trialInd).proposedRewardSizeULorMS=[];
            trialRecords(trialInd).proposedMsPenalty=[];
            trialRecords(trialInd).proposedMsRewardSound=[];
            trialRecords(trialInd).proposedMsPenaltySound=[];
            trialRecords(trialInd).errorRecords=[];
            trialRecords(trialInd).actualRewardDuration=[];

            % More Initializing
            trialRecords(trialInd).valveErrorDetails=[];
            trialRecords(trialInd).latencyToOpenValves=[];
            trialRecords(trialInd).latencyToCloseValveRecd=[];
            trialRecords(trialInd).latencyToCloseValves=[];
            trialRecords(trialInd).actualRewardDuration=[];
            trialRecords(trialInd).latencyToRewardCompleted=[];
            trialRecords(trialInd).latencyToRewardCompletelyDone=[];
            trialRecords(trialInd).primingValveErrorDetails=[];
            trialRecords(trialInd).latencyToOpenPrimingValves=[];
            trialRecords(trialInd).latencyToClosePrimingValveRecd=[];
            trialRecords(trialInd).latencyToClosePrimingValves=[];
            trialRecords(trialInd).actualPrimingDuration=[];

            stns=getStationsForBoxID(r,getBoxIDForSubjectID(r,getID(subject)));
            for stNum=1:length(stns)
                stationIDsInBox{stNum} = getID(stns(stNum));
            end

            trialRecords(trialInd).subjectsInBox = getSubjectIDsForBoxID(r,getBoxIDForSubjectID(r,getID(subject)));

            trialRecords(trialInd).trialManager = structize(decache(trialManager));
            trialRecords(trialInd).stimManagerClass = class(stimManager);
            trialRecords(trialInd).trialManagerClass = class(trialManager);
            trialRecords(trialInd).scheduler = structize(getScheduler(ts));
            trialRecords(trialInd).criterion = structize(getCriterion(ts));
            trialRecords(trialInd).schedulerClass = class(getScheduler(ts));
            trialRecords(trialInd).criterionClass = class(getCriterion(ts));

            resolutions=getResolutions(station);
            
            [newSM, ...
                updateSM, ...
                resInd, ...
                stim, ...           %not recorded in trial record
                LUT, ...            %not recorded in trial record
                trialRecords(trialInd).scaleFactor, ...
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
                trialRecords(1:end-1));

            if isvector(text)
                if ~((iscell(text) && length(text)==size(stim,3) && all(cellfun(@ischar,text))) || ischar(text))
                    error('frame label must be cell vector with same length as size(stim,3), or a char vector')
                end
            else
                error('frame label must be vector')
            end
            
            [station trialRecords(trialInd).resolution]=setResolution(station,resolutions(resInd));
            trialRecords(trialInd).station = structize(station); %wait til now to record, so we get an updated ifi measurement in the station object

            if (isempty(trialRecords(trialInd).targetPorts) || isvector(trialRecords(trialInd).targetPorts))...
                    && (isempty(trialRecords(trialInd).distractorPorts) || isvector(trialRecords(trialInd).distractorPorts))
                portUnion=[trialRecords(trialInd).targetPorts trialRecords(trialInd).distractorPorts];
                if length(unique(portUnion))~=length(portUnion) ||...
                        any(~ismember(portUnion, getResponsePorts(trialManager,getNumPorts(station))))

                    error('targetPorts and distractorPorts must be disjoint, contain no duplicates, and subsets of responsePorts')
                end
            else
                trialRecords(trialInd).targetPorts
                trialRecords(trialInd).distractorPorts
                error('targetPorts and distractorPorts must be row vectors')
            end


            audioStimulus = [];
            if ismethod(newSM,'getAudioStimulus');
                audioStim = getAudioStimulus(newSM);
                if ~isempty(audioStim)
                    audioStimulus=getName(audioStim);
                    % Add/replace the stimulus sound clip to the list of clips in
                    % the sound manager
                    trialManager.soundMgr = addSound(trialManager.soundMgr,audioStim);
                end
            end

            % Wait to cache sounds until here because you might get new ones
            [trialManager.soundMgr updateSndM]=cacheSounds(trialManager.soundMgr);  %update of soundManager was overwritting update of stimulus manager. now fixed pmm 2008/05/02
            updateTM = updateTM || updateSndM;  %



            %so that we can display the sessionUpTime - pmm 20080207
            % trialsThisSession=trialRecords(trialRecords.sessionID==trialRecords.sessionID(end));
            trialsThisSession=trialRecords;
            if size(trialsThisSession,2)>1
                sessionStartTime=datenum(trialsThisSession(1).date);
            else
                sessionStartTime=now;
            end


            trialRecords(trialInd).stimManager = structize(decache(newSM));
            trialRecords(trialInd).stimDetails = structize(stimulusDetails);

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

            [rm updateRM] =cache(getReinforcementManager(trialManager),trialRecords, subject);
            updateTM = updateTM || updateRM;

            drawnow;

            currentValveStates=verifyValvesClosed(station);

            pStr=[trialRecords(trialInd).protocolName '(' num2str(trialRecords(trialInd).protocolVersion.manualVersion) 'm:' num2str(trialRecords(trialInd).protocolVersion.autoVersion) 'a)' ' step:' num2str(trialRecords(trialInd).trainingStepNum) '/' num2str(trialRecords(trialInd).numStepsInProtocol) ];

            trialLabel=sprintf('session:%d trial:%d (%d)',sessionNumber,sum(trialRecords(trialInd).sessionNumber == [trialRecords.sessionNumber]),trialRecords(trialInd).trialNumber);            
            
            [stopEarly trialRecords(trialInd).response,...
                trialRecords(trialInd).responseDetails,...
                trialRecords(trialInd).containedManualPokes,...
                trialRecords(trialInd).leftWithManualPokingOn,...
                trialRecords(trialInd).containedAPause,...
                trialRecords(trialInd).containedForcedRewards, ... %pmm added 4/3/08
                trialRecords(trialInd).didHumanResponse, ... %pmm added 4/18/08
                trialRecords(trialInd).didStochasticResponse,...
                eyeData,...
                gaze,...
                station]= ...
                stimOGL( ...
                trialManager, ...
                stim, ...
                audioStimulus, ...
                LUT, ...
                trialRecords(trialInd).type, ...    % 'loop', ... %trialRecords(trialInd).type, ...
                trialRecords(trialInd).scaleFactor, ...
                union(trialRecords(trialInd).targetPorts, trialRecords(trialInd).distractorPorts), ...
                getRequestPorts(trialManager, getNumPorts(station)), ...
                trialRecords(trialInd).interTrialLuminance, ...
                station, ...
                manualOn, ...
                1, ...
                .1, ... % 10% should be ~1 ms of acceptable frametime error
                0,text,rn,getID(subject),trialRecords(trialInd).stimManagerClass,pStr,trialLabel,trialManager.eyeTracker,0);

            if ~isempty(trialManager.eyeTracker)
                [junk junk eyeDataVarNames]=getSample(trialManager.eyeTracker); %throws out a sample in order to get variable names... dirty
                saveEyeData(trialManager.eyeTracker,eyeData,eyeDataVarNames,gaze,trialRecords(trialInd).trialNumber)
            end


            if stopEarly
                'got stopEarly 1'
            end

            currentValveStates=verifyValvesClosed(station);



            resp=find(trialRecords(trialInd).response);
            if ~ischar(trialRecords(trialInd).response) && length(resp)==1

                trialRecords(trialInd).correct = ismember(resp,trialRecords(trialInd).targetPorts);
            else
                trialRecords(trialInd).correct = 0;
            end


            %UPDATE REWARDS AND PENALTIES BASED ON REWARD MANAGER - pmm 070525
            %rewardManager happens to live in trialManager for now... getting it for use
            [rm rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] =calcReinforcement(getReinforcementManager(trialManager),trialRecords, subject);
            updateTM = updateTM || updateRM;

            if updateRM
                trialManager = setReinforcementManager(trialManager, rm);
            end

            %if slow rewards check, here or the calc reinforcement are likely implicated
            trialRecords(trialInd).reinforcementManager = structize(trialManager.reinforcementManager);
            trialRecords(trialInd).reinforcementManagerClass = class(trialManager.reinforcementManager);
            trialRecords(trialInd).proposedRewardSizeULorMS=rewardSizeULorMS;
            trialRecords(trialInd).proposedMsPenalty=msPenalty;
            trialRecords(trialInd).proposedMsRewardSound=msRewardSound;
            trialRecords(trialInd).proposedMsPenaltySound=msPenaltySound;
            trialRecords(trialInd).proposedMsPuff=msPuff;

            if ~stopEarly

                if trialRecords(trialInd).correct

                    rewardValves=zeros(1,getNumPorts(station));
                    rewardValves(resp)=1;
                    rewardValves=logical(rewardValves);
                    allClosed=logical(zeros(1,getNumPorts(station)));

                    switch getRewardMethod(station)

                        case 'localPump'

                            valveStart=GetSecs();
                            station=doReward(station,rewardSizeULorMS/1000,rewardValves);
                            trialRecords(trialInd).actualRewardDuration = GetSecs()-valveStart;

                        case 'localTimed'
                            trialManager.soundMgr=playSound(trialManager.soundMgr,'correctSound',msRewardSound/1000.0,station);

                            %OPEN VALVE
                            %setValves(station, rewardValves)
                            %expectedValveState=zeros(1,getNumPorts(station));
                            [currentValveStates trialRecords(trialInd).responseDetails.valveErrorDetails]=...
                                setAndCheckValves(station,rewardValves,currentValveStates,...
                                trialRecords(trialInd).responseDetails.valveErrorDetails,...
                                trialRecords(trialInd).responseDetails.startTime,'correct reward open');
                            valveStart=GetSecs();

                            WaitSecs(rewardSizeULorMS/1000); %%pause(rewardSizeULorMS/1000)

                            %CLOSE VALVE
                            %setValves(station,zeros(1,getNumPorts(station)));
                            %expectedValveState=rewardValves;
                            [currentValveStates trialRecords(trialInd).responseDetails.valveErrorDetails]=...
                                setAndCheckValves(station,zeros(1,getNumPorts(station)),currentValveStates,...
                                trialRecords(trialInd).responseDetails.valveErrorDetails,...
                                trialRecords(trialInd).responseDetails.startTime,'correct reward close');
                            trialRecords(trialInd).actualRewardDuration = GetSecs()-valveStart;

                            if verbose
                                trialRecords(trialInd).actualRewardDuration
                            end
                            pctRewardOff=abs(1.0-(trialRecords(trialInd).actualRewardDuration/(rewardSizeULorMS/1000.0)));
                            if pctRewardOff>.05
                                warning('reward duration was off by %g',pctRewardOff)
                            end

                        case 'serverPump'
                            valveStart=GetSecs();
                            timeout=-5.0;
                            trialManager.soundMgr = playLoop(trialManager.soundMgr,'correctSound',station,1);

                            sprintf('*****should be no output between here *****')

                            stopEarly=sendToServer(rn,getClientId(rn),constants.priorities.IMMEDIATE_PRIORITY,constants.stationToServerCommands.C_REWARD_CMD,{rewardSizeULorMS,logical(rewardValves)});
                            rewardDone=false;
                            if ~stopEarly
                                trialRecords(trialInd).primingValveErrorDetails=[];
                                trialRecords(trialInd).latencyToOpenPrimingValves=[];
                                trialRecords(trialInd).latencyToClosePrimingValveRecd=[];
                                trialRecords(trialInd).latencyToClosePrimingValves=[];
                                trialRecords(trialInd).actualPrimingDuration=[];
                            end
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
                                        trialRecords(trialInd).latencyToOpenValveRecd=GetSecs()-valveStart;

                                        [stopEarly trialRecords(trialInd).valveErrorDetails,...
                                            trialRecords(trialInd).latencyToOpenValves,...
                                            trialRecords(trialInd).latencyToCloseValveRecd,...
                                            trialRecords(trialInd).latencyToCloseValves,...
                                            trialRecords(trialInd).actualRewardDuration,...
                                            trialRecords(trialInd).latencyToRewardCompleted,...
                                            trialRecords(trialInd).latencyToRewardCompletelyDone]...
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

                                        [stopEarly trialRecords(trialInd).primingValveErrorDetails(end+1),...
                                            trialRecords(trialInd).latencyToOpenPrimingValves(end+1),...
                                            trialRecords(trialInd).latencyToClosePrimingValveRecd(end+1),...
                                            trialRecords(trialInd).latencyToClosePrimingValves(end+1),...
                                            trialRecords(trialInd).actualPrimingDuration(end+1),...
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

                            trialManager.soundMgr = playLoop(trialManager.soundMgr,'',station,0);
                        otherwise
                            error('unrecognized reward method')
                    end

                elseif ~ischar(trialRecords(trialInd).response)
                    trialManager.soundMgr=playSound(trialManager.soundMgr,'wrongSound',msPenaltySound/1000,station);
                    numErrorFrames=ceil((msPenalty/1000)/getIFI(station));
                    [errStim errorScale] = errorStim(stimManager,numErrorFrames);
                    errAudioStim = [];

                    [stopEarly,...
                        errorRecords(trialInd).response,...
                        errorRecords(trialInd).responseDetails,...
                        errorRecords(trialInd).containedManualPokes,...
                        errorRecords(trialInd).leftWithManualPokingOn,...
                        errorRecords(trialInd).containedAPause,...
                        errorRecords(trialInd).containedForcedRewards, ...
                        errorRecords(trialInd).didHumanResponse, ...
                        errorRecords(trialInd).didStochasticResponse, ...
                        xxEyeData,...
                        xxGaze,...
                        station] ...
                        =stimOGL( ...
                        trialManager, ...
                        errStim, ...
                        errAudioStim, ...
                        LUT, ...
                        'cache', ...
                        errorScale, ...
                        [], ...
                        [], ...
                        trialRecords(trialInd).interTrialLuminance, ...
                        station,0,0,.5,1,'incorrect',rn,getID(subject),trialRecords(trialInd).stimManagerClass,pStr,trialLabel,trialManager.eyeTracker,msPuff);

                    trialRecords(trialInd).errorRecords=structize(errorRecords(trialInd));

                    if stopEarly
                        'got stopEarly 6'
                    end
                else
                    trialRecords(trialInd).response
                    stopEarly=1;

                    if stopEarly
                        'setting stopEarly '
                    end
                end
            end

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



            if verbose
                trialRecords(trialInd)
                trialRecords(trialInd).stimDetails
                trialRecords(trialInd).responseDetails
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
    class(r)
    stimManager
    isa(stimManager,'stimManager')
    isa(stimManager,'ifFeatureGoRightWithTwoFlank')
    rn
    getRewardMethod(station)
    '****'

    error('need station, stimManager, subject, ratrix, and rnet objects')
end
