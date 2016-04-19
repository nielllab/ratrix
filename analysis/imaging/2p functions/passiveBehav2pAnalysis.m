%%%
clear all

dt = 0.25;

useOld = input('align to std points (1) or choose new points (2) or read in prev points (3) : ')
if useOld ==1
    [pts dF ptsfname icacorr cellImg usePts] = align2pPts(dfofInterp,greenframe);
elseif useOld==2
    [pts dF neuropil ptsfname] = get2pPts(dfofInterp,greenframe);
    
else
    ptsfname = uigetfile('*.mat','pts file')
    load(ptsfname);
end

if ~exist('moviefname','var')
    [f p] = uigetfile('*.mat','session data');
    load(fullfile(p,f),'moviefname')
end

dFdecon = dF;

dFdecon=dF;
for i = 1:size(dF,1);
    dFdecon(i,:) = dFdecon(i,:)-prctile(dFdecon(i,:),1);
end

dFdecon=deconvg6s(dFdecon,0.25);



[dfAlign xpos sf theta phase timepts] = analyzePassiveBehav2p(dFdecon,moviefname,dt);
save(ptsfname,'dfAlign','xpos','sf','theta','phase','timepts','moviefname','dFdecon','-append')

usenonzero= find(mean(dFdecon,2)>0.015);

figure
imagesc(dFdecon(usenonzero,:),[0 1]); title('dF')

dFgood = dFdecon(usenonzero,:);

x = unique(xpos);
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

% figure
% subplot(2,2,1)
% draw2pSegs(usePts,top,jet,256,usenonzero,[-1 1]); title('top?')
% subplot(2,2,2)
% draw2pSegs(usePts,bottom,jet,256,usenonzero,[-1 1]); title('bottom?')
% subplot(2,2,3)
% draw2pSegs(usePts,vert,jet,256,usenonzero,[-1 1]); title('horiz?')
% subplot(2,2,4)
% draw2pSegs(usePts,horiz,jet,256,usenonzero,[-1 1]); title('vert?')

dFalignfix = dfAlign;
for i=1:size(dfAlign,1);
    for j = 1:size(dfAlign,3);
        dFalignfix(i,:,j) = dFalignfix(i,:,j)-min(dFalignfix(i,find(timepts>=-0.5 & timepts<=0),j));
    end
end


clear allTrialData
thetas = unique(theta); sfs = unique(sf); thetas= circshift(thetas,[0 2]);

if strcmp(moviefname,'C:\behavStim3sf4orient.mat')
    for i = 1:size(dfAlign,1);
        for j = 1:3
            for k = 1:4
                use = find(theta == thetas(k) & xpos == x(j));
                allTrialData(i,:,(j-1)*4 + k) = median(dFalignfix(i,5:end,use),3);
                allTrialDataErr(i,:,(j-1)*4 + k) = std(dFalignfix(i,5:end,use),[],3)/sqrt(length(use));
            end
        end
    end
end


if strcmp(moviefname,'C:\behavStim2sfSmall3366.mat')
    for i = 1:size(dfAlign,1)
        for j = 1:2
            for k = 1:2
                for m = 1:2
                   use = find(sf ==sfs(m) & theta == thetas(k) & xpos == x(j));
                allTrialData(i,:,4*(j-1) +2*(k-1)+ m) = median(dFalignfix(i,5:end,use),3);
                allTrialDataErr(i,:,4*(j-1) +2*(k-1)+ m) = std(dFalignfix(i,5:end,use),[],3)/sqrt(length(use));
                end
            end
        end
    end
end

        
        save(ptsfname,'allTrialData','allTrialDataErr','-append');


goodTrialData = allTrialData;
goodTrialData = reshape(goodTrialData,size(goodTrialData,1),size(goodTrialData,2)*size(goodTrialData,3));
usenonzero=mean(goodTrialData,2)~=0;
goodTrialData = goodTrialData(usenonzero,:);

figure
imagesc(goodTrialData,[-0.5 0.5])
        
dist = pdist(goodTrialData,'correlation');
%dist = pdist(dFgood,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);

if strcmp(moviefname,'C:\behavStim3sf4orient.mat')
goodTrialData(:,1:16:end)=NaN;
else
    goodTrialData(:,1:20:end)=NaN;
end


figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(dFgood(perm,:)),[0 1]); 
drawnow
title('sorted by condition')

figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(goodTrialData(perm,:)),[-0.5 0.5]); 
title('trials by conditions')
drawnow

[Y e] = mdscale(dist,1);
[y sortind] = sort(Y);
figure
imagesc(goodTrialData(sortind,:),[-0.5 0.5])
title('mds')

