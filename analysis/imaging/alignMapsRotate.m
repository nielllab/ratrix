function [imfit xshift yshift thetashift zoom] = alignmaps(map,merge,label);
if ~exist('label','var');
    label = [];
end
showImg =1;
if showImg
    figure
end

for i=1:2;
    zoom(i) = 260/size(map{i},1);
      map{i} = imresize(map{i},zoom(i));
      merge{i} = imresize(merge{i},zoom(i));
   if showImg   subplot(2,2,i)
    imshow(merge{i});
  if i==2
      title(label)      
  end
   end
end

alltheta = -10:5:10;
[dx dy dtheta] = meshgrid(-54:2:54,-60:2:60, alltheta);

imrange = -75:75;
x0 = round(size(map{1},1)/2);
y0 = round(size(map{1},2)/2);

im = map{1}(imrange+x0,imrange+y0,:);
match = zeros(size(dx));


for theta = 1:length(alltheta)
theta; 
imrot = imrotate(map{2},alltheta(theta),'bilinear','crop');
% figure
% imagesc(imrot(:,:,1))
for x = 1:size(dx,1);
    for y = 1:size(dy,2);
        imshift = imrot(imrange + x0 +dx(x,y, theta),imrange + y0 +dy(x,y,theta),:);
        match(x,y,theta) = sum(im(:).*imshift(:));
    end
end
end

if showImg
subplot(2,2,3)
imagesc(match(:,:,round(length(alltheta)/2)))
end

[m ind] = max(match(:));
xshift = dx(ind);
yshift = dy(ind);
thetashift = dtheta(ind);


imfit{1} = map{1}(imrange+x0,imrange+y0,:);
maprotate = imrotate(map{2},thetashift,'bilinear','crop');
imfit{2} = maprotate(imrange+x0+xshift,imrange+y0+yshift,:);


for c = [ 3]
imrgb(:,:,1) = (imfit{1}(:,:,c) + 0.04)/0.1;
imrgb(:,:,2) = (imfit{2}(:,:,c) + 0.04)/0.1;
imrgb(:,:,3) = zeros(size(imrgb(:,:,1)));
if showImg
    subplot(2,2,c+1);
imshow(imrgb);
end
end
imfit = imfit{2};
zoom = zoom(2);
        