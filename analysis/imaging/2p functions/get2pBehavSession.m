
[f p] = uigetfile({'*.mat;*.sbx'},'.mat or .tif file');
if strcmp(f(end-3:end),'.mat')
    display('loading data')
    sessionName = fullfile(p,f);
    load(sessionName)
    display('done')

else
    
    fname = f(1:end-4)

display('reading data')
tic
[img framerate] = readAlign2p_sbx(fullfile(p,fname),1,1,0.5);
toc

greenframe = mean(img,3);
display('resizing')
tic
img = imresize(img,0.5,'box');
toc
display('doing mean')
tic
m = mean(double(img(:,:,40:40:end)),3);
toc

display('doing dfof')
tic
dfof=zeros(size(img));
for f = 1:size(img,3)
    dfof(:,:,f)=(double(img(:,:,f))-m)./m;
end
toc

display('temporal downsampling')
binsize=4
downsampleLength = binsize*floor(size(dfof,3)/binsize);
tic
dfof= downsamplebin(dfof(:,:,1:downsampleLength),3,binsize)/binsize;
toc

    global info
    stim = find( info.event_id ==2 | info.event_id==3);
    stim=stim(1:2:end); %%% scanbox records rising and falling edge;
    phasetimes = info.frame(stim)/framerate;

    nframes = size(dfof,3);
display('doing interp')  %%% interpolate at image frames corresponding to dt interval, making framerate = 60Hz
tic
im_dt = (1/framerate)*binsize;

dfofInterp = interp1(im_dt*(1:nframes),shiftdim(dfof,2),dt:dt:(im_dt*nframes));
dfofInterp = shiftdim(dfofInterp,1);

clear dfof img
 toc   
    
    [fs ps] = uiputfile('*.mat','session data');
    if fs~=0
        display('saving data')
        tic
sessionName= fullfile(ps,fs);
        if twocolor
            save(sessionName,'dfofInterp','cycLength','redframe','greenframe','-v7.3');
        else
            save(sessionName,'dfofInterp','framerate','dt','phasetimes','greenframe','-v7.3');
        end
        display('done')
        toc
    end
end
