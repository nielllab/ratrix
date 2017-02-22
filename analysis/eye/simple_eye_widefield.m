close all; clear all;

cfile = ('02_17_17_g62ss4-lt_darkness_eye')
load(cfile)
% movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim1contrast_7_25min.mat';
%movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim3contrast10min.mat'
movieFile = 'C:\Users\Angie Michaiel\Desktop\movie files\cortex\DetectionStim2contrast_LOW_7_25min.mat';
load(movieFile);
data = squeeze(data);
mapsfile = ('g62ss4-lt_run3_darkness_premaps.mat')
load(mapsfile,'dfof_bg','frameT','cycMap','sp', 'stimRec');

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


% 
% figure
% for i=1:length(moviedata(:,:,i))/3
% imshow(moviedata(:,:,i))
% drawnow
% end
%movie = 30hz, eye camera & imaging camera = 10 hz

%need to find rad at each movie frame
clear fInterpR
frameT=frameT-frameT(1)
timeStamps = timeStamps-timeStamps(1)
dur =0.5+isi

%needs to start at 0 
fInterpR = interp1(frameT(1:length(rad)),rad,timeStamps) %camera/imaging times taken from dfof maps, rad, movie frame times
fInterpV = interp1(frameT, sp, timeStamps)
%fInterpC = interp1(dur,contrast,timeStamps)

%need to match up contrast with frame numbers
%dfof for rad (same length)
%dfof w/movie
%rad w/movie

figure
plot(timeStamps,fInterpR); xlabel('secs');
set(gcf,'Name', 'frame time & rad')

figure
plot(frameNum,fInterpR,'.'); xlabel('frame #');
set(gcf,'Name', 'frame # & rad')

for f = 1:75
    rAvg(f) = nanmean(fInterpR(mod(frameNum,75)==f-1));
end

figure
plot(rAvg)
figure
plot(frameT(1:1000),fInterpR(1:1000))

clear R
for tr = 1:floor(max(frameNum)/75)
    for t = 1:120
        R(tr,t) = nanmean(fInterpR(frameNum == (tr-1)*75 + t));%
    end
%     R(tr,:) = R(tr,:) - R(tr,1);
end

clear tr t
for tr = 1:floor(max(frameNum)/75)
    for t = 1:120
        V(tr,t) = nanmean(fInterpV(frameNum == (tr-1)*75 + t));%
    end
%     V(tr,:) = V(tr,:) - V(tr,1);
end



figure
subplot(2,2,1)
imagesc(R); title('rad')
subplot(2,2,2)
imagesc(V);title('velocity')
subplot(2,2,[3,4])
plot(fInterpR); hold on; plot(fInterpV*.01,'g')


%want to find all frameNum where contrast ==1
useTrials = timeStamps(contrast==1)
figure
plot(frameNum,fInterpR);hold on; plot(useTrials,'.')


use = find(contrast>=.01)

figure
for i = 1:20
subplot(5,4,i)
plot(R(use(i),:)); hold on;% plot(V(use(i),:)*.05)
ylim([12 25]); 
xlim([0 120])
 plot([60 60],[12 25],'g');  plot ([75 75],[12 25],'g');
if find(contrast(use(i))==1), title('1')
elseif find(contrast(use(i))==.01), title('0.01')
else title('0.04')
end
end

figure
 for i=1:length(use)
plot(i,max(R(use(i),60:120),'.')); hold on; % plot(V(use(i),:)*.05)
end

figure
plot(nanmean(R(contrast==1,:))); hold on; plot(nanmean(V(contrast==1,:)/5))
plot([60 60],[8 20],'g');  plot ([75 75],[8 20],'g');
title ('mean of full contrast')

% h5 = figure
% vidObj = VideoWriter('020217_g62ww2-tt_detection_dfof_eye');
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


 save(mapsfile,'rad','fInterpR','fInterpV', 'R','V','xEye','yEye','contrast','-append')