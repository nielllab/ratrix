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
        
        % 3/12/09 - call updateRatrixRevisionIfNecessary here when the trainingStep's svnCheckMode is 'session'
        [p t]=getProtocolAndStep(subject);
        ts=getTrainingStep(p,t);
        if ~isempty(rn) && strcmp(getSVNCheckMode(ts),'session')
            if ~isempty(getSVNRevNum(ts))
                args={getSVNRevURL(ts) getSVNRevNum(ts)};
            else
                args={getSVNRevURL(ts)};
            end
            doQuit=updateRatrixRevisionIfNecessary(args);
            if doQuit
                keepWorking=false;
            end
        end
        
        if n>=0
            
            ListenChar(2);
            if usejava('desktop') && usejava('jvm') %jvm still true if started with -nojvm?
                FlushEvents('keyDown');
            end
            
            if ~isempty(s.eyeTracker)
                s.eyeTracker=calibrate(s.eyeTracker);
            end
            %some calibration requires GUi's &  must happen before PTB
            
            % 4/6/09 - most of the datanet setup is now done by bootstrap(datanet)
            if ~isempty(s.datanet) && isa(s.datanet,'datanet')
                % send ack of START_TRIALS_CMD
                constants=getConstants(s.datanet);
                pnet(getAckCon(s.datanet),'write',constants.stimToDataResponses.S_TRIALS_STARTED);
            end
            
            try
                if strcmp(s.rewardMethod,'localPump')
                    if ~ s.localPumpInited
                        s.localPump=initLocalPump(s.localPump,s,dec2hex(s.decPPortAddr));
                        s.localPumpInited=true;
                    else
                        error('localPump already inited')
                    end
                end
                
                s=startPTB(s);
                
                % ==========================================================================
                
                
                %make sure valves are in a known state: closed - pmm 080621
                setValves(s, 0*getValves(s))
                %if this is not the case some stations (quatech PCMCIA) complain on the first setAndCheckValves
                
                % This is a hard coded trial records filter
                % Need to decide where to parameterize this
                filter = {'lastNTrials',int32(500)};
                
                % Load a subset of the previous trial records based on the given filter
                [trialRecords localRecordsIndex sessionNumber] = getTrialRecordsForSubjectID(r,getID(subject),filter, trustOsRecordFiles);
                
                % Initialize/start eyeTracker after getting trialRecords so we know the trialNumber
                if ~isempty(s.eyeTracker)
                    if isa(s.eyeTracker,'eyeTracker')
                        if isTracking(s.eyeTracker)
                            checkRecording(s.eyeTracker);
                        else
                            %figure out where to save eyeTracker data
                            if ~isempty(s.datanet) % NOTE:  this path should reslove at IP level if shared on a external drive
                                eyeDataPath = fullfile(getStorePath(s.datanet), 'eyeRecords');
                            else
                                %right now its hard coded when no datanet
                                %maybe put it with trial records in the permanent store?
                                eyeDataPath = fullfile('\\132.239.158.179','datanet_storage', getID(subject), 'eyeRecords');
                                eyeDataPath = fullfile('\\132.239.158.179','datanetOutput', getID(subject), 'eyeRecords'); % this is a shared folder on the G: external
                            end
                            
                            if isempty(trialRecords)
                                tn=1;
                            else
                                tn=trialRecords(end).trialNumber+1;
                            end
                            s.eyeTracker=initialize(s.eyeTracker,eyeDataPath);%,%station.window);
                            s.eyeTracker=start(s.eyeTracker,tn);
                        end
                    else
                        error('not an eyeTracker')
                    end
                end
                
                doProfile = false;
                if doProfile
                    profile on
                end
                
                while keepWorking
                    trialNum=trialNum+1;
                    [subject r keepWorking secsRemainingTilStateFlip trialRecords s]= ...
                        doTrial(subject,r,s,rn,trialRecords,sessionNumber);
                    % Cut off a trial record as we increment trials, IFF we
                    % still have remote records (because we need to keep all
                    % local records to properly save the local .mat)
                    length(trialRecords)
                    if localRecordsIndex > 1 %shouldn't we also check that they're longer than line 76?
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
                
                if doProfile
                    sca
                    profile viewer
                    keyboard
                end
                
                %should use secsRemainingTilStateFlip to ignore this
                %subject for a while?  turn off station if only subject in
                %box?
                
                
                s=stopPTB(s);
            catch ex
                disp(['CAUGHT ER (at doTrials): ' getReport(ex)]);
                %                 if ~isempty(s.datanet) && isa(s.datanet,'datanet')
                %                     pnet('closeall');
                %                     s.datanet=cleanup(s.datanet);
                %                 end
                rethrow(ex);
            end
            
            if ~isempty(s.eyeTracker)
                s.eyeTracker=stop(s.eyeTracker);
            end
            
            if strcmp(s.rewardMethod,'localPump')
                if s.localPumpInited
                    s.localPump=closeLocalPump(s.localPump);
                    s.localPumpInited=false;
                else
                    error('localPump not inited')
                end
            end
            
            
            close all
            if usejava('desktop')
                FlushEvents('mouseUp','mouseDown','keyDown','autoKey','update');
            end
            ListenChar(0);
        else
            error('n must be >= 0')
        end
        
    else
        error('that ratrix doesn''t contain this station')
    end
else
    error('need a ratrix and an rnet')
end
