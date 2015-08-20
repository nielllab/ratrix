function [dfofInterp im_dt greenframe framerate] = get2pdata_sbx(fname,dt,cycLength);
[img framerate] = readAlign2p_sbx(fname,1,1,0.5);
nframes = size(img,3);

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
for f = 1:nframes
    dfof(:,:,f)=(double(img(:,:,f))-m)./m;
end
toc

f = fspecial('gaussian',3,0.1)
display(' filtering')
tic
for i =1:3
    filt(:,:,i) = f;
end
filt = filt/sum(filt(:));
dfof = convn(dfof,filt,'same');
toc

display('doing interp')
tic
im_dt = 1/framerate;
dt = 0.25;
dfofInterp = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(dfof,2),0:dt:(nframes-1)*im_dt);
dfofInterp = shiftdim(dfofInterp,1);
toc