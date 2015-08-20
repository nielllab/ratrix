%%%
clear all

dt = 0.25;
framerate=1/dt;
twocolor = input('# of channels : ')
twocolor= (twocolor==2);
get2pSession_sbx;

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
    img(:,:,1) = 0.75*redframe/prctile(redframe(:),98);
    amp = abs(map);
    amp=0.75*amp/prctile(amp(:),99); amp(amp>1)=1;
    img(:,:,2) = amp;
    img(:,:,3)=amp;
    figure
    imshow(img)
end
title('visual resp (cyan) vs tdtomato')

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
    
    useOld = input('align to std points (1) or choose new points (2) or read in prev points (3) : ')
    if useOld ==1
        [pts dF ptsfname icacorr cellImg usePts] = align2pPts(dfofInterp,greenframe);
    elseif useOld==2
        [pts dF neuropil ptsfname] = get2pPts(dfofInterp,greenframe);
        
    else
        ptsfname = uigetfile('*.mat','pts file');
        load(ptsfname);
    end
    
    %     col = 'rgbcmykr'
    %     figure
    %     hold on
    %     inds = 1:size(dF,1)
    %     colordef black
    %     set(gcf,'Color',[0 0 0])
    %
    %     for i = length(inds):-1:1
    %
    %         h=bar(dF(inds(i),1:1000)/4 + i,1);
    %         set(h,'EdgeColor',[0 0 0]);
    %         plot(dF(inds(i),1:1000)/4 + i,'w');
    %     end
    %     axis off
    %     xlim([1 1000])
    %     set(gca,'Position',[0.2 0.2 0.6 0.65])
    %
    % colordef white
    
    usenonzero = find(mean(dF,2)~=0);
    
    phaseVal = 0;
    for i= 1:size(dfofInterp,3);
        phaseVal = phaseVal+dF(:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
    end
    phaseVal = phaseVal/size(dfofInterp,3);
    angle(phaseVal)
    abs(phaseVal)
 
    
    clear cycAvg
    for i = 1:cycLength;
        cycAvg(:,i) = mean(dF(:,i:cycLength:end),2);
    end
    for i = 1:size(cycAvg,1);
        cycAvg(i,:) = cycAvg(i,:) - min(cycAvg(i,:));
    end
       save(ptsfname,'phaseVal','cycAvg','-append');
    figure
    plot(cycAvg')
    ph = angle(phaseVal);
    ph = mod(ph,2*pi);
    figure
    hist(ph(usenonzero))
    
    figure
    hist(abs(phaseVal(usenonzero)),0:0.05:1)
    
    figure
    draw2pSegs(usePts,ph,jet,256,intersect(usenonzero,find(abs(phaseVal)>0.05)),[0 2*pi]);

end

