function rewardDuration = getRewardDuration(subID)
switch subID
    case {'267','268', '269', '270'} % Airpuff expt
        rewardDuration = 30;
    case {'181','182','187','188'} % Transference Experiment
        rewardDuration = 30;
    case {'159','161','180','186'} % Airpuff with experience
        rewardDuration = 50;
    otherwise
        error('do not recognize rat for protocol')
end
end