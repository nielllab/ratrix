% function pcaMovies(fname,label)
% load(fname,'dfof_bg','sp')

label='test'

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

d = shiftdim(obs_mov,2); %%% puts time in frot
d= shiftdim(d,-1); % pads a 1 in front
obs_mov = (deconvg6s(d,.1));
obs_mov(isnan(obs_mov))=0;
obs_mov = squeeze(obs_mov);
obs_mov = shiftdim(obs_mov,1);
obs = reshape(obs_mov,size(obs_mov,1)*size(obs_mov,2),size(obs_mov,3));
obs(isnan(obs))=0;



display('calculating svd ...')
tic
[u s v] = svd(obs);
toc

spatial=figure; title(label)
temporal=figure; title(label)
for i = 1:16
    figure(spatial)
    subplot(4,4,i);
    range = max(abs(u(:,i)));

    imagesc(reshape(u(:,i),size(obs_mov,1),size(obs_mov,2)),[-range range]);
    axis equal; axis off
    %colormap(gray);
    figure(temporal);
    subplot(4,4,i);
    plot(v(:,i))
  %  xlim([0 100])
    axis off
end


baseline = prctile(obs(:,:),1,2);
obs_pos= zeros(size(obs));
% for t = 1:size(obs,2);
%     obs_pos(:,t) = obs(:,t)-baseline; 
% end
obs_pos=obs;
obs_pos(obs_pos<0)=0;

nx=4; ny=3;
[u v] = nnmf(obs_pos,nx*ny);

spatial=figure; title(label)
temporal=figure; title(label)
for i = 1:nx*ny
    figure(spatial)
    subplot(nx,ny,i);
    range = max(abs(u(:,i)));

    imagesc(reshape(u(:,i),size(obs_mov,1),size(obs_mov,2)),[0 range]);
    axis equal; axis off
    %colormap(gray);
    figure(temporal);
    subplot(nx,ny,i);
    plot(v(i,:)*range)
    ylim([0 0.25])
  %  xlim([0 100])
   % axis off%
end

[y id] = max(u,2);
id = reshape(id,size(obs_mov,1),size(obs_mov,2));
figure
imagesc(id)
colormap hsv
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