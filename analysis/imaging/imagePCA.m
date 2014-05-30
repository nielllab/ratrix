for i = 1:2
    [f,p] = uigetfile('*.tif');
    im = imread(fullfile(p,f));
    img{i} = double(imresize(im,0.25));
end

figure
imagesc(img{1});
[y x] = ginput(2)
imgcrop{1} = img{1}(x(1):x(2),y(1):y(2));
imgcrop{2} = img{2}(x(1):x(2),y(1):y(2));
figure
imagesc(imgcrop{1})

figure
plot(imgcrop{1}(:),imgcrop{2}(:),'.');

data = [imgcrop{1}(:) imgcrop{2}(:)];

[coeff, score] =princomp(data);
for i = 1:2
    im = reshape(score(:,i),size(imgcrop{1}));
    figure
    imagesc(im,[prctile(im(:),2) prctile(im(:),98)]); colormap gray
end