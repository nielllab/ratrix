function showTuning(xtuning,range,cmap,label)
xtuning(xtuning<0)=0;
baseline = min(xtuning,[],3);

%baseline=0;

amp = max(xtuning,[],3);
xphase=0; total=0;
for x=1:size(xtuning,3)
    xphase = xphase+(xtuning(:,:,x)-baseline)*x;
    total = total+ (xtuning(:,:,x)-baseline);
end
xphase=xphase./(total+0.0001);
figure
subplot(2,2,1)
imagesc(xphase,range); colormap(cmap)
subplot(2,2,3)
imagesc(amp);
im = mat2im(xphase,cmap,range);
amp = amp/prctile(amp(:),90);
amp(amp>1)=1;
im = im.*(repmat(amp,[1 1 3]));
subplot(2,2,2);
imshow(im);

subplot(2,2,4)
imagesc(total);
title(label);