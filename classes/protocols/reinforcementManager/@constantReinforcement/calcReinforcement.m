function [r rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateRM] = calcReinforcement(r,trialRecords, subject)

        rewardSizeULorMS=r.rewardSizeULorMS;
        msPenalty=r.msPenalty;
        msPuff=r.msPuff;
        msRewardSound=r.rewardSizeULorMS*getFractionOpenTimeSoundIsOn(r.reinforcementManager);
        msPenaltySound=r.msPenalty*getFractionPenaltySoundIsOn(r.reinforcementManager);

        updateRM=0;
        
        
       
