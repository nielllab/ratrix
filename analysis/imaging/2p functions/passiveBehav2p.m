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
    title('visual resp (cyan) vs tdtomato')
end

if ~exist('stimType','var')
stimType = input('3x4orient (1)  or 2sfSmall (2) : ');
if stimType ==1
    moviefname = 'C:\behavStim3sf4orient.mat'
elseif stimType==2
    moviefname = 'C:\behavStim2sfSmall3366.mat'
end

[dFout xpos sf theta phase timepts] = analyzePassiveBehav2p(dfofInterp,moviefname,dt);
display('saving')
save(sessionName,'dFout','xpos','sf','theta','phase','timepts','moviefname','-append')
end
x=unique(xpos);

top = squeeze(mean(dFout(:,:,find(timepts==1.5),xpos==x(1))-dFout(:,:,find(timepts==0),xpos==x(1)),4));
bottom = squeeze(mean(dFout(:,:,find(timepts==1.5),xpos==x(end))-dFout(:,:,find(timepts==0),xpos==x(end)),4));
figure
subplot(2,2,1)
imagesc(top,[0 0.1]); axis equal; title('top')
subplot(2,2,2)
imagesc(bottom,[0 0.1]); axis equal; title('bottom')
subplot(2,2,3)
top(top<0)=0; bottom(bottom<0)=0;
imagesc((top-bottom)./(top+bottom),[-1 1]); title('top-bottom')
subplot(2,2,4);
plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,xpos==x(1)),4),2),1)))
hold on
plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,xpos==x(end)),4),2),1)))
title('position'); xlim([min(timepts) max(timepts)])


vert = squeeze(mean(dFout(:,:,find(timepts==1.5),theta==0)-dFout(:,:,find(timepts==0),theta==0),4));
horiz = squeeze(mean(dFout(:,:,find(timepts==1.5),theta==pi/2)-dFout(:,:,find(timepts==0),theta==pi/2),4));
figure
subplot(2,2,1)
imagesc(vert,[0 0.1]); title('vert')
subplot(2,2,2)
imagesc(horiz,[0 0.1]); title('horiz')
subplot(2,2,3)
vert(vert<0)=0; horiz(horiz<0)=0;
imagesc((vert-horiz)./(vert+horiz),[-1 1]); title('horiz vs vert')
subplot(2,2,4);
plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,theta==0),4),2),1)))
hold on
plot(timepts,squeeze(mean(mean(mean(dFout(:,:,:,theta==pi/2),4),2),1)))
title('position'); xlim([min(timepts) max(timepts)])
title('theta')



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
    
     dF(dF<0)=0;
    dF=deconvg6s(dF,0.25);
    
    edgepts = (pts(:,1)<18 | pts(:,1)>237 | pts(:,2)<18 | pts(:,2)>237);
    usenonzero= find(mean(dF,2)~=0 & ~edgepts);
    
[dfAlign xpos sf theta phase timepts] = analyzePassiveBehav2p(dF,moviefname,dt);
save(ptsfname,'dfAlign','xpos','sf','theta','phase','timepts','moviefname','-append')
top = squeeze(mean(dfAlign(:,find(timepts==0.75),xpos==x(1))-dfAlign(:,find(timepts==0),xpos==x(1)),3));
bottom = squeeze(mean(dfAlign(:,find(timepts==0.75),xpos==x(end))-dfAlign(:,find(timepts==0),xpos==x(end)),3));
    figure
    plot(top,bottom,'o');axis equal;axis square;hold on; plot([0 1],[0 1]);
    xlabel('top?') ; ylabel('bottom?')
    
vert = squeeze(mean(dfAlign(:,find(timepts==0.75),theta==0)-dfAlign(:,find(timepts==0),theta==0),3));
horiz = squeeze(mean(dfAlign(:,find(timepts==0.75),theta==pi/2)-dfAlign(:,find(timepts==0),theta==pi/2),3));
    figure
    plot(vert,horiz,'o'); axis equal;axis square;hold on; plot([0 1],[0 1])
    xlabel('vert?'); ylabel('horiz?') 
    
    figure
    plot(timepts,mean(dfAlign,3)')

figure
subplot(2,2,1)
       draw2pSegs(usePts,top,jet,256,usenonzero,[-1 1]); title('top?')
 subplot(2,2,2)
       draw2pSegs(usePts,bottom,jet,256,usenonzero,[-1 1]); title('bottom?')
       subplot(2,2,3)
       draw2pSegs(usePts,vert,jet,256,usenonzero,[-1 1]); title('horiz?')
       subplot(2,2,4)
       draw2pSegs(usePts,horiz,jet,256,usenonzero,[-1 1]); title('vert?')
       
    
    
end

