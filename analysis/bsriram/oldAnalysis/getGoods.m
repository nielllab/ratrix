function o = getGoods(d,removeWhat)
% removes manual kills and freeDrinks objects


switch removeWhat
    case 'RemFD'
        fDs = strcmp({d.trialtype},'freeDrinks');
        toKeep = ~(logical(fDs));
    case 'RemMK'
        mKs = strcmp({d.response},'manual kill');
        toKeep = ~(logical(mKs));
    case 'RemAll'
        fDs = strcmp({d.trialtype},'freeDrinks');
        mKs = strcmp({d.response},'manual kill');
        toKeep = ~(logical(fDs+mKs));
    case 'RemCorr'
        isCorrs = [d.correction];
        toKeep = ~(logical(isCorrs));
end
o = d(toKeep);
end
