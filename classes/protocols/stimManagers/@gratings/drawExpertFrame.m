function [doFramePulse expertCache dynamicDetails textLabel i dontclear] = ...
    drawExpertFrame(stimulus,stim,i,phaseStartTime,window,textLabel,destRect,filtMode,...
    expertCache,ifi,scheduledFrameNum,dropFrames,dontclear)
% 11/14/08 - implementing expert mode for gratings
% this function calculates an expert frame, and then makes and draws the texture; nothing needs to be done in runRealTimeLoop
% this should be a stimManager-specific implementation (if expert mode is supported for the given stimulus)

floatprecision=1;



% increment i
if dropFrames
    i=scheduledFrameNum;
else
    i=i+1;
end
% stimulus = stimManager

doFramePulse=true;
dynamicDetails=[];
% expertCache should contain masktexs and annulitexs
if isempty(expertCache)
    expertCache.masktexs=[];
    expertCache.annulitexs=[];
end
% ================================================================================
% start calculating frames now
numGratings = length(stim.pixPerCycs); % number of gratings
% find which grating we are supposed to draw
gratingInds = cumsum(stim.durations(:));
gratingToDraw = min(find(mod(i-1,gratingInds(end))+1<=gratingInds));

% stim.pixPerCycs - frequency of the grating (how wide the bars are)
% stim.orientations - angle of the grating
% stim.driftfrequencies - frequency of the phase (how quickly we go through a 0:2*pi cycle of the sine curve) - in cycles per second
% stim.locations - where to center each grating (modifies destRect)
% stim.contrasts - contrast of the grating
% stim.durations - duration of each grating (in frames)
% stim.masks - the masks to be used (empty if unmasked)
% stim.annuliMatrices - the annuli to be used

black=0.0;
% white=stim.contrasts(gratingToDraw);
white=1.0;
gray = (white-black)/2;

%stim.velocities(gratingToDraw) is in cycles per second
cycsPerFrameVel = stim.driftfrequencies(gratingToDraw)*ifi; % in units of cycles/frame
offset = 2*pi*cycsPerFrameVel*i;

% Create a 1D vector x based on the frequency pixPerCycs
% make the grating twice the normal width (to cover entire screen if rotated)
x = (1:stim.width*2)*2*pi/stim.pixPerCycs(gratingToDraw);
grating=stim.contrasts(gratingToDraw)*cos(x + offset+stim.phases(gratingToDraw))+stimulus.mean; % grating is the cos curve, with our calculated phase offset (based on driftfrequency) and initial phase
% grating=repmat(grating, [1 2]); 
% Make grating texture
gratingtex=Screen('MakeTexture',window,grating,0,0,floatprecision);

% set srcRect
srcRect=[0 0 size(grating,2) 1];

% Draw grating texture, rotated by "angle":
destWidth = destRect(3)-destRect(1);
destHeight = destRect(4)-destRect(2);
destRectForGrating = [destRect(1)-destWidth/2, destRect(2)-destHeight, destRect(3)+destWidth/2,destRect(4)+destHeight];
Screen('DrawTexture', window, gratingtex, srcRect, destRectForGrating, ...
    (180/pi)*stim.orientations(gratingToDraw), filtMode);

if ~isempty(stim.masks)
    % Draw gaussian mask over grating: We need to subtract 0.5 from
    % the real size to avoid interpolation artifacts that are
    % created by the gfx-hardware due to internal numerical
    % roundoff errors when drawing rotated images:
    % Make mask to texture
%     texsize=1024;
%     mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
%     [x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
%     mask(:, :, 2)=white * (1 - exp(-((x/90).^2)-((y/90).^2)));
%     grating=repmat(grating, [stim.height 1]).*stim.mask;
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % necessary to do the transparency blending
    if isempty(expertCache.masktexs)
        expertCache.masktexs=cell(1,length(unique(stim.maskInds)));
    end
    if isempty(expertCache.masktexs{stim.maskInds(gratingToDraw)})
        expertCache.masktexs{stim.maskInds(gratingToDraw)} = ...
            Screen('MakeTexture',window,stim.masks{stim.maskInds(gratingToDraw)},0,0,floatprecision);
    end

    if isempty(expertCache.annulitexs)
        expertCache.annulitexs=cell(1,length(unique(stim.annuliInds)));
    end
    if isempty(expertCache.annulitexs{stim.annuliInds(gratingToDraw)})
        expertCache.annulitexs{stim.annuliInds(gratingToDraw)}=...
            Screen('MakeTexture',window,double(stim.annuliMatrices{stim.annuliInds(gratingToDraw)}),...
            0,0,floatprecision);
    end
    % Draw mask texture: (with no rotation)
    Screen('DrawTexture', window, expertCache.masktexs{stim.maskInds(gratingToDraw)}, [], destRect,[], filtMode);
    Screen('DrawTexture',window,expertCache.annulitexs{stim.annuliInds(gratingToDraw)},[],destRect,[],filtMode);
end


inspect=0;
if inspect & i>3
    [oldmaximumvalue oldclampcolors] = Screen('ColorRange', window)
    x=Screen('getImage', window)
    tx=Screen('getImage', gratingtex)
    unique(tx(:)')
    figure; hist(double(tx(:)'),200)
    figure; imagesc(tx); % what is this? mean up front and then black heavy grating?
     unique(tx(:)')
    figure; hist(double(tx(:)'),200)
    sca
    keyboard
end


% clear the gratingtex from vram
Screen('Close',gratingtex);


end % end function