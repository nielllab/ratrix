close all; clear all;
warning off
cfile = '030117_j317a_detection_2lowcontrasts_eye.mat'
load(cfile)
% movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim1contrast_7_25min.mat';
%movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim3contrast10min.mat'
movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim2contrast_LOW_7_25min.mat';
load(movieFile);
data = squeeze(data);
mapsfile = 'J303a_run1_detection_2lowcontrastsmaps.mat'
load(mapsfile,'dfof_bg','frameT','cycMap','sp', 'stimRec');

path = 'D:\Angie_analysis\widefield_data\030117_J303a_eyeonly_naive\J303a_run1_detection_2lowcontrasts'
%myPDFfile=uiputfile('*.ps');
grpfilename = uiputfile('*.ps');% myPDFfile;
psfile = 'c:\tempAngie.ps';
if exist(psfile,'file')==2;delete(psfile);end

timeStamps=stimRec.ts
frameNum=stimRec.f
thresh = 0.80; %.85 %pupil threshold for binarization
        puprange = [8 40]; %[8 40] %set range of pupil radius
        pupercent = 0.8; %set range pupil radius window
        pupchange = 0.3; %acceptable percent change in radius per framerange
        framerange = 10; %number of frames to smooth over
       % user input to select center and right points
        sprintf('Please select pupil center and top, eyeball top and right points, darkest part of eyeball')
        h1 = figure('units','normalized','outerposition',[0 0 1 1])
        imshow(data(:,:,1000))
        [cent] = ginput(5);
        close(h1);
        yc = cent(1,2); %pupil center y val
        xc = cent(1,1); %pupil center x val
        horiz = (cent(4,1) - xc); %1/2 x search range
        vert = (yc - cent(3,2)); %1/2 y search range
        puprad = yc - cent(2,2); %initial pupil radius
       % puprange = [round(puprad - puprad*pupercent) round(puprad + puprad*pupercent)]; %range of pupil sizes to search over
        ddata = double(data);
        binmaxx = cent(5,1);
        binmaxy = cent(5,2);
        
        for i = 1:size(data,3)
            binmax(i) = mean(mean(mean(ddata(binmaxy-3:binmaxy+3,binmaxx-3:binmaxx+3,i))));
        end
        for i = 1:size(ddata,3)
            bindata(:,:,i) = (ddata(yc-vert:yc+vert,xc-horiz:xc+horiz,i)/binmax(i) > thresh);
        end
        
        %convert from uint8 into doubles and threshold, then binarize       
        tic
        centroid = nan(size(data,3),2);
        rad = nan(size(data,3),1);
        centroid(1,:) = [horiz vert];
        rad(1,1) = puprad;
        for n = 2:size(data,3)
            [center,radii,metric] = imfindcircles(bindata(:,:,n),puprange,'Sensitivity',0.995,'ObjectPolarity','dark');
            if(isempty(center))
                centroid(n,:) = [NaN NaN]; % could not find anything...
                rad(n) = NaN;
            else
                [~,idx] = max(metric); % pick the circle with best score
                centroid(n,:) = center(idx,:);
                rad(n,:) = radii(idx);
            end
        end
        

xEye = centroid(:,1)
yEye = centroid(:,2)

figure
plot(rad)
hold on;
plot(xEye);hold on; plot(yEye);
legend('rad','x pos','y pos')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

% h4 = figure
% 
% vidObj = VideoWriter('eyetracking_withfit.avi');
% %vidObj.FrameRate = 60;
% open(vidObj);
% 
% for i = 1:size(data,3)
%     
%     subplot(1,2,1)
%     imshow(data(yc-vert:yc+vert,xc-horiz:xc+horiz,i));
%     colormap gray
%     hold on
%     circle(centroid(i,1),centroid(i,2),rad(i))
%     drawnow
%     hold off
%     
%     subplot(1,2,2)
%     imshow(bindata(:,:,i));
%     colormap gray
%     hold on
%     circle(centroid(i,1),centroid(i,2),rad(i))
%     drawnow
%     hold off
%     
%     currFrame = getframe(gcf);
%     writeVideo(vidObj,currFrame);
% end
% close(vidObj);
small_mov = dfof_bg(4:4:end,4:4:end,4:4:end);
lowthresh = prctile(small_mov(:),2);
upperthresh = 1.5*prctile(small_mov(:),98);

