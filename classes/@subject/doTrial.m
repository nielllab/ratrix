function [subject r keepWorking secsRemainingTilStateFlip trialRecords station]=doTrial(subject,r,station,rn,trialRecords,sessionNumber)

if isa(r,'ratrix') && isa(station,'station') && (isempty(rn) || isa(rn,'rnet'))
    [p t]=getProtocolAndStep(subject);
    if t>0
        ts=getTrainingStep(p,t);

        [graduate keepWorking secsRemainingTilStateFlip subject r trialRecords station]=doTrial(ts,station,subject,r,rn,trialRecords,sessionNumber);
        'subject'
%         newTrialRecords
        
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
