clear all

global S2P
S2P = 0; %S2P analysis = 1, other = 0


%%% load pts file (contains cell locations and dF, along with analysis results
ptsfname = uigetfile('*.mat','pts file');
display('loading pts file');
tic;  load(ptsfname); toc

if ~exist('pixResp','var') | ~exist('dt','var') | ~exist('sbxfilename','var');
    if ~exist('sessName','var')
        [f p ] = uigetfile('*.mat','session data'); sessName = fullfile(p,f);
        save(ptsfname,'sessName','-append');
    end
    display('loading from session data');
    tic; load(sessName,'onsets','starts','trialRecs','pixResp','dt','sbxfilename'); toc
    save(ptsfname,'onsets','starts','trialRecs','pixResp','dt','sbxfilename','-append')
end

[f p] = uiputfile('*.pdf','pdf file');
psfilenameFinal = fullfile(p,f);
psfilename = 'c:\temp.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

if ~exist('eyes','var');
    display('calculating eyes')
    eyes = get2pEyes( [sbxfilename '_eye.mat'],0,dt);
end


%%% make movie of eye and extracted parameters
% load([sbxfilename '_eye.mat'],'data');
% d= squeeze(data(:,:,1,100:100:end));
% range = [min(d(:)) max(d(:))];
% figure
% mx = max(eyes(:));
% for i = 1:20:size(data,4);
%     subplot(2,2,2);
%     imagesc(data(:,:,1,i),range);
%     subplot(2,2,3:4);
%     hold off; plot(eyes); hold on; plot([i/2 i/2], [1 mx]);
%     drawnow;
% end


figure
plot(eyes); legend('x','y','r');
if exist('psfilename','var');    set(gcf, 'PaperPositionMode', 'auto');   print('-dpsc',psfilename,'-append'); end

timepts = -1:0.25:5;
eyeAlign = align2onsets(eyes',onsets,dt,timepts);
save(ptsfname,'eyes','eyeAlign','-append');

eyeNorm = eyeAlign - repmat(mean(eyeAlign(:,1:4,:),2),[1 size(eyeAlign,2) 1]);

titles = {'x','y','r'};
figure
for i = 1:3
    subplot(2,2,i)
    imagesc(squeeze(eyeNorm(i,:,:))',[-5 5])
    title(titles{i});
end
if exist('psfilename','var');    set(gcf, 'PaperPositionMode', 'auto');   print('-dpsc',psfilename,'-append'); end


%%% get target location, orientation, phase
stim = [trialRecs.stimDetails];
orient=[];gratingPh=[];location=[];targ=[];  %reset variables to be written so matrix size agrees
for i = 1:length(trialRecs);
    orient(i) = pi/2 - trialRecs(i).stimDetails.subDetails.orientations;
    gratingPh(i) = trialRecs(i).stimDetails.subDetails.phases;
    location(i) =  sign(trialRecs(i).stimDetails.subDetails.xPosPcts - 0.5);
    targ(i) = sign(stim(i).target);
end

%%% get correct
s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct] == 1;

resptime = starts(:,3)-starts(:,2);
stoptime = starts(:,2)-starts(:,1);

titles = {'x','y','r'};
figure
for i = 1:3
    subplot(2,2,i);
    plot(timepts,nanmean(eyeAlign(i,:,correct  & location<0),3)' - nanmedian(eyes(:,i)),'g');
    hold on
    plot(timepts,nanmean(eyeAlign(i,:,correct & location>0),3)' - nanmedian(eyes(:,i)),'c');
    plot(timepts,nanmean(eyeAlign(i,:,~correct & location<0),3)' - nanmedian(eyes(:,i)),'r');
    plot(timepts,nanmean(eyeAlign(i,:,~correct & location>0),3)' - nanmedian(eyes(:,i)),'m');
    axis([-1 5 -2 2])
    
    title(titles{i});
end
subplot(2,2,4); hold on; plot(1,1,'g'); plot(1,1,'c'); plot(1,1,'r'); plot(1,1,'m'); legend('correct top','correct bottom','error top','error bottom');
if exist('psfilename','var');    set(gcf, 'PaperPositionMode', 'auto');   print('-dpsc',psfilename,'-append'); end

figure
for i = 1:3
    subplot(2,2,i);
    plot(timepts,nanmean(eyeAlign(i,:,resptime<1),3)' - nanmedian(eyes(:,i)),'g');
    hold on
    plot(timepts,nanmean(eyeAlign(i,:,resptime>1),3)' - nanmedian(eyes(:,i)),'c');
    plot(timepts,nanmean(eyeAlign(i,:,stoptime<2),3)' - nanmedian(eyes(:,i)),'r');
    plot(timepts,nanmean(eyeAlign(i,:,stoptime>2),3)' - nanmedian(eyes(:,i)),'m');
    axis([-1 5 -2 2])
    
    title(titles{i});
end
subplot(2,2,4); hold on; plot(1,1,'g'); plot(1,1,'c'); plot(1,1,'r'); plot(1,1,'m'); legend('fast resp','slow resp','fast stop','slow stop');
if exist('psfilename','var');    set(gcf, 'PaperPositionMode', 'auto');   print('-dpsc',psfilename,'-append'); end




%dFdecon = dF;
if (exist('S2P','var')&S2P==1)
    dFdecon = spikes/2;
else
    dFdecon=spikes*10;
end

figure
imagesc(meanImg);
hold on
plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'g','linewidth',2);

if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

figure
imagesc(dF,[0 1])

if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

cc = corrcoef(dFdecon');
figure
imagesc(cc,[0 0.5]); colormap jet


cellCutoff = input('cell cutoff : ');
useCells= 1:cellCutoff;



figure
imagesc(dF(useCells,:),[0 1]);

figure
imagesc(dFdecon(useCells,:),[0 1]);

filt = ones(3,1); filt = filt/sum(filt);
clear dFnorm
for i = 1:size(dFdecon,1);
    dFnorm(i,:) = dFdecon(i,:)/std(dFdecon(i,:));
    % dFnorm(i,:) = dFdecon(i,:);
    dFnorm(i,:) = conv(dFnorm(i,:),filt,'same');
end

dFnorm(isnan(dFnorm))=0;
col = 'rgb';
[coeff score latent] = pca(dFnorm(useCells,:)');

range = 3:3:size(score,1);

figure
plot(score(range,1),score(range,2)); hold on
mapColors(score(range,1),score(range,2),'.',jet(length(range)))
drawnow
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end


figure
plot(score(range,1),score(range,3)); hold on
mapColors(score(range,1),score(range,3),'.',jet(length(range)));
drawnow;
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
plot(score(range,2),score(range,3)); hold on
mapColors(score(range,2),score(range,3),'.',jet(length(range)))
drawnow
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end


figure
for j = 1:5
    subplot(5,1,j)
    plot(score(:,j)); hold on
    for i = 1:length(onsets);
        if correct(i)==0
            plot([onsets(i)/dt onsets(i)/dt],[-5 5],'r');
        else
            plot([onsets(i)/dt onsets(i)/dt],[-5 5],'g');
        end
    end
end
subplot(5,1,1);title('correct');


figure
for j = 1:5
    subplot(5,1,j)
    plot(score(:,j)); hold on
    for i = 1:length(onsets);
        if location(i)<0
            plot([onsets(i)/dt onsets(i)/dt],[-5 5],'g');
        else
            plot([onsets(i)/dt onsets(i)/dt],[-5 5],'m');
        end
    end
end
subplot(5,1,1);title('location');

figure
for j = 1:5
    subplot(5,1,j)
    plot(score(:,j)); hold on
    for i = 1:length(onsets);
        if orient(i)==0
            plot([onsets(i)/dt onsets(i)/dt],[-5 5],'k');
        else
            plot([onsets(i)/dt onsets(i)/dt],[-5 5],'r');
        end
    end
end
subplot(5,1,1);title('orientation');


figure
plot(latent(1:10)/sum(latent))

for i = 1:size(coeff,2);
    if sum(coeff(:,i))<0;
        coeff(:,i) = -coeff(:,i);
        score(:,i) = -score(:,i);
    end
end

timepts = -0.9:0.1:2;
timepts = -1:0.1:5;
timepts = round(timepts*10)/10

dFalign = align2onsets(score',onsets,dt,timepts);


trialmean = mean(dFalign,3);
for i = 1:size(trialmean,1);
    trialmean(i,:) = trialmean(i,:)- min(trialmean(i,:));
end
figure
plot(trialmean(useCells,:)');
title('mean for all units')

filt = ones(1,1); filt = filt/sum(filt);
col(1:2,1) = 'rm'; col(1:2,2) = 'bc'; col = col';
orients = [0 pi/2]; locs = [-1 1];
for c = 0:1;
    figure; set(gcf,'Name',sprintf('correct = %d',c));
    for i =1:2
        for j = 1:2
            respmean = mean(dFalign(:,:,location == locs(i) & orient == orients(j) & correct ==c),3);
            for k = 1:length(respmean);
                respmean(k,:) = respmean(k,:) - min(respmean(k,timepts<=0));
            end
            
            for k = 1:25
                subplot(5,5,k)
                plot(timepts,conv(respmean(k,:),filt,'same'),col(i,j)); hold on;ylim([-2 5]);xlim([-1 5])
            end
        end
    end
    if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end
end

% figure
% imagesc(coeff(1:200,1:25),[-0.5 0.5])

dFalign = align2onsets(dFdecon(useCells,:),onsets,dt,timepts);

%%% get left/right traces
topmean = mean(dFalign(:,:,location==-1),3);
bottommean = mean(dFalign(:,:,location==1),3);
for i = 1:length(topmean)
    topmean(i,:) = topmean(i,:)-min(topmean(i,timepts<=0));
end
for i = 1:length(topmean)
    bottommean(i,:) = bottommean(i,:)-min(bottommean(i,timepts<=0));
end


figure
plot(timepts,topmean'); ylim([-1 2])
title('left targs')
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
imagesc(squeeze(pixResp(cropx(1):cropx(2),cropy(1):cropy(2),10,1) - pixResp(cropx(1):cropx(2),cropy(1):cropy(2),4,1)),[-0.5 0.5]); colormap jet
axis equal
title('left targs')

figure
draw2pSegs(usePts,topmean(:,timepts==0.4),jet,size(meanShiftImg),useCells,[-0.25 0.25])
title('left targs')
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
plot(timepts,bottommean')
title('right targs'); ylim([-1 2])
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
imagesc(squeeze(pixResp(cropx(1):cropx(2),cropy(1):cropy(2),10,2) - pixResp(cropx(1):cropx(2),cropy(1):cropy(2),4,2)),[-0.5 0.5]); colormap jet
axis equal
title('right targs')

figure
draw2pSegs(usePts,bottommean(:,timepts==0.4),jet,size(meanShiftImg),useCells,[-0.25 0.25])
title('right targs')
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
plot(topmean(:,timepts==0.4),bottommean(:,timepts==0.4),'o'); hold on
axis equal; axis square; plot([0 1],[0 1],'g'); xlabel('top'); ylabel('bottom');
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

title('performance')
results = [ sum(correct & location==-1)  sum(~correct&location==-1) sum(~correct & location==1)  sum(correct & location==1)];
results = results/sum(results(:))
figure
pie(results); legend('left correct','left error','right error','right correct');
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end


correctmean = mean(dFalign(:,:,correct),3);
wrongmean = mean(dFalign(:,:,~correct),3);
figure
plot(timepts,correctmean'); ylim([0 2]); title('mean correct trials')
figure
plot(timepts,wrongmean'); ylim([0 2]); title('mean incorrect trials')

%%% get start/stop time
resptime = starts(:,3)-starts(:,2);
figure
rtime = resptime; rtime(rtime>2)=2;
subplot(1,2,1); hist(rtime,0:0.1:2); xlabel('response time')
stoptime = starts(:,2)-starts(:,1);
stime = stoptime; stime(stime>20)=20;
subplot(1,2,2); hist(stime,0.5:1:20); xlabel('stopping time')
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

save(ptsfname,'dt','onsets','starts','trialRecs','correct','targ','location','orient','gratingPh','dFalign','pixResp','dFdecon','resptime','stoptime','-append')

dFdecon(dFdecon<-0.1)=-0.1;
dFdecon(dFdecon>5)=5;
figure
imagesc(corrcoef(dFdecon(useCells,:)),[-0.5 0.5]); colormap jet

figure
imagesc(corrcoef(dFdecon(useCells,:)'),[-0.5 0.5]); colormap jet

figure
imagesc(dFdecon(useCells,:),[0 1])

startTimes = zeros(ceil(length(dFdecon)*dt),1);
startTimes(round(onsets))=1;
x = [-60:60];
filt = exp(-0.5*x.^2 / (20^2));
filt = 60*filt/sum(filt);
trialRate = conv(startTimes,filt,'same');

for i = 1:size(dFdecon,1)
    dFmin(i,:) = dFdecon(i,:) - min(abs(dFdecon(i,:)));
    dFstd(i,:) = dFmin(i,:)/std(dFdecon(i,:));
end
dFstd(isnan(dFstd))=0;

correctRate = conv(double(correct),ones(1,10),'same')/10;
figure
plot(correctRate);
resprate = conv(resptime,ones(3,1),'same')/3;
stoprate = conv(stoptime,ones(3,1),'same')/3;

dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
dFlist = dFlist(useCells,:);
dFlist = dFlist + rand(size(dFlist))*10^-6;
for i = 1:size(dFlist,1)
    dFlist(i,:) = dFlist(i,:)/std(dFlist(i,:));
end


dist = pdist(dFlist,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(4,4,[5 9 13])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,1.5);
axis off
subplot(4,4,[6 7 8 10 11 12 14 15 16]);
imagesc(flipud(dFlist(perm,:)),[0 4]);
subplot(4,4,2:4)
plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
subplot(6,6,7:36);
dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
imagesc(corrcoef(dFlist(useCells,:)),[0 1]); xlabel('frame'); ylabel('frame')
subplot(6,6,1:6); plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)

nclust=4;
[idx] = kmeans(dFstd(useCells,:),nclust);
[y sortind] = sort(idx);

idxall = zeros(length(usePts),1);
idxall(useCells) = idx;


figure
subplot(6,6,7:36);
dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
dFlist = dFlist+rand(size(dFlist))*10^-6;
imagesc(dFlist(useCells(sortind),:),[0 1]); xlabel('frame'); ylabel('frame')
subplot(6,6,1:6); plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)
subplot(6,6,7:36); hold on;
col = 'bcyr';
for i = 1:4
    m = max(find(y==i));
    plot([1 size(dFlist,2)],[m m],'Color',col(i),'LineWidth',2)
end
title('k-means')
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
draw2pSegs(usePts,idxall,jet,size(meanShiftImg),useCells,[1 4])
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

dFalignfix = dFalign;
% for i=1:size(dFalign,1);
%     for j = 1:size(dFalign,3);
%         dFalignfix(i,:,j) = dFalignfix(i,:,j)-min(dFalignfix(i,3:5,j));
%     end
% end
% %dFalignfix(dFalignfix>5)=5;

clear allTrialData allTrialDataErr
for i = 1:size(dFalignfix,1);
    for j = 1:8
        if j==1
            use = location==-1 & orient==0 & correct==1;
        elseif j==2
            use = location==-1 & orient>0 & correct==1;
        elseif j ==3
            use = location==1 & orient==0 & correct==1;
        elseif j==4
            use = location==1 & orient>0 & correct==1;
        elseif j==5
            use = location==-1 & orient==0 & correct==0;
        elseif j==6
            use = location==-1 & orient>0 & correct==0;
        elseif j ==7
            use = location==1 & orient==0 & correct==0;
        elseif j==8
            use = location==1 & orient>0 & correct==0;
        end
        allTrialData(i,:,j) = mean(dFalignfix(i,:,use),3);
        allTrialDataErr(i,:,j) = std(dFalignfix(i,:,use),[],3)/sqrt(sum(use));
    end
end

goodTrialData = allTrialData(useCells,:,1:8);
goodTrialData = reshape(goodTrialData(:,:,1:4),size(goodTrialData(:,:,1:4),1),size(goodTrialData(:,:,1:4),2)*size(goodTrialData(:,:,1:4),3));
figure
imagesc(goodTrialData,[-1 1])
goodTrialData = goodTrialData+rand(size(goodTrialData))*10^-6; %%%% add a tiny amount of noise so neurons with zero activity don't create nans in distance


dist = pdist(imresize(goodTrialData, [size(goodTrialData,1),size(goodTrialData,2)*0.5]),'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(flipud(goodTrialData(perm,:)),[0 0.5]);
hold on; for i= 1:4, plot([i*length(timepts) i*length(timepts)]+1,[1 size(dFalign,1)],'g'); end
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
subplot(4,4,[5 9 13])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(4,4,[6 7 8 10 11 12 14 15 16]);
dFlistgood = dFlist(useCells,:);
imagesc(flipud(dFlistgood(perm,:)),[0 1]);
subplot(4,4,2:4)
plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

[Y e] = mdscale(dist,1);
[y sortind] = sort(Y);
figure
imagesc(goodTrialData(sortind,:),[0 1])
hold on; for i= 1:4, plot([i*length(timepts) i*length(timepts)]+1,[1 size(dFalign,1)],'g'); end
title('condition-wise sorted by mds')
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

figure
imagesc(dFlistgood(sortind,:),[0 1])
title('full data sorted by mds')
if exist('psfilename','var'),    set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfilename,'-append'); end

save(ptsfname,'timepts','allTrialData','allTrialDataErr','correctRate','resprate','stoprate','-append');



dos(['ps2pdf ' psfilename ' "' psfilenameFinal(1:(end-3)) 'pdf"'])
if exist([psfilenameFinal(1:(end-3)) 'pdf'],'file')
    ['ps2pdf ' psfilename ' "' psfilenameFinal(1:(end-3)) 'pdf"']
    display('generated pdf using dos ps2pdf')
else
    try
        ps2pdf('psfile', psfilename, 'pdffile', [psfilenameFinal(1:(end-3)) 'pdf'])
        [psfilenameFinal(1:(end-3)) 'pdf']
        display('generated pdf using builtin matlab ps2pdf')
    catch
        display('couldnt generate pdf');
        keyboard
    end
end
