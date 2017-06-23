%%% reads in 2-color data and creates avi movie
%%% puts first channel into green, second into red

[f p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');
fname = fullfile(p,f);
img = readAlign2p(fname,1,1,0.5);  %%% filename, align = yes, showimg=yes, filter width = 0.5

green = img(5:5:end,5:5:end,5:5:end);
rangegreen = [0 prctile(green(:),99)*1.2];

fullMov= mat2im(imresize(img(1:end-25,1:end-25,:),2),gray,rangegreen);
mov = immovie(permute(fullMov,[1 2 4 3]));

mov = immovie(permute(fullMov,[1 2 4 3]));
vid = VideoWriter(sprintf('%sfullMov.avi',fname(1:end-4)));
vid.FrameRate=15;

vid.Quality=80;
open(vid);
writeVideo(vid,mov);
close(vid)

figure
mean_im = squeeze(mean(fullMov,3));
size(mean_im)
imshow(mean_im)