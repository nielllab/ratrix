clear all

[f p] = uiputfile('*.mat','compiled data');
compiledFile = fullfile(p,f);

[f p] = uiputfile('*.pdf','pdf file');
pdfFile = fullfile(p,f);

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end

%%% get topo stimuli

%%% read topoX (spatially periodic white noise)
%%% long axis of monitor, generally vertical
[f p] = uigetfile('*.mat','topo x pts');
load(fullfile(p,f));

%%% extract phase and amplitude from complex fourier varlue at 0.1Hz
xph = phaseVal; rfCyc(:,:,1) = cycAvg;  %%%cycle averaged timecourse (10sec period)
rfAmp(:,1) = abs(xph); rf(:,1) = mod(angle(xph),2*pi)*128/(2*pi); %%% convert phase to pixel position
topoxUse = mean(dF,2)~=0;  %%% find cells that were successfully extracted

%%% read topoY (spatially periodic white noise)
%%% short axis of monitor, generally horizontal
[f p] = uigetfile('*.mat','topo y pts');
load(fullfile(p,f));

figure
imagesc(dF,[0 1])
cellCutoff = input('cell cutoff : ')

%%% extract phase and amplitude from complex fourier varlue at 0.1Hz
yph = phaseVal; rfCyc(:,:,2) = cycAvg; 
rf(:,2) = mod(angle(yph),2*pi)*72/(2*pi); rfAmp(:,2) = abs(yph);
topoyUse = mean(dF,2)~=0;

%%% find sbc? use distance from center?
d1 = sqrt((mod(angle(xph),2*pi)-pi).^2 + (mod(angle(yph),2*pi)-pi).^2);
d2 = sqrt((mod(angle(xph)+pi,2*pi)-pi).^2 + (mod(angle(yph)+pi,2*pi)-pi).^2);
sbc = (d1>1.5*d2);

%%% select cells responsive to both topoX and topoY
goodTopo = find(rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01);
goodTopo=goodTopo(goodTopo<=cellCutoff);
sprintf('%d cells with good topo under cutoff',length(goodTopo))

%%% plot RF locations
figure
plot(rf(goodTopo,2),rf(goodTopo,1),'o');axis equal;  axis([0 72 0 128]); 

figure
use = rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01 &~sbc;
plot(rf(use,2),rf(use,1),'go');axis equal;  axis([0 72 0 128]); 
hold on
use = rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01 &sbc;
plot(mod(rf(use,2),72),mod(rf(use,1),128),'bo');axis equal;  axis([0 72 0 128]); 

figure
use = rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01 &~sbc;
plot(rf(use,2),rf(use,1),'go');axis equal;  axis([0 72 0 128]); 
hold on
use = rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01 &sbc;
plot(mod(rf(use,2)+36,72),mod(rf(use,1)+64,128),'bo');axis equal;  axis([0 72 0 128]); 

    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');


%%% merge X and Y cycle averages together, and select good ones
rfCyc = reshape(rfCyc,size(rfCyc,1),size(rfCyc,2)*size(rfCyc,3));
rfCyc = downsamplebin(rfCyc,2,10)/10;

rfCycGood = rfCyc(goodTopo,:);
figure
imagesc(rfCycGood,[0 1]); title('topoX and topoY cyc average')

dist = pdist(rfCycGood,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(rfCycGood(perm,:)),[0 1]); 
hold on
plot([10.5 10.5],[1 length(perm)],'g')

    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');

[Y e] = mdscale(dist,1);
[y sortind] = sort(Y);
figure
imagesc(rfCycGood(sortind,:),[0 1])
hold on
plot([10.5 10.5],[1 length(perm)],'g')
title('mdscale')
%%% summary of topo
%%% rf(cells,x/y) = peak position (pixels)
%%% rfAmp(cells,x/y) = peak amplitude
%%% rfCyc(cells, 1:40 (x) 41:80 (y)) cycle average dF/F for topox and topoy concatenated
save(compiledFile,'rf','rfAmp','rfCyc');


%%% load behavior data
[f p ] = uigetfile('*.mat','behav pts');
load(fullfile(p,f));
behavUse = 1:cellCutoff
behavdF = dFdecon; behavTrialData = allTrialData;
trialdF = dFalign; onsetFrame = onsets/dt;
behavTimepts = timepts;
%%% reshape average across conditions into concatenation
trialData = reshape(behavTrialData,size(behavTrialData,1),size(behavTrialData,2)*size(behavTrialData,3));
trialData = trialData(behavUse,:);
%trialData = downsamplebin(trialData,2,3)/3;

