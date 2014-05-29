function periodic2p(fname, spname,period, label);

inf = imfinfo(fname)
img = imread(fname,1);
nframes = length(inf);
%nframes = 300;
mag = 1;
img = zeros(mag*size(img,1),mag*size(img,2),nframes);

clear t
 evalc(inf(1).ImageDescription);
 framerate = state.acq.frameRate;
 
 filt = fspecial('gaussian',5,0.25);
for f=1:nframes

   img(:,:,f) = imfilter(double(imread(fname,f)),filt);
end

m=mean(img,3);
% figure
% imagesc(m);
% colormap(gray)
m = prctile(img,10,3);
% figure
% imagesc(m);
% colormap(gray)

dfof=zeros(size(img));
for f = 1:nframes
    dfof(:,:,f)=(img(:,:,f)-m)./m;
end

% for f = 1:10
%     imagesc(dfof(:,:,f),[-0.25 1]);
%     mov(f)=getframe(gcf);
% end

im_dt = 1/framerate;
dt = 0.25;
dfofInterp = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(dfof,2),0:dt:(nframes-1)*im_dt);
dfofInterp = shiftdim(dfofInterp,1);


% for f = 1:10
%     imagesc(dfofInterp(:,:,f),[-0.25 1]);
%     mov(f)=getframe(gcf);
% end

cycLength=period;
cycFrames =cycLength/dt; 
map=0; clear cycAvg mov

dfmov = figure

for f = 1:cycFrames;
    cycAvg(:,:,f) = mean(dfofInterp(:,:,f:cycFrames:end),3);
    map = map + cycAvg(:,:,f)*exp(2*pi*sqrt(-1)*f/cycFrames);
    imagesc(cycAvg(:,:,f),[-0.1 2]); colormap gray
    mov(f)=getframe(gcf);
end

vid = VideoWriter(sprintf('%sCycleMov.avi',fname(1:end-4)));
vid.FrameRate=10;
open(vid);
writeVideo(vid,mov(1:end));
close(vid)

close(dfmov);

% figure
% imagesc(abs(map))
% figure
% imagesc(angle(map))
% colormap(hsv)
figure
imshow(polarMap(map)); axis square;
title([label ' polarmap']);
pmap = polarMap(map);


figure
imshow(m/(prctile(m(:),98)));
hold on
h=imshow(pmap);
transp = abs(map)>0.5;
set(h,'AlphaData',transp); axis square
title([label ' polar over cells']);
% 
%  filt = fspecial('gaussian',5,1)
% mapfilt = imfilter(map,filt);
% figure
% imshow(polarMap(mapfilt))
% 
% figure
% imshow(m/(prctile(m(:),99)));
% hold on
% h=imshow(polarMap(mapfilt))
% transp = abs(mapfilt)>1.5;
% set(h,'AlphaData',transp)

% figure
% h=imshow(pmap)
% transp = abs(map)>2;
% set(h,'AlphaData',transp)

% 
% absfig = figure
% %imshow(zeros(size(m)));
% imshow(m/max(m(:))*1.5);
% hold on
% capdf = mean(dfof,3);
% capdf(capdf>0.4)=0.4;
% %h= imagesc(capdf,[0.1 0.4]); colormap jet
% 
% im = mat2im(capdf, jet,[0.5 1.5]);
% h=imshow(im)
% transp = capdf>0.5;
% set(h,'AlphaData',transp)
% 
%  filt = fspecial('gaussian',5,1)
% mapfilt = imfilter(map,filt);
% absmap = figure
% imshow(polarMap(mapfilt))
% 
% for i = 1:3;
%     figure(absmap)
%     [y x ]= (ginput(1));
%     x = round(x); y=round(y);
%     figure
%     plot(squeeze(dfofInterp(x,y,:)))
%     figure
%     plot(squeeze(cycAvg(x,y,:)));
%     trace(:,i) = dfofInterp(x,y,:);
%     avgTrace(:,i) = cycAvg(x,y,:);
%     
% %     figure
% %     plot(0:45:315,avgTrace(4:10:end,i))
% end
%     
% % figure
% % plot(trace);
% % figure
% % plot(avgTrace);
% % 
% % c = 'rgbcmk'
% % figure
% % hold on
% % for i = 1:25;
% %     plot(trace(50:1250,i)/max(trace(:,i)) + i/2,c(mod(i,6)+1));
% % end
% 
% 
% 
% 
