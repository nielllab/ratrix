clear all
pack

[f,p] = uiputfile('*.avi','dfof cycle average movie file');

[dfof map mapNorm]= readTifBlueGreen;
save(fullfile(p,[f(1:end-4) 'maps.mat']),'map','mapNorm','-v7.3')
dfof_bg=dfof{3};
clear dfof;



startframe =200;
cyc_period = 100;
cycle_mov = zeros(size(dfof_bg,1),size(dfof_bg,2),cyc_period);
for i = 1:cyc_period;
    cycle_mov(:,:,i) = mean(dfof_bg(:,:,i+startframe:cyc_period:end),3);
end

save(fullfile(p,[f(1:end-4) 'maps.mat']),'cycle_mov','-append')

baseline = prctile(cycle_mov,2,3);

for i = 1:cyc_period;
    cycle_mov(:,:,i)=cycle_mov(:,:,i) - baseline;
end
    
lowthresh = prctile(cycle_mov(:),1)
upperthresh = 1.5*prctile(cycle_mov(:),99)
figure
for i = 1:size(cycle_mov,3);
    imagesc(imresize(cycle_mov(:,:,i),0.5,'box'),[lowthresh upperthresh]);
    colormap(gray);
    axis equal;
    mov(i) = getframe(gcf);
end

vid = VideoWriter(fullfile(p,f));
vid.FrameRate=25;
open(vid);
writeVideo(vid,mov);
close(vid)


[f,p] = uigetfile('*.mat','stim object file');
load(fullfile(p,f));
figure
plot(stimRec.pos)

posx = cumsum(stimRec.pos(:,1)-900);
posy = cumsum(stimRec.pos(:,2)-500);
frameT = 0.1:0.1:300;
vx = diff(interp1(stimRec.ts(1:9000)-stimRec.ts(1),posx(1:9000),frameT));
vy = diff(interp1(stimRec.ts(1:9000)-stimRec.ts(1),posy(1:9000),frameT));
vx(end+1)=0; vy(end+1)=0;

figure
plot(vx); hold on; plot(vy,'g');
sp = sqrt(vx.^2 + vy.^2);


%% raw movie
small_mov = dfof_bg(4:4:end,4:4:end,4:4:end);
lowthresh = prctile(small_mov(:),2);
upperthresh = prctile(small_mov(:),98);

clear mov
figure
for i = 1:size(dfof_bg,3);
    imagesc(imresize(dfof_bg(:,:,i),0.5,'box'),[lowthresh upperthresh]);
    colormap(gray);
    hold on
    
       if sp(i)<500
       plot(15,15,'ro','Markersize',8,'Linewidth',8);
   else
       plot(15,15,'go','Markersize',8,'Linewidth',8); 
   end
    axis equal;
    mov(i) = getframe(gcf);

end

[f,p] = uiputfile('*.avi','dfof movie file');

vid = VideoWriter(fullfile(p,f));
vid.FrameRate=50;
open(vid);
writeVideo(vid,mov(1:3000));
close(vid)

clear mov


% %%% use svd to get rid of artifacts
% 
% sz = size(imresize(squeeze(dfof_bg(:,:,1)),0.5));
% downsamp = zeros(sz(1),sz(2),size(dfof_bg,3));
% for i = 1:size(dfof_bg,3);
% downsamp(:,:,i) = imresize(squeeze(dfof_bg(:,:,i)),0.5);
% end
% 
% obs_mov = downsamp(:,:,500:2900);
% obs = reshape(obs_mov,size(obs_mov,1)*size(obs_mov,2),size(obs_mov,3));
% obs(isnan(obs))=0;
% 
% tic
% [u s v] = svd(obs);
% toc
% 
% spatial=figure
% temporal=figure
% for i = 1:36
%     figure(spatial)
%     subplot(6,6,i);
%     range = max(abs(u(:,i)));
%     
%     imagesc(reshape(u(:,i),size(obs_mov,1),size(obs_mov,2)),[-range range]);
%     axis square; axis off
%     %colormap(gray); 
%     figure(temporal);
%     subplot(6,6,i);
%     plot(v(:,i))
%     axis off
% end
% 
% keyboard
% 
% s_clean = s;
% rmv = [1 2 3 4 5 7 10 11 12 ];
% for i = 1:length(rmv)
%     s_clean(rmv(i),rmv(i))=0;
% end
% 
% s_clean(100:end,100:end)=0;
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
% lowthresh=prctile(im_clean(:),1)
% upperthresh=1.5*prctile(im_clean(:),99) 
% 
% figure
% for i = 1:size(im_clean,3);
%     imagesc(im_clean(:,:,i),[lowthresh upperthresh]);
%     colormap(gray);
%     axis equal;
%     mov(i) = getframe(gcf);
% end
% 
% [f,p] = uiputfile('*.avi','dfof movie file');
% 
% vid = VideoWriter(fullfile(p,f));
% vid.FrameRate=50;
% open(vid);
% writeVideo(vid,mov);
% close(vid)