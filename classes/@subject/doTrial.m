function [subject r keepWorking secsRemainingTilStateFlip trialRecords station] ...
    =doTrial(subject,r,station,rn,trialRecords,sessionNumber)

if isa(r,'ratrix') && isa(station,'station') && (isempty(rn) || isa(rn,'rnet'))
    [p t]=getProtocolAndStep(subject);
    if t>0
        ts=getTrainingStep(p,t);

        [graduate keepWorking secsRemainingTilStateFlip subject r trialRecords station manualTs] ...
            =doTrial(ts,station,subject,r,rn,trialRecords,sessionNumber);
        %'subject'
%         newTrialRecords

        % 1/22/09 - if newTsNum is not empty, this means we want to manually move the trainingstep (not graduate)
        if manualTs
            newTsNum=[];
            [proto currentTsNum]=getProtocolAndStep(subject);
            validTs=[1:getNumTrainingSteps(p)];
            validInputs{1}=validTs;
            type='manual ts';
            typeParams.currentTsNum=currentTsNum;
            typeParams.trainingStepNames={};
            for i=validTs
                typeParams.trainingStepNames{end+1}=generateStepName(getTrainingStep(proto,i),'','');
            end
            newTsNum = userPrompt(getPTBWindow(station),validInputs,type,typeParams);
            trialRecords(end).result=[trialRecords(end).result ' ' num2str(newTsNum)];
            if newTsNum~=currentTsNum
                [subject r]=setStepNum(subject,newTsNum,r,sprintf('manually setting to %d',newTsNum),'ratrix');
            end
            keepWorking=1;
        end
        
        if graduate && ~manualTs % 6/11/09 - dont graduate if manual k+t switching to new training step
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
