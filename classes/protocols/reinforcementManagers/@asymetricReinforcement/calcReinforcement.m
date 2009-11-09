function [r rewardSizeULorMS requestRewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] = ...
    calcReinforcement(r,trialRecords, subject)


%confirm trial redords contains THIS trial (not merely the trials before this trial)

evalStr = sprintf('sm = %s();',trialRecords(end).stimManagerClass);
eval(evalStr);
details=trialRecords(end).stimDetails;
targetIsPresent=checkTargetIsPresent(sm,details);

if targetIsPresent==1
    rewardSizeULorMS=getScalar(r) * r.hitRewardSizeULorMS;
    msPenalty=r.missMsPenalty;
elseif targetIsPresent==0;
    rewardSizeULorMS=getScalar(r) * r.correctRejectRewardSizeULorMS;
    msPenalty=r.falseAlarmMsPenalty;
else  %(ie. any negative value)
    class(sm)
    targetIsPresent
    error('this reinforcement manager requires the stim manager to report that the target is present or absent')
end

rewardSizeULorMS= getScalar(r) * rewardSizeULorMS;

requestRewardSizeULorMS = getScalar(r) * getRequestRewardSizeULorMS(r);
msPuff=getMsPuff(r);
msRewardSound=rewardSizeULorMS*getFractionOpenTimeSoundIsOn(r);
msPenaltySound=msPenalty*getFractionPenaltySoundIsOn(r);

updateRM=0;