%%%
[f p] = uigetfile('*.mat','topo x pts');
load(fullfile(p,f));

xph = phaseVal; rfCyc(:,:,1) = cycAvg; 
rf(:,1) = mod(angle(xph),2*pi)*128/(2*pi); rfAmp(:,1) = abs(xph);
topoxUse = mean(dF,2)~=0;

[f p] = uigetfile('*.mat','topo y pts');
load(fullfile(p,f));

yph = phaseVal; rfCyc(:,:,2) = cycAvg; 
rf(:,2) = mod(angle(yph),2*pi)*72/(2*pi); rfAmp(:,2) = abs(yph);
topoyUse = mean(dF,2)~=0;

goodTopo = rfAmp(:,1)>0.05 & rfAmp(:,2)>0.05;
sum(goodTopo)

figure
plot(rf(goodTopo,2),rf(goodTopo,1),'o');axis equal;  axis([0 72 0 128]); 

rfCyc = reshape(rfCyc,size(rfCyc,1),size(rfCyc,2)*size(rfCyc,3));
goodTopo = topoxUse & topoyUse;
rfCycGood = rfCyc(goodTopo,:);
figure
imagesc(rfCycGood,[0 1])

dist = pdist(rfCycGood,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(rfCycGood(perm,:)),[0 1]); 

[Y e] = mdscale(dist,1);
[y sortind] = sort(Y);
figure
imagesc(rfCycGood(sortind,:),[0 1])
title('mdscale')
%%% summary of topo
%%% rf(cells,x/y) = peak position (pixels)
%%% rfAmp(cells,x/y) = peak amplitude
%%% rfCyc(cells, 1:40 (x) 41:80 (y)) cycle average dF/F for topox and topoy concatenated

[f p ] = uigetfile('*.mat','behav pts');
load(fullfile(p,f));
behavUse = mean(dF,2)~=0;
sum(behavUse & (topoxUse | topoyUse))
behavdF = dF; behavTrialData = allTrialData;

trialData = reshape(behavTrialData,size(behavTrialData,1),size(behavTrialData,2)*size(behavTrialData,3));
trialData = trialData(behavUse,:);

dist = pdist(trialData,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
trialData(:,14)=-1; trialData(:,27)=-1; trialData(:,40)=-1;
imagesc(flipud(trialData(perm,:)),[-0.5 0.5]); 
title('behav resp')

behavTopo = rfCyc(behavUse,:);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(behavTopo(perm,:)),[0 1]); 
title('topo clusterd by behav resp type')

behavdFgood = behavdF(behavUse,:);
dist = pdist(behavdFgood,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(behavdFgood(perm,:)),[0 1]); 
title('topo clusterd by behav resp type')

%%%summary of behav
%%% behavdF(cells,t) = continue dF/F (deconvolved) traces for all neurons
%%% correctRate(t), resprate(t), stoprate(t) 
%%% = running averages of percent correct, time to response, and time to stop (aligned to times in behavdF)
%%% behavTrialData(cells, t, cond) average trial timecourse for each condition
%%% conds defined by
%         if j==1            use = targ==-1 & orient==0 & correct==1;
%         elseif j==2        use = targ==1 & orient==0 & correct==1;
%         elseif j ==3       use = targ==-1 & orient>0 & correct==1;
%         elseif j==4        use = targ==1 & orient>0 & correct==1;
%         elseif j==5        use = targ==-1 & orient==0 & correct==0;
%         elseif j==6        use = targ==1 & orient==0 & correct==0;
%         elseif j ==7       use = targ==-1 & orient>0 & correct==0;
%         elseif j==8        use = targ==1 & orient>0 & correct==0;

[f p] = uigetfile('*.mat','passive 3x')
load(fullfile(p,f));
passiveData3x = allTrialData;
dF3x = dF;
use3x = mean(dF,2)~=0;

sum(behavUse & use3x)

trialData = reshape(behavTrialData,size(behavTrialData,1),size(behavTrialData,2)*size(behavTrialData,3));
trialData = trialData(behavUse & use3x,:);

dist = pdist(trialData,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
trialData(:,14)=-1; trialData(:,27)=-1; trialData(:,40)=-1;
imagesc(flipud(trialData(perm,:)),[-0.5 0.5]); 
title('behav resp')

passData = reshape(passiveData3x, size(passiveData3x,1),size(passiveData3x,2)*size(passiveData3x,3));

behavPass = passData(behavUse& use3x,:);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(behavPass(perm,:)),[-0.5 0.5]); 
title('passive 3x clustered by behav resp type')
