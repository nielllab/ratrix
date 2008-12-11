function ts=setTrialManager(ts,tm)
if(isa(tm, 'trialManager'))

        ts.trialManager = tm;

else
     class(tm)
    error('input is not of type trialManager');
end