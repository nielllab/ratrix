function shiftimg = shiftImage(img,xshift,yshift, zoom, width);
xshift
yshift
img_range = -width:width;
img = imresize(img,zoom,'bilinear');
x0 = round(size(img,1)/2);
y0 = round(size(img,2)/2);
shiftimg = img(img_range + xshift+x0,img_range+yshift+y0,:);