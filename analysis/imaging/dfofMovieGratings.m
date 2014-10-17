function dfofMovieGratings(in);


%[f,p] = uiputfile('*.avi','dfof cycle average movie file');
if ~exist('in','var') || isempty(in);
    [f,p] = uigetfile({'*.tif'; '*.tiff'; '*.mat'},'choose pco data');
    datafile = fullfile(p,f(1:end-4));
    mapfilename =fullfile(p,[f(1:end-8) 'maps.mat'])
    
else
    datafile = [in '_0001'];
    mapfilename = [in 'maps.mat'];
    [p f] = fileparts(datafile);

end
datadir = p;

[dfof map mapNorm cycMap]= readTifBlueGreenGratings(datafile);
%keyboard
use_chan=3;

% [dfof map mapNorm]= readTifGreen;
% use_chan=1;
% [dfof map mapNorm]= readTifRatio;
% use_chan=3;
dfof_bg= single(dfof{use_chan});
display('saving')
tic
save(mapfilename,'map','mapNorm','dfof_bg','-v7.3')
toc
dfof_bg= dfof{use_chan};
%clear dfof;

startframe =200;
cyc_period = 100;
cycle_mov = zeros(size(dfof_bg,1),size(dfof_bg,2),cyc_period);
cycle_mov_std = zeros(size(dfof_bg,1),size(dfof_bg,2),cyc_period);
for i = 1:cyc_period;
    cycle_mov(:,:,i) = mean(dfof_bg(:,:,i+startframe:cyc_period:end),3);
    cycle_mov_std(:,:,i) = std(dfof_bg(:,:,i+startframe:cyc_period:end),[],3);
end



save(mapfilename,'cycle_mov','cycle_mov_std','cycMap','-append')

baseline = prctile(cycle_mov,5,3);
cycle_mov = cycle_mov - repmat(baseline,[1 1 size(cycle_mov,3)]);
lowthresh= prctile(cycle_mov(:),2);
upperthresh = prctile(cycle_mov(:),98)*1.5;
cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
mov = immovie(permute(cycMov,[1 2 4 3]));
vid = VideoWriter(fullfile(p,f));
% mov = immovie(permute(shiftmov,[1 2 4 3]));
% vid = VideoWriter('bilateralS1.avi');
vid.FrameRate=25;
open(vid);
writeVideo(vid,mov);
close(vid)

dfshort = (double(dfof_bg(:,:,:)));
dfshort = imresize(dfshort,0.5,'method','box');
baseline = prctile(dfshort,3,3);
cycle_mov = dfshort - repmat(baseline,[1 1 size(dfshort,3)]);
lowthresh= prctile(cycle_mov(:),2);
upperthresh = prctile(cycle_mov(:),98)*1.25;
cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
mov = immovie(permute(cycMov,[1 2 4 3]));
vid = VideoWriter(fullfile(p,[f '_RAW']));
% mov = immovie(permute(shiftmov,[1 2 4 3]));
% vid = VideoWriter('bilateralS1.avi');
vid.FrameRate=25;
open(vid);
writeVideo(vid,mov);
close(vid)


% keyboard
% lowthresh = prctile(cycle_mov(:),3)
% upperthresh = 2*prctile(cycle_mov(:),99)
% figure
% for i = 1:size(cycle_mov,3);
%     imagesc(imresize(cycle_mov(:,:,i),0.5,'box'),[lowthresh upperthresh]);
%     colormap(gray);
%     axis equal;
%     mov(i) = getframe(gcf);
% end
%
% vid = VideoWriter(fullfile(p,f));
% vid.FrameRate=25;
% open(vid);
% writeVideo(vid,mov);
% close(vid)


use_speed=0;

fs = dir([datadir '\stim*.mat']);