%need to find rad at each movie frame
clear fInterpR
frameT=frameT-frameT(1)
timeStamps = timeStamps-timeStamps(1)
dur =0.5+isi

%needs to start at 0 
fInterpR = interp1(frameT(1:length(rad)),rad,timeStamps) %camera/imaging times taken from dfof maps, rad, movie frame times
fInterpV = interp1(frameT, sp, timeStamps)

fInterpX = interp1(frameT(1:length(xEye)),xEye,timeStamps)
fInterpY = interp1(frameT(1:length(yEye)),yEye,timeStamps)

% fInterpC = interp1(frameT,contrast,timeStamps)

figure
plot(timeStamps,fInterpR); xlabel('secs');
set(gcf,'Name', 'frame time & rad')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(frameNum,fInterpR,'.'); xlabel('frame #');
set(gcf,'Name', 'frame # & rad')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

for f = 1:75
    rAvg(f) = nanmean(fInterpR(mod(frameNum,75)==f-1));
end

figure
plot(rAvg);title('cycle average');
figure
plot(frameT(1:1000),fInterpR(1:1000));
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

clear R
for tr = 1:floor(max(frameNum)/75)
    for t = 1:180
        R(tr,t) = nanmean(fInterpR(frameNum == (tr-1)*75 + t));%
    end
%     R(tr,:) = R(tr,:) - R(tr,1);
end

clear tr t
for tr = 1:floor(max(frameNum)/75)
    for t = 1:180
        V(tr,t) = nanmean(fInterpV(frameNum == (tr-1)*75 + t));%
    end
%     V(tr,:) = V(tr,:) - V(tr,1);
end

clear tr t
for tr = 1:floor(max(frameNum)/75)
    for t = 1:180
        X(tr,t) = nanmean(fInterpX(frameNum == (tr-1)*75 + t));%
    end
end

clear tr t
for tr = 1:floor(max(frameNum)/75)
    for t = 1:180
        Y(tr,t) = nanmean(fInterpY(frameNum == (tr-1)*75 + t));%
    end
end

figure
subplot(2,2,1)
imagesc(R); title('rad')
subplot(2,2,2)
imagesc(V);title('velocity')
subplot(2,2,[3,4])
plot(fInterpR); hold on; plot(fInterpV*.01,'g')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
subplot(1,2,1)
plot(mean(R(contrast==.01))); hold on; axis square; %plot(nanmean(V(contrast==.01,:))./(2.5*median(R(contrast==.01,:))))
ylim([min(mean(R(contrast==.01,:)))-.25 max(mean(R(contrast==.01,:)))+.25])
plot([60 60],[14 20],'g');  plot ([75 75],[14 20],'g');
title ('mean of .01 contrast')
subplot(1,2,2)
plot(nanmean(R(contrast==.04,:))); hold on; axis square;% plot(nanmean(V(contrast==.01,:)/5))
ylim([min(mean(R(contrast==.04,:)))-.25 max(mean(R(contrast==.04,:)))+.25])
plot([60 60],[14 20],'g');  plot ([75 75],[14 20],'g');
title ('mean of .04 contrast')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');
% useTrials = timeStamps(contrast==1)
% figure
% plot(frameNum,fInterpR);hold on; plot(useTrials,'.')
% set(gcf, 'PaperPositionMode', 'auto');
% print('-dpsc',psfile,'-append');
left=unique(xpos(3))
right=unique(xpos(1))

clear use
use = find(contrast==.01)
figure
set(gcf,'Name','contrast=0.01')
for i = 1:length(use)-1
subplot(4,4,i)
plot(R(use(i),:)); hold on;% plot(V(use(i),:)*.05)
ylim([min(R(use(i),:))-.5 max(R(use(i),:))+.5]); 
xlim([0 180])
plot([60 60],[min(R(use(i),:)) max(R(use(i),:))],'g'); plot ([75 75],[min(R(use(i),:)) max(R(use(i),:))],'g');
if find(use(i) & xpos(use(i))==left), title('left')
else  title('right')
end
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');


