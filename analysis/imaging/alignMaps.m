function [imfit xshift yshift zoom] = alignmaps(map,merge,label);
if ~exist('label','var');
    label = [];
end
figure


for i=1:2;
    zoom(i) = 260/size(map{i},1);
      map{i} = imresize(map{i},zoom(i));
      merge{i} = imresize(merge{i},zoom(i));
      subplot(2,2,i)
    imshow(merge{i});
  if i==2
      title(label)      
  end
end

[dx dy] = meshgrid(-45:2:45,-60:2:60);

imrange = -80:80;
x0 = round(size(map{1},1)/2)
y0 = round(size(map{1},2)/2)

im = map{1}(imrange+x0,imrange+y0,:);
match = zeros(size(dx));

for x = 1:size(dx,1);
    for y = 1:size(dy,2);
        imshift = map{2}(imrange + x0 +dx(x,y),imrange + y0 +dy(x,y),:);
        match(x,y) = sum(im(:).*imshift(:));
    end
end


subplot(2,2,3)
imagesc(match)

[m ind] = max(match(:));
xshift = dx(ind)
yshift = dy(ind)

imfit{1} = map{1}(imrange+x0,imrange+y0,:);
imfit{2} = map{2}(imrange+x0+xshift,imrange+y0+yshift,:);


for c = [ 3]
imrgb(:,:,1) = (imfit{1}(:,:,c) + 0.04)/0.1;
imrgb(:,:,2) = (imfit{2}(:,:,c) + 0.04)/0.1;
imrgb(:,:,3) = zeros(size(imrgb(:,:,1)));
subplot(2,2,c+1);
imshow(imrgb);
end
imfit = imfit{2};
zoom = zoom(2);
        