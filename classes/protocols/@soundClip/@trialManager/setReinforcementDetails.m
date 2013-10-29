function t=setReinforcementDetails(t,details)
error('edf thinks this should never be called')
%to be general set all the details that exist...

%right now just doing all the ones that get extracted by
%calcReinforcementDetails (which maybe should exist in the super class
%also...) -pmm 070523
            

 t.rewardSizeULorMS=details.rewardSizeULorMS;
 t.msPenalty=details.msPenalty;
 t.msRewardSoundDuration=details.msRewardSound;
 

 %t.msPenaltySound=details.msPenaltySound;  %not used yet
        
%  %not used currently:
%         t.msFlushDuration=0;
%         t.msMinimumPokeDuration=0;
%         t.msMinimumClearDuration=0;
%         t.soundMgr=soundManager();


%disp(t.description)
%out=getRewardSizeULorMS(trialManager) %test
warning('trialManager description is likely out of sync with values b/c of updating')

