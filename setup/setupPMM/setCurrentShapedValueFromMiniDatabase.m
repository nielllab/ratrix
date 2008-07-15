function r=setCurrentShapedValueFromMiniDatabase(s, r)

[p stepNum]=getProtocolAndStep(s);
ts = getTrainingStep(p,stepNum);
stim = getStimManager(ts);
currentValue = getCurrentShapedValue(stim);
% there are two plausible reasons for the currentValue to be empty:
% 1. the stimulus is not shaping anything 
% 2. the stimulus is shaping something but currentValue is [], this should
% never happen! We passed back a string of the word 'empty'
% 3. somehow, an empty value got loaded in from the miniDatabase, possibly
% because the field was never defined, this should never happen and if it
% did, see 2. above
if ~isempty(currentValue) % some steps have no shaping, so don't get database fact, and replace value
    valueInDatabase = getMiniDatabaseFact(s,'currentShapedValue'); %this is if you have to reinit...
    if ~isempty(valueInDatabase)
        stim = setCurrentShapedValue(stim, valueInDatabase);
        ts = setStimManager(ts, stim);
        %     subject = setTrainingStep(subject, ts);
        [s r]=changeProtocolStep(s,ts,r,'updating shaping value','pmm'); % only change the current step!
        
        % confirm it worked
        s2=getSubjectFromID(r,getID(s));
        [p stepNum]=getProtocolAndStep(s2);
        ts = getTrainingStep(p,stepNum);
        stim = getStimManager(ts);
        currentValue = getCurrentShapedValue(stim)
        if currentValue ~= valueInDatabase
            error('what up wi'' dat?')
        end

    else
        getID(s)
        stepNum = stepNum
        valueInDatabase = valueInDatabase
        currentValue = currentValue
        error('must have currentShapedValue defined in database, if rat is on a shaping step ')
    end
end
