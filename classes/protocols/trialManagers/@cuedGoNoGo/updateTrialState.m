function [tm trialDetails result spec rewardSizeULorMS requestRewardSizeULorMS ...
    msPuff msRewardSound msPenalty msPenaltySound floatprecision textures destRect] = ...
    updateTrialState(tm, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone, punishResponses)
% This function is a tm-specific method to update trial state before every
% flip. This is similar to nAFC, except that timeOuts might be considered
% correct, and rewards of 0msec and penalties of 0msec are tolerated.
% (numErrorFrames/numCorrectFrames forced to 1 in this case)
% the logic for msPuff has not been excersized yet.

% Things done here include:
%   - set trialRecords.correct and trialRecords.result as necessary
%   - call RM's calcReinforcement as necessary
%   - update the stimSpec as necessary (with correctStim() and errorStim())
%   - update the TM's RM if neceesary

rewardSizeULorMS=0;
msPuff=0;
msRewardSound=0;
msPenalty=0;
msPenaltySound=0;

if isfield(trialRecords(end),'trialDetails') && isfield(trialRecords(end).trialDetails,'correct')
    correct=trialRecords(end).trialDetails.correct;
else
    correct=[];
end

% ========================================================
% if the result is a port vector, and we have not yet assigned correct, then the current result must be the trial response
% because phased trial logic returns the 'result' from previous phase only if it matches a target/distractor
% 3/13/09 - we rely on nAFC's phaseify to correctly assign stimSpec.phaseLabel to identify where to check for correctness
% call parent's updateTrialState() to do the request reward handling and check for 'timeout' flag
[tm.trialManager possibleTimeout result garbage garbage requestRewardSizeULorMS] = updateTrialState(tm.trialManager, sm, result, spec, ports, lastPorts, targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, floatprecision, textures, destRect, requestRewardDone, punishResponses);

if isempty(possibleTimeout)
    if ~isempty(result) && ~ischar(result) && isempty(correct) && strcmp(getPhaseLabel(spec),'reinforcement')
        resp=find(result);
        if length(resp)==1
            correct = ismember(resp,targetPorts);
            result = 'nominal';
        else
            correct = 0;
            result = 'multiple ports';
        end
    end
else
    %GO NOGO SPECIAL CODE HANDLES TIME OUTS AS NO-GO, which could be correct
    %correct=possibleTimeout.correct;
    if checkTargetIsPresent(sm,trialRecords(end).stimDetails);  %&& was previously in "discrim" Phase (so early pushied responses remain incorrect!)
        correct=0;
    else
        correct=1;
    end
    result = 'nominal';
end

%by turning this off reinforced correct works... why?
% if punishResponses % this means we got a response, but we want to punish, not reward
%     correct=0; % we could only get here if we got a response (not by request or anything else), so it should always be correct=0
% end
% 

% ========================================================
phaseType = getPhaseType(spec);
framesUntilTransition=getFramesUntilTransition(spec);
% now, if phaseType is 'reinforced', use correct and call updateRewards(tm,correct)
% this trialManager-specific method should do the following:
% - call calcReinforcement(RM)
% - update msRewardOwed/msAirpuffOwed as necessary (depending on correctness and TM class)
% - call errorStim(SM), correctStim(SM) as necessary and fill in the
% stimSpec's stimulus field

