clear all
fname ='orientation 256 1ms no sync001.tif';
fname = 'orientation 256 1ms no sync spot2002.tif'
inf = imfinfo(fname)

img = imread(fname,1);

nframes = length(inf);
%nframes = 300;
mag = 0.5;
img = zeros(mag*size(img,1),mag*size(img,2),nframes);

clear t
 eval(inf(1).ImageDescription);
 framerate = state.acq.frameRate;
 
for f=1:nframes

   img(:,:,f) = imresize(double(imread(fname,f)),mag);
end

m = prctile(img,10,3);
%m=mean(img,3);
figure
imagesc(m);
colormap(gray)

dfof=zeros(size(img));
for f = 1:nframes
    dfof(:,:,f)=(img(:,:,f)-m)./m;
end

for f = 1:10
    imagesc(dfof(:,:,f),[-0.25 1]);
    mov(f)=getframe(gcf);
end

im_dt = 1/framerate;
dt = 0.25;
dfofInterp = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(dfof,2),0:dt:(nframes-1)*im_dt);
dfofInterp = shiftdim(dfofInterp,1);


% for f = 1:10
%     imagesc(dfofInterp(:,:,f),[-0.25 1]);
%     mov(f)=getframe(gcf);
% end

cycLength=20;
cycFrames =cycLength/dt; 
map=0; clear cycAvg mov
for f = 1:cycFrames;
    cycAvg(:,:,f) = mean(dfofInterp(:,:,f:cycFrames:end),3);
    map = map + cycAvg(:,:,f)*exp(2*pi*sqrt(-1)*f/cycFrames);
    imagesc(cycAvg(:,:,f),[-0.1 0.5]); colormap gray
    mov(f)=getframe(gcf);
end

vid = VideoWriter(sprintf('%smov.avi',fname(1:end-4)));
vid.FrameRate=15;
open(vid);
writeVideo(vid,mov(1:end));
close(vid)

figure
imagesc(abs(map))
figure
imagesc(angle(map))
colormap(hsv)
figure
imshow(polarMap(map))
pmap = polarMap(map);


figure
imshow(m/(prctile(m(:),98)));
hold on
h=imshow(pmap);
transp = abs(map)>1;
set(h,'AlphaData',transp)

absfig=figure
imagesc(abs(map))
clear trace avgTrace
for i = 1:3;
    figure(absfig)
    [y x ]= (ginput(1));
    x = round(x); y=round(y);
    figure
    plot(squeeze(dfofInterp(x,y,:)))
    figure
    plot(squeeze(cycAvg(x,y,:)));
    trace(:,i) = dfofInterp(x,y,:);
    avgTrace(:,i) = cycAvg(x,y,:);
end
    
figure
plot(trace);
figure
plot(avgTrace);


