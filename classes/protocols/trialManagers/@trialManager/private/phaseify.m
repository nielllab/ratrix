function [stimSpecs startingStimSpecInd] = phaseify(trialManager,stim,type,...
    targetPorts,distractorPorts,requestPorts,scaleFactor,interTrialLuminance,hz,indexPulses)
% this method takes the output from calcStim of a non-phased stim manager, and converts it to stimSpecs according to the trialManager class
% output is cell arrays of stimSpecs

stimulusOnsetCriterion=[];
startingStimSpecInd=1; % which phase to start with (passed to stimOGL->runRealTimeLoop)
% this allows us to have an optional 'waiting for request' phase in nAFC and not mess up sound handling
% set framesUntilStimulusOnset for delayManager
if isempty(trialManager.delayManager)
    if iscell(type) && strcmp(type{1},'timedFrames') && type{2}(end)~=0
        framesUntilStimulusOnset=sum(type{2});
    else
        framesUntilStimulusOnset=[];
    end
elseif isa(trialManager.delayManager,'delayManager')
    [delayMs toutMs]=getDelayAndTimeout(trialManager.delayManager);
    if isempty(delayMs)
        stimulusOnsetCriterion={[],4};
        framesUntilStimulusOnset=floor(hz*toutMs/1000);
    else
        framesUntilStimulusOnset=floor(hz*delayMs/1000);
    end
	%framesUntilStimulusOnset=fnc_name(); % replace with eval?
else
	error('unsupported delayManager - how did this get past the constructor?');
end

if ~isempty(trialManager.responseWindowMs)
	framesUntilResponseTimeout=floor(hz*trialManager.responseWindowMs/1000);
else
	framesUntilResponseTimeout=[];
end

if strmatch(class(trialManager), 'nAFC')

    % waiting for request
    criterion = {requestPorts, 2, [], 2};
    if ~isempty(stimulusOnsetCriterion)
        criterion=stimulusOnsetCriterion;
    end
    stimSpecs{1} = stimSpec(interTrialLuminance,criterion,'loop',0,framesUntilStimulusOnset,[],0,0,hz,[],'waiting for request',false);
    
    % waiting for response
    criterion = {[targetPorts distractorPorts], 3, [], 3};
    stimSpecs{2} = stimSpec(stim,criterion,type,0,framesUntilResponseTimeout,[],scaleFactor,0,hz,[],'discrim',true,indexPulses);
    
    % reinforcement (correct/wrong)
    criterion = {[], 4};
    stimSpecs{3} = stimSpec([],criterion,'cache',0,[],[],[],0,hz,'reinforced','reinforcement',false); % timeout assigned during runRealTimeLoop
    
    % final
    criterion = {[], 4};
    stimSpecs{4} = stimSpec(interTrialLuminance,criterion,'cache',0,1,[],0,1,hz,[],'itl',false);
    
    if isempty(requestPorts) && isempty(trialManager.delayManager) % was this for passiveViewing?
        startingStimSpecInd=2;
    end
    
elseif strmatch(class(trialManager), 'freeDrinks')

    % waiting for response phase
    criterion = {targetPorts, 2, [], 2};
    stochasticP = getFreeDrinkLikelihood(trialManager);
    stimSpecs{1} = stimSpec(stim, criterion,'loop',0,framesUntilResponseTimeout,{stochasticP,1,stochasticP,2,stochasticP,3},scaleFactor,0,hz,[],'discrim',true,indexPulses);

    % correct phase (always correct)
    criterion = {[], 3};
    stimSpecs{2} = stimSpec([],criterion,'cache',0,[],[],0,0,hz,'reinforced','reinforcement',false);
    
    % final
    criterion = {[], 3};
    stimSpecs{3} = stimSpec(interTrialLuminance,criterion,'cache',0,1,[],0,1,hz,[],'itl',false);
    
elseif strmatch(class(trialManager), 'goNoGo')
    
    if isempty(requestPorts) && isempty(trialManager.delayManager)
        error('cannot have empty delayManager with no request ports in goNoGo');
    end
    lockoutDuration=floor(hz*getResponseLockoutMs(trialManager)/1000);
    % waiting for request
    criterion = {requestPorts, 2, [], 2};
    if ~isempty(stimulusOnsetCriterion)
        criterion=stimulusOnsetCriterion;
    end
    stimSpecs{1} = stimSpec(interTrialLuminance,criterion,'loop',0,framesUntilStimulusOnset,[],0,0,hz,[],'waiting for request',false);

    % waiting for response
    criterion = {[targetPorts distractorPorts], 3, [], 3};
    stimSpecs{2} = stimSpec(stim,criterion,type,0,framesUntilResponseTimeout,[],scaleFactor,0,hz,[],'discrim',true,indexPulses,lockoutDuration);

    % reinforcement (correct/wrong)
    criterion = {[], 4};
    stimSpecs{3} = stimSpec([],criterion,'cache',0,[],[],[],0,hz,'reinforced','reinforcement',false); % timeout assigned during runRealTimeLoop

    % final
    criterion = {[], 4};
    stimSpecs{4} = stimSpec(interTrialLuminance,criterion,'cache',0,1,[],0,1,hz,[],'itl',false);

elseif strcmp(class(trialManager), 'autopilot')

    % just put in loop mode, one phase
    criterion = {[], 2};
    stimSpecs{1} = stimSpec(stim, criterion,'loop',0,[],[],scaleFactor,0,hz,[],'display',true);

    % final phase
    criterion = {[], 2};
    stimSpecs{2} = stimSpec(interTrialLuminance,criterion,'cache',0,1,[],0,1,hz,[],'itl',false);

else
    error('only nAFC, freeDrinks, and autopilot for now');
end

