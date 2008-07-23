function [graduate keepWorking secsRemainingTilStateFlip subject r trialRecords station]=doTrial(ts,station,subject,r,rn,trialRecords,sessionNumber)
graduate=0;


if ~isempty(rn)
    if ~isempty(ts.svnRevNum)
        args={ts.svnRevURL ts.svnRevNum};
    else
        args={ts.svnRevURL};
    end
    doQuit=updateRatrixRevisionIfNecessary(args);
    if doQuit
        keepWorking=false;
        secsRemainingTilStateFlip=0;
        return
    end
end

try


    if isa(station,'station') && isa(r,'ratrix') && isa(subject,'subject') && (isempty(rn) || isa(rn,'rnet'))
        if isa(ts,'trainingStep')
            if isa(ts.stimManager,'stimManager')
                %everything is good!
            else
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
        else
            class(ts);
            error('it''s not a trainingStep')
        end


        'boohoo'
        class(ts.scheduler)
        [keepDoingTrials secsRemainingTilStateFlip  updateScheduler newScheduler] = checkSchedule(ts.scheduler,subject,ts,trialRecords,sessionNumber);

        %UPDATE SESSION RECORDS
        %         if keepWorking
        %             if ts.previousSchedulerState==1
        %                 %still in a session
        %                 sessionNum=size(ts.sessionRecords,1);
        %             elseif ts.previousSchedulerState==0
        %                 %just started a session
        %                 sessionNum=size(ts.sessionRecords,1)+1;
        %                 ts.sessionRecords(sessionNum,1)=now; %sessionStartTime
        %                 ts.sessionRecords(sessionNum,2)=0;   %initialize SessionStopTime to 0
        %                 ts.sessionRecords(sessionNum,3)=0;   %initialize TrialNum to 0
        %                 %ts.trialNum=0;  % this is not being used actively
        %             else
        %                 error('previousSchedulerState must be 0 or 1')
        %             end
        %         elseif ~keepWorking
        %             if ts.previousSchedulerState==1
        %                 %session ended
        %                 sessionNum=size(ts.sessionRecords,1);
        %                 ts.sessionRecords(sessionNum,2)=now; %sessionStops
        %                 ts.sessionRecords(sessionNum,3)=ts.trialNum;  % trialsCompleted this session
        %             elseif ts.previousSchedulerState==0
        %                 %still in an off state
        %                 disp(sprintf('A trial attempt was rejected at %d!',now))
        %             else
        %                 error('previousSchedulerState must be 0 or 1')
        %             end
        %         end

        %SAVE PREVIOUS STATE
        %         ts.previousSchedulerState=keepWorking;

        if keepDoingTrials

            [newTM updateTM newSM updateSM stopEarly trialRecords station]=doTrial(ts.trialManager,station,ts.stimManager,subject,r,rn,trialRecords,sessionNumber);
            keepWorking=~stopEarly;

            graduate = checkCriterion(ts.criterion,subject,ts, trialRecords);
            %END SESSION BY GRADUATION
            if graduate
                %do the graduation
                %This code already exists in the doTrial for the subject

                %stop the session
                keepWorking=0;
            end

            if updateTM
                ts.trialManager=newTM;
            end
            if updateSM
                ts.stimManager=newSM;
            end
            if updateScheduler
                ts.scheduler=newScheduler;
            end

            if updateTM || updateSM || updateScheduler
                % This will update the protocol locally, and also update
                % the subject's protocolversion.autoVersion, which will
                % propagate the changes back to the server upon session end
                [subject r]=changeProtocolStep(subject,ts,r,'trialManager or stimManager or scheduler state change','ratrix');
            end

        else
            disp('*************************INTERTRIAL PERIOD STARTS!*****************************')
            stopEarly = doInterSession(ts, rn, getPTBWindow(station)); % note: we have no records of this
            keepWorking=~stopEarly;
            disp('*************************INTERTRIAL PERIOD ENDS!*****************************')
        end
    else
        sca
        isa(station,'station')
        isa(r,'ratrix')
        isa(subject,'subject')


        error('need station and ratrix and subject and rnet objects')
    end

catch ex
    display(ts)

    ple
    Screen('CloseAll');
    rethrow(ex)
end