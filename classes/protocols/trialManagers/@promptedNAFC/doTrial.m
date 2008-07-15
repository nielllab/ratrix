function [trialManager updateTM newSM updateSM stopEarly trialRecords]=doTrial(trialManager,station,stimManager,subject,r,window,ifi,rn,trialRecords,sessionNumber)
%for all modifications from trialManagers doTrial (mergeCode svn version 1116; Jun.06,2008) search 'promptNewLine'
%problems:
%playSound does not return sound manager to trial manager, so may never cache.
%calls a duplicate copy of StimOGL (identical as of date...b/c stimOGL is a private method which can't be found by the subclass)

verbose=1;
updateTM=false;
stopEarly=0;



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
            trialRecords(trialInd).box = struct(getBoxFromID(r,getBoxIDForSubjectID(r,getID(subject))));
            trialRecords(trialInd).station = struct(station);
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
            trialRecords(trialInd).delayRecords=[];  %promptNewLine
            trialRecords(trialInd).promptRecords=[];  %promptNewLine

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
            trialRecords(trialInd).schedulerClass = class(trialRecords(trialInd).scheduler);
            trialRecords(trialInd).criterionClass = class(trialRecords(trialInd).criterion);

            [newSM, ...
                updateSM, ...
                stim, ...                %trialRecords(trialInd).stim, ...
                LUT, ...
                trialRecords(trialInd).scaleFactor, ...
                trialRecords(trialInd).type, ...
                trialRecords(trialInd).targetPorts, ...
                trialRecords(trialInd).distractorPorts, ...
                stimulusDetails, ...
                trialRecords(trialInd).interTrialLuminance, ...
                isCorrection]= ...
                calcStim(stimManager, ...
                class(trialManager), ...
                1/ifi, ...
                getResponsePorts(trialManager,getNumPorts(station)), ...
                getNumPorts(station), ...
                getWidth(station), ...
                getHeight(station), ...
                trialRecords(1:end-1));

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

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%promted inserts these lines%%%%%%%%%%%%%%%promptNewLine
            %Everything is writen at the level of the trial manager
            %                 if isa(trialManager,'trialManager')
            %                     isSubclass=~strcmp(class(trialManager),'trialManager')
            %                     tmSub{1}=trialManager;
            %                     while isSubclass
            %                         trialManager=getSuper(trialManager) %hack, will cause problems if updateTM
            %                         tmSub{end+1}=trialManager;
            %                         isSubclass=~strcmp(class(trialManager),'trialManager')
            %                     end
            %                 end
            %%%%%%%%%%%%%%%%%%%%%%%%%%


            % Wait to cache sounds until here because you might get new ones
            %             [trialManager.soundMgr updateSndM]=cacheSounds(trialManager.soundMgr);  %update of soundManager was overwritting update of stimulus manager. now fixed pmm 2008/05/02
            %             updateTM = updateTM || updateSndM;  %
            %
            %
            %             if updateTM
            %                 error('incompatible with subclass hack') %promptNewLine
            %             end

            %so that we can display the sessionUpTime - pmm 20080207
            % trialsThisSession=trialRecords(trialRecords.sessionID==trialRecords.sessionID(end));
            trialsThisSession=trialRecords;
            if size(trialsThisSession,2)>1
                sessionStartTime=datenum(trialsThisSession(1).date);
            else
                sessionStartTime=now;
            end


            %trialRecords(trialInd).stimManager = structize(newSM); %edf: removed 11.04.06 -- the timedFrame stim manager is too large (it has a cache).  could call a decache() method...
            if isa(stimulusDetails,'structable')
                trialRecords(trialInd).stimDetails = structize(stimulusDetails);
            elseif isobject(stimulusDetails)
                trialRecords(trialInd).stimDetails = struct(stimulusDetails);
            elseif isstruct(stimulusDetails)
                trialRecords(trialInd).stimDetails = stimulusDetails;
            else
                error('stim manager returned a stimulusDetails that was neither a structure nor an object')
            end

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



            if window>=0 && ifi>0











                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%promted inserts these lines%%%%%%%%%%%%%%%promptNewLine
                if 0  %inserts a prompt phase, not used
                    %stim
                    msDelay=max(trialManager.delayMeanMs+randn*trialManager.delayStdMs,1);
                    numDelayFrames=ceil((msDelay/1000)/ifi);
                    %[dlyStim delayScale] = delayStim(stimManager,numDelayFrames);
                    dlyStim=reshape(trialManager.delayStim*ones(1,numDelayFrames),1,1,numDelayFrames);
                    delayScale=[0 1];

                    %sound
                    msDelaySound=300;
                    % trialManager.soundMgr=playSound(trialManager.soundMgr,'keepGoingSound',msDelaySound/1000,station);
                    junk=playSound(getSoundManager(trialManager),'keepGoingSound',msDelaySound/1000,station);
                    dlyAudioStim = [];

                    [stopEarly,...
                        delayRecords(trialInd).response,...
                        delayRecords(trialInd).responseDetails,...
                        delayRecords(trialInd).containedManualPokes,...
                        delayRecords(trialInd).leftWithManualPokingOn,...
                        delayRecords(trialInd).containedAPause,...
                        delayRecords(trialInd).containedForcedRewards, ...
                        delayRecords(trialInd).didHumanResponse, ...
                        delayRecords(trialInd).didStochasticResponse] ...
                        =stimOGL( ...
                        trialManager, ...
                        dlyStim, ...
                        dlyAudioStim, ...
                        LUT, ...
                        'cache', ...
                        delayScale, ...
                        window, ...
                        ifi, ...
                        [], ...
                        [], ...
                        trialManager.promptStim, ... %only works as a luminance
                        station,0,0,.5,1,0,rn,getID(subject),trialRecords(trialInd).stimManagerClass);
                    trialRecords(trialInd).delayRecords=delayRecords(trialInd);



                    %stim
                    msPrompt=200;
                    numPromptFrames=ceil((msPrompt/1000)/ifi);
                    %[dlyStim promptScale] = promptStim(stimManager,numPromptFrames);
                    dlyStim=reshape(trialManager.promptStim*ones(1,numPromptFrames),1,1,numPromptFrames);
                    promptScale=[0 1];

                    %sound
                    msPromptSound=100;
                    junk=playSound(getSoundManager(trialManager),'keepGoingSound',msPromptSound/1000,station);

                    [stopEarly,...
                        promptRecords(trialInd).response,...
                        promptRecords(trialInd).responseDetails,...
                        promptRecords(trialInd).containedManualPokes,...
                        promptRecords(trialInd).leftWithManualPokingOn,...
                        promptRecords(trialInd).containedAPause,...
                        promptRecords(trialInd).containedForcedRewards, ...
                        promptRecords(trialInd).didHumanResponse, ...
                        promptRecords(trialInd).didStochasticResponse] ...
                        =stimOGL( ...
                        trialManager, ...
                        dlyStim, ...
                        dlyAudioStim, ...
                        LUT, ...
                        'cache', ...
                        promptScale, ...
                        window, ...
                        ifi, ...
                        [], ...
                        [], ...
                        trialManager.promptStim, ... %only works as a luminance
                        station,0,0,.5,1,0,rn,getID(subject),trialRecords(trialInd).stimManagerClass);
                    trialRecords(trialInd).promptRecords=promptRecords(trialInd);
                end
                %                 %%%%%%%%%%%%%%%%%%%%%%%%% end promptNewLines


                [stopEarly trialRecords(trialInd).response,...
                    trialRecords(trialInd).responseDetails,...
                    trialRecords(trialInd).containedManualPokes,...
                    trialRecords(trialInd).leftWithManualPokingOn,...
                    trialRecords(trialInd).containedAPause,...
                    trialRecords(trialInd).containedForcedRewards, ... %pmm added 4/3/08
                    trialRecords(trialInd).didHumanResponse, ... %pmm added 4/18/08
                    trialRecords(trialInd).didStochasticResponse]= ...
                    stimOGL( ...
                    trialManager, ...
                    stim, ...
                    audioStimulus, ...
                    LUT, ...
                    trialRecords(trialInd).type, ...    % 'loop', ... %trialRecords(trialInd).type, ...
                    trialRecords(trialInd).scaleFactor, ...
                    window, ...
                    ifi, ...
                    union(trialRecords(trialInd).targetPorts, trialRecords(trialInd).distractorPorts), ...
                    getRequestPorts(trialManager, getNumPorts(station)), ...
                    trialRecords(trialInd).interTrialLuminance, ...
                    station, ...
                    manualOn, ...
                    1, ...
                    .1, ... % 10% should be ~1 ms of acceptable frametime error
                    0,isCorrection,rn,getID(subject),trialRecords(trialInd).stimManagerClass);

                if stopEarly
                    'got stopEarly 1'
                end

                currentValveStates=verifyValvesClosed(station);

            else
                error('bad window or ifi')
            end

            resp=find(trialRecords(trialInd).response);
            if ~ischar(trialRecords(trialInd).response) && length(resp)==1

                trialRecords(trialInd).correct = ismember(resp,trialRecords(trialInd).targetPorts);
            else
                trialRecords(trialInd).correct = 0;
            end


            %UPDATE REWARDS AND PENALTIES BASED ON REWARD MANAGER - pmm 070525
            %rewardManager happens to live in trialManager for now... getting it for use
            [rm rewardSizeULorMS msPenalty msRewardSound msPenaltySound updateRM] =calcReinforcement(getReinforcementManager(trialManager),trialRecords, subject);
            updateTM = updateTM || updateRM;

            if updateRM
                trialManager = setReinforcementManager(trialManager, rm);
            end

            %if slow rewards check, here or the calc reinforcement are likely implicated
            trialRecords(trialInd).reinforcementManager = getReinforcementManager(trialManager);  %promptChanged
            trialRecords(trialInd).reinforcementManagerClass = class(getReinforcementManager(trialManager)); %promptChanged
            trialRecords(trialInd).proposedRewardSizeULorMS=rewardSizeULorMS;
            trialRecords(trialInd).proposedMsPenalty=msPenalty;
            trialRecords(trialInd).proposedMsRewardSound=msRewardSound;
            trialRecords(trialInd).proposedMsPenaltySound=msPenaltySound;

            if ~stopEarly

                if trialRecords(trialInd).correct

                    rewardValves=zeros(1,getNumPorts(station));
                    rewardValves(resp)=1;
                    rewardValves=logical(rewardValves);
                    allClosed=logical(zeros(1,getNumPorts(station)));

                    switch getRewardMethod(station)

                        case 'localTimed'
                            junk=playSound(getSoundManager(trialManager),'correctSound',msRewardSound/1000.0,station); %promptChanged

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
                            trialManager.soundMgr = playLoop(trialManager.soundMgr,'correctSound',station,1); %might need getSoundManager(trialManager)

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

                            trialManager.soundMgr = playLoop(trialManager.soundMgr,'',station,0);  %might need getSoundManager(trialManager)
                        otherwise
                            error('unrecognized reward method')
                    end

                elseif ~ischar(trialRecords(trialInd).response)
                    junk=playSound(getSoundManager(trialManager),'wrongSound',msPenaltySound/1000,station); % changed to getSoundManager(trialManager)
                    numErrorFrames=ceil((msPenalty/1000)/ifi);
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
                        errorRecords(trialInd).didStochasticResponse] ...
                        =stimOGL( ...
                        trialManager, ...
                        errStim, ...
                        errAudioStim, ...
                        LUT, ...
                        'cache', ...
                        errorScale, ...
                        window, ...
                        ifi, ...
                        [], ...
                        [], ...
                        trialRecords(trialInd).interTrialLuminance, ...
                        station,0,0,.5,1,0,rn,getID(subject),trialRecords(trialInd).stimManagerClass);

                    trialRecords(trialInd).errorRecords=errorRecords(trialInd);

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
    isa(station,'station')
    isa(stimManager,'stimManager')
    isa(subject,'subject')
    isa(r,'ratrix')
    stimManager
    isa(stimManager,'stimManager')
    isa(stimManager,'ifFeatureGoRightWithTwoFlank')

    error('need station, stimManager, subject, ratrix, and rnet objects')
end
