%% MakeSideBySideMovieWF
%this script allows you to put two WF movies side by side
close all;clear all;

spatialBin = 1;
temporalBin = 1;
movierate = 25;
acqrate = 10; %in Hz

movlen = 30; %in sec
aniname = 'G62WW3RT';
avifname = [aniname '_WFClip.mp4'];
avipath = 'C:\Users\nlab\Desktop\2pmov';


%% load in data for WF movies
datapath = avipath; %set path to data
cd(datapath)
datafiles = {'010418_G62WW3RT_DOI_RIG2_PRE_TOPOXmaps.mat',...
    '010418_G62WW3RT_DOI_RIG2_POST_TOPOXmaps.mat'};
df={};
for f = 1:2
    load(datafiles{f},'dfof_bg')
    
    if f==1
        stdimg = squeeze(std(dfof_bg,[],3));
        figure;colormap jet
        imagesc(stdimg,[-0.01 0.1])
        title('select three points on circle')
        abc = ginput(3);
        abc = round(abc);
        [R,xcyc] = fit_circle_through_3_points(abc);R=round(R);xcyc=round(xcyc);
        [X,Y] = meshgrid(1:size(stdimg,1),1:size(stdimg,2));
        dist = sqrt((X-xcyc(2)).^2 + (Y-xcyc(1)).^2)';
        dist = dist(xcyc(2)-R:xcyc(2)+R-1,xcyc(1)-R:xcyc(1)+R-1);
        img = stdimg(xcyc(2)-R:xcyc(2)+R-1,xcyc(1)-R:xcyc(1)+R-1);
        img(dist>R)=0;
        figure;colormap jet
        imagesc(img,[-0.01 0.1])
        axis square
        axis off
        
        satisfied=0;
        while satisfied~=1 %rotate
            figure;imagesc(img,[-0.01 0.1]);axis square;axis off;title('select back then front')
            [y x] = ginput(2);
            x=round(x);y=round(y);
            theta = -rad2deg(atan((x(1)-x(2))/(y(2)-y(1))));
            img2 = imrotate(img,theta,'crop');
            figure;imagesc(img2,[-0.01 0.1]);axis square;axis off
            satisfied = input('satisfied? 1=f*&$ yea!, 0=plz no: ');
        end
    end
    
    dfof_bg = dfof_bg(xcyc(2)-R:xcyc(2)+R-1,xcyc(1)-R:xcyc(1)+R-1,:);
    for i = 1:size(dfof_bg,3)
        frm = dfof_bg(:,:,i);
        frm(dist>R)=0;
        frm = imrotate(frm,theta,'crop');
        dfof_bg(:,:,i)=frm;
    end
    df{f} = dfof_bg;
end
img1 = df{1};img2 = df{2};

% figure
% hold on
% plot(squeeze(mean(mean(img1,2),1)),'k')
% plot(squeeze(mean(mean(img2,2),1)),'r')
% sprintf('select starting point for movie, leave at least %d frames at end',movlen*acqrate)
% [x y] = ginput(1);x = round(x);
% close
% img1 = img1(:,:,x:x + movlen*acqrate - 1);
% img2 = img2(:,:,x:x + movlen*acqrate - 1);

%% combine data into one
% imgcomb = nan(size(img1,2),size(img1,1)*2,size(img1,3));
% imgcomb(:,1:end/2,:) = img1;
% imgcomb(:,end/2+1:end,:) = img2;
% 
% spatial downsample
% imgcomb = imresize(imgcomb,1/spatialBin,'box');
img1 = imresize(img1,1/spatialBin,'box');

cyc_period = 100;
cycle_mov = zeros(size(img1,1),size(img1,2),cyc_period);
for i = 1:cyc_period;
    cycle_mov(:,:,i) = mean(img1(:,:,i:cyc_period:end),3);
end
cycle_mov = repmat(cycle_mov,[1,1,3]);
%temporal downsample
% binsize=temporalBin;
% downsampleLength = binsize*floor(size(imgcomb,3)/binsize);
% imgcomb = downsamplebin(imgcomb(:,:,1:downsampleLength),3,binsize)/binsize;  %%% downsamplebin based on patick mineault's code
% cycle_mov = downsamplebin(cycle_mov(:,:,1:downsampleLength),3,binsize)/binsize;  %%% downsamplebin based on patick mineault's code

%% make the movie

% %get lower and upper bounds
% dimg = imgcomb(5:5:end,5:5:end,5:5:end);
% lb = prctile(dimg(:),0.1); ub = prctile(dimg(:),99.5);
% 
% %write movie
% imgcomb = mat2im(imgcomb,gray,[lb ub]);
% mov = immovie(permute(imgcomb,[1 2 4 3]));

% baseline = prctile(imgcomb,1,3);
% imgcomb = imgcomb - repmat(baseline,[1 1 size(imgcomb,3)]);
% lowthresh= prctile(imgcomb(:),2);
% upperthresh = prctile(imgcomb(:),98)*1.5;
% imgcomb= mat2im(imgcomb,gray,[lowthresh upperthresh]);
% mov = immovie(permute(imgcomb,[1 2 4 3]));

baseline = prctile(cycle_mov,1,3);
cycle_mov = cycle_mov - repmat(baseline,[1 1 size(cycle_mov,3)]);
lowthresh= prctile(cycle_mov(:),2);
upperthresh = prctile(cycle_mov(:),98)*1.5;
cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
mov = immovie(permute(cycMov,[1 2 4 3]));

vid = VideoWriter(fullfile(avipath,avifname),'MPEG-4');
vid.FrameRate=movierate;
vid.Quality = 100;
open(vid);
display('writing movie')
writeVideo(vid,mov);
close(vid)


% dfshort = (double(dfof_bg(:,:,:)));
% dfshort = imresize(dfshort,1,'method','box');
% baseline = prctile(dfshort,3,3);
% cycle_mov = dfshort - repmat(baseline,[1 1 size(dfshort,3)]);
% lowthresh= prctile(cycle_mov(:),2);
% upperthresh = prctile(cycle_mov(:),98)*1.25;
% cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
% mov = immovie(permute(cycMov,[1 2 4 3]));
% [f p] = uiputfile('*.mp4','save video file');
% vid = VideoWriter(fullfile(p,f),'MPEG-4');
% % mov = immovie(permute(shiftmov,[1 2 4 3]));
% % vid = VideoWriter('bilateralS1.avi');
% vid.FrameRate=25;
% vid.Quality = 100;
% open(vid);
% writeVideo(vid,mov);
% close(vid)