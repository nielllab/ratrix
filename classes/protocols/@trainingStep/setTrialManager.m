function ts=setTrialManager(ts,tm)
if(isa(tm, 'trialManager'))
    if(isa(ts, 'trainingStep'))
        ts.trialManager = tm;
    else
        class(ts)
        error('input is not of type trainingStep');
    end
else
     class(tm)
    error('input is not of type trialManager');
end