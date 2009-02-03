function [TM, SM] = makeFreeDrinksTM(p, pctStochasticReward, contrast)

%constantReinforcement
rewardManager=constantReinforcement(p.rewardNthCorrect(1),p.msPenalty,p.fractionOpenTimeSoundIsOn,p.fractionPenaltySoundIsOn,p.scalar,p.msPuff)
TM = freeDrinks(p.msFlushDuration,p.msMinimumPokeDuration,p.msMinimumClearDuration,p.sndManager,pctStochasticReward,rewardManager,...
    p.eyeTracker,p.eyeController,p.datanet,...
    p.frameDropCorner,p.dropFrames,p.displayMethod);

targetOrientations      =0; % less calculating
distractorOrientations  =[];
SM = orientedGabors(p.pixPerCycs,targetOrientations,distractorOrientations,p.mean,p.stdGaussMask,contrast,p.thresh,p.yPositionPercent,p.maxWidth,p.maxHeight,p.scaleFactor,p.interTrialLuminance);

