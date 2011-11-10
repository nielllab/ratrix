function    [value]  = hasUpdatablePercentCorrectionTrial(sm)
% returns false unless a stim subclass overrides it. Then can use
% changeAllPercentCorrectionTrials

error('edf hates this -- all correction trial info should be on the trialManager')

  value = false;

