function [r rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] = calcReinforcement(r,trialRecords, subject)

[rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = calcCommonValues(r,r.rewardSizeULorMS);

updateRM=0;