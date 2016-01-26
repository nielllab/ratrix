blue = imread('blue illumination 200ms_0001.tif');
green = imread('green illumination 200ms_0001.tif');
blue = double(blue); green= double(green);
figure
plot(blue(:),green(:),'.');

figure
imagesc(green)

[x y] = meshgrid(1:640,1:540);
r = (x-300).^2 + (y-270).^2; r = sqrt(r);

bluecrop = blue.*(r<200); greencrop = green.*(r<200);

figure
imagesc(bluecrop)

figure
plot(bluecrop(:),greencrop(:),'.')
axis equal
hold on
plot([0 20000],[0 10000])

td = greencrop - 0.5*bluecrop;

figure
imagesc(td)

figure
plot(x(:),td(:),'.')
tdbalance = td - 12*x + 4500; tdbalance(r>140)=0; tdbalance(tdbalance<0)=0;
f = fspecial('gaussian',[20 20],3); f= f/sum(f(:));
tdbalance = imfilter(tdbalance,f);

figure
imagesc(tdbalance);
colormap gray

im = mat2im(tdbalance,gray);
im(:,:,2)=0;
im(:,:,3)=0;
figure
imshow(im)


% figure
% plot(x(:),tdbalance(:),'.')
