[f p ] = uigetfile('*.mat','maps file');
load(fullfile(p,f),'map');
[f p ] = uigetfile('*.tif','tdt image');
im = imread(fullfile(p,f));
im= double(im);
[f p ] = uigetfile('*.tif','green image');
imgr = imread(fullfile(p,f));
imgr = double(fliplr(imgr));


figure
imshow(imgr)


figure
imshow(im)

merge= zeros(size(im,1),size(im,2),3);
merge(:,:,1) = im/max(im(:));
merge(:,:,2)=5*imgr/max(imgr(:));
figure
imshow(merge)
im = im/max(im(:));
imgr= imgr/max(imgr(:));
[optimizer, metric] = imregconfig('multimodal');
tform = imregtform(im,imgr,'rigid',optimizer,metric)

imReg = imwarp(im,tform,'OutputView',imref2d(size(imgr)));
figure
imshow(imReg)

merge= zeros(size(im,1),size(im,2),3);
merge(:,:,1) = imReg/max(imReg(:));
merge(:,:,2)=3*imgr/max(imgr(:));
figure
imshow(merge)

topo=fliplr(polarMap(map{1},99));
topo = imresize(topo,size(im,1)/size(topo,1));
topo = topo(145:345,240:440,:);
imgrcrop = imgr(145:345,240:440,:);
imcrop = im(150:350,250:450,:);
figure
subplot(2,2,1);
imshow(topo);
subplot(2,2,2);
imagesc(imcrop);  axis equal
lim = get(gca,'clim');
callosal = imcrop>0.5;
% subplot(2,2,3);
% imagesc(callosal); axis equal
subplot(2,2,3);
imagesc(imgrcrop); colormap gray; axis equal

subplot(2,2,4);
imshow(topo);
hold on
h = imagesc(imcrop,lim); colormap hot
set(h,'alphadata',(imcrop>0.75) );


