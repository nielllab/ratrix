[frameT out] = readTifStandalone;
m = repmat(mean(double(out),3),[1 1 size(out,3)]);
dfof = (double(out)-m)./m;
clear m


figure
for i = 1:size(dfof,3);
    imagesc(imresize(dfof(:,:,i),0.5,'box'),[-0.05 0.05]);
    colormap(gray);
    axis equal;
    mov(i) = getframe(gcf);
end

vid = VideoWriter('0831_binned');
vid.FrameRate=50;
open(vid);
writeVideo(vid,mov);
close(vid)