use = find(contrast==.04)
figure
set(gcf,'Name','contrast=0.04')
for i = 1:length(use)
subplot(4,4,i)
plot(R(use(i),:)); hold on;% plot(V(use(i),:)*.05)
% hold on;
% plot(R(use04(i),:),'r')
ylim([min(R(use(i),:))-.5 max(R(use(i),:))+.5]); 
xlim([0 180])
plot([60 60],[min(R(use(i),:)) max(R(use(i),:))],'g'); plot ([75 75],[min(R(use(i),:)) max(R(use(i),:))],'g');
title('.04')
if find(use(i) & xpos(use(i))==left), title('left')
else  title('right')
end
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

% dfof_bg= dfof_bg(15:160,50:190,:);
% dfof_bg = imresize(dfof_bg,0.5);
contrast = contrast(1:end-5); %%% cut off last few in case imaging stopped early
xpos = xpos(1:end-5);

%%% median filter eye and speed data to remove transients
x = medfilt1(xEye,5); y= medfilt1(yEye,5);
v = medfilt1(sp,9); r = medfilt1(rad,7);

Xfilt = medfilt1(X,5); Yfilt = medfilt1(Y,5);
%%% show raw and filtered data
figure
plot(xEye); hold on; plot(x); title('x'); legend('raw','filtered')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');
figure
plot(rad); hold on; plot(r); title('r'); legend('raw','filtered')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');
figure
plot(sp); hold on; plot(v); title('v'); legend('raw','filtered')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

%%% normalize eye/speed data (custom function nrm)
x = nrm(x); y = nrm(y); r= nrm(r); v = nrm(v);
%X = nrm(Xfilt(:,60:180)); Y=nrm(Yfilt)
figure
hist(x,0.01:0.02:1); title('x position')
% figure
% hist(Xfilt,0.01:0.02:1)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

clear use
left=unique(xpos(3))
right=unique(xpos(1))
test = unique(contrast)
for c = 2:length(test)
 use = find(contrast==test(c) & xpos==left)
if sum(contrast==.01)>0
    figure
    for i=1:length(use)
        subplot(2,8,i)
        plot(R(use(i),:)); axis square ; ylim([min(R(use(i),:))-.5 max(R(use(i),:))+.5]); xlim([0 180]);hold on;
        plot([60 60],[10 max(R(use(i),:))+.5],'g');  plot ([75 75],[10 max(R(use(i),:))+.5],'g');
        subplot(2,8,i+8)
        plot(Xfilt(use(i),:),Yfilt(use(i),:));hold on; axis square
        xlim([min(Xfilt(use)) max(Xfilt(use))]);
        ylim([min(Yfilt(use)) max(Yfilt(use))]);
        plot(Xfilt(use(i),:),Yfilt(use(i),:),'.r');
    end
    if c == 2 
    title('contrast = .01, left position')
    set(gcf,'Name','contrast= 0.01, Left Position')
    else   title('contrast = .04, left position')
    set(gcf,'Name','contrast= .04, Left Position'), end
else display ('no contrast 01 trials')
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');
end


clear use
right=unique(xpos(1))
test = unique(contrast)
for c = 2:length(test)
 use = find(contrast==test(c) & xpos==right)
if sum(contrast==.01)>0
    figure
    for i=1:length(use)
        subplot(2,8,i)
        plot(R(use(i),:)); axis square ; ylim([min(R(use(i),:))-.5 max(R(use(i),:))+.5]); xlim([0 180]); hold on;
        plot([60 60],[10 max(R(use(i),:))+.5],'g');  plot ([75 75],[10 max(R(use(i),:))+.5],'g');
        subplot(2,8,i+8)
        plot(Xfilt(use(i),:),Yfilt(use(i),:));hold on; axis square
        xlim([min(Xfilt(use)) max(Xfilt(use))]);
        ylim([min(Yfilt(use)) max(Yfilt(use))]);
        plot(Xfilt(use(i),:),Yfilt(use(i),:),'.r');
    end
    if c == 2 
    title('contrast = .01, Right position')
    set(gcf,'Name','contrast= 0.01, Right Position')
    else   title('contrast = .04, Right position')
    set(gcf,'Name','contrast= .04, Right Position'), end
