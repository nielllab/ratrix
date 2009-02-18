function textures = cacheTextures(tm, strategy, stim, window, floatprecision, verbose)

% This function precaches all textures for the given stimulus using Screen('MakeTexture') and Screen('PreloadTextures').
% Note that if finalScreenLuminance is blank (ie for phased stim), then it does not get loaded as a texture

if ~(ischar(strategy) && strcmp(strategy,'expert')) && (floatprecision~=0 || ~strcmp(class(stim),'uint8')) % only in non-expert mode
    error('expects floatprecision to be 0 and stim to be uint8 so that maketexture is fast')
end

textures=[];

switch strategy
    case 'textureCache'
        %load all frame caches into VRAM
        
        if ~isempty(stim) % necessary because size([],3)==1 stupidly enough
            textures=zeros(1,size(stim,3));
            for i=1:size(stim,3)
                if window>=0
                    textures(i)=Screen('MakeTexture', window, squeeze(stim(:,:,i)),0,0,floatprecision); %ned floatprecision=0 for remotedesktop
                end
            end
        end
        
        if window>=0
            [resident texidresident] = Screen('PreloadTextures', window);
            
            if resident ~= 1
                disp(sprintf('error: some textures not cached'));
                find(texidresident~=1)
            end
        end
        if verbose
            disp(sprintf('took %g to load textures',toc)); %no corresponding tic?
        end
        
    case 'noCache'
        %pass
    case 'expert'
        % 10/31/08 - in our implementation of dynamic mode, 'stim' should have all parameters necessary to do on-the-fly drawing
        % no caching of textures should happen
    otherwise
        error('unrecognized strategy')
end



end % end function