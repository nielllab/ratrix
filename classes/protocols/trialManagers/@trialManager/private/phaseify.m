function [stimSpecs] = phaseify(trialManager,stim,stimManager,type,...
    targetPorts,distractorPorts,scaleFactor,rewardSizeULorMS,msPenalty,ifi)
% this function takes the output from calcStim of a non-phased stim manager, and converts it to stimSpecs according to the trialManager class
% inputs should be self-explanatory
% outputs are cell arrays of stimSpecs 

% =====================================================================================================
if strmatch(class(trialManager), 'nAFC')
    % nAFC
    % =====================================================================================================
    % waiting for request
    criterion = {[2], [2]};
    stimSpecs{1} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',[],rewardSizeULorMS,[],[],0,0);
    % waiting for response
    %reverse frames
%     reverse_stim(:,:,1) = stim(:,:,2);
%     reverse_stim(:,:,2) = stim(:,:,1);
    criterion = {targetPorts, 3, distractorPorts, 4};
    stimSpecs{2} = stimSpec(stim,criterion,type,[],rewardSizeULorMS,[],[],scaleFactor,0);
    % correct
    criterion = {[], 5};
    numCorrectFrames=ceil((rewardSizeULorMS/1000)/ifi);
    stimSpecs{3} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache','reward',rewardSizeULorMS,numCorrectFrames,[],0,0);
    % wrong
    criterion = {[], 5};
    numErrorFrames=ceil((msPenalty/1000)/ifi);
    [errStim errorScale] = errorStim(stimManager,numErrorFrames);
    stimSpecs{4} = stimSpec(errStim,criterion,'cache',[],rewardSizeULorMS,numErrorFrames,[],errorScale,0);
    % final
    criterion = {[], 1};
    stimSpecs{5} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',...
        [],rewardSizeULorMS,1,[],0,1);
elseif strmatch(class(trialManager), 'freeDrinks')
    % freeDrinks
    % =====================================================================================================
    % waiting for response phase
    criterion = {targetPorts, 2};
    stochasticP = getFreeDrinkLikelihood(trialManager);
    stimSpecs{1} = stimSpec(stim, criterion,'loop',[],rewardSizeULorMS,[],{stochasticP,1,stochasticP,2,stochasticP,3},scaleFactor,0);
    % correct phase (always correct)
    criterion = {[], 3};
    numCorrectFrames=ceil((rewardSizeULorMS/1000)/ifi);
    stimSpecs{2} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache','reward',rewardSizeULorMS,numCorrectFrames,[],0,0);
    % final
    criterion = {[], 1};
    stimSpecs{3} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',...
        [],rewardSizeULorMS,1,[],0,1);
elseif strcmp(class(trialManager), 'autopilot')
    % autopilot
    % just put in loop mode, one phase
    criterion = {[], 2};
    stimSpecs{1} = stimSpec(stim, criterion,'loop',[],rewardSizeULorMS,[],[],scaleFactor,0);
    % final phase
    criterion = {[], 1};
    stimSpecs{2} = stimSpec(getInterTrialLuminance(stimManager),criterion,'cache',...
        [],rewardSizeULorMS,1,[],0,1);
else
    error('only nAFC and freeDrinks for now');
end

