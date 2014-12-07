gc_red = imread('F:\Axon Scope Data\Axon Gondry (red)\flavitest\Gcamp6\101314_G62H1TT\G62H1TT_stepBinary_50ms_Gondry_0001.tif');
gc_green= fliplr(imread('F:\Axon Scope Data\Axon Woody (green)\flavotest\Gcamp6\101314 G62H1TT\G62H1TT_stepBinary_50ms_Woody_000001.tif'));

wt_green =fliplr( imread('F:\Axon Scope Data\Axon Woody (green)\flavotest\Gcamp6\101314 CTTA22\CTTA22_stepBinary_50ms_Woody_000001.tif'));
wt_red = imread('F:\Axon Scope Data\Axon Gondry (red)\flavitest\Gcamp6\101314 CTTA22\CTTA22_stepBinary_50ms_Gondry_0001.tif');

lp_red = imread('F:\Axon Scope Data\Axon Gondry (red)\flavitest\Gcamp6\101314 J144_LP\J144_LP_stepBinary_50ms_Gondry_0001.tif');
lp_green = fliplr(imread('F:\Axon Scope Data\Axon Woody (green)\flavotest\Gcamp6\101314 J144 LP\J144_LP_stepBinary_50ms_Woody_000001.tif'));


im = zeros(size(gc_green,1),size(gc_green,2),3,'uint16');
im(:,:,1) = gc_red;
im(:,:,2) = gc_green;
figure
imshow(im)

[y x] = ginput(1);
gc = squeeze(mean(mean(im(x-5:x+5,y-5:y+5,:),2),1));
gc = gc/max(gc)

im = zeros(size(gc_green,1),size(gc_green,2),3,'uint16');
im(:,:,1) = wt_red;
im(:,:,2) =wt_green;
figure
imshow(3*im)

[y x] = ginput(1);
wt = squeeze(mean(mean(im(x-5:x+5,y-5:y+5,:),2),1))
wt= wt/max(wt)

mix = [1 0.67; 0.67 1];
mix = [1 0.67; 0.67 1]/1.67;  %%% should actually be normalizing by each row to get dfof

mix = [1 1; 1.7 1]
unmix = mix^-1
clear img
img(1,:)= double(lp_red(:));
img(2,:) = double(lp_green(:));
im_unmix = unmix*img;

img_unmix(:,:,1) = reshape(im_unmix(1,:),size(gc_red,1),size(gc_red,2));
img_unmix(:,:,2) = reshape(im_unmix(2,:),size(gc_red,1),size(gc_red,2));
img_unmix(:,:,3)=0;
img_unmix = 5*img_unmix/max(img_unmix(:));
figure
imshow(img_unmix)

