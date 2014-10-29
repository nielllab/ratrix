clear all
close all
load('D:\grating2p8orient2sf.mat');
%load('D:\grating2p8orient2sfBlank.mat');

cycLength=10;
cycLength = input('cycle length (secs) :');
[f p] = uigetfile('*.tif','tif file');
fname = fullfile(p,f)

[img framerate] = readAlign2p(fname,1,1,0.5);
nframes = size(img,3);

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

figure
timecourse = squeeze(mean(mean(dfofInterp(:,:,1:60/dt),2),1));
plot(timecourse);

cycTimecourse = squeeze(mean(mean(cycAvg,2),1));
figure
plot(cycTimecourse);



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





% figure
% imshow(m/(prctile(m(:),99)));
% hold on
% h=imshow(polarMap(mapfilt))
% transp = abs(mapfilt)>1.5;
% set(h,'AlphaData',transp)
% title('mean image with filtered and masked map');

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


nstim = length(xpos);
baseRange = (2:dt:3.5)/dt;
evokeRange = (0:dt:3.5)/dt;
startTime=124;

startTime = input('start time : ');
for s = 1:nstim;
    base(:,:,s) = mean(dfofInterp(:,:,startTime + (s-1)*(duration+isi)/dt +baseRange),3);
    evoked(:,:,s) = mean(dfofInterp(:,:,startTime + isi/dt +(s-1)*(duration+isi)/dt +evokeRange),3);
end

figure
imagesc(squeeze(mean(evoked-base,3)),[-0.5 0.5]);
resp = evoked-base;

angles = unique(theta);
sfs = unique(sf);

for th = 1:length(angles);
    for sp = 1:length(sfs);
    
    orientation(:,:,th,sp) = median(resp(:,:,theta ==angles(th) & sf==sfs(sp)),3);
%     figure   
%     imagesc(squeeze(orientation(:,:,th)),[-0.5 0.5]);
ori_std(:,:,th,sp) = std(resp(:,:,theta ==angles(th) & sf==sfs(sp)),[],3)/sqrt(sum(theta ==angles(th) & sf==sfs(sp)));
    end
end

figure
im1=squeeze(max(max(orientation(:,:,[1 5],:),[],4),[],3));
imagesc(im1,[0 0.75])
colormap gray
im1= im1/1;
im1(im1<0)=0; im1(im1>1)=1;
im1 = im1(25:end,1:end-25);
figure
imshow(im1)

figure

im2=squeeze(max(max(orientation(:,:,[3 7],:),[],4),[],3));
imagesc(im2,[0 0.75])
colormap gray
im2= im2/1;
im2(im2<0)=0; im2(im2>1)=1;
im2 = im2(25:end,1:end-25);
figure
imshow(im2)


im = zeros(size(im1,1),size(im1,2),3);
im(:,:,1)=im1;
im(:,:,2)=im2;
im(:,:,3)=im2;

figure
imshow(im)

keyboard

R = max(max(orientation,[],4),[],3);

figure
imagesc(R,[0 2]);

for x = 1:size(orientation,1);
 x
 for y=1:size(orientation,2);
        tftuning=squeeze(mean(orientation(x,y,:,:),3));
        tfpref(x,y) =(tftuning(2)-tftuning(1))/(tftuning(2) + tftuning(1));
        if tfpref(x,y)>1            
            tf_use=2;
        else
            tf_use=1;
        end
        tuning = squeeze(orientation(x,y,:,tf_use));
        [osi(x,y) theta(x,y)] = calcOSI(tuning,0);
    end
end

figure
imagesc(osi,[0 1]);

figure
imagesc(theta,[-pi pi]);
colormap hsv;
theta(isnan(theta))=-0.1;
im = mat2im(theta,hsv,[-0.1 pi]);
osi_norm = 3*osi; osi_norm(osi_norm>1)=1;
R_norm=R/2; R_norm(R_norm>1)=1; R_norm(R_norm<0)=0;

white =ones(size(im(:,:,1)));

for c = 1:3
    im(:,:,c) = (white.*(1-osi_norm) + im(:,:,c).*osi_norm).*R_norm;
end
figure
imshow(imresize(im,4));
title('orientation preference')

j= jet;
j = j(end/2:end,:);
tf_im = mat2im(tfpref,j,[-1 1]);
for c =1:3
    tf_im(:,:,c) = tf_im(:,:,c).*R_norm;
end
figure
imshow(imresize(tf_im,4));
title('tf preference')

keyboard

absmap = figure
imagesc(R,[0 2])
range=-2:2;
%for i = 1:25;
done=0;

i=0;
while ~done
   i=i+1;
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
    
       figure
   ori = squeeze(mean(mean(orientation(x+range,y+range,:,:),2),1));
   ori_std = squeeze(std(std(orientation(x+range,y+range,:,:),[],2),[],1));
   
   %%% here, find all trials and pixels that go into the sum. get mean and
   %%% std. calculate std err mean from std and total number of pix x trial
   plot(ori)
    title('orientation');
    legend('lo','hi')
    
    
    trace(:,i) = full;
    avgTrace(:,i) = avg;
    %oriTuning(:,i)=ori;
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





