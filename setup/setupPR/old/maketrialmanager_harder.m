function tm= maketrialmanager(varargin);
%function tm= maketrialmanager(varargin);
%returns a default trial manager as follows
% tm=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
%     percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
%     maximumNumberStimPresentations,doMask,increasingReward);
% where
%     msFlushDuration=10;
%     msMinimumPokeDuration   =10;
%     msMinimumClearDuration  =10;
%     requestRewardSizeULorMS=1;  % not 10
%     percentCorrectionTrials=.25; % not 0.5
%     msResponseTimeLimit=0; % 0 means unlimited
%     pokeToRequestStim=true;
%     maintainPokeToMaintainStim=true;
%     msMaximumStimPresentationDuration=0; % 0 means unlimited
%     maximumNumberStimPresentations=0; % 0 means unlimited
%     doMask=false;
%     sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
%         soundClip('keepGoingSound','allOctaves',[300],20000), ...
%         soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
%         soundClip('wrongSound','tritones',[300 400],20000)});
% which is now built using makeStandardSoundManager();
%     scalar=1;
%     msPenalty=4000; % not 0
%     increasingReward=rewardNcorrectInARow([20,80,150],msPenalty,1,1, scalar);
% %%%%%%%%%%%

msFlushDuration=1;%%%
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
requestRewardSizeULorMS=10;
percentCorrectionTrials=.25;%%%
msResponseTimeLimit=0; % 0 means unlimited
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0; % 0 means unlimited
maximumNumberStimPresentations=0; % 0 means unlimited
doMask=false;

% default sound manager
sm=makeStandardSoundManager();

% default reward manager
scalar=1;
msPenalty=4000; %%%
increasingReward=rewardNcorrectInARow([20,80,150],msPenalty,1,1, scalar); %[20 80 100 150 250] is what philip uses ..
%%%%%%%%%%%

tm=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingReward);