if ~isempty(phaseType) && strcmp(phaseType,'earlyPenalty')
    %      [rm rewardSizeULorMS=0 garbage msPenalty msPuff=0 msRewardSound=0 msPenaltySound updateRM] =...
    %         calcEarlyPenalty(getReinforcementManager(tm),trialRecords, []);
    
    [rm rewardSizeULorMS garbage msPenalty msPuff msRewardSound msPenaltySound updateRM] =...
        calcEarlyPenalty(getReinforcementManager(tm),trialRecords, []);
    
    framesUntilTransition=[]; %this is needed or else you will never get to the next part, this is very dirty and should never
    %be repeated anywhere else, but Duc is allowed to do this (yay!)
    
    if window>0
        numErrorFrames=max(1,ceil((msPenalty/1000)/ifi));
        if isempty(framesUntilTransition)
            framesUntilTransition = numErrorFrames;
        end
    else
        error('no LED support.. too add see below')
    end
    
    spec=setFramesUntilTransition(spec,framesUntilTransition);

    if msPenalty>0
        [eStim errorScale] = errorStim(sm,numErrorFrames);
    end
    spec=setScaleFactor(spec,errorScale);
    strategy='noCache';
    if window>0
        [floatprecision eStim] = determineColorPrecision(tm, eStim, strategy);
        textures = cacheTextures(tm,strategy,eStim,window,floatprecision);
        destRect=Screen('Rect',window);
    else
        error('no LED support.. too add see below')
    end
    spec=setStim(spec,eStim);
end


if ~isempty(phaseType) && strcmp(phaseType,'reinforced') && ~isempty(correct) && framesInPhase==0
    % we only check to do rewards on the first frame of the 'reinforced' phase
    [rm rewardSizeULorMS garbage msPenalty msPuff msRewardSound msPenaltySound updateRM] =...
        calcReinforcement(getReinforcementManager(tm),trialRecords, []);
    if updateRM
        tm=setReinforcementManager(tm,rm);
    end
    
    if correct
        msPuff=0;
        msPenalty=0;
        msPenaltySound=0;
        
        if window>0
            numCorrectFrames=max(1,ceil((rewardSizeULorMS/1000)/ifi)); %less than 1 frame errors on index pulse, -pmm
            if isempty(framesUntilTransition)
                framesUntilTransition = numCorrectFrames;
            end
            
        elseif strcmp(getDisplayMethod(tm),'LED')
            numCorrectFrames=max(1,ceil(getHz(spec)*rewardSizeULorMS/1000));
            if isempty(framesUntilTransition)
                framesUntilTransition=numCorrectFrames;
            else
                framesUntilTransition
                error('LED needs framesUntilTransition empty for reward')
            end
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
        elseif strcmp(getDisplayMethod(tm),'LED')
            floatprecision=[];
        else
            error('huh?')
        end
        spec=setStim(spec,cStim);
    else
        rewardSizeULorMS=0;
        msRewardSound=0;
        msPuff=0; % for now, we don't want airpuffs to be automatic punishment, right?
        
        if window>0
            numErrorFrames=max(1,ceil((msPenalty/1000)/ifi));
            if isempty(framesUntilTransition)
                framesUntilTransition = numErrorFrames;
            end
            
            
        elseif strcmp(getDisplayMethod(tm),'LED')
            numErrorFrames=max(1,ceil(getHz(spec)*msPenalty/1000));
            if isempty(framesUntilTransition)
                framesUntilTransition=numErrorFrames;
            else
                framesUntilTransition
                error('LED needs framesUntilTransition empty for reward')
            end
        else
            error('huh?')
        end
        spec=setFramesUntilTransition(spec,framesUntilTransition);
        if msPenalty>0
            [eStim errorScale] = errorStim(sm,numErrorFrames);
        else
            %if the penalty is 0 on incorrect trials, it will display one
            %frame, and goNoGo will use the correctStim, which is typically
            %mean screen, and not flashing full screen
            [eStim errorScale] = correctStim(sm,numErrorFrames);
        end
        spec=setScaleFactor(spec,errorScale);
        
        strategy='noCache';
        if window>0
            [floatprecision eStim] = determineColorPrecision(tm, eStim, strategy);
            textures = cacheTextures(tm,strategy,eStim,window,floatprecision);
            destRect=Screen('Rect',window);
        elseif strcmp(getDisplayMethod(tm),'LED')
            floatprecision=[];
        else
            error('huh?')
        end
        spec=setStim(spec,eStim);
    end
end % end reward handling

trialDetails.correct=correct;

if strcmp(getPhaseLabel(spec),'intertrial luminance') && ischar(result) && strcmp(result,'timeout')
    % this should be the only allowable result in autopilot
    result='timedout'; % so we continue to next trial
end

end  % end function