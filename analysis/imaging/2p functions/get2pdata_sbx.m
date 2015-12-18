function [dfofInterp im_dt greenframe framerate] = get2pdata_sbx(fname,dt,cycLength);
display('reading data')
tic
[img framerate] = readAlign2p_sbx(fname,1,1,0.5);
toc

greenframe = mean(img,3);
display('resizing')
tic
img = imresize(img,0.5,'box');
toc
display('doing prctile')
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

display('downsampling')
binsize=4
downsampleLength = binsize*floor(size(dfof,3)/binsize);
tic
dfof= downsamplebin(dfof(:,:,1:downsampleLength),3,binsize)/binsize;
toc

    global info
    stim = find( info.event_id ==1 | info.event_id==3);
    fr =(info.frame(stim)/binsize);

nframes = size(dfof,3);
display('doing interp')  %%% interpolate at image frames corresponding to dt interval, making framerate = 60Hz
tic
im_dt = (1/framerate)*binsize;
dt = 0.25;
df = dt*60;
fr = fr(round(df/2):df:end);
fr=fr(fr<nframes);
figure
plot(diff(fr))
ylabel('interp #')

dfofInterp = interp1(1:nframes,shiftdim(dfof,2),fr);
dfofInterp = shiftdim(dfofInterp,1);
toc