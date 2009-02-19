function [floatprecision stim] = determineColorPrecision(tm, stim, strategy)

% 10/31/08 - handle expert mode (floatprecision should be specified as a field in stim)
if ~isempty(strategy) && strcmp(strategy, 'expert')
    floatprecision = stim.floatprecision;
else % non expert - calculate floatprecision
    floatprecision=0;
    if isreal(stim)
        switch class(stim)
            case {'double','single'}
                if any(stim(:)>1) || any(stim(:)<0)
                    error('stim had elements <0 or >1 ') % 10/23/08 - to allow whiteNoise
                else
                    floatprecision=1;%will tell maketexture to use 0.0-1.0 format with 16bpc precision (2 would do 32bpc)
                end

                %edf thinks maketexture will barf if we try to send it singles
                if strcmp(class(stim),'single')
                    stim=double(stim);
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
        error('stim  must be real')
    end

    % only do this if non-expert mode % 2/17/09 - fli
    if floatprecision ~=0 || ~strcmp(class(stim),'uint8')
        %convert stim/floatprecision to uint8 so when
        %drawFrameUsingTextureCache calls maketexture it is fast
        %(especially when strategy is noCache and we make each texture
        %during each frame)
        floatprecision=0;
        stim=uint8(stim*double(intmax('uint8')));
    end
end

end % end function