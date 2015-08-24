load mapOverlay
downsamp = 4;

figure
plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
while 1>0
    [y x] = ginput(1);
  hold off
    imagesc(squeeze(cc_im(round(x),round(y),:,:)));

     hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
end
    