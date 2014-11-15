function img_interp = getLine(img)

figure
imagesc(img);


[y x] = ginput(2);
dist = sqrt(diff(x)^2 + diff(y)^2);
xpts = x(1) + (1:dist)*diff(x)/dist;
ypts = y(1)+ (1:dist)*diff(y)/dist;

img_interp = interp2(img',xpts,ypts);
figure
plot(img_interp);


