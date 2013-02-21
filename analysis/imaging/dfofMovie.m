dfof = readTifBlueGreen;

dfof_bg=dfof{3};
figure

downsamp = dfof_bg(2:2:end,2:2:end,2:2:end);
lowthresh = prctile(downsamp(:),2.5)
upperthresh = prctile(downsamp(:),97.5)



figure
for i = 1:size(dfof_bg,3);
    imagesc(imresize(dfof_bg(:,:,i),0.5,'box'),[lowthresh upperthresh]);
    colormap(gray);
    axis equal;
    mov(i) = getframe(gcf);
end

[f,p] = uiputfile('*.avi','dfof movie file');

vid = VideoWriter(fullfile(p,f));
vid.FrameRate=50;
open(vid);
writeVideo(vid,mov);
close(vid)


%%% use svd to get rid of artifacts
obs_mov = downsamp;
obs = reshape(obs_mov,size(obs_mov,1)*size(obs_mov,2),size(obs_mov,3));
obs(isnan(obs))=0;

tic
[u s v] = svd(obs);
toc

spatial=figure
temporal=figure
for i = 1:64
    figure(spatial)
    subplot(8,8,i);
    imagesc(reshape(u(:,i),size(obs_mov,1),size(obs_mov,2)));
    axis square; axis off
    colormap(gray); 
    figure(temporal);
    subplot(8,8,i);
    plot(v(:,i))
    axis off
end

s_clean = s;
s_clean(2,2)=0;
s_clean(1,1)=0;

obs_clean = u*s_clean*v';

im_clean = reshape(obs_clean,size(obs_mov,1),size(obs_mov,2),size(obs_mov,3));
lowthresh=prctile(im_clean(:),2.5);
upperthresh=prctile(im_clean(:),97.5);

figure
for i = 1:size(im_clean,3);
    imagesc(imresize(im_clean(:,:,i),1,'box'),[lowthresh upperthresh]);
    colormap(gray);
    axis equal;
    mov(i) = getframe(gcf);
end