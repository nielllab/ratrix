function [xphase amp  xtuning] = getPixelTuning(trialdata, xpos,label, range, cmap);

xrange = unique(xpos);
for x=1:length(xrange);
    xtuning(:,:,x) = median(trialdata(:,:,find(xpos==xrange(x))),3); %%% taking median
end
xtuning(xtuning<0)=0; %%% set values below zero to zero
baseline = min(xtuning,[],3);
if length(xrange)<=2
    baseline=0;
end
baseline=0;  %%% no baseline subtraction

amp = max(xtuning,[],3);
xphase=0; total=0;
for x=1:length(xrange)
    xphase = xphase+(xtuning(:,:,x)-baseline)*x;
    total = total+ (xtuning(:,:,x)-baseline);
end
xphase=xphase./(total+0.0001);
amp = amp/prctile(amp(:),90);
amp(amp>1)=1;


% subplot(2,2,1)
% imagesc(xphase,range); colormap(cmap)
im = mat2im(xphase,cmap,range);
% subplot(2,2,3)
% imagesc(amp);

im = im.*(repmat(amp,[1 1 3]));
% subplot(2,2,2);
imshow(im);
title(label);
set(gca,'LooseInset',get(gca,'TightInset'))

% subplot(2,2,4)
% imagesc(total);
% title(label);

% phmap=figure;
% imagesc(xphase,range,cmap); 
% 
% for i = 1:10
%     figure(phmap);
%     [y x] = ginput(1);
%     figure
%     plot(squeeze(xtuning(round(x),round(y),:)));
%     xphase(round(x),round(y))
% end

