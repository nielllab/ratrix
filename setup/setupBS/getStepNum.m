function stepNum = getStepNum(subID)
switch subID
    case {'267','268', '269', '270'} % Airpuff expt
        stepNum = 3;
    case {'181','182','187','188', '159','161','180','186'} % Transference Experiment
        stepNum = 1;
    otherwise
        error('do not recognize rat for protocol')
end
end