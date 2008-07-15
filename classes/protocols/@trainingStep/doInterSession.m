function stopEarly = doInterSession(ts, rn, window)
%hack : in the future call "run" on trial manager with the variable far more ally known as "intertrial context" sent to the stimManager

%things to do here:
%1) save the trialRecords, get the RS to send em to the DS
%this prevents the memory problems with large trail records

%note: the number of session is preserved in the session
%record in the the training step, but this hack version
%always overwrites the ratrix, so isn't making use of that
%funcitonality, even though it should work

%always make a new session after an intersession
stopEarly = 1;  %stopEarly = 0;
interSessionScreenLuminance=0;
texture=Screen('MakeTexture', window, interSessionScreenLuminance);
destRect= Screen('Rect', window);
xTextPos = 25;
yTextPos =100;
 if ~isempty(rn)
        constants = getConstants(rn);
 end
    

interSessionStart = now; %ts.sessionRecords(end,2);
interTrialContinues=1; i=0;
while interTrialContinues
    disp(sprintf('waited for %d frames',i))
    i=i+1;
    secondsSince=etime(datevec(now),datevec(interSessionStart));
    secondsUntil=getCurrentHoursBetweenSession(ts.scheduler)*3600-secondsSince;  %okay this depends on my scheduler
    %consider secsRemainingTilStateFlip

    if rand<0.001
        disp(sprintf('timeSince %d, timeUntil: %d',secondsSince,secondsUntil))
    end

    Screen('DrawTexture', window, texture,[],destRect,[],0);
    [garbage,yNewTextPos] = Screen('DrawText',window,[ ' frame ind:' num2str(i) ' hoursSince: ' num2str(secondsSince/3600,'%8.3f') ' hoursUntil: ' num2str(secondsUntil/3600,'%8.3f') ' percentThere: ' num2str((100*secondsSince/(secondsSince+secondsUntil)),'%8.1f') ],xTextPos,yTextPos,100*ones(1,3));
    [vbl sos ft]=Screen('Flip',window);

    if secondsUntil< 0
        interTrialContinues=0;
    end

    %check for key presses
    [keyIsDown,secs,keyCode]=KbCheck;
    keys=find(keyCode);
    kDown=0;
    if keyIsDown
        for keyNum=1:length(keys)
            kDown= kDown || strcmp(KbName(keys(keyNum)),'k');  % IF HOLD "K"
        end
    end

    if kDown
        'kdown!'
        for keyNum=1:length(keys)
            keyName=KbName(keys(keyNum));
            if strcmp(keyName,'q')  % AND PRESS "Q"
                interTrialContinues=0;
                disp('manual kill of interSession')
                stopEarly = 1;
                %record belongs in interSessionRecords eventually:
%                 trialRecords(end).response='manual kill'; %this should break loop in RatSubjectSession.m
%                 updateTrialRecordsForSubjectID(r,getID(subject),trialRecords);
            end
        end
    end

    if ~isempty(rn)

        if ~isConnected(rn)
            interTrialContinues=0;
        end


        while commandsAvailable(rn,constants.priorities.IMMEDIATE_PRIORITY) && interTrialContinues
            logwrite('handling IMMEDIATE priority command in interTrial');
            if ~isConnected(rn)
                interTrialContinues=0;
            end
            
            com=getNextCommand(rn,constants.priorities.IMMEDIATE_PRIORITY);
            if ~isempty(com)
                [good cmd args]=validateCommand(rn,com);
                logwrite(sprintf('interSession command is %d',cmd));
                
                if good
                    done=clientHandleVerifiedCommand(rn,com,cmd,args,constants.statuses.MID_TRIAL)
                    if done
                        interTrialContinues = 0;
%                         response='server kill';
                    end
            % no rewards handled during interSession
            
            % stimOGL handled two commands
            %   constants.serverToStationCommands.S_SET_VALVES_CMD,
            %   constants.serverToStationCommands.S_REWARD_COMPLETE_CMD
            % all other commands were handled as follows: 
            
            
            % old stimOGL code below ... pmm 04/03/08
%                     switch cmd
%                         case constants.serverToStationCommands.S_SET_VALVES_CMD
%                             isPrime=args{2};
%                             if isPrime
%                                 if reqeustRewardStarted && ~requestRewardDone
%                                     quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'stimOGL received priming S_SET_VALVES_CMD while a non-priming request reward was unfinished');
%                                 else
%                                     timeout=-1;
%                                     [quit valveErrorDetails(end+1)]=clientAcceptReward(rn,...
%                                         com,...
%                                         station,...
%                                         timeout,...
%                                         valveStart,...
%                                         requestedValveState,...
%                                         [],...
%                                         isPrime);
%                                     if quit
%                                         done=true;
%                                     end
%                                 end
%                             else
%                                 if all(size(ports)==size(args{1}))
% 
%                                     serverValveStates=args{1};
%                                     serverValveChange=true;
% 
%                                     if reqeustRewardStarted && requestRewardStartLogged && ~requestRewardDone
%                                         if requestRewardOpenCmdDone
%                                             if all(~serverValveStates)
%                                                 requestRewardDone=true;
%                                             else
%                                                 quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received S_SET_VALVES_CMD for closing request reward but not all valves were indicated to be closed');
%                                             end
%                                         else
%                                             if all(serverValveStates==requestRewardPorts)
%                                                 requestRewardOpenCmdDone=true;
%                                             else
%                                                 quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received S_SET_VALVES_CMD for opening request reward but wrong valves were indicated to be opened');
%                                             end
%                                         end
%                                     else
%                                         quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'stimOGL received unexpected non-priming S_SET_VALVES_CMD');
%                                     end
%                                 else
%                                     quit=sendError(rn,com,constants.errors.CORRUPT_STATE_SENT,'stimOGL received inappropriately sized S_SET_VALVES_CMD arg');
%                                 end
%                             end


%                         case constants.serverToStationCommands.S_REWARD_COMPLETE_CMD
%                             if requestRewardDone
%                                 quit=sendAcknowledge(rn,com);
%                             else
%                                 if requestRewardStarted
%                                     quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_REWARD_COMPLETE_CMD apparently not preceeded by open and close S_SET_VALVES_CMD''s');
%                                 else
%                                     quit=sendError(rn,com,constants.errors.BAD_STATE_FOR_COMMAND,'client received S_REWARD_COMPLETE_CMD not preceeded by C_REWARD_CMD (MID_TRIAL)');
%                                 end
%                             end
%                         otherwise
%                             done=clientHandleVerifiedCommand(rn,com,cmd,args,constants.statuses.MID_TRIAL);
%                             if done
%                                 quit=true;
%                                 response='server kill';
%                             end
%                     end
                end
            end
        end
%         newValveState=doValves|serverValveStates;

    end
end