clear all
% points file
load('G:\EnrichmentWidefield\enrichmentPts021321.mat')
load('G:\EnrichmentWidefield\enrichmentOverlay021321.mat')
areas = {'V1','P','LM','AL','RL','AM','PM','MM'}
nAreas = length(x)

%%% create
psfilename = 'tempWF.ps'; 
if exist(psfilename,'file')==2;delete(psfilename);end

figure
hold on
for i = 1:nAreas
    plot(y(i),x(i),'o')
end
axis ij; axis equal
legend(areas)
hold on
plot(ypts,xpts,'.')
if exist('psfilename','var');   set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');  print('-dpsc',psfilename,'-append'); end

load('EE_control.mat','fit')
fitControl(:,:,:,:) = fit;  %%% %%% fit(x,y,tuning params, subj) has full tuning curves (1:4=x, 5:7=y, 8:13 = sf, 14:16=tf, [] , [])

load('EE_enrichment.mat','fit')
fitEnrich(:,:,:,:) = fit;  %%% %%% fit has full tuning curves (1:4=x, 5:7=y, 8:13 = sf, 14:16=tf, [] , [])

analysisFiles = {'EE_control.mat','EE_enrichment.mat'}

%analysisFiles = {'EE_control.mat'}

%analysisFiles = {'EE_enrichment.mat'}



for f = 1:length(analysisFiles)
    load(analysisFiles{f},'fit','mv')
    fitMerge(:,:,:,f) = nanmean(fit(:,:,:,:),4);
    fitMergeErr(:,:,:,f) = nanstd(fit(:,:,:,:),[],4)/sqrt(size(fit,4));
    mvMerge(f) = nanmean(mv);
    mvMergeErr(f) = nanstd(mv)/sqrt(length(mv));
end   

figure
bar(mvMerge)
hold on
errorbar(1:length(mvMerge),mvMerge,mvMergeErr,'o');
ylabel('fraction time running')
set(gca,'XTickLabel',{'control','enrichment'})

if exist('psfilename','var');   set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');  print('-dpsc',psfilename,'-append'); end



% load('EE_enrichment.mat','fit', 'allsubj')
% notv = [1 4 ]
% tv = [2 3 5 6 7]
% 
% fitMerge(:,:,:,1) = nanmean(fit(:,:,:,notv),4);
% fitMergeErr(:,:,:,1) = nanstd(fit(:,:,:,notv),[],4)/sqrt(size(fit(:,:,:,notv),4));
% 
% fitMerge(:,:,:,2) = nanmean(fit(:,:,:,tv),4);
% fitMergeErr(:,:,:,2) = nanstd(fit(:,:,:,tv),[],4)/sqrt(size(fit(:,:,:,tv),4));



nArea = length(x)
for i = 1:nArea %%% loop over points - select data at that location
    areaTuning(i,:,:) = fitMerge(x(i),y(i),:,:);
    areaTuningErr(i,:,:) = fitMergeErr(x(i),y(i),:,:);
end


figure
for area = 1:nArea
    subplot(4,nArea,area);
    errorbar(squeeze(areaTuning(area,1:4,:)), squeeze(areaTuningErr(area,1:4,:)))
    ylabel('X position')
    title(areas{area})
    
    subplot(4,nArea,nArea+area)
    errorbar(squeeze(areaTuning(area,5:7,:)), squeeze(areaTuningErr(area,5:7,:)))
    ylim([0 1])
    ylabel('Y position')
    
    subplot(4,nArea,2*nArea+area)
    errorbar(squeeze(areaTuning(area,8:13,:)), squeeze(areaTuningErr(area,8:13,:)))
    ylim([0 1])
    ylabel('spatial frequency')
    
    subplot(4,nArea,3*nArea+area)
    errorbar(squeeze(areaTuning(area,14:16,:)), squeeze(areaTuningErr(area,14:16,:)))
    ylim([0 1])
    ylabel('temporal frequency')
    
end
if exist('psfilename','var');   set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');  print('-dpsc',psfilename,'-append'); end




try
    dos(['ps2pdf ' psfilename ' "' 'EnrichmentGratingsAnalysis.pdf' '"'])
    delete(psfilename);
catch
    disp('couldnt generate pdf');
    keyboard
end    