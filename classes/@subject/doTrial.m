function [subject r keepWorking secsRemainingTilStateFlip station]=doTrial(subject,r,station,window,ifi,rn)

if isa(r,'ratrix') && isa(station,'station') && (isempty(rn) || isa(rn,'rnet'))
    [p t]=getProtocolAndStep(subject);
    if t>0
        ts=getTrainingStep(p,t);

        [graduate keepWorking secsRemainingTilStateFlip subject r station]=doTrial(ts,station,subject,r,window,ifi,rn);
        'subject'
%         newTrialRecords
        
        if graduate
            if getNumTrainingSteps(p)>=t+1
                [subject r]=setStepNum(subject,t+1,r,'graduated!','ratrix');
            else
                [subject r]=setStepNum(subject,0,r,'graduated!','ratrix');
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