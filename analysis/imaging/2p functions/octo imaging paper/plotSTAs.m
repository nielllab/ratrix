load('100719_Loc6_Acq17_SN1_denoised_zbinned_range5to5_011223.mat')

zthresh = 7;
useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);

cmap = flipud(cbrewer('div','RdBu',64));

ind = ceil(rand(24,1)*length(useOn));

figure
for i = 1:length(ind)
    subplot(4,6,i);
    imagesc(stas(:,:,useOn(ind(i)),1)',[-0.125 0.125])
    colormap(cmap); axis equal;
end
figure
imagesc(stas(:,:,useOn(ind(i)),1)',[-0.125 0.125])
colormap(cmap);colorbar

ind = ceil(rand(24,1)*length(useOff));


figure
for i = 1:length(ind)
    subplot(4,6,i);
    imagesc(stas(:,:,useOff(ind(i)),2)',[-0.125 0.125])
    colormap(cmap); axis equal
end
figure
imagesc(stas(:,:,useOff(ind(i)),2)',[-0.125 0.125])
colormap(cmap);colorbar



zthresh = 5.5;
useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);
rfxs = [rfx(useOn,1); rfx(useOff,2)];
rfys = [rfy(useOn,1); rfy(useOff,2)];
x0 = nanmedian(rfxs);
y0 = nanmedian(rfys);

badRFon = sqrt((rfx(:,1)-x0).^2 + (rfy(:,1)-y0).^2)>75;
badRFoff = sqrt((rfx(:,2)-x0).^2 + (rfy(:,2)-y0).^2)>75;

useOn = find(zscore(:,1)>zthresh& zscore(:,2)>-zthresh & ~badRFon);
useOff = find(zscore(:,2)<-zthresh & zscore(:,1)<zthresh & ~badRFoff);
useOnOff = find(zscore(:,2)<-zthresh & zscore(:,1)>zthresh & ~badRFon & ~badRFoff);

figure
imagesc(stdImg); axis equal; colormap gray; hold on
plot(xpts(useOn),ypts(useOn),'.','Markersize',12,'Color',[1 0 0]);
plot(xpts(useOff),ypts(useOff),'.','Markersize',12,'Color',[0 0 1]);
plot(xpts(useOnOff),ypts(useOnOff),'.','Markersize',12,'color',[1 0 1]);




%%% plot topographic maps
dist = 22;

pixpercm = 256/75;  %%% screen is 256 pix, 95mm wide
rf_az = (rfx - 128)/pixpercm;
rf_el = (rfy - 96)/pixpercm;
rf_az = atan2d(rf_az, dist);
rf_el = atan2d(rf_el, dist);

figure
plot(rf_az(:,1),rf_el(:,1),'.')


useOn = find(zscore(:,1)>zthresh& ~badRFon);
useOff = find(zscore(:,2)<-zthresh & ~badRFoff);
rfxs = [rf_az(useOn,1); rf_az(useOff,2)];
rfys = [rf_el(useOn,1); rf_el(useOff,2)];
x0 = nanmedian(rfxs);
y0 = nanmedian(rfys);

for i = 1:size(stas,3);
    if i/10 ==round(i/10)
        sprintf('%d / %d',i, size(stas,3))
    end
    p = fitOctorf(stas(:,:,i,1));
    center_x(i,1) = p(3); center_y(i,1) = p(4);
    [center_az(i,1) center_el(i,1)] = octoPix2Deg(p(3),p(4),dist);
    p = fitOctorf(stas(:,:,i,2));
    center_x(i,2) = p(3); center_y(i,2) = p(4);
    [center_az(i,2) center_el(i,2)] = octoPix2Deg(p(3),p(4),dist);
end

[center_az center_el] = octoPix2Deg(center_x,center_y,dist);
figure
plot(rf_az(useOn,1),center_az(useOn,1),'.')

figure
plot(rfx(useOff,2),center_x(useOff,2),'.')

zthresh = 5.5;
useOn = find(zscore(:,1)>zthresh& ~badRFon);
useOff = find(zscore(:,2)<-zthresh & ~badRFoff);

axLabel = {'X','Y'};
onoffLabel = {'On','Off'};

figure
for ax = 1:2
    for rep = 1:2;
        subplot(2,2,2*(rep-1)+ax)
        
        imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
        hold on
        if rep==1
            data = useOn;
        else data = useOff;
        end
        
        for i = 1:length(data)
            if ax ==1
                plot(xpts(data(i)),ypts(data(i)),'.','Markersize',8,'Color',cmapVar(center_az(data(i),rep)-x0,-20, 20, jet));
            else
                plot(xpts(data(i)),ypts(data(i)),'.','Markersize',8,'Color',cmapVar(center_el(data(i),rep)-y0,-20, 20, jet));
            end
        end
        axis off
%         if ax ==1 & rep==1
%             title(sprintf('x0 = %0.1f y0=%0.1f',x0,y0))
%         else
%             title(sprintf('%s %s',axLabel{ax},onoffLabel{rep}))
%         end
        
    end
end
fig = gcf;
fig.Renderer = 'Painter';

figure
imagesc(rand(20),[-20 20]); colormap jet; colorbar('Location','southoutside');  colorbar('Location','eastoutside');


zthresh = 6

pts_x0= median(xpts);
pts_y0=median(ypts);
x0 = nanmedian(center_az(useOn,1));
y0 = nanmedian(center_el(useOn,1))-5;
umperpix = 2;
figure
plot((xpts(useOn)-pts_x0)*umperpix,center_az(useOn,1)-x0,'r.'); hold on
plot((xpts(useOff)-pts_x0)*umperpix,center_az(useOff,2)-x0,'b.');
xlabel('x (um)'); ylabel('RF azimuth (deg)'); axis square; axis([-350 350 -25 25]); 
legend('ON','OFF')
figure
plot((ypts(useOn)-pts_y0)*umperpix,center_el(useOn,1)-y0,'r.'); hold on
plot((ypts(useOff)-pts_y0)*umperpix,center_el(useOff,2)-y0,'b.');
xlabel('y (um)'); ylabel('RF elevation (deg)');axis square; axis([-400 400 -20 20]); 