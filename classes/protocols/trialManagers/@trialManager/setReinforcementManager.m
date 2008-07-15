function t = setReinforcementManager(t, rm)


if(isa(t, 'trialManager'))

    if(isa(rm, 'reinforcementManager'))
        t.reinforcementManager = rm;
    else
        error('input is not of type reinforcementManager');
    end
else
    error('input is not of type trialManager');
end