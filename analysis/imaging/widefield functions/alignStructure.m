[f p ] = uigetfile('*.mat','maps file');
load(fullfile(p,f),'map');
[f p ] = uigetfile('*.tif','tdt image');
im = imread(fullfile(p,f));



topo=fliplr(polarMap(map{1},98));
topo = imresize(topo,size(im,1)/size(topo,1));
topo = topo(150:350,200:400,:);
im = im(150:350,200:400,:);
figure
subplot(2,2,1);
imshow(topo);
subplot(2,2,2);
imagesc(im); colormap gray; axis equal

callosal = im>2800;
subplot(2,2,3);
imagesc(callosal); axis equal

subplot(2,2,4);
imshow(topo);
hold on
h = imagesc(callosal);
set(h,'alphadata',callosal>0);


