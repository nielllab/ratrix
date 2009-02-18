function [rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = calcCommonValues(r,base,baseRequest)
rewardSizeULorMS= getScalar(r) * base;
requestRewardSizeULorMS = getScalar(r) * baseRequest;
msPenalty=getMsPenalty(r);
msPuff=getMsPuff(r);
msRewardSound=rewardSizeULorMS*r.fractionOpenTimeSoundIsOn;
msPenaltySound=getMsPenalty(r)*r.fractionPenaltySoundIsOn;