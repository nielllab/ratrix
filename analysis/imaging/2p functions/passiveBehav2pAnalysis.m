%%%
clear all

dt = 0.25;

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

