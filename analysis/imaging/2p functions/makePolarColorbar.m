dx = 0.02;
[x y] = meshgrid(0:dx:1,-1:dx:1);

theta= atan2(x,y);
r= (x.^2 + y.^2);
im = mat2im(theta,hsv,[0 pi]);
figure
imshow(im);

white = ones(size(im(:,:,1)));
for c = 1:3
    im(:,:,c) = white.*(1-r) + im(:,:,c).*r;
end
figure
imshow(im);