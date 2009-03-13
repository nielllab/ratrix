function [tm trialDetails result spec rewardSizeULorMS requestRewardSizeULorMS ...
    msPuff msRewardSound msPenalty msPenaltySound floatprecision textures destRect] = ...
    updateTrialState(tm, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone)
% This function is a tm-specific method to update trial state before every flip.
% Things done here include:
%   - set trialRecords.correct and trialRecords.result as necessary
%   - call RM's calcReinforcement as necessary
%   - update the stimSpec as necessary (with correctStim() and errorStim())
%   - update the TM's RM if neceesary

rewardSizeULorMS=0;
requestRewardSizeULorMS=0;
msPuff=0;
msRewardSound=0;
msPenalty=0;
msPenaltySound=0;

% ========================================================
% if the result is a port vector, and we have not yet assigned correct, then the current result must be the trial response
% because phased trial logic returns the 'result' from previous phase only if it matches a target/distractor
if ~isempty(result) && ~ischar(result)
    resp=find(result);
    if length(resp)==1
        result = 'nominal';
    else
        result = 'multiple ports';
    end
end

% ========================================================
phaseType = getPhaseType(spec);
framesUntilTransition=getFramesUntilTransition(spec);
% now, if phaseType is 'reinforced', use correct and call updateRewards(tm,correct)
% this trialManager-specific method should do the following:
% - call calcReinforcement(RM)
% - update msRewardOwed/msAirpuffOwed as necessary (depending on correctness and TM class)
% - call errorStim(SM), correctStim(SM) as necessary and fill in the stimSpec's stimulus field

if ~isempty(phaseType) && strcmp(phaseType,'reinforced') && framesInPhase==0
    % we only check to do rewards on the first frame of the 'reinforced' phase
    [rm rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] =...
        calcReinforcement(getReinforcementManager(tm),trialRecords, []);
    if updateRM
        tm=setReinforcementManager(tm,rm);
    end
    
    if strcmp(result,'nominal')
        msPuff=0;
        msPenalty=0;
        msPenaltySound=0;

        if window>0
            if isempty(framesUntilTransition)
                framesUntilTransition = ceil((rewardSizeULorMS/1000)/ifi);
            end
            numCorrectFrames=ceil((rewardSizeULorMS/1000)/ifi);

        elseif strcmp(tm.displayMethod,'LED')
            if isempty(framesUntilTransition)
                framesUntilTransition=ceil(getHz(spec)*rewardSizeULorMS/1000);
            else
                framesUntilTransition
                error('LED needs framesUntilTransition empty for reward')
            end
            numCorrectFrames=ceil(getHz(spec)*rewardSizeULorMS/1000);
        else
            error('huh?')
        end
        spec=setFramesUntilTransition(spec,framesUntilTransition);
        [cStim correctScale] = correctStim(sm,numCorrectFrames);
        spec=setScaleFactor(spec,correctScale);
        strategy='noCache';
        if window>0
            [floatprecision cStim] = determineColorPrecision(tm, cStim, strategy);
            textures = cacheTextures(tm,strategy,cStim,window,floatprecision);
            destRect = determineDestRect(tm, window, station, correctScale, cStim, strategy);
        elseif strcmp(tm.displayMethod,'LED')
            floatprecision=[];
        else
            error('huh?')
        end
        spec=setStim(spec,cStim);
    
    elseif strcmp(result,'multiple ports')
        % this only happens when multiple ports are triggered
        rewardSizeULorMS=0;
        msRewardSound=0;
        msPuff=0; % for now, we don't want airpuffs to be automatic punishment, right?

        if window>0
            if isempty(framesUntilTransition)
                framesUntilTransition = ceil((msPenalty/1000)/ifi);
            end
            numErrorFrames=ceil((msPenalty/1000)/ifi);

        elseif strcmp(tm.displayMethod,'LED')
            if isempty(framesUntilTransition)
                framesUntilTransition=ceil(getHz(spec)*msPenalty/1000);
            else
                framesUntilTransition
                error('LED needs framesUntilTransition empty for reward')
            end
            numErrorFrames=ceil(getHz(spec)*msPenalty/1000);
        else
            error('huh?')
        end
        spec=setFramesUntilTransition(spec,framesUntilTransition);
        [eStim errorScale] = errorStim(sm,numErrorFrames);
        spec=setScaleFactor(spec,errorScale);
        strategy='noCache';
        if window>0
            [floatprecision eStim] = determineColorPrecision(tm, eStim, strategy);
            textures = cacheTextures(tm,strategy,eStim,window,floatprecision);
            destRect=Screen('Rect',window);
        elseif strcmp(tm.displayMethod,'LED')
            floatprecision=[];
        else
            error('huh?')
        end
        spec=setStim(spec,eStim);
    end
end % end reward handling

% call parent's updateTrialState() to do the request reward handling
[tm.trialManager garbage garbage garbage garbage requestRewardSizeULorMS] = ...
    updateTrialState(tm.trialManager, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone);

trialDetails=[];
end  % end function