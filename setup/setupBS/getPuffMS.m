function msPuff = getPuffMS(subID)
switch subID
    case {'267','268'}
        msPuff = 100;
    case {'269','270'}
        msPuff = 0;
    otherwise
        msPuff = 100;
end
end
