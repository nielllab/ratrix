function [subject r keepWorking secsRemainingTilStateFlip trialRecords station] ...
    =doTrial(subject,r,station,rn,trialRecords,sessionNumber)

if isa(r,'ratrix') && isa(station,'station') && (isempty(rn) || isa(rn,'rnet'))
    [p t]=getProtocolAndStep(subject);
    if t>0
        ts=getTrainingStep(p,t);

        [graduate keepWorking secsRemainingTilStateFlip subject r trialRecords station newTsNum] ...
            =doTrial(ts,station,subject,r,rn,trialRecords,sessionNumber);
        'subject'
%         newTrialRecords

        % 1/22/09 - if newTsNum is not empty, this means we want to manually move the trainingstep (not graduate)
        if ~isempty(newTsNum)
            if getNumTrainingSteps(p)>=newTsNum
                % do we need to do this? datanet belongs to the trialManager, but we do not flag updateTM (because setup datanet is typically
                % done during station/doTrials (before we even care about updating tm)
                % so, we cant persist datanet across stim switching
                % stop datanet here if it exists - subject = setUpOrStopDatanet(subject,'stop',[]);
                % if that is causing it to hang...
                % also need to check to see if we want to start datanet/eyeTracker for newTsNum...wtf this sucks b/c all this is handled in doTrials
                % call setUpDatanet AFTER updating the subject's stepNum (this is used in trainingStep.setUpDatanet)
                % note that this will have bad interaction with the listener - stop(datanet) causes listener to shutdown
                % so user will have to manually restart listener after stim switching...
                subject = setUpOrStopDatanet(subject,'stop',[]); % stop if datanet exists for the current trainingStep
                [subject r]=setStepNum(subject,newTsNum,r,sprintf('manually setting to %s',newTsNum),'ratrix');
                subject = setUpOrStopDatanet(subject,'start',[]); % start datanet if exists for new trainingStep
            else
%                 [subject r]=setStepNum(subject,t,r,'invalid trainingStep specified - ignoring!','ratrix');
            end
            keepWorking=1;
        end
        
        if graduate
            if getNumTrainingSteps(p)>=t+1
                [subject r]=setStepNum(subject,t+1,r,'graduated!','ratrix');
            else
                [subject r]=setStepNum(subject,t,r,'can''t graduate because no more steps defined!','ratrix');
            end
        end
    elseif t==0
        keepWorking=0;
        secsRemainingTilStateFlip=-1;
        newStep=[];
        updateStep=0;
    else
        error('training step is negative')
    end
else
    error('need ratrix and station and rnet objects')
end
