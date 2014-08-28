function [amp xphase xtuning] = getPixelTuning(trialdata, xpos,label);

xrange = unique(xpos);
for x=1:length(xrange);
    xtuning(:,:,x) = median(trialdata(:,:,find(xpos==xrange(x))),3);
end
baseline = min(xtuning,[],3);
amp = max(xtuning,[],3);
for x=1:length(xrange)
    xphase = xphase+(xtuning(:,:,x)-baseline)*x;
    total = total+ (xtuning(:,:,x)-baseline);
end
xphase=xphase./total;
figure
subplot(2,2,1)
imagesc(xphase);
im = mat2im(xphase,jet,[1 length(xrange)]);
im = im.*amp/prctile(amp(:),95);
subplot(2,2,2)
imshow(im);
subplot(2,2,3)
imagesc(amp);
subplot(2,2,4)
imagesc(total);
title(label);
