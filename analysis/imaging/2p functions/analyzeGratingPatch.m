%%%analyzeGratingPatch
close all
clear all
dbstop if error

%select batch file
batchDeniseEnrichment
cd(pathname)
 
%select animals to use
use = find(strcmp({files.notes},'good imaging session'))
sprintf('%d experiments for individual analysis',length(use))

indani = input('analyze individual data? 0=no 1=yes: ')
if indani
    redoani = input('reanalyze old experiments? 0=no, 1=yes: ');
    if redoani
        reselect = input('reselect ROI in each experiment? 0=no, 1=yes: ');
    else
        reselect = 0;
    end
else
    redoani = 0;
end   

alluse = use;%needed for doTopography
allsubj = unique({files(alluse).subj}); %needed for doTopography
if indani
    for s=1:1 %needed for doTopography
    %     rotateCropWF; %%%manually rotate and crop dF movies first
        doTopography; %%%align across animals second
        doGratingPatch; %%%run individual analysis
    end
    sprintf('individual analysis complete, starting group...')
end

% group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained: ')
% redogrp = input('reanalyze group data? 0=no, 1=yes: ')

redogrp=1
for group=1:2

    if group==1
        use = (strcmp({files.cond},'control') & strcmp({files.notes},'good imaging session')) 
        grpfilename = 'ControlGratingPatchWF'
    elseif group==2
        use = (strcmp({files.cond},'enrichment') & strcmp({files.notes},'good imaging session'))
        grpfilename = 'EnrichmentGratingPatchWF'
    end

    if isempty(use)
        sprintf('No animals in %s',grpfilename)
        return
    end

    psfilename = 'C:\Users\nlab\Documents\MATLAB\tempDeniseWF.ps';
    if exist(psfilename,'file')==2;delete(psfilename);end

    %%%load stimulus info
    load('C:\gratingpatch3sf2tf8dir')
    sfrange = unique(sf);tfrange = unique(tf);thetarange = unique(theta);xrange = unique(xpos);
    imagerate=10;
    cyclength = imagerate*(isi+duration);
    base = isi*imagerate-4:isi*imagerate-1;
    peakWindow = isi*imagerate+1:isi*imagerate+3;
    timepts = 0:1/imagerate:(2*isi+duration);timepts = timepts - isi;timepts = timepts(1:end-1);
    numAni = length(use);

    %% concatenate individual experiments into group data
    if redogrp
        cd(outpathname)
        load(sprintf('%s_%s_%s_gratingpatch.mat',files(use(1)).expt,files(use(1)).subj,files(use(1)).cond));
        grpring = nan(numAni,50,size(ring,2),size(ring,3),size(ring,4),size(ring,5),2);
        grpcyc = nan(numAni,size(trialcycavg,1),size(trialcycavg,2),size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),2);
        grptrace = nan(numAni,size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),2);

        anicnt = 1;
        for f = 1:2:length(use)
            aniFile = sprintf('%s_%s_%s_gratingpatch.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).cond);
            load(aniFile,'ring','trialcycavg','x','y')
            grpcyc(anicnt,:,:,:,:,:,:,:,:) = trialcycavg;
            for i = 1:length(xrange)
                grpring(anicnt,1:size(ring,1),:,:,:,:,:) = ring;
                grptrace(anicnt,:,i,:,:,:,:) = squeeze(nanmean(nanmean(trialcycavg(x(i)-2:x(i)+2,y(i)-2:y(i)+2,:,i,:,:,:,:),1),2));
            end

            anicnt = anicnt+1;
        end
        try
            save(fullfile(outpathname,grpfilename),'grpcyc','grpring','grptrace','-v7.3','-append');
        catch
            save(fullfile(outpathname,grpfilename),'grpcyc','grpring','grptrace','-v7.3');
        end
    else
        load(fullfile(outpathname,grpfilename))    
    end


    %% plot averages for the different stimulus parameters
    sprintf('plotting responses')
    dfrange = [-0.01 0.05;-0.01 0.15]; %%%range for imagesc visualization, row is running/stationary
    ringx = size(grpring,2);pixbin=5;ringxrange=ceil(ringx/10)*2;

    %%%plot pixelwise responses
    for m = 1:2 %sit/run
        for i = 1:length(xrange)
            figure;colormap jet
            figcnt=1;
            for j = 1:length(sfrange)
                for k = 1:length(tfrange)
                    subplot(length(sfrange),length(tfrange),figcnt)
                    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,i,j,k,:,m),8),4),1)),dfrange(1,:))
                    axis off;axis equal;
                    title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
                    figcnt=figcnt+1;
                end
            end
            mtit(sprintf('%s pixelwise xpos%d %s',grpfilename,i,behavState{m}))
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
            
            figure;colormap jet
            figcnt=1;
            for j = 1:length(sfrange)
                for k = 1:length(tfrange)
                    subplot(length(sfrange),length(tfrange),figcnt)
                    plot(timepts,squeeze(nanmean(nanmean(grptrace(:,:,i,j,k,:,m),6),1)))
                    ylabel('dfof')
                    xlabel('time(s)')
                    axis([timepts(1) timepts(end) -0.01 0.1])
                    axis square
                    title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
                    figcnt=figcnt+1;
                end
            end
            mtit(sprintf('%s cycavg xpos%d %s',grpfilename,i,behavState{m}))
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
            
            figure;
            figcnt=1;
            for j = 1:length(sfrange)
                for k = 1:length(tfrange)
                    subplot(length(sfrange),length(tfrange),figcnt)
                    plot(1:size(grpring,2),squeeze(nanmean(nanmean(grpring(:,:,i,j,k,:,m),6),1)))
                    ylabel('dfof')
                    xlabel('distance from cent (pix)')
                    axis([0 ceil(size(grpring,2)/10)*5 -0.001 0.1])
                    set(gca,'xtick',0:10:ceil(size(grpring,1)/10)*5,'xticklabel',0:10*pixbin:ceil(size(grpring,1)/10)*5*pixbin)
                    axis square
                    title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
                    figcnt = figcnt+1;
                end
            end
            mtit(sprintf('%s spread xpos%d %s',grpfilename,i,behavState{m}))
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
        end
    end


    %% save pdf

    try
        dos(['ps2pdf ' psfilename ' "' [grpfilename '.pdf'] '"'])
    catch
        display('couldnt generate pdf');
    end

    delete(psfilename);
end


