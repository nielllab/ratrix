function r=setValuesFromMiniDatabase(s,r, miniDatabasePath)

[p stepNum]=getProtocolAndStep(s);
ts = getTrainingStep(p,stepNum);
stim = getStimManager(ts);
tm=getTrialManager(ts);
rm = getReinforcementManager(tm);

currentShapedValue = getCurrentShapedValue(stim);
currentMsPenalty = getPenalty(rm);
currentScalar = getScalar(rm);
% there are two plausible reasons for the currentShapedValue to be empty:
% 1. the stimulus is not shaping anything
% 2. the stimulus is shaping something but currentShapedValue is [], this should
% never happen! We passed back a string of the word 'empty'
% 3. somehow, an empty value got loaded in from the miniDatabase, possibly
% because the field was never defined, this should never happen and if it
% did, see 2. above

updateRM=0;
updateSM=0;

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

valueInDatabase = getMiniDatabaseFact(s,'msPenalty');
if currentMsPenalty~=valueInDatabase
    if ~isempty(valueInDatabase)
        rm = setPenalty(rm, valueInDatabase);
        updateRM=1;
        newMsPenalty = valueInDatabase;
    else
        doMiniDatabaseError(s, stepNum, valueInDatabase, currentMsPenalty, 'msPenalty');
    end
else
    disp('no change b/c they matched')
    newMsPenalty = currentMsPenalty;
end

valueInDatabase = getMiniDatabaseFact(s,'rewardScalar');
if currentScalar~=valueInDatabase
    if ~isempty(valueInDatabase)
        rm = setScalar(rm, valueInDatabase);
        updateRM=1;
        newScalar = valueInDatabase;
    else
        doMiniDatabaseError(s, stepNum, valueInDatabase, currentScalar, 'rewardScalar');
    end
else
    disp('no change b/c they matched')
    newScalar = currentScalar;
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
end

if updateRM   
    [s r]=changeAllReinforcementManagers(s,rm,r,sprintf('reinforcement set; penalty: %d, scalar: %d',newMsPenalty,newScalar),'pmm');

    
    %serverDataPath = fullfile(dataPath, 'ServerData');
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
s=getSubjectFromID(r,getID(s));

    [p,step]=getProtocolAndStep(s);
    ts=getTrainingStep(p,step);
    tm=getTrialManager(ts);
    currentRm =getReinforcementManager(tm);
    if ~all(display(currentRm)==display(rm))
        display(currentRm)
        display(rm)
        error('change didn''t work!')
        %first make the error actually work!
        %eventually make change error sensitive to getImmuatble(rm)
    end
end

function  doMiniDatabaseError(s, stepNum, valueInDatabase, currentValue, factType)
getID(s)
stepNum = stepNum
valueInDatabase = valueInDatabase
currentShapedValue = currentShapedValue
error(sprintf('must have %s defined in database', factType))