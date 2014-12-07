%%% generates figures for effect of blue-green subtraction
figure
clear cyc
for i = 1:3
    %subplot(2,2,i);
    figure
    imshow(polarMap(map{i},99));
    axis square; axis equal; axis off
    for t = 1:100;
        cyc(:,:,t,i) = mean(dfof{i}(:,:,t:100:end),3);
    end
    
end
mapfig = figure
imshow(polarMap(map{1}));

range = -2:2
for i =1:10
    figure(mapfig)
    [y x] = ginput(1); y= round(y); x= round(x);
    figure
    data = squeeze(mean(mean((cyc(x+range,y+range,:,:)),2),1));
    plot(circshift(data -repmat(min(data),100,1),-40));
end
        