baseline = mean(mean(behavTrialData(behavUse,behavTimepts<0,1:4),3),2);
% for i = 1:length(baseline)
%     trialData(i,:) = trialData(i,:)-baseline(i);
% end

clear epochData
epochData(:,1,:) = mean(behavTrialData(behavUse,1:12,:),2);
epochData(:,2,:) = mean(behavTrialData(behavUse,13:16,:),2);
epochData(:,3,:) = mean(behavTrialData(behavUse,20:30,:),2);
eData = reshape(epochData,size(epochData,1),size(epochData,2)*size(epochData,3));

dist = pdist(eData(:,1:end/2),'correlation');  %%% sort based on correct
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(trialData(perm,:)),[0 0.5]); 
hold on; for i= 1:8, plot([i*length(behavTimepts) i*length(behavTimepts)]+1,[1 size(trialData,1)],'g'); end
title('behav resp')

    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');

behavTopo = rfCyc(behavUse,:);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(behavTopo(perm,:)),[0 1]); 
title('topo clusterd by behav resp type')
hold on; plot([10.5 10.5],[1 length(perm)],'g')

    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');


behavdFgood = behavdF(behavUse,:);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(behavdFgood(perm,:)),[0 1]); 
title('full behavior trace clusterd by behav resp type')

    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');

%%%summary of behav

%%% full data trace  %%%
%%% behavdF(cells,t) = continuous dF/F (deconvolved) traces for all neurons
%%% correctRate(t), resprate(t), stoprate(t) = running averages of percent correct, time to response, and time to stop (aligned to times in behavdF)
%%% onsetFrame(trial) = time (in frames of behavdF) when stimulus onset occured

%%% data by trials %%% 
%%% trialdF = (cells,t,trial) = deconvolved timecourse for each individual trial
%%% location(trial) = target location (-1 vs 1 = top vs bottom)
%%% orient(trial) = target orientation (0 = vert; pi/2 = horiz);
%%% correct(trial) = correct (1) vs incorrect (0);
%%% targ(trial) = target response (-1 vs 1 = go left vs go right)
%%% stoptime(trial) = time in secs to initiate trial
%%% resptime(trial) = time in secs to respond

%%% data by condition %%%
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
save(compiledFile,'behavdF','correctRate','resprate','stoprate','onsetFrame','trialdF','location','targ','orient','correct','stoptime','resptime','behavTrialData','-append')


%%% passive 3x data
[f p] = uigetfile('*.mat','passive 3x')
load(fullfile(p,f));
trialdF3x = dfAlign;
passiveData3x = allTrialData;
dF3x = dFdecon; xpos3x=xpos; theta3x=xpos; phase3x=phase;
x = unique(xpos);
xpos(xpos==x(1))=-1; xpos(xpos==x(2))=0; xpos(xpos==x(3))=1;
th = unique(theta)
theta(theta==th(1))=3; theta(theta==th(2))=4; theta(theta==th(3))=1;theta(theta==th(4))=2; %%% reorder to batch behavior

use3x = 1:cellCutoff

passData = reshape(passiveData3x, size(passiveData3x,1),size(passiveData3x,2)*size(passiveData3x,3));
behavPass = passData(behavUse& use3x,:);
behavPass = downsamplebin(behavPass,2,2)/2;
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(behavPass(perm,:)),[0 0.5]); 
title('passive 3x clustered by behav resp type')
hold on; for i= 1:12, plot([i*length(usepts)/2 i*length(usepts)/2]+1,[1 size(trialData,1)],'g'); end

    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');


%%% summary of passive 3x (3x positions, 4 thetas, 1 sf (matched to behav), random phase

%%% dF3x(cells,frame) = continuous deconvolved trace

%%% data by trial
%%% trialdF3x(cells,t,trial) = deconvolved timecourse for each individual trial
%%% xpos3x(trial) = x position (-1, 0 , 1);
%%% theta3x(trial) = orientation (1:4 =  0 pi/4, pi/2 3*pi/4)
%%% phase3x(trial) = spatial phase (radians, 0-2*pi)

%%% data by condition
%%% passiveData3x(cell,t,cond) average trial timecourse for each position/orientation condition
%%% cond defined by:
%%% cond(1:4)  x==-1; 
%%% cond(5:8)   x==0;
%%% cond(9:12) x==1;
%%% cond ([1 5 9]) theta ==1;
%%% cond([2 6 10]) theta ==2;
%%% cond([3 7 11]) theta ==3;
%%% cond(4 8 12]) theta ==4;

save(compiledFile,'dF3x','trialdF3x','xpos3x','theta3x','phase3x','passiveData3x','cellCutoff','-append')
