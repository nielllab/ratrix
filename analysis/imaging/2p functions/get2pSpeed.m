function spInterp = get2pSpeed(stimRec,dt,nframes);
% extracts optical mouse speed from stimRec
% stimRec = stimRec variable from stim_obj.mat file
% dt = time interval for 2p frames (usually 0.1 sec);
% nframes = number of frames in 2p movie
% spInterp = calculated average speed (in pixels) at each 2p frame
% length of spInterp is matched to nframes, if longer it's clipped, if shorter it's padded with NaNs 
% (often will be one frame short since calculating a speed requires diff)

posx = cumsum(stimRec.pos(:,1)-900);
posy = cumsum(stimRec.pos(:,2)-500);

dFrames = round(60*dt);
vx = diff(interp1(1:length(posx),posx,1:dFrames:length(posx)));
vy = diff(interp1(1:length(posy),posy,1:dFrames:length(posx)));

sp = sqrt(vx.^2 + vy.^2);
figure
plot(sp);

if length(sp)<nframes
    spInterp = zeros(1,nframes) + NaN;
    spInterp(1:length(sp))=sp;
else
    spInterp = sp(1:nframes);
end
