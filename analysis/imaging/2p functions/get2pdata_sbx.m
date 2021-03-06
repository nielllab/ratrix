function [dfofInterp im_dt greenframe framerate phasetimes m dt vidframetimes] = get2pdata_sbx(fname,dt,cycLength,cfg);
%%% reads in 2p data and syncs with stimulus signals

global S2P

%%% read in sbx data and perform motion correction (if not already done)
display('reading data')
tic
alignData=cfg.alignData; showImages=1;

[img framerate] = readAlign2p_sbx(fname,alignData,showImages);
toc
size(img)

%greenframe = prctile(img(:,:,25:25:end),10,3);  %%% keep mean raw fluorescence image
greenframe = median(img(:,:,25:25:end),3); % was 10th percentile, changed to median to avoid zeros

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
% tic
% m = prctile(double(img(:,:,3:3:end)),10,3);  %%% changed to median - cmn 072119
% toc
tic
m = median(double(img(:,:,3:3:end)),3);  %%% change to median
toc

%%% Yeti seems to have a large DC offset, even in blanks on edge of image
%%% Estimate this as minimum of mean image and subtract it off

figure
imagesc(m);
title('baseline image')

dcOffset = 0.95*min(m(:));
dcOffset = 0; %%% not a major issue since scanbox upgrade. and dcOffset subtraction creates a lot of noise in dark regions, esp after swtich to median baseline (which creates higher dcOffset)
m = m-dcOffset;
img = img-dcOffset;
greenframe=greenframe-dcOffset;

figure
imagesc(m);
title('baseline image after dcOffset')

sprintf('dcOffset = %0.2f',dcOffset)

if (exist('S2P','var')&S2P==1)
    dfof = double(img);
else
    display('doing dfof')
    tic
    dfof=zeros(size(img));
    for f = 1:size(img,3)
        dfof(:,:,f)=(double(img(:,:,f))-m)./m;
    end
    toc
end

%%% get sync triggers
%%% info on scanbox triggers here
%%% https://scanbox.org/2014/06/09/scanbox-system-integration/
%%% event_id==1, TTL0 (just rising edge)
%%% event_id==2, TTL1 (rising and falling)
%%% event_id==3, both
global info
TTL0 = 1; TTL1 = 2; TTLboth =3;

%%% new TTL format, contains both rising and falling
%%% bit 0 = TTL0 rise; bit 1 = TTL0 fall; bit 2 = TTL1 rise; bit 3 = TTL1 fall


if max(info.event_id)>3 %%% new TTL format
    info.event_id(info.event_id==1) = TTL0; %%% TTL0 rising
    info.event_id(info.event_id ==4 | info.event_id==8)=TTL1; %%% TTL1 rising or falling
    info.event_id(info.event_id ==5 | info.event_id==9)=TTLboth; %%% TTL0 rising + TTL 1 rising/falling
end
    
stim = find( info.event_id ==TTL0 | info.event_id==TTLboth);
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
    
    phasesync = find( info.event_id ==TTL1 | info.event_id==TTLboth); %%% get phase trigger signals
    phasesync=phasesync(1:2:end); %%% scanbox records rising and falling edge;
    for i = 1:length(phasesync);
        phasetimes(i)= max(find(stim<=phasesync(i)+2))/60;  %%% find frame trigger that occurred right before this, and convert to time bsed on stim framerate (60Hz) // need offset of two since phase trigger goes up/down before
    end
    vidframetimes = [];
    
else %%% leave timing intact and adjust video stim times to acq rate
    
    dt = 1/(framerate*binsize);   %%% keep dt as the actual acquired framerate
    dfofInterp = dfof;
    
    phasesync = find( info.event_id ==TTL1 | info.event_id==TTLboth); %%% get phase trigger signals
   % phasesync = find( info.event_id ==2);
    if info.frame(phasesync(1))==0  %%% something funny happens at start giving transition on first frame
        phasesync = phasesync(2:end);
    end
    phasesync=phasesync(1:2:end); %%% scanbox records rising and falling edge;
    %%phasetimes = phasesync*dt; %%% convert to frame time (dt)
    fr =(info.frame(phasesync) + info.line(phasesync)/796) /binsize; %%% get frame each trigger occured on,  add on fractio nbased on lineand correct for binning
    phasetimes = fr*dt; 
    
    frsync =  find( info.event_id ==TTL0 | info.event_id==TTLboth);
    fr = (info.frame(frsync) + info.line(frsync)/796) /binsize;
    vidframetimes = fr*dt;

end

if (exist('S2P','var')&S2P==1)
    sprintf('exporting to tif')
    sess = ['S2P\' fname(end)];
    mkdir(sess);
    for i = 1:size(dfofInterp,3)
        q = uint16(round(dfofInterp(:,50:750,i)));
        imwrite(q,fullfile(sess,[fname sprintf('_%05d.tif',i)]),'tif');
    end
end

