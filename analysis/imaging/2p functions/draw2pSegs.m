function draw2pSegs(usePts,ph,cmap,sz,use,range);
hold on
if isscalar(sz)    
img = zeros(sz,sz);
else
    img = zeros(sz(1),sz(2));
end

for i = 1:3
    subimg{i}=img;
end
for i = 1:length(use)
   col = cmapVar(ph(use(i)),range(1),range(2),cmap);
   for j = 1:3
       subimg{j}(usePts{use(i)}) = col(j);
   end
end
for i = 1:3
    img(:,:,i) = subimg{i};
end


imshow(imresize(img,8));
axis ij;  colormap(cmap); h=colorbar; set(h,'YTick',[0 0.5 1]) ; set(h,'YTickLabel',{num2str(range(1)); num2str(0.5*(range(1)+range(2))); num2str(range(2))})
