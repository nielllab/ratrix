function [textures, numDots, dotX, dotY, dotLocs, dotSize, dotCtr] ...
  = cacheTextures(tm, strategy, stim, window, floatprecision, verbose)
% This function precaches all textures for the given stimulus using Screen('MakeTexture') and Screen('PreloadTextures').
% Note that if finalScreenLuminance is blank (ie for phased stim), then it does not get loaded as a texture
% Part of stimOGL rewrite.
% INPUT: strategy, stim, window, floatprecision, verbose
% OUTPUT: textures, numDots, dotX, dotY, dotLocs, dotSize, dotCtr

numDots = [];
dotX = [];
dotY = [];
dotLocs = [];
dotSize = [];
dotCtr = [];
textures=[];

tic
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
        
    case 'expert'
        % 10/31/08 - in our implementation of dynamic mode, 'stim' should have all parameters necessary to do on-the-fly drawing
        % no caching of textures should happen
%         numDots = size(stim,1)*size(stim,2);
%         [dotX dotY] = meshgrid(1:size(stim,1),1:size(stim,2));
%         dotLocs = [dotX(1:numDots);dotY(1:numDots)];
%         dotSize = 1;
%         dotCtr = [destRect(3)-destRect(1) destRect(4)-destRect(2)]/2;

    otherwise
        error('unrecognized strategy')
end

if window>=0
%     if ~isempty(finalScreenLuminance)  % only add finalScreenLuminance if it is nonempty
%         textures(size(stim,3)+1)=Screen('MakeTexture', window, finalScreenLuminance,0,0,floatprecision);
%     end
    [resident texidresident] = Screen('PreloadTextures', window);

    if resident ~= 1
        disp(sprintf('error: some textures not cached'));
        find(texidresident~=1)
    end
end
if verbose
    disp(sprintf('took %g to load textures',toc));
end

end % end function