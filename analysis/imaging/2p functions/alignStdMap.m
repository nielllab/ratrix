nfiles = input('# of files : ')

[f p] = uigetfile('*.mat','session file');
load(fullfile(p,f));
refFrame = greenframe;
stdref = std(dfofInterp,[],3);
figure
imagesc(stdref,[0 prctile(stdref(:),99.5)])




for n = 2:nfiles
clear greenframe
[f p] = uigetfile('*.mat','session file');
load(fullfile(p,f));
stdframe = std(dfofInterp,[],3);
figure
imagesc(stdframe,[0 1.5])
% 
% im(:,:,1)=0.8*refFrame/prctile(refFrame(:),99);
% im(:,:,2) = 0.8*greenframe/prctile(greenframe(:),99);
% im(:,:,3)=0;
% figure
% imshow(im)

ref = refFrame-mean(refFrame(:));
gr = greenframe-mean(greenframe(:));
for dx=-20:20;
    for dy = -20:20;
        xc(dx+21,dy+21)=sum(sum(circshift(ref,[dx dy]).*gr));
    end
end
figure
imagesc(xc);
[m ind] = max(xc(:));
[shiftx shifty] = ind2sub([41 41],ind);
shiftx=shiftx-21
shifty=shifty-21

greenframe = circshift(greenframe,-[shiftx shifty]);
im(:,:,1)=0.8*refFrame/prctile(refFrame(:),95);
im(:,:,2) = 0.8*greenframe/prctile(greenframe(:),95);
im(:,:,3)=0;
figure
imshow(im)

stdref = max(stdref,circshift(stdframe,-[shiftx shifty]));
end
figure
imagesc(stdref,[0 1.5])
figure
imagesc(refFrame)

figure
imagesc(stdref.*refFrame)

[x y] = getAxonPts(stdref,refFrame);
[f p ] = uiputfile('*mat','generic pts file')
save(fullfile(p,f),'x','y','refFrame','stdref');



