function [graduate keepWorking secsRemainingTilStateFlip subject r station]=doTrial(ts,station,subject,r,window,ifi,rn)
    

try

    graduate=0;
    if isa(station,'station') && isa(r,'ratrix') && isa(subject,'subject') && (isempty(rn) || isa(rn,'rnet'))
        
         if ~isa(ts.stimManager,'stimManager')
                sca
                ts.stimManager
                'hey'
                ts
                class(ts.stimManager)
                class(ts.trialManager)
                class(ts.criterion)
                class(ts.scheduler)
                class(ts)
                'boo'
                class(ts.stimManager)
                error('Its gotta be a stim manager')
         end
            
        [keepWorking secsRemainingTilStateFlip  updateScheduler newScheduler] = checkSchedule(ts.scheduler,subject,ts);
        
        %UPDATE SESSION RECORDS
        if keepWorking
            if ts.previousSchedulerState==1
                %still in a session
                sessionNum=size(ts.sessionRecords,1);
            elseif ts.previousSchedulerState==0
                %just started a session
                sessionNum=size(ts.sessionRecords,1)+1;
                ts.sessionRecords(sessionNum,1)=now; %sessionStartTime
                ts.sessionRecords(sessionNum,2)=0;   %initialize SessionStopTime to 0
                ts.sessionRecords(sessionNum,3)=0;   %initialize TrialNum to 0
                %ts.trialNum=0;  % this is not being used actively
            else
                error('previousSchedulerState must be 0 or 1')
            end
        elseif ~keepWorking
            if ts.previousSchedulerState==1
                %session ended
                sessionNum=size(ts.sessionRecords,1);
                ts.sessionRecords(sessionNum,2)=now; %sessionStops
                ts.sessionRecords(sessionNum,3)=ts.trialNum;  % trialsCompleted this session
             elseif ts.previousSchedulerState==0
                %still in an off state  
                disp(sprintf('A trial attempt was rejected at %d!',now))
             else
                 error('previousSchedulerState must be 0 or 1')
             end
        end
        
        %SAVE PREVIOUS STATE
        ts.previousSchedulerState=keepWorking;
        
        if keepWorking
            
            %do another trial
            
            %ts.trialNum=ts.trialNum+1; % this is not being used actively, instead: ts.sessionRecords(sessionNum,3)
            ts.sessionRecords(sessionNum,3)=ts.sessionRecords(sessionNum,3)+1;
            ts.trialNum=ts.sessionRecords(sessionNum,3); % this is not being used actively
            
            [newTM updateTM newSM updateSM stopEarly station]=doTrial(ts.trialManager,station,ts.stimManager,subject,r,window,ifi,rn);
            
            %write the sessionNum into to the trialRecords
            
            keepWorking=~stopEarly;
                
            graduate = checkCriterion(ts.criterion,subject,ts);
            
            
            if updateTM || updateSM || updateScheduler
            	if updateTM
                	ts.trialManager=newTM;
                end
                if updateSM
                	ts.stimManager=newSM;
                end
                if updateScheduler
                	ts.scheduler=newScheduler;
                end	
                
                [subject r]=changeProtocolStep(subject,ts,r,'trialManager or stimManager or scheduler state change','ratrix');
            end
            
        else
            disp('*************************INTERTRIAL PERIOD STARTS!*****************************')
            %hack : in the future call "run" on trial manager with the variable far more ally known as "intertrial context" sent to the stimManager
            
            %things to do here: 
            %1) save the trialRecords, get the RS to send em to the DS
               %this prevents the memory problems with large trail records
            
               %note: the number of session is preserved in the session
               %record in the the training step, but this hack version
               %always overwrites the ratrix, so isn't making use of that
               %funcitonality, even though it should work
               
            interSessionScreenLuminance=0;
            texture=Screen('MakeTexture', window, interSessionScreenLuminance);
            destRect= Screen('Rect', window);
            xTextPos = 25;
            yTextPos =100;
            
            interTrialContinues=1; i=0;
            while interTrialContinues
              disp(sprintf('waited for %d frames',i))
              i=i+1;
              secondsSince=etime(datevec(now),datevec(ts.sessionRecords(end,2)));
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
                        
                        %record belongs in interSessionRecords eventually:
                        %trialRecords(end).response='manual kill'; %this should break loop in RatSubjectSession.m, but doesn't
                    end
                end
              end
            
              
            end
            
            disp('*************************INTERTRIAL PERIOD ENDS!*****************************')
        end
    else
        sca
        isa(station,'station')
        isa(r,'ratrix')
        isa(subject,'subject')
        
        error('need station and ratrix and subject and rnet objects')
    end
    
           'training step:'
%             trialRecords   
catch
    
    display(ts)
    
    ers=lasterror
    ers.message
    ers.stack.file
    ers.stack.name
    ers.stack.line
    
    
    
    Screen('CloseAll');
    rethrow(lasterror)
end