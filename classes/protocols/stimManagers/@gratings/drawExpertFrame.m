function [doFramePulse masktex] = drawExpertFrame(stimulus,stim,i,window,floatprecision,destRect,filtMode,masktex)
% 11/14/08 - implementing expert mode for gratings
% this function calculates an expert frame, and then makes and draws the texture; nothing needs to be done in runRealTimeLoop
% this should be a stimManager-specific implementation (if expert mode is supported for the given stimulus)

% stimulus = stimManager
doFramePulse=true;
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
% stim.mask - the mask to be used (empty if unmasked)

black=0.0;
% white=stim.contrasts(gratingToDraw);
white=1.0;
gray = (white-black)/2;

%stim.velocities(gratingToDraw) is in cycles per second
ifi=Screen('GetFlipInterval', window);
cycsPerFrameVel = stim.driftfrequencies(gratingToDraw)*ifi; % in units of cycles/frame
offset = 2*pi*cycsPerFrameVel*i;

% Create a 1D vector x based on the frequency pixPerCycs
% make the grating twice the normal width (to cover entire screen if rotated)
x = (1:stim.width*2)*2*pi/stim.pixPerCycs(gratingToDraw);
grating=stim.contrasts(gratingToDraw)*cos(x + offset+stim.phases(gratingToDraw)); % grating is the cos curve, with our calculated phase offset (based on driftfrequency) and initial phase
% grating=repmat(grating, [1 2]); 
% Make grating texture
gratingtex=Screen('MakeTexture',window,grating,0,0,floatprecision);

% set srcRect
% srcRect=[0 0 stim.width 1];
% srcRect=[2 512 3 1536];
srcRect=[0 0 size(grating,2) 1];
% srcRect = [512 2 600 3];

% Draw grating texture, rotated by "angle":
destWidth = destRect(3)-destRect(1);
destHeight = destRect(4)-destRect(2);
destRectForGrating = [destRect(1)-destWidth/2, destRect(2)-destHeight, destRect(3)+destWidth/2,destRect(4)+destHeight];
Screen('DrawTexture', window, gratingtex, srcRect, destRectForGrating, ...
    (180/pi)*stim.orientations(gratingToDraw), filtMode);
% Screen('DrawTexture', window, gratingtex, srcRect, destRect, 30, filtMode,[],[],[],sflags);

% shift grating by "shiftperframe" pixels per frame
% waitduration=Screen('GetFlipInterval', window);
% if i==1
%     waitduration
% end
% shiftperframe= stim.velocities(gratingToDraw) * stim.pixPerCycs(gratingToDraw) * waitduration; % in pixels per frame
% k=mod(i-1,gratingInds(gratingToDraw));
% xoffset = mod(k*shiftperframe,stim.pixPerCycs(gratingToDraw));
% srcRect=[xoffset 0 xoffset+stim.width 1];

% % Create one single static grating image:
% [x,y]=meshgrid(-texsize:texsize + stim.pixPerCycs(gratingToDraw), -texsize:texsize);
% grating=gray + (stim.contrasts(gratingToDraw)/2)*cos(2*pi*x/stim.pixPerCycs(gratingToDraw));
% % Store grating in texture:
% gratingtex=Screen('MakeTexture',window,grating,0,0,floatprecision);
%     
% % Shift the grating by "shiftperframe" pixels per frame:
% ifi=Screen('GetFlipInterval', window);
% shiftperframe = ifi*stim.velocities(gratingToDraw)*stim.pixPerCycs(gratingToDraw);
% k=mod(i-1,gratingInds(gratingToDraw));
% xoffset = mod(k*shiftperframe,stim.pixPerCycs(gratingToDraw));
% 
% % Define shifted srcRect that cuts out the properly shifted rectangular
% % area from the texture:
% srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
        

% Screen('DrawTexture', window, gratingtex, [], destRect, stim.orientations(gratingToDraw), filtMode);

if ~isempty(stim.mask)
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
    if isempty(masktex)
        masktex = Screen('MakeTexture',window,stim.mask,0,0,floatprecision);
    end
    % Draw mask texture: (with no rotation)
    Screen('DrawTexture', window, masktex, [], destRect,[], filtMode);
end;



% [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('srcRect %d %d %d %d',srcRect(1),srcRect(2),srcRect(3),srcRect(4)),...
%     100,150,100*ones(1,3));
% % 
% [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('destRect: %d %d %d %d',destRect(1),destRect(2),destRect(3),destRect(4)),...
%     100,250,100*ones(1,3));

% 11/14/08 - moved the make and draw to stimManager specific getExpertFrame b/c they might draw differently
% dynTex = Screen('MakeTexture', window, expertFrame,0,0,floatprecision);
% Screen('DrawTexture', window, dynTex,[],destRect,[],filtMode);

end % end function