else display ('no contrast 01 trials')
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');
end

figure
plot(x,y); title('eye position'); hold on; plot(x,y,'r.')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');
figure
plot(Xfilt(contrast==0.01,:));hold on; plot(Y(contrast==0.01,:))
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');
figure
plot(frameT(1:length(x)),x/max(x)); title('X')
hold on
plot(frameT,v/max(v))
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(frameT(1:length(y)),y/max(y)); title('Y')
hold on
plot(frameT,v/max(v))
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(frameT(1:length(r)),r/max(r)); title('radius')
hold on
plot(frameT,v/max(v))
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

frameT=frameT(1:length(rad))
v = v(1:length(rad))

dF = squeeze(mean(mean(dfof_bg,2),1));
dF = nrm(dF);
dF=dF(1:length(r))
figure
plot(frameT,dF/max(dF)); title('dF')
hold on
plot(frameT,v/max(v))
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(frameT,dF); title('dF')
hold on
plot(frameT,r)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(r,dF,'.'); xlabel('r'); ylabel('dF');
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(v,dF,'.'); xlabel('v'); ylabel('dF');
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(x,dF,'.');xlabel('x'); ylabel('dF');
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(x,y,'.'); xlabel('x'); ylabel('y')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

figure
plot(x,r,'.'); xlabel('x'); ylabel('r')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

%%% align data to stim onsets
stimT = stimRec.ts - stimRec.ts(1);
figure
plot(diff(stimT))

isiFrames = 20; durFrames = 5;
vis = zeros(size(r));
nstim=0;
for trial = 1:length(contrast);
   trial
   start=  (trial-1)*(durFrames+isiFrames) + isiFrames;
    stop = start + durFrames;
    vis(start:stop) = contrast(trial);
    range = (start-isiFrames+1):(stop + 30);
    trialR(trial,:) = r(range);
    trialV(trial,:) = v(range);
    trialX(trial,:) = x(range);
    trialY(trial,:) = y(range);
    trialDF(trial,:,:,:) = dfof_bg(:,:,(start-1):(stop+10));
    %%% add other variables here = position and orientation
end

%%% look at averages for contrast==1
% figure
% trials = find(contrast==.01);
% for i = 1:16
%     subplot(4,4,i);
%     plot(trialX(trials(i),:)); %xlim([1 size(trialV,2)])
%     hold on; plot(trialR(trials(i),:));
%     plot(isiFrames,0.5,'*');
%    % xlim([1 size(trialV,2)]); ylim([0 1])
%     legend('eyeX', 'eyeR')
% end
% set(gcf, 'PaperPositionMode', 'auto');
% print('-dpsc',psfile,'-append');

vis = vis(1:length(r));

%%% calculate change in variables (maybe better than actual position)
dx = [0 ; diff(x)];
dy = [0 ;diff(y) ];
dr = [ 0 ; diff(r)];
dv = [0 ; diff(v)];
dvis = [0 ; diff(vis)];
dvis(dvis<0)=0;

figure
imagesc(mean(dfof_bg(:,:,vis==1),3)- mean(dfof_bg(:,:,vis==0),3))
title('mean visual activation')

