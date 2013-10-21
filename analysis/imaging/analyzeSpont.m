clear all
pack

[f,p] = uiputfile('*.avi','dfof cycle average movie file');

%[dfof map mapNorm]= readTifBlueGreen;
% use_chan=3;
[dfof map mapNorm]= readTifBlueGreen;
keyboard
use_chan=3;
save(fullfile(p,[f(1:end-4) 'maps.mat']),'map','mapNorm','-v7.3')
dfof_bg=dfof{use_chan};
clear dfof;


psfilename = fullfile(p,[f(1:end-4) '.ps']);
if exist(psfilename,'file')==2;delete(psfilename);end

use_speed=0;

[f,p] = uigetfile('*.mat','map points');
if f~=0
    load(fullfile(p,f))
end

[f,p] = uigetfile('*.mat','stim object file');
if f~=0
    use_speed=1;
    load(fullfile(p,f));
    figure
    plot(stimRec.pos)
    
    posx = cumsum(stimRec.pos(:,1)-900);
    posy = cumsum(stimRec.pos(:,2)-500);
    frameT = 0.1:0.1:300;
    
    uniqueT = find(diff(stimRec.ts)>0)+1;
    vx = diff(interp1(stimRec.ts(uniqueT)-stimRec.ts(1),posx(uniqueT),frameT));
    vy = diff(interp1(stimRec.ts(uniqueT)-stimRec.ts(1),posy(uniqueT),frameT));
    vx(end+1)=0; vy(end+1)=0;
    
    figure
    plot(vx); hold on; plot(vy,'g');
    sp = sqrt(vx.^2 + vy.^2);
end;

figure
stdimg = std(dfof_bg,[],3);
range = prctile(stdimg(:),99);
imagesc(stdimg,[0 range]);
axis equal

%%% speed triggered average
if use_speed    
    figure
    speedDiff = mean(dfof_bg(:,:,sp>500),3) - mean(dfof_bg(:,:,sp<500),3);
    range = prctile(abs(speedDiff(:)),99);
    imagesc(speedDiff,[-range range]);
    colorbar
    axis equal
    hold on
    if exist('pts','var')
        plot(pts(:,2),pts(:,1),'b*')
    end
    set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

    figure
    spcorr = imgcorr(sp,dfof_bg);
    range = prctile(abs(spcorr(:)),99);
    if isnan(range) 
        range = 0.1;
    end
    imagesc(spcorr,[-range range]);
    axis equal
    colorbar
    set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

end

%%% seed pix correlation
mapfig =figure
imagesc(dfof_bg(:,:,100));
colormap(gray)
done =0
squeeze_mat = reshape(dfof_bg,size(dfof_bg,1)*size(dfof_bg,2),size(dfof_bg,3));

while ~done
    [y x b] = ginput(1);
    if b==3 %%%% right click
        done=1;
        break;
    end
    seed_corr = corr(squeeze(dfof_bg(round(x),round(y),:)),squeeze_mat');
    seed_corr_img = reshape(seed_corr,size(dfof_bg,1),size(dfof_bg,2));
    figure
    imagesc(seed_corr_img);
end


%%% svd analysis of motifs
downsize = 0.5;
sz = size(imresize(squeeze(dfof_bg(:,:,1)),downsize));
downsamp = zeros(sz(1),sz(2),size(dfof_bg,3));
for i = 1:size(dfof_bg,3);
    downsamp(:,:,i) = imresize(squeeze(dfof_bg(:,:,i)),downsize);
end

obs_mov = downsamp(:,:,:);
obs = reshape(obs_mov,size(obs_mov,1)*size(obs_mov,2),size(obs_mov,3));
obs(isnan(obs))=0;

tic
[u s v] = svd(obs);
toc
% tic
% [v u w] = fastica(obs');
% toc
spatial=figure
temporal=figure
speedcorr=figure
svdfft = figure
nx = 4; ny=4;
for i = 1:nx*ny
    figure(spatial)
    subplot(nx,ny,i);
    range = prctile(abs(u(:,i)),99);
    
    imagesc(reshape(u(:,i),size(obs_mov,1),size(obs_mov,2)),[-range range]);
    axis square; axis off
    hold on
%     if exist('pts','var')
%         plot(pts(:,2)*downsize,pts(:,1)*downsize,'bo');
%         plot(pts(:,2)*downsize,pts(:,1)*downsize,'g*');
%     end
    %colormap(gray);
    figure(temporal);
    subplot(nx,ny,i);
    plot(v(:,i))
    axis off
    
    figure(speedcorr)
    subplot(nx,ny,i);
    plot(v(:,i),sp,'.')
    xlim([-0.1 0.1])
    axis off
    
    figure(svdfft)
    subplot(nx,ny,i)
      spect = abs(fft(squeeze(v(:,i))));
        fftPts = 2:length(spect)/2;
        loglog((fftPts-1)/length(spect),spect(fftPts));
        ylim([min(spect(fftPts)) max(spect(fftPts))])
        axis off
end
keyboard
figure(spatial)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

figure(temporal)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
figure(speedcorr)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

ps2pdf('psfile', psfilename, 'pdffile', [psfilename(1:(end-2)) 'pdf']);
delete(psfilename);


%% raw movie
small_mov = dfof_bg(4:4:end,4:4:end,4:4:end);
lowthresh = prctile(small_mov(:),2);
upperthresh = prctile(small_mov(:),98);

clear mov
figure
mov_length = size(dfof_bg,3)
for i = 1:mov_length;
    imagesc(imresize(dfof_bg(:,:,i),0.5,'box'),[lowthresh upperthresh]);
    colormap(gray);
    hold on
    if use_speed
        if sp(i)<500
            plot(15,15,'ro','Markersize',8,'Linewidth',8);
        else
            plot(15,15,'go','Markersize',8,'Linewidth',8);
        end
    end
    axis equal;
    if i==1;
        mov(1:mov_length) = getframe(gcf); %%%% initializes structure array
    end
    mov(i) = getframe(gcf);
    
end

[f,p] = uiputfile('*.avi','dfof movie file');

vid = VideoWriter(fullfile(p,f));
vid.FrameRate=30;
open(vid);
writeVideo(vid,mov(1:end));
close(vid)

clear mov

