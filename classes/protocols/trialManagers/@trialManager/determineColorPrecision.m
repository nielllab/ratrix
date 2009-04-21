function [floatprecision stim] = determineColorPrecision(tm, stim, strategy)

if ~isempty(strategy) && strcmp(strategy, 'expert')
    floatprecision = []; % no default floatprecision for expert mode - override during drawExpertFrame or will throw error
else
    switch tm.displayMethod
        case 'ptb'
            floatprecision=0;
            if isreal(stim)
                switch class(stim)
                    case {'double','single'}
                        if any(stim(:)>1) || any(stim(:)<0)
                            error('stim had elements <0 or >1 ')
                        else
                            floatprecision=1;%will tell maketexture to use 0.0-1.0 format with 16bpc precision (2 would do 32bpc)
                        end
                        
                        %maketexture barfs on singles
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
            
            if floatprecision ~=0 || ~strcmp(class(stim),'uint8')
                %convert stim/floatprecision to uint8 so when drawFrameUsingTextureCache calls maketexture it is fast
                %(especially when strategy is noCache and we make each texture during each frame)
                floatprecision=0;
                warning('off','MATLAB:intConvertNonIntVal')
                stim=uint8(stim*double(intmax('uint8')));
                warning('on','MATLAB:intConvertNonIntVal')
            end
        case 'LED'
            floatprecision=1;
      
            
            if isreal(stim)
                switch class(stim)
                    case {'double','single'}
                        if any(stim(:)>1) || any(stim(:)<0)
                            error('stim had elements <0 or >1 ')
                        end
                    case 'uint8'
                        stim=single(stim)/intmax('uint8');
                    case 'uint16'
                        stim=single(stim)/intmax('uint16');
                    case 'logical'
                        stim=single(stim);
                    otherwise
                        error('unexpected stim variable class; currently stimOGL expects double, single, unit8, uint16, or logical')
                end
            else
                stim
                class(stim)
                error('stim  must be real')
            end
            
            
        otherwise
            tm.displayMethod
            error('bad displayMethod')
    end
end

end % end function