set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');
%%% perform regression on behavioral variables at multiple lags, and covert
%%% to images
clear vfit xcorr mx
for lag = -20:2:10;
    dfShift = circshift(dfof_bg,[0 0 lag]);
    clear vfit vcorr
    for i = 1:size(dfof_bg,1);
        i
        for j = 1:size(dfof_bg,2);
            [vfit(i,j,:) nil resid]= regress(squeeze(dfShift(i,j,:)),[v r   dvis abs(dx) dx ones(size(r))]);
            vcorr(i,j,:) = partialcorri(squeeze(dfShift(i,j,:)),[v r   dvis abs(dx) dx]);
        end
    end
    
    figure
    for i = 1:5
        subplot(2,3,i);
        if i<4
            im = mat2im(vfit(:,:,i),jet,[0 0.1]);
        elseif i==4
            im = mat2im(vfit(:,:,i),jet,[0 0.25]); 
        elseif i==5
            im = mat2im(vfit(:,:,i),jet,[-0.1 0.1]);
        end
        vc = vcorr(:,:,i);
        range = max(0.05, prctile(abs(vc(:)),95));
        im = im.*repmat(abs(squeeze(vcorr(:,:,i))),[1 1 3])/range;
        timecourse(:,:,:,i,(lag+20)/2 +1) = im
        imshow(imresize(im,5))
        mx(i,(lag+20)/2 +1) = prctile(abs(vc(:)),95);
        title(sprintf('r2 %0.2f',prctile(abs(vc(:)),95)));
    end
    set(gcf,'Name',sprintf('lag %d',lag));
    drawnow
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
plot(-1:0.2:2,mx(:,end:-1:1)'); xlabel('secs'); ylabel('partial correlation')
legend('v','r','vis','abs(dx)','dx')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfile,'-append');

titles = {'V','R','vis stim','abs(dx)','dx'};
for i = 1:5
    figure
    for j = 1:12
    subplot(3,4,j)
    imshow(imresize(squeeze(timecourse(:,:,:,i,16-j)),2))
    end
    set(gcf,'Name',titles{i});
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

try
    dos(['ps2pdf ' psfile ' "' [fullfile(path,grpfilename) '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

save(mapsfile,'rad','fInterpR','fInterpV', 'R','V','xEye','yEye','contrast','xpos','ypos','X','Y','-append')

% h4 = figure
% 
% vidObj = VideoWriter('eyetracking_withfit.avi');
% %vidObj.FrameRate = 60;
% open(vidObj);
% 
% for i = 1:size(data,3)
%     
%     subplot(1,2,1)
%     imshow(data(yc-vert:yc+vert,xc-horiz:xc+horiz,i));
%     colormap gray
%     hold on
%     circle(centroid(i,1),centroid(i,2),rad(i))
%     drawnow
%     hold off
%     
%     subplot(1,2,2)
%     imshow(bindata(:,:,i));
%     colormap gray
%     hold on
%     circle(centroid(i,1),centroid(i,2),rad(i))
%     drawnow
%     hold off
%     
%     currFrame = getframe(gcf);
%     writeVideo(vidObj,currFrame);
% end
% close(vidObj);
% 
% 
% small_mov = dfof_bg(4:4:end,4:4:end,4:4:end);
% lowthresh = prctile(small_mov(:),2);
% upperthresh = 1.5*prctile(small_mov(:),98);

% 
% h5 = figure
% vidObj = VideoWriter('022717_g62rr2-tt_detection_2lowcontrasts_dfof_eye');
% %vidObj.FrameRate = 60;
% open(vidObj);
% for i=1:size(data,3)
%     subplot(3,2,[3,4,5,6])
%     imagesc(imresize(dfof_bg(:,:,i),1.75,'box'),[lowthresh upperthresh]);axis square;
%     %drawnow
%     hold on
%     if sp(i)<500
%         plot(50,250,'ro','Markersize',8,'Linewidth',8); %stationary
%     else
%         plot(50,250,'go','Markersize',8,'Linewidth',8);
%     end
%     %hold off
%     h = axes('Position', [.05 .65 .4 .4], 'Layer','top');
%     imshow(imresize(data(yc-vert:yc+vert,xc-horiz:xc+horiz,i),1.0,'box'));
%     axis(h, 'off', 'tight')
%     colormap gray;
%     hold on
%     circle(centroid(i,1),centroid(i,2),rad(i))
%     drawnow
%     hold off
%     subplot(3,2,2)
%     plot(rad);xlim([0 4350]);ylim([5 40]);
%     hold on; plot(sp*.01,'g')
%     plot(i,35,'ro','Markersize',4,'Linewidth',4)
%     hold off
%     currFrame = getframe(gcf);
%     writeVideo(vidObj,currFrame);
% end
% close(vidObj);
 

 