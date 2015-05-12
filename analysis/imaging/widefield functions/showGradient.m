function showGradient(data,amp,xpts,ypts);
resamp=4;
for i = 1:2;
    datasample = imresize(data(:,:,i),1/resamp,'method','box');
    [x y] = gradient(datasample);
    dx(:,:,i) = imresize(x,resamp); dy(:,:,i)=imresize(y,resamp);
end



mapsign = dx(:,:,1).*dy(:,:,2) - dy(:,:,1).*dx(:,:,2);
mapsign(isnan(mapsign))=0;


mag = sqrt(dx.^2 + dy.^2);
dx = dx./mag; dy = dy./mag;

gradamp = sqrt(mag(:,:,1).*mag(:,:,2));
%gradamp = mag(:,:,2);
% figure
% imagesc(gradamp);
%amp(amp<0.1)=0;
mapsign = mapsign./(gradamp.^2);
% figure
% imagesc(mapsign,[-1 1]);
% hold on; plot(ypts,xpts,'w.','Markersize',2)
% 
% figure
% imshow(repmat(amp,[1 1 3]))
% hold on; plot(ypts,xpts,'w.','Markersize',2)

cmap = zeros(64,3);
cmap(:,1) = linspace(0,1,64); cmap(:,2)=linspace(1,0,64); cmap(:,3)=linspace(1,0,64);
% figure
% imshow(mat2im(mapsign,cmap,[-0.0001 0.0001]).*repmat(amp,[1 1 3]));
% hold on; plot(ypts,xpts,'w.','Markersize',2)

dx(isnan(dx))=0; dy(isnan(dy))=0;
green = zeros(64,3); green(:,2)=linspace(0,1,64);
red = zeros(64,3); red(:,1)=linspace(0,1,64);
blue = zeros(64,3); blue(:,3)=linspace(1,0,64);

redgreen = zeros(64,3); redgreen(:,1)=linspace(0,1,64); redgreen(:,2)=linspace(1,0,64);

mapsign(isnan(mapsign))=0;

lim = 0.1;
%im  = mat2im(dx(:,:,1),blue,[-lim lim]) + mat2im(dy(:,:,1),red,[-lim lim]) + mat2im(-mapsign,green,[-0.0001 0.0001]);
im  = mat2im(-dx(:,:,2),blue,[0 lim]) + mat2im(-mapsign,redgreen,[-0.01 0.01]);
% figure
% imagesc(amp)


%figure
imshow(im.*repmat(amp,[1 1 3]));
hold on; plot(ypts,xpts,'w.','Markersize',2)

allwhite = ones(size(im));
gradamp = repmat(gradamp,[1 1 3])/0.12;
gradamp(gradamp>1)=1;


imshow((im.*gradamp + allwhite.*(1-gradamp)).*repmat(amp,[1 1 3]));
hold on; plot(ypts,xpts,'w.','Markersize',2)



