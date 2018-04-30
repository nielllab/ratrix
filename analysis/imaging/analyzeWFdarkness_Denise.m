%%%analyzeWFdarkness
close all
clear all
dbstop if error
%opengl('save','software')

%select batch file
batchDeniseEnrichment
%connectivityTest_batch
cd(pathname)

%select animals to use
use = find(strcmp({files.notes},'good imaging session') | strcmp({files.notes},'good DARKNESS session'))
% use = find(strcmp({files.subj}, '42RT') &strcmp({files.expt}, '012518'))

%use = find(strcmp({files.cond}, 'control') &strcmp({files.notes}, 'good imaging session') | strcmp({files.notes}, 'good DARKNESS session'))
sprintf('%d experiments for individual analysis',length(use))
indani = input('analyze individual data? 0=no 1=yes: ')

if indani
    redoani = input('reanalyze old experiments? 0=no, 1=yes: ');
    if redoani
        reselect = input('reselect ROI in each experiment? 0=no, 1=yes: ');
    else
        reselect = 0;
    end
end

alluse = use;%needed for doTopography
allsubj = unique({files(alluse).subj}); %needed for doTopography
if indani
    for s=1:1 %needed for doTopography
        %     rotateCropWF; %%%manually rotate and crop dF movies first
        doTopography; %%%align across animals second
        %doDarkness; %%%run individual analysis
        batchWFDarkness_Enrichment
        %batchWidefieldConnectivity_angieTest
    end
   % sprintf('individual analysis complete, starting group...')
else 
    
    for f=1:length(use)
fcfile = [pathname2  '\' files(use(f)).wfdarkfile '.mat'];
%load(fcfile,'dfof_bgAlignDS','sp','corrAll', 'decorrTraceAll');
load(fcfile,'sp');

%allImgDS(f,:,:,:) = dfof_bgAlignDS;
% mapsfile = [pathname   files(use(f)).darkness ];
% load(mapsfile,'sp')
%fullCorr = corrAll;
%fullCorr(f,:,:,:) = corrAll;
 spAll(f,:) = sp;
    end
    
end

group = 1:2;
for group = 1:2
    
    if group==1
        useSess = find(strcmp({files.cond},'control') & strcmp({files.label},'camk2 gc6') & (strcmp({files.notes},'good imaging session') | strcmp({files.notes},'good DARKNESS session'))  )
        grpfilename = 'WFdarkness_control'
    else group==2
        useSess = find(strcmp({files.cond},'enrichment') & strcmp({files.label},'camk2 gc6') & (strcmp({files.notes},'good imaging session') | strcmp({files.notes},'good DARKNESS session'))  )
        grpfilename = 'WFdarkness_enriched'
    end    
    
useAllImgDS = squeeze(nanstd(allImgDS,1)); %all sessions

useGrp = ismember(use,useSess);
stat = spAll <250; %0 = stationary, 1 = mv
mv = spAll >250; %0 = stationary, 1 = mv
useTime(:,:,1) = stat;
useTime(:,:,2) = mv;

figure
for ani = 1:numel(useSess)
subplot(3,2,ani)
plot(spAll(useSess(ani),:))
end
 if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
grpImg = squeeze(nanmean(allImgDS(useGrp,:,:,:),1));
maxim = squeeze(prctile(grpImg,95,3));
stdImg = squeeze(std(grpImg,[],3));
figure;imagesc(stdImg)
img = stdImg;

    for mv = 1:2
        clear traceCorr

        grptraceCorr = fullCorr(useGrp,:,:,mv);
        traceCorr = squeeze(nanmean(grptraceCorr,1));
        figure
        imagesc(stdImg) ; colormap gray; axis equal
        hold on
        clear dist contra
        for i = 1:npts
            for j= 1:npts
                dist(i,j) = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2);
                contra(i,j) = (x(i)-size(img,2)/2) * (x(j)-size(img,2)/2) <0 & ~(x(i)==33) & ~(x(j)==33) ; %%% does it cross the midline
                if traceCorr(i,j)>0.65 && contra(i,j)
                  %  plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*(traceCorr(i,j)-0.6),'Color','b');
                    corrLine= plot([y(i) y(j)],[x(i) x(j)],'Linewidth',6*(abs(traceCorr(i,j)-0.6))); corrLine.Color(4)=0.4;
                    plot(y,x,'.y','Markersize',2);
                end
            end
        end
        axis ij
        axis equal
         title ('contra FC grp Avg')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
        

figure
    imagesc(maxim) ;
    colormap gray; axis equal
    hold on
    for i = 1:npts
        for j= 1:npts
            if traceCorr(i,j)>0.65 && dist(i,j) > gridspace*2 &&~contra(i,j)
               corrLine= plot([y(i) y(j)],[x(i) x(j)],'Linewidth',6*(abs(traceCorr(i,j)-0.6))); corrLine.Color(4)=0.4;
                plot(y,x,'.y','Markersize',2);

              % test(i,j)= traceCorr(i,j)>.75

            end
        end
        
    end
     title ('Ipsi FC grp Avg')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
     dist = dist(:);
    traceCorr = traceCorr(:);
    contra = contra(:);
    
        figure;hist(traceCorr,-.5:.1:1);hold on; plot([.65 .65], [0 20000],'Linewidth',4);
     title ('correlation threshold')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    clear meanC
    distbins = gridspace/2:gridspace:30;
    for i = 1:length(distbins)-1;
        meanC(i) = nanmean(traceCorr(dist>distbins(i) & dist<=distbins(i+1) & ~contra));
    end
    meanC(i+1) = nanmean(traceCorr(contra & dist>2*gridspace));
    
    figure
    bar(distbins,meanC)
    xlabel('distance'); ylabel('correlation')
    title ('distance corr')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    figure
    hold on
    plot(dist(contra),traceCorr(contra),'r*')
    plot(dist(~contra),traceCorr(~contra),'o');
    xlabel('distance'); ylabel('correlation')
    legend('contra','ipsi');
    title ('distance FC')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
        
    
    end
%      try
%         save(fullfile(outpathname,grpfilename),'img','traceCorr','decorrTrace','corrAll','grptraceCorr','-v7.3','-append');
%     catch
%         save(fullfile(outpathname,grpfilename),'img','traceCorr','decorrTrace','corrAll','grptraceCorr','-v7.3');
%     end
    
    try
        dos(['ps2pdf ' psfilename ' "' [grpfilename '.pdf'] '"'])
    catch
        display('couldnt generate pdf');
    end
    
    delete(psfilename);
end


