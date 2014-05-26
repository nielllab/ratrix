function running2p(fname,spname);
% fname ='running area - darkness stim - zoom1004.tif'
% spname = 'running area - darkness stim - zoom1004_stim_obj.mat';

inf = imfinfo(fname)

img = imread(fname,1);
nframes = length(inf);
%nframes = 300;
mag = 1;
img = zeros(mag*size(img,1),mag*size(img,2),nframes);

clear t
 eval(inf(1).ImageDescription);
 framerate = state.acq.frameRate;
 
 filt = fspecial('gaussian',5,0.5)
for f=1:nframes

   img(:,:,f) = imfilter(double(imread(fname,f)),filt);
end


m=mean(img,3);
figure
imagesc(m);
colormap(gray)
m = prctile(img,10,3);
figure
imagesc(m);
colormap(gray)


dfof=zeros(size(img));
for f = 1:nframes
    dfof(:,:,f)=(img(:,:,f)-m)./m;
end

meanimg = squeeze(mean(mean(img,2),1));
meandf = squeeze(mean(mean(dfof,2),1));

figure
plot(meandf);
hold on
plot(meanimg/max(meanimg),'g')


interval = 1/framerate;
    load(spname);

    
    mouseT = stimRec.ts- stimRec.ts(1);
%     figure
%     plot(diff(mouseT));
%     
    dt = diff(mouseT);
    use = [1>0; dt>0];
    mouseT=mouseT(use);
    
    posx = cumsum(stimRec.pos(use,1)-900);
    posy = cumsum(stimRec.pos(use,2)-500);
    frameT = interval:interval:max(mouseT);
    vx = diff(interp1(mouseT,posx,frameT));
    vy = diff(interp1(mouseT,posy,frameT));
    vx(end+1)=0; vy(end+1)=0;
    
%     figure
%     plot(vx); hold on; plot(vy,'g');
%     sp = sqrt(vx.^2 + vy.^2);
%     figure
%     plot(sp)

figure
spshift = sp(1:length(meandf));
spshift = circshift(spshift,25);
meanstationary = mean(img(:,:,spshift<200),3);
figure
imagesc(meanstationary);
    
    
    figure
    plot((1:nframes)/framerate,meandf);
    hold on
    plot(frameT,sp/max(sp),'g');
    
    
    figure
    plot(xcorr(sp-mean(sp),meandf-mean(meandf)));
    
    figure
    plot(xcorr(sp-mean(sp),meanimg-mean(meanimg)))
 

    for x = 1:size(dfof,1);
        for y = 1:size(dfof,2);
            xc(x,y) = xcorr(circshift(squeeze((dfof(x,y,:))),-25)-mean(dfof(x,y,:)),sp(1:size(dfof,3))'-mean(sp),0);
            %  xc(x,y) = corr(squeeze(dfof(x,y,:)),sp(1:size(dfof,3))','type','spearman');
        end
    end
    
   fig = figure
   imagesc(xc,[-10^6 10^6])
   for i = 1:10;
       figure(fig)
       [y x] = ginput(1);
       figure
       df = circshift(squeeze(dfof(round(x),round(y),:)),-25);
       plot(df);
       
       hold on
      plot( sp(1:size(dfof,3))/max(sp),'g');
      
      figure
      plot(xcorr(sp(1:size(dfof,3))-mean(sp(1:size(dfof,3))), df-mean(df)));
      [xcc lag] = xcorr(sp(1:size(dfof,3))-mean(sp(1:size(dfof,3))), df-mean(df));
      [y ind] = max(abs(xcc));
      title(sprintf('xc = %f lag = %d',xcc(ind),lag(ind)));
   end

    


