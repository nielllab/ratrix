function [stimSpecs] = phaseify(trialManager,stim,stimManager,type,...
    targetPorts,distractorPorts,scaleFactor,rewardSizeULorMS,msPenalty,ifi,hz)
% this function takes the output from calcStim of a non-phased stim manager, and converts it to stimSpecs according to the trialManager class
% inputs should be self-explanatory
% outputs are cell arrays of stimSpecs 

% =====================================================================================================
if strmatch(class(trialManager), 'nAFC')
    % nAFC
    % =====================================================================================================
    % if the type is timedFrames and last element of the vector is not zero, make sure you set a framesUntilTransition timeout
    if iscell(type) && strcmp(type{1},'timedFrames') && type{2}(end)~=0
        framesUntilTransition=sum(type{2});
    else
        framesUntilTransition=[];
    end
    % waiting for request
    criterion = {[2], [2]};
    stimSpecs{1} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',1,[],rewardSizeULorMS,targetPorts,framesUntilTransition,[],0,0,hz);
    % waiting for response
    %reverse frames
%     reverse_stim(:,:,1) = stim(:,:,2);
%     reverse_stim(:,:,2) = stim(:,:,1);
    criterion = {targetPorts, 3, distractorPorts, 4};
    stimSpecs{2} = stimSpec(stim,criterion,type,1,[],rewardSizeULorMS,targetPorts,[],[],scaleFactor,0,hz);
    % correct
    criterion = {[], 5};
    numCorrectFrames=ceil((rewardSizeULorMS/1000)/ifi);
    stimSpecs{3} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',1,'reward',rewardSizeULorMS,targetPorts,numCorrectFrames,[],0,0,hz);
    % wrong
    criterion = {[], 5};
    numErrorFrames=ceil((msPenalty/1000)/ifi);
    [errStim errorScale] = errorStim(stimManager,numErrorFrames);
    stimSpecs{4} = stimSpec(errStim,criterion,'cache',1,[],rewardSizeULorMS,targetPorts,numErrorFrames,[],errorScale,0,hz);
    % final
    criterion = {[], 1};
    stimSpecs{5} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',1,...
        [],rewardSizeULorMS,targetPorts,1,[],0,1,hz);
elseif strmatch(class(trialManager), 'freeDrinks')
    % freeDrinks
    % =====================================================================================================
    % waiting for response phase
    criterion = {targetPorts, 2};
    stochasticP = getFreeDrinkLikelihood(trialManager);
    stimSpecs{1} = stimSpec(stim, criterion,'loop',1,[],rewardSizeULorMS,targetPorts,[],{stochasticP,1,stochasticP,2,stochasticP,3},scaleFactor,0,hz);
    % correct phase (always correct)
    criterion = {[], 3};
    numCorrectFrames=ceil((rewardSizeULorMS/1000)/ifi);
    stimSpecs{2} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',1,'reward',rewardSizeULorMS,targetPorts,numCorrectFrames,[],0,0,hz);
    % final
    criterion = {[], 1};
    stimSpecs{3} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',1,...
        [],rewardSizeULorMS,targetPorts,1,[],0,1,hz);
elseif strcmp(class(trialManager), 'autopilot')
    % autopilot
    % just put in loop mode, one phase
    criterion = {[], 2};
    stimSpecs{1} = stimSpec(stim, criterion,'loop',1,[],rewardSizeULorMS,targetPorts,[],[],scaleFactor,0,hz);
    % final phase
    criterion = {[], 1};
    stimSpecs{2} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',1,...
        [],rewardSizeULorMS,targetPorts,1,[],0,1,hz);
else
    error('only nAFC and freeDrinks for now');
end

