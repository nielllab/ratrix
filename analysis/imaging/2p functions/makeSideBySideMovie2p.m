%% MakeSideBySideMovie
%this script allows you to put two 2p movies side by side
close all;clear all;

acqrate = 10; %original acquisition rate in Hz

%choose movie parameters
spatialBin = 2;
temporalBin = 4;
movierate = 25;
alignData = 1;
showImages = 1; %displays mean image during data reading
movlen = 60; %output movie length in sec
aniname = 'G62GGG3LT';
avifname = [aniname '_2pClip.mp4'];
avipath = 'C:\Users\nlab\Desktop\2pmov';

%% load in data for 2p movies

%movie 1
datapath = avipath; %set path to data
cd(datapath)
datafile = 'G62GGG3LT_001_007';
[img1 framerate] = readAlign2p_sbx(datafile,alignData,showImages);
load([datafile '.mat'],'info')
startfrm = info.frame(1);
img1 = img1(48:end-49,48:end-49,startfrm:end);

%movie 2
datafile = 'G62GGG3LT_001_008';
[img2 framerate] = readAlign2p_sbx(datafile,alignData,showImages);
load([datafile '.mat'],'info')
startfrm = info.frame(1);
img2 = img2(48:end-49,48:end-49,startfrm:end);

figure
hold on
plot(squeeze(mean(mean(img1,2),1)),'k')
plot(squeeze(mean(mean(img2,2),1)),'r')
sprintf('select starting point for movie, leave at least %d frames at end',movlen*acqrate)
[x y] = ginput(1);x = round(x);
close
img1 = img1(:,:,x:x + movlen*acqrate - 1);
img2 = img2(:,:,x:x + movlen*acqrate - 1);

%% combine and downsample data

% imgcomb = nan(size(img1,2),size(img1,1)*2,size(img1,3));
% imgcomb(:,1:end/2,:) = img1;
% imgcomb(:,end/2+1:end,:) = img2;
imgcomb = img1;
%spatial downsample
imgcomb = imresize(imgcomb,1/spatialBin,'box');

%temporal downsample
binsize=temporalBin;
downsampleLength = binsize*floor(size(imgcomb,3)/binsize);
imgcomb= downsamplebin(imgcomb(:,:,1:downsampleLength),3,binsize)/binsize;  %%% downsamplebin based on patick mineault's code

%% make the movie

%get lower and upper bounds
dimg = imgcomb(5:5:end,5:5:end,5:5:end);
lb = prctile(dimg(:),0.1); ub = prctile(dimg(:),99.5)*1.5;

%write movie
cycMov= mat2im(imgcomb,gray,[lb ub]);
mov = immovie(permute(cycMov,[1 2 4 3]));
vid = VideoWriter(fullfile(avipath,avifname),'MPEG-4');
vid.FrameRate=movierate;
vid.Quality = 100;
open(vid);
display('writing movie')
writeVideo(vid,mov);
close(vid)
