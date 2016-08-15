function cellPh = getMapPhase(map,cropx,cropy, usePts)
%%% takes topo map, removes cells, filters, 
%%% and gets phase for each cell location
ph = mod(angle(map),2*pi);
figure
subplot(2,2,1); imagesc(ph); colormap hsv

ph = ph(cropx(1):cropx(2),cropy(1):cropy(2));

subplot(2,2,2); imagesc(ph,[0 2*pi]), colormap hsv

maskPh = ph;
for i = 1:length(usePts);
    [x y] = ind2sub(size(ph),usePts{i});
    for j = 1:length(x)
        maskPh(x(j),y(j)) = NaN;
    end
end

subplot(2,2,3); imagesc(maskPh),colormap hsv
    
filt = fspecial('disk',10);
filtPh = nanconv(maskPh,filt,'edge');

subplot(2,2,4);imagesc(filtPh,[0 2*pi]); colormap hsv

fillPh = ph;
for i = 1:length(usePts);
    [x y] = ind2sub(size(ph),usePts{i});
    cellPh(i) = mean(mean(filtPh(x,y)));
    fillPh(usePts{i}) = cellPh(i);
end
% figure
% imagesc(fillPh,[0 2*pi]); colormap hsv