function r=doTrials(s,r,n,rn,trustOsRecordFiles)
%this will doTrials on station=(s) of ratrix=(r).  
%n=number of trials, where 0 means repeat indefinitely
%rn is a ratrix network object, which only the server uses, otherwise leave empty
%trustOsRecordFiles is risky because we know that they can be wrong when
%the server is taxed. The ratrix downstairs does not trust them. But you
%are free of oracle dependency. It is not recommended to trustOsRecordFiles
%unless your permanentStore is local, then it might be okay.
%recordNeuralData is a flag to decide whether or not to start datanet for NIDAQ recording
if ~exist('trustOsRecordFiles','var')
    trustOsRecordFiles=false;
end 

if isa(r,'ratrix') && (isempty(rn) || isa(rn,'rnet'))
    if ~isempty(getStationByID(r,s.id))

        subject=getCurrentSubject(s,r);
        keepWorking=1;
        trialNum=0;

        if n>=0
          
            
            subject = calibrateEyeTracker(subject);
            %some calibration requires GUi's &  must happen before PTB       

            if strcmp(s.rewardMethod,'localPump')
                if ~ s.localPumpInited
                    s.localPump=initLocalPump(s.localPump,s,dec2hex(s.decPPortAddr));
                    s.localPumpInited=true;
                else
                    error('localPump already inited')
                end
            end

            s=startPTB(s);
            
            % 10/17/08 - start datanet (for neural data recording)
            % ==========================================================================
            % this has to be done at the trialManager level, because the datanet is owned by the trialManager
            % so we need to tunnel down and pass back subject->protocol->trainingStep->trialManager
            params = Screen('Resolution', s.screenNum);
            parameters = [];
            parameters.refreshRate = params.hz;
            parameters.subjectID = getID(subject);
            subject = setUpOrStopDatanet(subject,'setup',parameters); % replace datanet_path with oracle lookup (hard coded for now in setup(datanet))
            
            % 10/29/08 - send a command to data listener to store local variables (resolution, refreshRate)
            % ==========================================================================
            
            
            %make sure valves are in a known state: closed - pmm 080621
            setValves(s, 0*getValves(s))
            %if this is not the case some stations (quatech PCMCIA) complain on the first setAndCheckValves 
            
            % This is a hard coded trial records filter
            % Need to decide where to parameterize this
            filter = {'lastNTrials',int32(100)};
            
            % Load a subset of the previous trial records based on the given filter
            [trialRecords localRecordsIndex sessionNumber] = getTrialRecordsForSubjectID(r,getID(subject),filter, trustOsRecordFiles);
            
        
            while keepWorking
                trialNum=trialNum+1;
                [subject r keepWorking secsRemainingTilStateFlip trialRecords s]= ...
                    doTrial(subject,r,s,rn,trialRecords,sessionNumber);
                % Cut off a trial record as we increment trials, IFF we
                % still have remote records (because we need to keep all
                % local records to properly save the local .mat)
                if localRecordsIndex > 1
                    trialRecords = trialRecords(2:end);
                end
                % Now update the local index (eventually all of the records
                % will be local if run long enough)
                localRecordsIndex = max(1,localRecordsIndex-1);
                % Only save the local records to the local copy!
                updateTrialRecordsForSubjectID(r,getID(subject),trialRecords(localRecordsIndex:end));

                if n>0 && trialNum>=n
                    keepWorking=0;
                    
                end
            end


            %should use secsRemainingTilStateFlip to ignore this
            %subject for a while?  turn off station if only subject in
            %box?


            s=stopPTB(s);

            stopEyeTracking(subject); 
            
            % 10/17/08 - stop datanet
            % ==========================================================================
            subject = setUpOrStopDatanet(subject,'stop',[]);
            % ==========================================================================

            if strcmp(s.rewardMethod,'localPump')
                if s.localPumpInited
                    s.localPump=closeLocalPump(s.localPump);
                    s.localPumpInited=false;
                else
                    error('localPump not inited')
                end
            end


            close all
        else
            error('n must be >= 0')
        end

    else
        error('that ratrix doesn''t contain this station')
    end
else
    error('need a ratrix and an rnet')
end
