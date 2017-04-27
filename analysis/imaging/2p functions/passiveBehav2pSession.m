function passiveBehav2pSession(fileName,sessionName,moviefname, psfile)
%%% create session file for passive presentation of behavior (grating patch) stim
%%% reads raw images, calculates dfof, and aligns to stim sync

dt = 0.1; %%% resampled time frame
framerate=1/dt;

cycLength=8;
blank =1;


global S2P

if (exist('S2P','var')&S2P==1)
    cfg.dt = dt; cfg.spatialBin=1; cfg.temporalBin=1;  %%% configuration parameters suite2p
    cfg.syncToVid=1; cfg.saveDF=0; cfg.nodfof=1;
else
    cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters eff
    cfg.syncToVid=1; cfg.saveDF=0;
end

get2pSession_sbx;

cycLength = cycLength/dt;
map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map=map/size(dfofInterp,3);
map(isnan(map))=0;
amp = abs(map);
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[0 2*pi]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(img)
colormap(hsv); colorbar

if twocolor
    clear img
    img(:,:,1) = 0.75*redframe/prctile(redframe(:),98);
    amp = abs(map);
    amp=0.75*amp/prctile(amp(:),99); amp(amp>1)=1;
    img(:,:,2) = amp;
    img(:,:,3)=amp;
    figure
    imshow(img)
    title('visual resp (cyan) vs tdtomato')
end

if ~exist('moviefname','var')
    stimType = input('3x4orient (1)  or 2sfSmall (2) : ');
    if stimType ==1
        moviefname = 'C:\behavStim3sf4orient.mat'
    elseif stimType==2
        moviefname = 'C:\behavStim2sfSmall3366.mat'
    end
end

[dFout xpos sf theta phase timepts] = analyzePassiveBehav2p(dfofInterp,moviefname,dt);
display('saving')
save(sessionName,'xpos','sf','theta','phase','timepts','moviefname','-append')


x=unique(xpos);
timepts = round(timepts*10^3)/10^3;
top = squeeze(mean(dFout(:,:,find(timepts==1),xpos==x(1))-dFout(:,:,find(timepts==0),xpos==x(1)),4));
bottom = squeeze(mean(dFout(:,:,find(timepts==1),xpos==x(end))-dFout(:,:,find(timepts==0),xpos==x(end)),4));
figure
subplot(2,2,1)
imagesc(top,[-0.3 0.3]); axis equal; title('top'); colormap jet; axis off ; colorbar
subplot(2,2,2)
imagesc(bottom,[-0.3 0.3]); axis equal; title('bottom'); colormap jet; axis off; colorbar
subplot(2,2,3)
top(top<0)=0; bottom(bottom<0)=0;
imagesc((top-bottom),[-0.3 0.3]); title('top-bottom'); colormap jet; axis equal; axis off; colorbar
subplot(2,2,4);
plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,xpos==x(1)),4),2),1)))
hold on
plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,xpos==x(end)),4),2),1)))
title('position'); xlim([min(timepts) max(timepts)])

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

vert = squeeze(mean(dFout(:,:,find(timepts==1),theta==0)-dFout(:,:,find(timepts==0),theta==0),4));
horiz = squeeze(mean(dFout(:,:,find(timepts==1),theta==pi/2)-dFout(:,:,find(timepts==0),theta==pi/2),4));
figure
subplot(2,2,1)
imagesc(vert,[-0.3 0.3]); title('vert'); colormap jet; axis off; colorbar
subplot(2,2,2)
imagesc(horiz,[-0.3 0.3]); title('horiz'); colormap jet; axis off; colorbar
subplot(2,2,3)
vert(vert<0)=0; horiz(horiz<0)=0;
imagesc((vert-horiz),[-0.3 0.3]); title('horiz vs vert'); axis off; colorbar
subplot(2,2,4);
plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,theta==0),4),2),1)))
hold on
plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,theta==pi/2),4),2),1)))
title('position'); xlim([min(timepts) max(timepts)])
title('theta')

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end



amp = meanImg/prctile(meanImg(:),99);
amp(amp>1)=1;
topScaled = mat2im(top,jet,[-0.3 0.3]);
bottomScaled = mat2im(bottom,jet,[-0.3 0.3]);
topScaled = mat2im(top,jet,[-0.3 0.3]).*repmat(amp,[1 1 3]);
bottomScaled = mat2im(bottom,jet,[-0.3 0.3]).*repmat(amp,[1 1 3]);

figure
subplot(1,2,1);
imshow(imresize(topScaled,2));
title('top')
subplot(1,2,2);
imshow(imresize(bottomScaled,2));
title('bottom')

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

sbxfilename = fileName;
save(sessionName,'sbxfilename','-append')
