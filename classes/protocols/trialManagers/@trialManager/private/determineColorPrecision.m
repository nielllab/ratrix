function [floatprecision stim finalScreenLuminance] = determineColorPrecision(tm, stim, verbose, strategy, finalScreenLuminance)
% This function determines the floatprecision and finalScreenLuminance of the trial.
% Part of stimOGL rewrite.
% INPUT: stim, verbose, strategy, finalScreenLuminance
% OUTPUT: floatprecision, stim, finalScreenLuminance

if verbose
    disp(sprintf('stim class is %s',class(stim)));
end

% 10/31/08 - handle expert mode (floatprecision should be specified as a field in stim)
if ~isempty(strategy) && strcmp(strategy, 'expert')
    floatprecision = stim.floatprecision;
else % non expert - calculate floatprecision
    floatprecision=0;
    if isreal(stim) && isreal(finalScreenLuminance)
        switch class(stim)
            case {'double','single'}
                if any(stim(:)>1) || any(stim(:)<0)
                    error('stim had elements <0 or >1 ') % 10/23/08 - to allow whiteNoise
                else
                    floatprecision=1;%will tell maketexture to use 0.0-1.0 format with 16bpc precision (2 would do 32bpc)
                end
            case 'uint8'
                %do nothing
            case 'uint16'
                stim=single(stim)/intmax('uint16');
                floatprecision=1;
            case 'logical'
                stim=uint8(stim)*intmax('uint8'); %force to 8 bit
            otherwise
                error('unexpected stim variable class; currently stimOGL expects double, single, unit8, uint16, or logical')
        end
    else
        stim       
        class(stim)
        finalScreenLuminance
        class(finalScreenLuminance)
        error('stim and finalScreenLuminance must be real')
    end
end

end % end function