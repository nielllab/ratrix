function [dfofInterp im_dt greenframe framerate] = get2pdata_sbx(fname,dt,cycLength,cfg);
%%% reads in 2p data and syncs with stimulus signals

%%% read in sbx data and perform motion correction (if not already done)
display('reading data')
tic
alignData=1; showImages=1;
[img framerate] = readAlign2p_sbx(fname,alignData,showImages);
toc

greenframe = prctile(img,10,3);  %%% keep mean raw fluorescence image


%%% spatial downsampling
display('resizing')
tic
img = imresize(img,1/cfg.spatialBin,'box');
toc

%%% temporal binning, to improve SNR before interpolation
%%% a gaussian temporal filter might be better, but slow!
display('temporal downsampling')
binsize=cfg.temporalBin;
downsampleLength = binsize*floor(size(dfof,3)/binsize);
tic
img= downsamplebin(img(:,:,1:downsampleLength),3,binsize)/binsize;  %%% downsamplebin based on patick mineault's code
toc

display('computing baseline')
tic
m = prctile(double(img(:,:,10:10:end)),10,3);
toc
%%% Yeti seems to have a large DC offset, even in blanks on edge of image
%%% Estimate this as minimum of mean image and subtract it off
dcOffset = min(m(:))*0.95;
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
    fr =(info.frame(stim)/binsize); %%% get frame each trigger occured on, and correct for binning
  
nframes = size(dfof,3);
display('doing interp')  %%% interpolate at image frames corresponding to dt interval, making stim framerate = 60Hz

im_dt = (1/framerate)*binsize; %%% 2p sample interval after binning
dt = cfg.dt;  %%% desired 2p sample interval
df = dt*60;    %%% desired 2p sample interval in terms of stimulus frames (typical == 15_
fr = fr(round(df/2):df:end); %%% get 2p frames when desired stimulus intervals occured
fr=fr(fr<nframes);

tic
dfofInterp = interp1(1:nframes,shiftdim(dfof,2),fr);
dfofInterp = shiftdim(dfofInterp,1);
toc