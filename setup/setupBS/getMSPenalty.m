function msPenalty = getMSPenalty(subID)
switch subID
    case {'267'} % Airpuff expt
        msPenalty = 2000;
    case {'268'} % Airpuff expt
        msPenalty = 2000;
    case {'269'} % Airpuff expt
        msPenalty = 2000;
    case {'270'} % Airpuff expt
        msPenalty = 2000;
    case {'181'} % Transference Experiment
        msPenalty = 2000;
    case {'182','187','188'} % Transference Experiment
        msPenalty = 2000;
    case {'159','161','180','186'} % Airpuff with experience
        msPenalty = 2000;
    otherwise
        error('do not recognize rat for protocol')
end
end