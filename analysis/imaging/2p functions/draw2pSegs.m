function draw2pSegs(usePts,ph,cmap,sz,use,range);
hold on
img = zeros(sz,sz);
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


imshow(img);
axis ij;  colormap(cmap); h=colorbar; set(h,'YTick',[1 64]) ; set(h,'YTickLabel',{num2str(range(1)); num2str(range(2))})
axis([0 sz 0 sz]); axis square