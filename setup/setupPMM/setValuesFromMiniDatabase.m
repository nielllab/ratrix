function r=setValuesFromMiniDatabase(s,r, miniDatabasePath)

[r s p stepNum ts stim tm rm subID]=getCurrent(s);

currentShapedValue = getCurrentShapedValue(stim);
currentMsPenalty = getMsPenalty(rm);
currentScalar = getScalar(rm);
currentPctCTs=getPercentCorrectionTrials(stim); %only check current, trust this to be the same on all steps

if isnan(currentPctCTs)
    currentPctCTs=0.5;  %default is always .5 when starting from oriented gabors free drinks
end

% there are two plausible reasons for the currentShapedValue to be empty:
% 1. the stimulus is not shaping anything
% 2. the stimulus is shaping something but currentShapedValue is [], this should
% never happen! We passed back a string of the word 'empty'
% 3. somehow, an empty value got loaded in from the miniDatabase, possibly
% because the field was never defined, this should never happen and if it
% did, see 2. above

updateSM=0;
updatePctCTsAllSM=0;

if ~isempty(currentShapedValue) % some steps have no shaping, so don't get database fact, and replace value
    valueInDatabase = getMiniDatabaseFact(s,'currentShapedValue'); %this is if you have to reinit...
    if ~isempty(valueInDatabase)
        stim = setCurrentShapedValue(stim, valueInDatabase);
        updateSM=1;
        ts = setStimManager(ts, stim);
        newShapedValue = valueInDatabase;
    else
        doMiniDatabaseError(s, stepNum, valueInDatabase, currentShapedValue, 'currentShapedValue')
    end
end

if updateSM
    [s r]=changeProtocolStep(s,ts,r,sprintf('updating shaping value: %d',newShapedValue),'pmm'); % only change the current step for stims - currentShapedValue!

    % confirm it worked
    s2=getSubjectFromID(r,getID(s));
    [p stepNum]=getProtocolAndStep(s2);
    ts = getTrainingStep(p,stepNum);
    stim = getStimManager(ts);
    currentShapedValue = getCurrentShapedValue(stim);
    if currentShapedValue ~= newShapedValue
        error('what up wi'' dat?')
    end
    
    [r s p stepNum ts stim tm rm subID]=getCurrent(s);
end


valueInDatabase = getMiniDatabaseFact(s,'msPenalty');
if currentMsPenalty~=valueInDatabase
    if ~isempty(valueInDatabase)
        r=setReinforcementParam('penaltyMS',{subID},valueInDatabase,'all','from miniDB','pmm');
        if getMsPenalty(getCurrentRM(s))==getMsPenalty(rm)
            error('failed to update')
        end
        [r s p stepNum ts stim tm rm subID]=getCurrent(s);
    else
        doMiniDatabaseError(s, stepNum, valueInDatabase, currentMsPenalty, 'msPenalty');
    end
else
    disp('no change b/c they matched or database value is empty')
end


valueInDatabase = getMiniDatabaseFact(s,'rewardScalar');
if currentScalar~=valueInDatabase
    if ~isempty(valueInDatabase)
        r=setReinforcementParam('scalar',{subID},valueInDatabase,'all','from miniDB','pmm')
        if getScalar(getCurrentRM(s))==getScalar(rm)
            error('failed to update')
        end
        [r s p stepNum ts stim tm rm subID]=getCurrent(s);
    else
        doMiniDatabaseError(s, stepNum, valueInDatabase, currentScalar, 'rewardScalar');
    end
else
    disp('no change b/c they matched or database value is empty')

end

valueInDatabase = getMiniDatabaseFact(s,'pctCTs')
if currentPctCTs~=valueInDatabase
    if ~isempty(valueInDatabase)
        updatePctCTsAllSM=1;
        newPctCTs = valueInDatabase;
    else
        doMiniDatabaseError(s, stepNum, valueInDatabase, currentPctCTs, 'pctCTs');
    end
else
    disp('no change b/c they matched or database value is empty')
    newPctCTs = currentPctCTs;
end



if updatePctCTsAllSM
    [s r]=changeAllPercentCorrectionTrials(s,newPctCTs,r,sprintf('percentCorrectionTrials set: %d',newPctCTs),'pmm') 
    
    %check it
    r=getRatrix;
    s=getSubjectFromID(r,getID(s));
    
    [p stepNum]=getProtocolAndStep(s);
    ts = getTrainingStep(p,stepNum);
    stim = getStimManager(ts);
    currentPctCTs=getPercentCorrectionTrials(stim);
    if currentPctCTs~=newPctCTs
        currentPctCTs=currentPctCTs
        desiredPctCTs=newPctCTs
        error('percent correction trials did not update!')
    end
    %[r s p stepNum ts stim tm rm subID]=getCurrent(s); % only needed if more operations below   
end

function  doMiniDatabaseError(s, stepNum, valueInDatabase, currentValue, factType)
getID(s)
stepNum = stepNum
valueInDatabase = valueInDatabase
currentValue = currentValue
error(sprintf('must have %s defined in database', factType))

function currentRm=getCurrentRM(s)
    r=getRatrix;
    s=getSubjectFromID(r,getID(s));
    [p,step]=getProtocolAndStep(s);
    ts=getTrainingStep(p,step);
    tm=getTrialManager(ts);
    currentRm =getReinforcementManager(tm);
    

function   [r s p stepNum ts stim tm rm subID]=getCurrent(s)
r=getRatrix;
s=getSubjectFromID(r,getID(s));
[p stepNum]=getProtocolAndStep(s);
ts = getTrainingStep(p,stepNum);
stim = getStimManager(ts);
tm=getTrialManager(ts);
rm = getReinforcementManager(tm);
subID=getID(s);
