function [tm trialDetails result spec rewardSizeULorMS requestRewardSizeULorMS ...
    msPuff msRewardSound msPenalty msPenaltySound floatprecision textures destRect] = ...
    updateTrialState(tm, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone, punishResponses, request, lastFrame)
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
% call parent's updateTrialState() to do the request reward handling and check for 'timeout' flag
[tm.trialManager possibleTimeout result garbage garbage requestRewardSizeULorMS] = ...
    updateTrialState(tm.trialManager, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone,punishResponses,request);
if ~isempty(result) && ~ischar(result)
	resp=find(result);
	if length(resp)==1
		result = 'nominal';
        correct=1;
        if punishResponses
            correct=0;
        end
    else
        correct=0;
		result = 'multiple ports';
    end
    trialDetails.correct=correct;
elseif ischar(result) && strcmp(result,'timedout')
    correct=0;
    trialDetails.correct=correct;
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
            if isempty(framesUntilTransition)
                framesUntilTransition = ceil((rewardSizeULorMS/1000)/ifi);
            end
            numCorrectFrames=ceil((rewardSizeULorMS/1000)/ifi);

        elseif strcmp(getDisplayMethod(tm),'LED')
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
        
        [cStim cType cStartFrame cScale framesUntilTransition] = correctStim(sm,numCorrectFrames,ifi,tm,lastFrame);
        
        spec=setFramesUntilTransition(spec,max(numCorrectFrames,framesUntilTransition));
        spec=setScaleFactor(spec,cScale);
        
        %if ismember(cType,{'static','cache','loop'}) || (iscell(cType) && all(size(cType)==[1 2]) && ismember(cType{1},{'trigger','timedFrames','indexedFrames'}))
            spec=setType(spec,cType); %needs to be compatible with fixed framesUntilTransition -- how deal with dynamic/expert/etc?
        %end
        spec=setStartFrame(spec,cStartFrame);
        
        strategy='noCache';
        if window>0
            if ~strcmp(cType,'expert')
                [floatprecision cStim] = determineColorPrecision(tm, cStim, strategy);
                textures = cacheTextures(tm,strategy,cStim,window,floatprecision);
                destRect = determineDestRect(tm, window, station, cScale, cStim, strategy);
            end
        elseif strcmp(getDisplayMethod(tm),'LED')
            floatprecision=[];
        else
            error('huh?')
        end
        spec=setStim(spec,cStim);         
                        
    elseif ~correct
        % this only happens when multiple ports are triggered
        rewardSizeULorMS=0;
        msRewardSound=0;
        msPuff=0; % for now, we don't want airpuffs to be automatic punishment, right?

        if window>0
            if isempty(framesUntilTransition)
                framesUntilTransition = ceil((msPenalty/1000)/ifi);
            end
            numErrorFrames=ceil((msPenalty/1000)/ifi);

        elseif strcmp(getDisplayMethod(tm),'LED')
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
        elseif strcmp(getDisplayMethod(tm),'LED')
            floatprecision=[];
        else
            error('huh?')
        end
        spec=setStim(spec,eStim);
    end
end % end reward handling



trialDetails=[];
end  % end function