if ~isempty(fs)
    use_speed=1;
    load(fullfile(datadir,fs(1).name));
    %     figure
    %     plot(stimRec.pos)
    
    mouseT = stimRec.ts- stimRec.ts(2)+0.0001; %%% first is sometimes off
    figure
    plot(diff(mouseT));
    
    dt = diff(mouseT);
    use = [1<0; dt>0];
    mouseT=mouseT(use);
    
    posx = cumsum(stimRec.pos(use,1)-900);
    posy = cumsum(stimRec.pos(use,2)-500);
    frameT = 0.1:0.1:290;
    vx = diff(interp1(mouseT,posx,frameT));
    vy = diff(interp1(mouseT,posy,frameT));
    vx(end+1)=0; vy(end+1)=0;
    
    figure
    plot(vx); hold on; plot(vy,'g');
    sp = sqrt(vx.^2 + vy.^2);
    figure
    plot(sp)
    hold on 
    plot(squeeze(mean(mean(dfof_bg,2),1))*30000,'g')
    figure
    plot(xcorr(sp,mean(mean(dfof_bg,2),1)))
    for i=1:100;
        sp_avg(i) = nanmeanMW(sp(i:100:end)');
        sp_med(i) = nanmedianMW(sp(i:100:end)');
    end
%     sp_all = reshape(sp,[100 30]);
%     figure
%     plot(0.1:0.1:10,sp_all)
%     title('all speeds')
    figure
    plot(0.1:0.1:10,sp_avg)
    title('mean speed')
    ylim([0 2500])
    figure
    plot(0.1:0.1:10,sp_med)
    title('median speed')
    ylim([0 1500])
    
    thresh = [100 ];
    for i = 1:1
        stop_img = mean(dfof_bg(:,:,sp<thresh(i)),3);
        mov_img = mean(dfof_bg(:,:,sp>thresh(i)),3);
        
        figure
        subplot(2,2,1);
        imagesc(stop_img,[-0.2 0.2]);
        subplot(2,2,2);
        imagesc(mov_img,[-0.2 0.2]);
        subplot(2,2,3);
        imagesc(mov_img-stop_img,[-0.05 0.05]);
    end
    
    movemap = mov_img-stop_img;
    
    %[f p] =uiputfile('*.mat','move map file');
    save(mapfilename,'movemap','sp','-append');
end



%keyboard

%
% keyboard
% %% raw movie
%
%
% [f,p] = uiputfile('*.avi','dfof movie file');
% small_mov = dfof_bg(4:4:end,4:4:end,4:4:end);
% lowthresh = prctile(small_mov(:),2);
% upperthresh = 1.5*prctile(small_mov(:),98);
%
% clear mov
% figure
% mov_length = size(dfof_bg,3);
% mov_length=400
% for i = 1:mov_length;
% i
%     imagesc(imresize(dfof_bg(:,:,i+300),0.5,'box'),[lowthresh upperthresh]);
%     colormap(gray);
%    hold on
%     if use_speed
%         if sp(i)<500
%             plot(15,15,'ro','Markersize',8,'Linewidth',8);
%         else
%             plot(15,15,'go','Markersize',8,'Linewidth',8);
%         end
%     end
%     axis equal;
%     if i==1;
%         mov(mov_length) = getframe(gcf); %%%% initializes structure array
%     end
%     mov(i) = getframe(gcf);
%
% end
%
%
% vid = VideoWriter(fullfile(p,f));
% vid.FrameRate=25;
% open(vid);
% writeVideo(vid,mov(1:end));
% close(vid)
%
% clear mov
%
%
% % %%% use svd to get rid of artifacts
% %
% % sz = size(imresize(squeeze(dfof_bg(:,:,1)),0.5));
% % downsamp = zeros(sz(1),sz(2),size(dfof_bg,3));
% % for i = 1:size(dfof_bg,3);
% % downsamp(:,:,i) = imresize(squeeze(dfof_bg(:,:,i)),0.5);
% % end
% %
% % obs_mov = downsamp(:,:,500:2900);
% % obs = reshape(obs_mov,size(obs_mov,1)*size(obs_mov,2),size(obs_mov,3));
% % obs(isnan(obs))=0;
% %
% % tic
% % [u s v] = svd(obs);
% % toc
% %
% % spatial=figure
% % temporal=figure
% % for i = 1:36
% %     figure(spatial)
% %     subplot(6,6,i);
% %     range = max(abs(u(:,i)));
% %
% %     imagesc(reshape(u(:,i),size(obs_mov,1),size(obs_mov,2)),[-range range]);
% %     axis square; axis off
% %     %colormap(gray);
% %     figure(temporal);
% %     subplot(6,6,i);
% %     plot(v(:,i))
% %     axis off
% % end
% %
% % keyboard
% %
% % s_clean = s;
% % rmv = [1 2 3 4 5 7 10 11 12 ];
% % for i = 1:length(rmv)
% %     s_clean(rmv(i),rmv(i))=0;
% % end
% %
% % s_clean(100:end,100:end)=0;
% % % s_clean = zeros(size(s));
% % % kp = [ 5 7  11];
% % % for i = 1:length(kp)
% % %     s_clean(kp(i),kp(i))=s(kp(i),kp(i));
% % % end
% %
% % % s_clean(40:end,40:end)=0;
% %
% %
% % obs_clean = u*s_clean*v';
% %
% % im_clean = reshape(obs_clean,size(obs_mov,1),size(obs_mov,2),size(obs_mov,3));
% % lowthresh=prctile(im_clean(:),1)
% % upperthresh=1.5*prctile(im_clean(:),99)
% %
% % figure
% % for i = 1:size(im_clean,3);
% %     imagesc(im_clean(:,:,i),[lowthresh upperthresh]);
% %     colormap(gray);
% %     axis equal;
% %     mov(i) = getframe(gcf);
% % end
% %
% % [f,p] = uiputfile('*.avi','dfof movie file');
% %
% % vid = VideoWriter(fullfile(p,f));
% % vid.FrameRate=50;
% % open(vid);
% % writeVideo(vid,mov);
% % close(vid)