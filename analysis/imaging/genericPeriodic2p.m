clear all
close all
grating2p8orient2sf.mat

[f p] = uigetfile('*.tif','tif file');
fname = fullfile(p,f)

cycLength=10;
cycLength = input('cycle length (secs) :');

inf = imfinfo(fname)


img = imread(fname,1);

nframes = length(inf);
%nframes = 300;
mag = 1;
img = zeros(mag*size(img,1),mag*size(img,2),nframes);

 eval(inf(1).ImageDescription);
 framerate = state.acq.frameRate;
 
display('doing alignement')
tic
    r = sbxalign(fname,1:nframes);
   toc
   figure

   plot(r.T(:,1));
    hold on
    plot(r.T(:,2),'g');
figure
    imagesc(r.m{1}); colormap gray; axis equal


 filt = fspecial('gaussian',5,0.5)
for f=1:nframes
   img(:,:,f) = imfilter(double(imread(fname,f)),filt);
end

mn=mean(img,3);
%mn= prctile(img,99,3);
figure
range = [prctile(mn(:),2) prctile(mn(:),98)];
imagesc(mn,range);
title('non aligned mean img')
colormap(gray)

 filt = fspecial('gaussian',5,0.25)
for f=1:nframes

   img(:,:,f) = circshift(squeeze(img(:,:,f)),[r.T(f,1),r.T(f,2)]);
end



mn=mean(img,3);
%mn= prctile(img,99,3);
figure
range = [prctile(mn(:),2) prctile(mn(:),98)];
imagesc(mn,range);
title('aligned mean img')
colormap(gray)


display('doing prctile')
tic
m = prctile(img(:,:,10:10:end),10,3);
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

cycFrames =cycLength/dt; 
map=0; clear cycAvg mov

range = [prctile(mn(:),2) prctile(mn(:),98)];
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

figure
for f = 1:cycFrames;
    cycAvg(:,:,f) = mean(dfofInterp(:,:,f:cycFrames:end),3);
    map = map + cycAvg(:,:,f)*exp(2*pi*sqrt(-1)*f/cycFrames);
    imagesc(cycAvg(:,:,f),[-0.1 2]); colormap gray
    mov(f)=getframe(gcf);
end
title('dfof frames')
vid = VideoWriter(sprintf('%sdfofCycleMov.avi',fname(1:end-4)));
vid.FrameRate=10;
open(vid);
writeVideo(vid,mov(1:end));
close(vid)

figure
plot(squeeze(mean(mean(dfofInterp(:,:,1:60/dt),2),1)))


figure
plot(squeeze(mean(mean(dfofInterp(:,:,end-360/dt:end),2),1)))

figure
imagesc(abs(map))
title('map amp');

figure
imagesc(angle(map))
title('map phase');
colormap(hsv)

figure
imshow(polarMap(map))
title('polarMap')

pmap = polarMap(map);

figure
imshow(m/(prctile(m(:),98)));
hold on
h=imshow(pmap);
transp = abs(map)>1;
set(h,'AlphaData',transp)
title('mean img overlaid with masked map');


 filt = fspecial('gaussian',5,1)
mapfilt = imfilter(map,filt);
figure
imshow(polarMap(mapfilt))
title('filtered map');

figure
imshow(m/(prctile(m(:),99)));
hold on
h=imshow(polarMap(mapfilt))
transp = abs(mapfilt)>1.5;
set(h,'AlphaData',transp)
title('mean image with filtered and masked map');

figure
h=imshow(pmap)
transp = abs(map)>2;
set(h,'AlphaData',transp)
title('maked with higher thresh')

absfig = figure
%imshow(zeros(size(m)));
imshow(m/max(m(:))*1.5);
hold on
capdf = mean(dfof,3);
capdf(capdf>0.4)=0.4;
%h= imagesc(capdf,[0.1 0.4]); colormap jet
im = mat2im(capdf, jet,[0.1 0.4]);
h=imshow(im)
transp = capdf>0.2;
set(h,'AlphaData',transp)
title('mean elicited response')


absmap = figure
imshow(polarMap(mapfilt))
range=-1:1;
%for i = 1:25;
done=0;
while ~done
    figure(absmap)
    [y x b]= (ginput(1));
   if b==3
       done=1;
   else
       x = round(x); y=round(y);
    figure
    full = squeeze(mean(mean(dfofInterp(x+range,y+range,:),2),1));
    plot(full)
    title('full timecourse');
    figure
   avg = squeeze(mean(mean(cycAvg(x+range,y+range,:),2),1));
   plot(avg)
    title('cyc avg timecourse');
    trace(:,i) = full;
    avgTrace(:,i) = avg;
   end
%     figure
%     plot(0:45:315,avgTrace(4:10:end,i))
end
    
figure
plot(trace);
figure
plot(avgTrace);

c = 'rgbcmk'
figure
hold on
for i = 1:25;
    plot(trace(50:1250,i)/max(trace(:,i)) + i/2,c(mod(i,6)+1));
end

thresh=0.8;
cor = corr(trace);
np =0; clear mergetrace mergeAvgTrace
for i = 1:size(cor,1);
    merge = find(cor(:,i)>thresh);
    if ~isempty(merge);
        np=np+1;
        mergetrace(:,np) = mean(trace(:,merge),2);
        mergeAvgTrace(:,np) = mean(avgTrace(:,merge),2);
        normAvgTrace(:,np) = mergeAvgTrace(:,np)/max(mergeAvgTrace(:,np));
        cor(merge,:)=0;
        cor(:,merge)=0;
    end
end

figure
plot(mergeAvgTrace);

c = 'rgbcmk'
nc = 3;
idx=kmeans(normAvgTrace',nc);
figure
hold on
for i = 1:np;
    plot(0.25:0.25:10,mergeAvgTrace(:,i),c(idx(i)));
end
%figure
hold on
for i = 1:nc;
    plot(0.25:0.25:10,mean(mergeAvgTrace(:,idx==i),2),c(i),'LineWidth',3);
end

c = 'rgbcmk'
figure
hold on
for i = 1:np;
    plot(0.25*(1:length(50:1250)),mergetrace(50:1250,i)/max(trace(:,i)) + i,c(mod(i,6)+1));
end
xlabel('secs')
ylim([0 np+2]);





