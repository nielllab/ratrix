function [dfofInterp im_dt greenframe framerate phasetimes m dt] = get2pdata_sbx(fname,dt,cycLength,cfg);
%%% reads in 2p data and syncs with stimulus signals

%%% read in sbx data and perform motion correction (if not already done)
display('reading data')
tic
alignData=1; showImages=1;

[img framerate] = readAlign2p_sbx(fname,alignData,showImages);
toc

greenframe = prctile(img(:,:,25:25:end),10,3);  %%% keep mean raw fluorescence image


%%% spatial downsampling
display('resizing')
tic
img = imresize(img,1/cfg.spatialBin,'box');
toc

size(img)
%%% temporal binning, to improve SNR before interpolation
%%% a gaussian temporal filter might be better, but slow!
display('temporal downsampling')
binsize=cfg.temporalBin;
if binsize~=1
    downsampleLength = binsize*floor(size(img,3)/binsize);
    tic
    img= downsamplebin(img(:,:,1:downsampleLength),3,binsize)/binsize;  %%% downsamplebin based on patick mineault's code
    toc
else
    display('binsize ==1')
end


display('computing baseline')
tic
m = prctile(double(img(:,:,10:10:end)),10,3);
toc
%%% Yeti seems to have a large DC offset, even in blanks on edge of image
%%% Estimate this as minimum of mean image and subtract it off
dcOffset = 0.95*min(m(:));
m = m-dcOffset;
img = img-dcOffset;
greenframe=greenframe-dcOffset;

display('doing dfof')
tic
dfof=zeros(size(img));
for f = 1:size(img,3)
    dfof(:,:,f)=(double(img(:,:,f))-m)./m;
end
toc

%%% get sync triggers
global info
stim = find( info.event_id ==1 | info.event_id==3);
fr =(info.frame(stim) + info.line(stim)/796) /binsize; %%% get frame each trigger occured on,  add on fractio nbased on lineand correct for binning


nframes = size(dfof,3);
display('doing interp')  %%% interpolate at image frames corresponding to dt interval, making stim framerate = 60Hz

im_dt = (1/framerate)*binsize; %%% 2p sample interval after binning


if cfg.syncToVid
    dt = cfg.dt;  %%% desired 2p sample interval
    df = dt*60;    %%% desired 2p sample interval in terms of stimulus frames (typical == 15_
    fr = fr(round(df/2):df:end); %%% get 2p frames when desired stimulus intervals occured
    fr=fr(fr<nframes);
    
    tic
    dfofInterp = interp1(1:nframes,shiftdim(dfof,2),fr);
    dfofInterp = shiftdim(dfofInterp,1);
    toc
    
    %%% second trigger line
    %%%either beginning of each stim, or (more importantly) phases for behavior
    
    phasesync = find( info.event_id ==2 | info.event_id==3); %%% get phase trigger signals
    phasesync=phasesync(1:2:end); %%% scanbox records rising and falling edge;
    for i = 1:length(phasesync);
        phasetimes(i)= max(find(stim<=phasesync(i)+2))/60;  %%% find frame trigger that occurred right before this, and convert to time bsed on stim framerate (60Hz) // need offset of two since phase trigger goes up/down before
    end
    
else %%% leave timing intact and adjust video stim times to acq rate
    
    dt = 1/(framerate*binsize);   %%% keep dt as the actual acquired framerate
    dfofInterp = dfof;
    
    phasesync = info.frame(find( info.event_id ==2 | info.event_id==3))/binsize; %%% get phase trigger signals
    phasesync=phasesync(1:2:end); %%% scanbox records rising and falling edge;
    phasetimes = phasesync*dt; %%% convert to frame time (dt)
    
end




