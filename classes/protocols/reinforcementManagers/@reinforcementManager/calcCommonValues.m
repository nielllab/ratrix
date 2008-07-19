function [rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = calcCommonValues(r,base)
rewardSizeULorMS= getScalar(r) * base;
msPenalty=getMsPenalty(r);
msPuff=getMsPuff(r);
msRewardSound=rewardSizeULorMS*r.fractionOpenTimeSoundIsOn;
msPenaltySound=getMsPenalty(r)*r.fractionPenaltySoundIsOn;