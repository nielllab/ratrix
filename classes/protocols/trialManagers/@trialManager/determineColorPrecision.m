function [floatprecision finalScreenLuminance] = determineColorPrecision(tm, stim, finalScreenLuminance, verbose)
% This function determines the floatprecision and finalScreenLuminance of the trial.
% Part of stimOGL rewrite.
% INPUT: stim, finalScreenLuminance, verbose
% OUTPUT: floatprecision, finalScreenLuminance

if verbose
    disp(sprintf('stim class is %s',class(stim)));
end

floatprecision=0;
if isreal(stim) && strcmp(class(stim),class(finalScreenLuminance)) && isscalar(finalScreenLuminance)
    switch class(stim)
        case {'double','single'}
            if any([finalScreenLuminance; stim(:)]>1) || any([finalScreenLuminance; stim(:)]<0)
                error('stimor finalScreenLuminance had elements <0 or >1 ')
            else
                floatprecision=1;%will tell maketexture to use 0.0-1.0 format with 16bpc precision (2 would do 32bpc)
                % finalScreenLuminance=round(finalScreenLuminance*intmax('uint8')); what was point of this?
            end
        case 'uint8'
            %do nothing
        case 'uint16'
            stim=single(stim)/intmax('uint16');
            finalScreenLuminance=single(finalScreenLuminance)/intmax('uint16');
            floatprecision=1;
        case 'logical'
            stim=uint8(stim)*intmax('uint8'); %force to 8 bit
            finalScreenLuminance=finalScreenLuminance*intmax('uint8');
        otherwise
            error('unexpected stim variable class; currently stimOGL expects double, single, unit8, uint16, or logical')
    end
else
    stim
    finalScreenLuminance
    class(stim)
    class(finalScreenLuminance)
    isscalar(finalScreenLuminance)
    error('stim must be real, and type must match interTrialLuminance, and interTrialLuminance must be scalar')
end

end % end function