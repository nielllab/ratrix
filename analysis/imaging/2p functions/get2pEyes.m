function [eyeAlign] = get2pEyes(fname,syncToVid,dt);
%%% analyzes pupil position/size and syncs with 2p frames
%%% syncToVid aligns with visual stim frames (for passive stim), 
%%% otherwise leaves timing intact (for behavior stim)
%%% dt is final frame interval (for syncToVid only)


load(fname,'eye');
if ~exist('eye','var')
    display('getting eyes')
    tic
    eye = sbxeyemotion(fname);
    toc
end
load(fname,'Area','Centroid');

%%% eyes are sampled at twice framerate
n = 2*floor(size(Area,1)/2);
Area = downsamplebin(Area(1:n,:),1,2)/2;
Centroid = downsamplebin(Centroid(1:n,:),1,2)/2;

fname(1:end-8)
try
    load(fname(1:end-8),'info');
catch
     load(fname(1:end-4),'info');
end
     binsize=1;

%%% perform same sync as get2pdata_sbx

framerate = info.resfreq/info.config.lines;
stim = find( info.event_id ==1 | info.event_id==3);
fr =(info.frame(stim) + info.line(stim)/796) /binsize; %%% get frame each trigger occured on,  add on fractio nbased on lineand correct for binning


nframes = length(eye);
display('doing interp')  %%% interpolate at image frames corresponding to dt interval, making stim framerate = 60Hz

im_dt = (1/framerate)*binsize; %%% 2p sample interval after binning

if syncToVid

    df = dt*60;    %%% desired 2p sample interval in terms of stimulus frames (typical == 15_
    fr = fr(round(df/2):df:end); %%% get 2p frames when desired stimulus intervals occured
    fr=fr(fr<nframes);
    
    tic
    eyeAlign(:,1) = interp1(1:length(Centroid),Centroid(:,1),fr);
    eyeAlign(:,2) = interp1(1:length(Centroid),Centroid(:,2),fr);
    a = interp1(1:length(Centroid),Area,fr);
    eyeAlign(:,3) = sqrt(a)/pi;
    toc
    
    
else %%% leave timing intact and adjust video stim times to acq rate
    
    eyeAlign(:,1) = Centroid(:,1);
    eyeAlign(:,2) = Centroid(:,2);
    eyeAlign(:,3) = sqrt(Area)/pi;
    
end