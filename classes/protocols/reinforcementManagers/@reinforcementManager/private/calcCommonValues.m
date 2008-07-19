function [rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = calcCommonValues(r,base)
rewardSizeULorMS= getScalar(r) * base;
msPenalty=getMsPenalty(r);
msPuff=getMsPuff(r);
msRewardSound=rewardSizeULorMS*getFractionOpenTimeSoundIsOn(r.reinforcementManager);
msPenaltySound=getMsPenalty(r)*getFractionPenaltySoundIsOn(r.reinforcementManager);