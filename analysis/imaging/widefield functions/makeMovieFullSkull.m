%% make wide skull movie from custom ROI
%requires fit_circle_through_3_points available on MathWorks site (Danylo Malyuta)
[f p] = uigetfile('*.mat','maps file');
sprintf('loading')
tic
load(fullfile(p,f),'dfof_bg');
toc

p = 'C:\Users\nlab\Box Sync\Phil Niell Lab\Example Data';

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

dfof_bg = dfof_bg(xcyc(2)-R:xcyc(2)+R-1,xcyc(1)-R:xcyc(1)+R-1,1001:1250);
for i = 1:size(dfof_bg,3)
    frm = dfof_bg(:,:,i);
    frm(dist>R)=0;
    dfof_bg(:,:,i)=frm;
end
dfshort = (double(dfof_bg(:,:,:)));
dfshort = imresize(dfshort,1,'method','box');
baseline = prctile(dfshort,3,3);
cycle_mov = dfshort - repmat(baseline,[1 1 size(dfshort,3)]);
lowthresh= prctile(cycle_mov(:),2);
upperthresh = prctile(cycle_mov(:),98)*1.25;
cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
mov = immovie(permute(cycMov,[1 2 4 3]));
[f p] = uiputfile('*.mp4','save video file');
vid = VideoWriter(fullfile(p,f),'MPEG-4');
% mov = immovie(permute(shiftmov,[1 2 4 3]));
% vid = VideoWriter('bilateralS1.avi');
vid.FrameRate=25;
vid.Quality = 100;
open(vid);
writeVideo(vid,mov);
close(vid)