clear all

[f p] = uigetfile('*.mat','topo x');
load(fullfile(p,f),'map');
data(:,:,1) = (map{3});
size(map{3})
[f p] = uigetfile('*.mat','topo y');
load(fullfile(p,f),'map');
data(:,:,2) = (map{3});
size(map{3})

for multipleTifs=1:3

[f p] = uigetfile('*.tif', 'overlay tif');
overlayImg = imread(fullfile(p,f));

ph = angle(data);
ph(ph<0)= ph(ph<0)+2*pi;

resamp=4;
for i = 1:2;
    [x y] = gradient(imresize(ph(:,:,i),1/resamp));
    dx(:,:,i) = imresize(x,[size(ph,1) size(ph,2)])  ; dy(:,:,i)=imresize(y,[size(ph,1) size(ph,2)]);
end

mapsign = dx(:,:,1).*dy(:,:,2) - dy(:,:,1).*dx(:,:,2);
mapsign(isnan(mapsign))=0;

mag = sqrt(dx.^2 + dy.^2);
dx = dx./mag; dy = dy./mag;
gradamp = sqrt(mag(:,:,1).*mag(:,:,2));
mapsign = mapsign./(gradamp.^2);

amp = sqrt(abs(data(:,:,1)).*abs(data(:,:,2)));
amp = amp/prctile(amp(:),99);
amp(amp>1)=1;

dx(isnan(dx))=0; dy(isnan(dy))=0;
green = zeros(64,3); green(:,2)=linspace(0,1,64);
red = zeros(64,3); red(:,1)=linspace(0,1,64);
blue = zeros(64,3); blue(:,3)=linspace(1,0,64);
redgreen = zeros(64,3); redgreen(:,1)=linspace(0,1,64); redgreen(:,2)=linspace(1,0,64);

lim = 0.1;
im  = mat2im(-dx(:,:,2),blue,[0 lim]) + mat2im(-mapsign,redgreen,[-0.01 0.01]);

overlayImg = imresize(overlayImg,[size(ph,1) size(ph,2)]);
overlayImg = double(overlayImg);
overlayImg = overlayImg/prctile(overlayImg(:),99);
overlayImg(overlayImg>1)=1;
alpha=0.6; beta = 0.4;
figure
subplot(2,2,1);
imshow(overlayImg);
subplot(2,2,2);
imshow(im.*repmat(amp,[1 1 3]) *alpha + repmat(overlayImg,[1 1 3])*beta);
for i= 1:2
im = mat2im(ph(:,:,i),hsv,[0.75*pi 3*pi/2]);
subplot(2,2,2+i);
imshow(im.*repmat(amp,[1 1 3]) *alpha + repmat(overlayImg,[1 1 3])*beta);
end

end
