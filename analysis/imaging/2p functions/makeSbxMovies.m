[f p] = uigetfile({'*.sbx'},'sbx file');
fname = fullfile(p,f)

spatialBin = input('spatial binning factor: ');
temporalBin = input('temporal binning factor: ');
fullMovie = input('make full movie? (0/1) :');
cycMovie = input('make cycle avg movie? (0/1) :');
if cycMovie
    cycLength =input('cycle length (secs) :');
end
framerate = input('framerate :');



%%% read in sbx data and perform motion correction (if not already done)
display('reading data')
tic
alignData=1; showImages=1;

[img framerate] = readAlign2p_sbx(fname(1:end-4),alignData,showImages);
toc


%%% spatial downsampling
display('resizing')
tic
img = imresize(img,1/spatialBin,'box');
toc

%%% temporal binning, to improve SNR before interpolation
%%% a gaussian temporal filter might be better, but slow!
display('temporal downsampling')
binsize=temporalBin;
downsampleLength = binsize*floor(size(img,3)/binsize);
tic
img= downsamplebin(img(:,:,1:downsampleLength),3,binsize)/binsize;  %%% downsamplebin based on patick mineault's code
toc

d = img(5:5:end,5:5:end,5:5:end);
figure
hist(d(:),100);
lb = input('lower limit on range: ');
ub = input('upper limit on range: ');

if fullMovie
    display('converting to movie')
    cycMov= mat2im(img,gray,[lb ub]);
    mov = immovie(permute(cycMov,[1 2 4 3]));
    vid = VideoWriter([fname(1:end-4) '_FULL.avi']);
    vid.FrameRate=framerate;
    open(vid);
    display('writing movie')
    writeVideo(vid,mov);
    close(vid)
end

if cycMovie
    
    global info
    stim = find( info.event_id ==1 | info.event_id==3);
    fr =(info.frame(stim)/binsize); %%% get frame each trigger occured on, and correct for binning
    
    nframes = size(img,3);
    display('doing interp')  %%% interpolate at image frames corresponding to dt interval, making stim framerate = 60Hz
    
    im_dt = (1/framerate)*binsize; %%% 2p sample interval after binning
    dt =0.25;  %%% desired 2p sample interval
    df = dt*60;    %%% desired 2p sample interval in terms of stimulus frames (typical == 15_
    fr = fr(round(df/2):df:end); %%% get 2p frames when desired stimulus intervals occured
    fr=fr(fr<nframes);
    
    tic
    imgInterp = interp1(1:nframes,shiftdim(img,2),fr);
    imgInterp = shiftdim(imgInterp,1);
    toc
    
    frms = cycLength/dt;
    clear cycAvg
    for f = 1:frms
        cycAvg(:,:,f) = mean(imgInterp(:,:,f:frms:end),3);
    end
    
    cycMov= mat2im(cycAvg,gray,[lb ub]);
    mov = immovie(permute(cycMov,[1 2 4 3]));
    vid = VideoWriter([fname(1:end-4) '_cycAvg.avi']);
    vid.FrameRate=20;
    open(vid);
    display('writing movie')
    writeVideo(vid,mov);
    close(vid)
    
end