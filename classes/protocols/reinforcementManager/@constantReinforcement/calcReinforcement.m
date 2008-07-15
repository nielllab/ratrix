function [r rewardSizeULorMS msPenalty msRewardSound msPenaltySound updateRM] = calcReinforcement(r,trialRecords, subject)

        rewardSizeULorMS=r.rewardSizeULorMS;
        msPenalty=r.msPenalty;
        msRewardSound=r.rewardSizeULorMS*getFractionOpenTimeSoundIsOn(r.reinforcementManager);
        msPenaltySound=r.msPenalty*getFractionPenaltySoundIsOn(r.reinforcementManager);

        updateRM=0;
        
        
       
