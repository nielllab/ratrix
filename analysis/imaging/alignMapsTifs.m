%%% reads in results of dfof to show topoX, topoY, and sign maps
%%% overlays them onto tif image of cortex, to allow targeting for 2p or ephys
%%% asks for topox and topo y maps file, and a tif image
%%% outputs matlab fig that can be saved as tif, png etc
%%% cmn 2015 -

clear all

%%% load files
%%% topoX
[f p] = uigetfile('*.mat','topo x');
load(fullfile(p,f),'map','rigzoom');
if length(map)==3
    data(:,:,1) = (map{3});
    size(map{3})
else
    map{1} = imresize(map{1},225/size(map{1},1));
    data(:,:,1) = (map{1});
    size(map{1})
end

%%% topoY
[f p] = uigetfile('*.mat','topo y');
load(fullfile(p,f),'map');
if length(map)==3
    data(:,:,2) = (map{3});
    size(map{3})
else
    map{1} = imresize(map{1},225/size(map{1},1));
    data(:,:,2) = (map{1});
    size(map{1})
end

%%% raw tif image to overlay on
[f p] = uigetfile('*.tif', 'overlay tif');
overlayImg = imread(fullfile(p,f));
rig = input('widefield rig 1 or 2 ? ');
if rig==2
    overlayImg = flip(overlayImg(20:end,:),2);
    s = size(overlayImg); news = round(s*rigzoom);
    overlayImg = overlayImg(round(s(1)/2 - news(1)/2) + 1:news(1), round(s(2)/2 - news(2)/2) + 1:news(2));
    overlayImg = imresize(overlayImg,rigzoom);
end

%%% data(x,y,2) has topoX and topoY periodic maps as complex values
%%% gaussian filter complex map data (need to split into real, imag) 
filtsize = 2;
data = imgaussfilt(real(data),filtsize) + imgaussfilt(imag(data),filtsize)*sqrt(-1);

%%% calculate phase
ph = angle(data);
ph(ph<0)= ph(ph<0)+2*pi;

%%% calculate gradients (for sign map)
resamp=4;
for i = 1:2;
    [x y] = gradient(imresize(ph(:,:,i),1/resamp));
    dx(:,:,i) = imresize(x,[size(ph,1) size(ph,2)])  ; dy(:,:,i)=imresize(y,[size(ph,1) size(ph,2)]);
end

mapsign = dx(:,:,1).*dy(:,:,2) - dy(:,:,1).*dx(:,:,2);
mapsign(isnan(mapsign))=0;

%%% calculate amplitude and normalize sign map
mag = sqrt(dx.^2 + dy.^2);
dx = dx./mag; dy = dy./mag;
gradamp = sqrt(mag(:,:,1).*mag(:,:,2));
mapsign = mapsign./(gradamp.^2);

%%% calculate amps of topoX,Y maps
amp = sqrt(abs(data(:,:,1)).*abs(data(:,:,2)));
amp = amp/prctile(amp(:),95);
amp(amp>1)=1;

%%% create colormap of sign map
dx(isnan(dx))=0; dy(isnan(dy))=0;
green = zeros(64,3); green(:,2)=linspace(0,1,64);
red = zeros(64,3); red(:,1)=linspace(0,1,64);
blue = zeros(64,3); blue(:,3)=linspace(1,0,64);
redgreen = zeros(64,3); redgreen(:,1)=linspace(0,1,64); redgreen(:,2)=linspace(1,0,64);
lim = 0.1;
signmapImg  = mat2im(-dx(:,:,2),blue,[0 lim]) + mat2im(-mapsign,redgreen,[-0.01 0.01]);

%%% prepare tif image for overlay
overlayImg = imresize(overlayImg,[size(ph,1) size(ph,2)]);
overlayImg = double(overlayImg);
overlayImg = overlayImg/prctile(overlayImg(:),99);
overlayImg(overlayImg>1)=1;

%%% ratio of tif vs map
alpha=0.6; beta = 0.4;

%%% create plots
figure
subplot(2,2,1);  %%% raw tif
imshow(overlayImg);
subplot(2,2,2);   %%% sign map
imshow(signmapImg.*repmat(amp,[1 1 3]) *alpha + repmat(overlayImg,[1 1 3])*beta);

%%% topoX,Y
for i= 1:2
im = mat2im(ph(:,:,i),hsv,[0.75*pi 3*pi/2]);   %% scale phase map
subplot(2,2,2+i);
imshow(im.*repmat(amp,[1 1 3]) *alpha + repmat(overlayImg,[1 1 3])*beta);
end

% end
