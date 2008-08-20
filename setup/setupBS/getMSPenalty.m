function msPenalty = getMSPenalty(subID)
switch subID
    case {'267','268', '269', '270'} % Airpuff expt
        msPenalty = 2000;
    case {'181','182','187','188'} % Transference Experiment
        msPenalty = 8000;
    case {'159','161','180','186'} % Airpuff with experience
        msPenalty = 2000;
    otherwise
        error('do not recognize rat for protocol')
end
end