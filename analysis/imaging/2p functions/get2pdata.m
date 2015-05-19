function [dfofInterp im_dt greenframe] = get2pdata(fname,dt,cycLength);
[img framerate] = readAlign2p(fname,1,1,0.5);
nframes = size(img,3);

greenframe = mean(img,3);

display('doing prctile')
tic
m = prctile(img(:,:,40:40:end),10,3);
toc
figure
imagesc(m);
title('10th prctile')
colormap(gray)

dfof=zeros(size(img));
for f = 1:nframes
    dfof(:,:,f)=(img(:,:,f)-m)./m;
end



im_dt = 1/framerate;
dt = 0.25;
dfofInterp = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(dfof,2),0:dt:(nframes-1)*im_dt);
dfofInterp = shiftdim(dfofInterp,1);
imgInterp = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(img,2),0:dt:(nframes-1)*im_dt);
imgInterp = shiftdim(imgInterp,1);

cycFrames =cycLength/dt
map=0; clear cycAvg mov

range = [prctile(m(:),2) 1.5*prctile(m(:),99)];
figure
for f = 1:cycFrames;
    cycAvg(:,:,f) = mean(imgInterp(:,:,f:cycFrames:end),3);
    imagesc(cycAvg(:,:,f),range); colormap gray
    mov(f)=getframe(gcf);
end
title('raw img frames')
vid = VideoWriter(sprintf('%sCycleMov.avi',fname(1:end-4)));
vid.FrameRate=10;
open(vid);
writeVideo(vid,mov(1:end));
close(vid)

fullMov= mat2im(imresize(img(25:end-25,25:end-25,150:550),2),gray,[prctile(m(:),2) 1.5*prctile(m(:),99)]);
%fullMov = squeeze(fullMov(:,:,:,1));
mov = immovie(permute(fullMov,[1 2 4 3]));
%mov = immovie(fullMov);
vid = VideoWriter(sprintf('%sfullMov.avi',fname(1:end-4)));
vid.FrameRate=15;

vid.Quality=100;
open(vid);
writeVideo(vid,mov(1:end));
close(vid)

cycTimecourse = squeeze(mean(mean(cycAvg,2),1));
figure
plot(cycTimecourse);