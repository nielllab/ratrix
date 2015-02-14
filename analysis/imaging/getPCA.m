function getPCA(dfof_bg,sp,label)


sz = size(imresize(squeeze(dfof_bg(:,:,1)),0.125));
downsamp = zeros(sz(1),sz(2),size(dfof_bg,3));
for i = 1:size(dfof_bg,3);
downsamp(:,:,i) = imresize(squeeze(dfof_bg(:,:,i)),0.125);
end

obs_mov = downsamp;
baseline = prctile(obs_mov,1,3);
for t = 1:size(obs_mov,3)
    obs_mov(:,:,t) = obs_mov(:,:,t)-baseline;
end


obs = reshape(obs_mov,size(obs_mov,1)*size(obs_mov,2),size(obs_mov,3));
obs(isnan(obs))=0;

display('calculating svd ...')
tic
[u s v] = svd(obs);
toc

spatial=figure; title(label)

for i = 1:3
    figure(spatial)
    subplot(2,3,i);
    range = max(abs(u(:,i)));
if median(u(:,i))<0
    u(:,i)=-u(:,i);
    v(:,i)=-v(:,i);
end
    imagesc(reshape(u(:,i),size(obs_mov,1),size(obs_mov,2)),[-range range]);
    axis equal; axis off
    %colormap(gray);
 
    subplot(2,3,i+3);
    plot(sp/max(sp),'g')
    hold on
    plot(v(:,i)/max(v(:,i)))

  %  xlim([0 100])
    axis off
end


