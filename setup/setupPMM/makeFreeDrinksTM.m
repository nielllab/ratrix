function [TM, SM] = makeFreeDrinksTM(pctStochasticReward, contrast)

% shared parameters for free drinks
if ~exist('contrast', 'var')
    contrast = 0; % if wrong for shaping, show nothing!
end

msFlushDuration         =1000;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;

rewardSizeULorMS        =100;
msPenalty               =1;
%msRewardSoundDuration   =rewardSizeULorMS;
fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
msPuff=0;
rewardManager=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msPuff)

sndManager            =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});


%constantReinforcement


pixPerCycs              =[20];
targetOrientations      =0;%rand*pi;%[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.1;
% contrast                =1; passed in
thresh                  =.00005;
yPosPct                 =.65;
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;





% contrast                =1;   % if wrong for shaping, show nothing!
% maxWidth                =800;
% maxHeight               =600;
% scaleFactor             =[1 1];

maxWidth                =120;
maxHeight               =100;
scaleFactor             =[0];

TM = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,pctStochasticReward,rewardManager);
SM = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

