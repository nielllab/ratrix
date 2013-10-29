function textures = cacheTextures(tm, strategy, stim, window, floatprecision)

% Note that if finalScreenLuminance is blank (ie for phased stim), then it does not get loaded as a texture

if ~(ischar(strategy) && strcmp(strategy,'expert')) && (floatprecision~=0 || ~strcmp(class(stim),'uint8'))
    error('expects floatprecision to be 0 and stim to be uint8 so that maketexture is fast')
end

textures=[];

switch strategy
    case 'textureCache'
        %load all frames into VRAM
        
        if ~isempty(stim) % necessary because size([],3)==1 stupidly enough
            textures=zeros(1,size(stim,3));
            for i=1:size(stim,3)
                if window>=0
                    textures(i)=Screen('MakeTexture', window, squeeze(stim(:,:,i)),0,0,floatprecision); %need floatprecision=0 for remotedesktop
                end
            end
        end
        
        if window>=0
            
            if false
                % actually not recommended (tho doc makes it sound like a good idea)
                % http://tech.groups.yahoo.com/group/psychtoolbox/message/9165
                [resident texidresident] = Screen('PreloadTextures', window);
                
                if resident ~= 1
                    fprintf('error: some textures not cached');
                    find(texidresident~=1)
                end
            end
        end
        
    case 'noCache'
        %pass
    case {'expert','dynamic'}
        % no caching of textures should happen
    otherwise
        error('unrecognized strategy')
end

end % end function