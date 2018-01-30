%%% reads in 2-color data and creates avi movie
%%% puts first channel into green, second into red
if ~exist('fname','var')
[f p] = uigetfile({'*.tif'},'.tif file');
fname = fullfile(p,f);
end

if ~exist('usered','var')
    usered = input('include red channel?');
end

opt.saveFigs =0;
opt.align=1;
opt.ZBinning = 0;
opt.Rotation =0;
opt.MakeMov=0;
opt.SaveFigs=0;
opt.fwidth=0.5;
opt.AlignmentChannel=1;
opt.clip =1;
img = readAlign2color(fname,opt);  %%% filename, align = yes, showimg=yes, filter width = 0.5

fullMov = zeros(size(img));
fullMov(:,:,:,3)=0;

red = img(5:5:end,5:5:end,5:5:end,2);
rangered = [0 prctile(red(:),99)*1.6];
green = img(5:5:end,5:5:end,5:5:end,1);
rangegreen = [prctile(green(:),1) prctile(green(:),99)*1.2];

if usered
    fullMov(:,:,:,1) = (img(:,:,:,2) - rangered(1))/(rangered(2)-rangered(1));
end
fullMov(:,:,:,2) = (img(:,:,:,1) - rangegreen(1))/(rangegreen(2)-rangegreen(1));
figure
mean_im = squeeze(mean(fullMov,3));
size(mean_im)
imshow(mean_im)

mov = immovie(permute(fullMov,[1 2 4 3]));
%mov=mov(1:850)
vid = VideoWriter(sprintf('%sfullMov_g_low.avi',fname(1:end-4)));
vid.FrameRate=20;

vid.Quality=90;
open(vid);
writeVideo(vid,mov);
close(vid)

