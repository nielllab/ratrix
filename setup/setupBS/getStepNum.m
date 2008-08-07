function stepNum = getStepNum(subID)
switch subID
    case {'267','268', '269', '270'} % Airpuff expt
        StepNum = 3;
    case {'181','182','187','188', '159','161','180','186'} % Transference Experiment
        StepNum = 1;
    otherwise
        msPuff = 100;
end
end