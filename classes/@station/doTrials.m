function r=doTrials(s,r,n,rn)

if isa(r,'ratrix') && (isempty(rn) || isa(rn,'rnet'))
    if ~isempty(getStationByID(r,s.id))

        subject=getCurrentSubject(s,r);
        keepWorking=1;
        trialNum=0;

        if n>=0


            if strcmp(s.rewardMethod,'localPump')
                if ~ s.localPumpInited
                    s.localPump=initLocalPump(s.localPump,s,s.parallelPortAddress);
                    s.localPumpInited=true;
                else
                    error('localPump already inited')
                end
            end

            [window ifi]=startPTB(s);


            %             trialRecords = getTrialRecordsForSubjectID(r,getID(subject));
            %             trialRecords
            %             class(trialRecords)
            %warning:  this trialRecords array is going to get modified and may be very
            %large -- will lead to large latencies from passing it all over the place.  how solve this?


            while keepWorking
                trialNum=trialNum+1;
                [subject r keepWorking secsRemainingTilStateFlip s]=doTrial(subject,r,s,window,ifi,rn);
                %                 trialRecords
                if n>0 && trialNum>=n
                    keepWorking=0;
                end
            end


            %should use secsRemainingTilStateFlip to ignore this
            %subject for a while?  turn off station if only subject in
            %box?



            stopPTB(s);



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