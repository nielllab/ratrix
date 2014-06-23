function pcaMovies(fname,label)
load(fname,'dfof_bg')


sz = size(imresize(squeeze(dfof_bg(:,:,1)),0.25));
downsamp = zeros(sz(1),sz(2),size(dfof_bg,3));
for i = 1:size(dfof_bg,3);
downsamp(:,:,i) = imresize(squeeze(dfof_bg(:,:,i)),0.25);
end

obs_mov = downsamp;
obs_mov(isnan(obs_mov))=0;
obs = reshape(obs_mov,size(obs_mov,1)*size(obs_mov,2),size(obs_mov,3));
obs(isnan(obs))=0;



display('calculating svd ...')
tic
[u s v] = svd(obs);
toc

spatial=figure; title(label)
temporal=figure; title(label)
for i = 1:4
    figure(spatial)
    subplot(2,2,i);
    range = max(abs(u(:,i)));

    imagesc(reshape(u(:,i),size(obs_mov,1),size(obs_mov,2)),[-range range]);
    axis equal; axis off
    %colormap(gray);
    figure(temporal);
    subplot(2,2,i);
    plot(v(:,i))
  %  xlim([0 100])
    axis off
end

figure
plot(sp)
title(sprintf('%s running',label))

% keyboard
% 
% s_clean = s;
% rmv = [ 1];
% for i = 1:length(rmv)
%     s_clean(rmv(i),rmv(i))=0;
% end
% 
% %s_clean(100:end,100:end)=0;
% % s_clean = zeros(size(s));
% % kp = [ 5 7  11];
% % for i = 1:length(kp)
% %     s_clean(kp(i),kp(i))=s(kp(i),kp(i));
% % end
% 
% % s_clean(40:end,40:end)=0;
% 
% 
% obs_clean = u*s_clean*v';
% 
% im_clean = reshape(obs_clean,size(obs_mov,1),size(obs_mov,2),size(obs_mov,3));
% 
% 
% [rawmap rawcycMap fullMov] =phaseMap(im_clean,10,10,1);
%     rawmap(isnan(rawmap))=0;
%    f=figure
%    imshow(imresize(polarMap(rawmap),4));