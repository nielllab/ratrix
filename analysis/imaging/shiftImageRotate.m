function shiftimg = shiftImage(img,xshift,yshift, thetashift, zoom, width);
xshift;
yshift;
thetashift;
img_range = (-width+1):width;
img = imresize(img,zoom,'bilinear');
img = imrotate(img,thetashift,'bilinear','crop');
padsize = 100;
img = padarray(img,[padsize padsize]);

x0 = round(size(img,1)/2);
y0 = round(size(img,2)/2);
shiftimg = img(img_range + xshift+x0,img_range+yshift+y0,:);