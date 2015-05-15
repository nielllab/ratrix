%%%
clear all

dt = 0.25;
framerate=1/dt;
twocolor = input('# of channels : ')
twocolor= (twocolor==2);
get2pSession;

cycLength = cycLength/dt;
map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
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
    img(:,:,1) = redframe/prctile(redframe(:),95);
    img(:,:,2) = amp;
    img(:,:,3)=0;
    figure
    imshow(img)
end

% clear cycAvg
% for i = 1:cycLength
%     cycAvg(:,:,i) = squeeze(mean(dfofInterp(:,:,i:cycLength:end),3));
% end
%
%
% [y x] = ginput(1);
% figure
% plot(squeeze(cycAvg(round(x),round(y),:)))
% angle(map(round(x),round(y)))

selectPts = input('select points for further analysis? 0/1 ')
if selectPts==1
    
    ptsfname = uigetfile('*.mat','pts file');
    if ptsfname==0
        
        useOld = input('align to old points (1) or choose new points (2) : ')
        if useOld ==1
            [pts dF ptsfname] = align2pPts(dfofInterp,greenframe);
        else
            [pts dF neuropil ptsfname] = get2pPts(dfofInterp,greenframe);
        end
    else
        load(ptsfname);
    end
    
    col = 'rgbcmykr'
    figure
    hold on
    inds = 1:size(dF,1)
    colordef black
    set(gcf,'Color',[0 0 0])
    
    for i = length(inds):-1:1
        
        h=bar(dF(inds(i),1:1000)/4 + i,1);
        set(h,'EdgeColor',[0 0 0]);
        plot(dF(inds(i),1:1000)/4 + i,'w');
    end
    axis off
    xlim([1 1000])
    set(gca,'Position',[0.2 0.2 0.6 0.65])

colordef white

phaseVal = 0;
for i= 1:size(dfofInterp,3);
    phaseVal = phaseVal+dF(:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
phaseVal = phaseVal/size(dfofInterp,3);
angle(phaseVal)
abs(phaseVal)
save(ptsfname,'phaseVal','-append');

clear cycAvg
for i = 1:cycLength;
    cycAvg(:,i) = mean(dF(:,i:cycLength:end),2);
end
for i = 1:size(cycAvg,1);
    cycAvg(i,:) = cycAvg(i,:) - min(cycAvg(i,:));
end
figure
plot(cycAvg')
ph = angle(phaseVal);
ph = mod(ph,2*pi);
figure
hist(ph)

figure
hist(abs(phaseVal),0:0.01:0.25)

use = find(abs(phaseVal)>0);
figure
hold on
for i = 1:length(use)
    plot(pts(use(i),2),pts(use(i),1),'o','Color',cmapVar(ph(use(i)),0,2*pi,hsv),'LineWidth',2)
end
axis ij
use = find(abs(phaseVal)==0);
plot(pts(use,2),pts(use,1),'k.')
axis([0 256 0 256]); axis square

end

