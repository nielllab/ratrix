function msPuff = getPuffMS(subID)
switch subID
    case {'267','268','159','161','180','186'}
        msPuff = 0;
    case {'269','270','181','182','187','188'}
        msPuff = 0;
    otherwise
        msPuff = 100;
end
end
