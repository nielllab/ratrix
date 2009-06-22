function [TM, SM] = makeFreeDrinksTM(p, pctStochasticReward, contrast)

%constantReinforcement
rewardManager=constantReinforcement(p.rewardNthCorrect(1),p.requestRewardSizeULorMS,p.requestMode,p.msPenalty,p.fractionOpenTimeSoundIsOn,p.fractionPenaltySoundIsOn,p.scalar,p.msPuff)
TM = freeDrinks(p.sndManager,pctStochasticReward,p.allowFreeDrinkRepeatsAtSameLocation, rewardManager)
%   [eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts],[saveDetailedFramedrops],
%	[delayManager],[responseWindowMs],[showText])

targetOrientations      =0; % less calculating
distractorOrientations  =[];
SM = orientedGabors(p.pixPerCycs,targetOrientations,distractorOrientations,p.mean,p.stdGaussMask,contrast,p.thresh,p.yPositionPercent,p.maxWidth,p.maxHeight,p.scaleFactor,p.interTrialLuminance);

