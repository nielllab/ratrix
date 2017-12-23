%%%analyzePatchOnPatch
close all
clear all
dbstop if error

%select batch file
batchPhilIntactSkull
cd(pathname)
 
%select animals to use
use = find(strcmp({files.notes},'good darkness and stimulus') | strcmp({files.notes},'good stimulus'))
sprintf('%d experiments for individual analysis',length(use)/2)

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
        doPatchOnPatch; %%%run individual analysis
    end
    sprintf('individual analysis complete, starting group...')
end

% group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained: ')
% redogrp = input('reanalyze group data? 0=no, 1=yes: ')

redogrp=1
for group=1:4

    if group==1
        use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & (strcmp({files.notes},'good darkness and stimulus') | strcmp({files.notes},'good stimulus'))  ) 
        grpfilename = 'SalineNaiveIsoCrossWF'
    elseif group==2
        use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & (strcmp({files.notes},'good darkness and stimulus') | strcmp({files.notes},'good stimulus'))  ) 
        grpfilename = 'SalineTrainedIsoCrossWF'
    elseif group==3
        use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & (strcmp({files.notes},'good darkness and stimulus') | strcmp({files.notes},'good stimulus'))  ) 
        grpfilename = 'DOINaiveIsoCrossWF'
    elseif group==4
        use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & (strcmp({files.notes},'good darkness and stimulus') | strcmp({files.notes},'good stimulus'))  ) 
        grpfilename = 'DOITrainedIsoCrossWF'
    else
        sprintf('please restart and choose a number 1-4')
    end

    if isempty(use)
        sprintf('No animals in this group')
        return
    end

    psfilename = 'c:\tempPhilWF.ps';
    if exist(psfilename,'file')==2;delete(psfilename);end

    %%%load stimulus info
    load('C:\patchonpatch16min')

    imagerate=10;
    cyclength = imagerate*(isi+duration);
    base = isi*imagerate-4:isi*imagerate-1;
    peakWindow = isi*imagerate+1:isi*imagerate+3;
    timepts = 0:1/imagerate:(2*isi+duration);timepts = timepts - isi;timepts = timepts(1:end-1);
    numAni = length(use)/2;

    %%
    if redogrp
        cd(outpathname)
        load(sprintf('%s_%s_%s_%s_patchonpatch.mat',files(use(1)).expt,files(use(1)).subj,files(use(1)).timing,files(use(1)).inject));
        grpring = nan(numAni,50,size(ring,2),size(ring,3),size(ring,4),2);
        grpcyc = nan(numAni,size(trialcycavg,1),size(trialcycavg,2),size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),2);
        grptrace = nan(numAni,size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),2);

        anicnt = 1;
        for f = 1:2:length(use)
            aniFile = sprintf('%s_%s_%s_%s_patchonpatch.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).timing,files(use(f)).inject);
            load(aniFile,'ring','trialcycavg','x','y')
            grpring(anicnt,1:size(ring,1),:,:,:,1) = ring;
            grpcyc(anicnt,:,:,:,:,:,:,1) = trialcycavg;
            grptrace(anicnt,:,:,:,:,1) = squeeze(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,:,:,:),1),2));

            aniFile = sprintf('%s_%s_%s_%s_patchonpatch.mat',files(use(f+1)).expt,files(use(f+1)).subj,files(use(f+1)).timing,files(use(f+1)).inject);
            load(aniFile,'ring','trialcycavg','x','y')
            grpring(anicnt,1:size(ring,1),:,:,:,2) = ring;
            grpcyc(anicnt,:,:,:,:,:,:,2) = trialcycavg;
            grptrace(anicnt,:,:,:,:,2) = squeeze(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,:,:,:),1),2));

            anicnt = anicnt+1;
        end
        save(fullfile(outpathname,grpfilename),'grpring','grpcyc','grptrace')
    else
        load(fullfile(outpathname,grpfilename))    
    end


    %%
    %%%plot averages for the different stimulus parameters
    sprintf('plotting responses')
    dfrangesit = [-0.001 0.015]; %%%range for imagesc visualization
    dfrangerun = [-0.001 0.025]; %%%range for imagesc visualization
    ringx = size(grpring,2);pixbin=5;ringxrange=ceil(ringx/10)*2;

    %%%center only maps
    figure
    colormap jet
    subplot(2,2,1)
    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,2,:,1,1),4),6),1)),dfrangesit)
    axis off
    title('center sit pre')
    subplot(2,2,3)
    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,2,:,2,1),4),6),1)),dfrangesit)
    axis off
    title('center run pre')
    subplot(2,2,2)
    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,2,:,1,2),4),6),1)),dfrangesit)
    axis off
    title('center sit post')
    subplot(2,2,4)
    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,2,:,2,2),4),6),1)),dfrangesit)
    axis off
    title('center run post')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end

    %%%surround only maps
    figure
    colormap jet
    subplot(2,2,1)
    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,3,:,1,1),4),6),1)), dfrangerun)
    axis off
    title('surround sit pre')
    subplot(2,2,3)
    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,3,:,2,1),4),6),1)), dfrangerun)
    axis off
    title('surround run pre')
    subplot(2,2,2)
    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,3,:,1,2),4),6),1)), dfrangerun)
    axis off
    title('surround sit post')
    subplot(2,2,4)
    imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,3,:,2,2),4),6),1)), dfrangerun)
    axis off
    title('surround run post')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end

    %%%center/surround traces
    figure
    subplot(2,2,1)
    pre = squeeze(nanmean(grptrace(:,:,2,:,1,1),4));post = squeeze(nanmean(grptrace(:,:,2,:,1,2),4));
    hold on
    shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('time(s)')
    axis([timepts(1) timepts(end) -0.01 0.1])
    axis square
    title('center sit')
    subplot(2,2,2)
    pre = squeeze(nanmean(grptrace(:,:,2,:,2,1),4));post = squeeze(nanmean(grptrace(:,:,2,:,2,2),4));
    hold on
    shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('time(s)')
    axis([timepts(1) timepts(end) -0.01 0.1])
    axis square
    title('center run')
    subplot(2,2,3)
    pre = squeeze(nanmean(grptrace(:,:,3,:,1,1),4));post = squeeze(nanmean(grptrace(:,:,3,:,1,2),4));
    hold on
    shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('time(s)')
    axis([timepts(1) timepts(end) -0.01 0.1])
    axis square
    title('surround sit')
    subplot(2,2,4)
    pre = squeeze(nanmean(grptrace(:,:,3,:,2,1),4));post = squeeze(nanmean(grptrace(:,:,3,:,2,2),4));
    hold on
    shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('time(s)')
    axis([timepts(1) timepts(end) -0.01 0.1])
    axis square
    title('surround run')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end

    %%%center/surround spread
    figure
    subplot(2,2,1)
    pre = squeeze(nanmean(grpring(:,:,2,:,1,1),4));post = squeeze(nanmean(grpring(:,:,2,:,1,2),4));
    hold on
    shadedErrorBar(1:ringx,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:ringx,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('distance from cent (pix)')
    axis([0 ringxrange -0.001 0.1])
    set(gca,'xtick',0:10:ringxrange,'xticklabel',0:10*pixbin:ringxrange*pixbin)
    axis square
    title('center sit')
    subplot(2,2,2)
    pre = squeeze(nanmean(grpring(:,:,2,:,2,1),4));post = squeeze(nanmean(grpring(:,:,2,:,2,2),4));
    hold on
    shadedErrorBar(1:ringx,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:ringx,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('distance from cent (pix)')
    axis([0 ringxrange -0.001 0.1])
    set(gca,'xtick',0:10:ringxrange,'xticklabel',0:10*pixbin:ringxrange*pixbin)
    axis square
    title('center run')
    subplot(2,2,3)
    pre = squeeze(nanmean(grpring(:,:,3,:,1,1),4));post = squeeze(nanmean(grpring(:,:,3,:,1,2),4));
    hold on
    shadedErrorBar(1:ringx,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:ringx,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('distance from cent (pix)')
    axis([0 ringxrange -0.001 0.1])
    set(gca,'xtick',0:10:ringxrange,'xticklabel',0:10*pixbin:ringxrange*pixbin)
    axis square
    title('surround sit')
    subplot(2,2,4)
    pre = squeeze(nanmean(grpring(:,:,3,:,2,1),4));post = squeeze(nanmean(grpring(:,:,3,:,2,2),4));
    hold on
    shadedErrorBar(1:ringx,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:ringx,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('distance from cent (pix)')
    axis([0 ringxrange -0.001 0.1])
    set(gca,'xtick',0:10:ringxrange,'xticklabel',0:10*pixbin:ringxrange*pixbin)
    axis square
    title('surround run')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end


    %%%iso maps
    figure
    colormap jet
    subplot(2,2,1)
    imagesc(squeeze(nanmean(nanmean(grpcyc(:,:,:,peakWindow,4,1,1,1),4),1)),dfrangesit)
    axis off
    title('iso sit pre')
    subplot(2,2,2)
    imagesc(squeeze(nanmean(nanmean(grpcyc(:,:,:,peakWindow,4,1,1,2),4),1)),dfrangesit)
    axis off
    title('iso sit post')
    subplot(2,2,3)
    imagesc(squeeze(nanmean(nanmean(grpcyc(:,:,:,peakWindow,4,1,2,1),4),1)),dfrangesit)
    axis off
    title('iso run pre')
    subplot(2,2,4)
    imagesc(squeeze(nanmean(nanmean(grpcyc(:,:,:,peakWindow,4,1,2,2),4),1)),dfrangesit)
    axis off
    title('iso run post')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end

    %%%cross maps
    figure
    colormap jet
    subplot(2,2,1)
    imagesc(squeeze(nanmean(nanmean(grpcyc(:,:,:,peakWindow,4,2,1,1),4),1)),dfrangesit)
    axis off
    title('cross sit pre')
    subplot(2,2,2)
    imagesc(squeeze(nanmean(nanmean(grpcyc(:,:,:,peakWindow,4,2,1,2),4),1)),dfrangesit)
    axis off
    title('cross sit post')
    subplot(2,2,3)
    imagesc(squeeze(nanmean(nanmean(grpcyc(:,:,:,peakWindow,4,2,2,1),4),1)),dfrangesit)
    axis off
    title('cross run pre')
    subplot(2,2,4)
    imagesc(squeeze(nanmean(nanmean(grpcyc(:,:,:,peakWindow,4,2,2,2),4),1)),dfrangesit)
    axis off
    title('cross run post')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end

    %%%iso/cross traces
    figure
    subplot(2,2,1)
    pre = squeeze(grptrace(:,:,4,1,1,1));post = squeeze(grptrace(:,:,4,1,1,2));
    hold on
    shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('time(s)')
    axis([timepts(1) timepts(end) -0.01 0.1])
    axis square
    title('iso sit')
    subplot(2,2,2)
    pre = squeeze(grptrace(:,:,4,1,2,1));post = squeeze(grptrace(:,:,4,1,2,2));
    hold on
    shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('time(s)')
    axis([timepts(1) timepts(end) -0.01 0.1])
    axis square
    title('iso run')
    subplot(2,2,3)
    pre = squeeze(grptrace(:,:,4,2,1,1));post = squeeze(grptrace(:,:,4,2,1,2));
    hold on
    shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('time(s)')
    axis([timepts(1) timepts(end) -0.01 0.1])
    axis square
    title('cross sit')
    subplot(2,2,4)
    pre = squeeze(grptrace(:,:,4,2,2,1));post = squeeze(grptrace(:,:,4,2,2,2));
    hold on
    shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('time(s)')
    axis([timepts(1) timepts(end) -0.01 0.1])
    axis square
    title('cross run')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end

    %%%iso/cross spread
    figure
    subplot(2,2,1)
    pre = squeeze(grpring(:,:,4,1,1,1));post = squeeze(grpring(:,:,4,1,1,2));
    hold on
    shadedErrorBar(1:ringx,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:ringx,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('distance from cent (pix)')
    axis([0 ringxrange -0.001 0.1])
    set(gca,'xtick',0:10:ringxrange,'xticklabel',0:10*pixbin:ringxrange*pixbin)
    axis square
    title('iso sit')
    subplot(2,2,2)
    pre = squeeze(grpring(:,:,4,1,2,1));post = squeeze(grpring(:,:,4,1,2,2));
    hold on
    shadedErrorBar(1:ringx,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:ringx,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('distance from cent (pix)')
    axis([0 ringxrange -0.001 0.1])
    set(gca,'xtick',0:10:ringxrange,'xticklabel',0:10*pixbin:ringxrange*pixbin)
    axis square
    title('iso run')
    subplot(2,2,3)
    pre = squeeze(grpring(:,:,4,2,1,1));post = squeeze(grpring(:,:,4,2,1,2));
    hold on
    shadedErrorBar(1:ringx,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:ringx,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('distance from cent (pix)')
    axis([0 ringxrange -0.001 0.1])
    set(gca,'xtick',0:10:ringxrange,'xticklabel',0:10*pixbin:ringxrange*pixbin)
    axis square
    title('cross sit')
    subplot(2,2,4)
    pre = squeeze(grpring(:,:,4,2,2,1));post = squeeze(grpring(:,:,4,2,2,2));
    hold on
    shadedErrorBar(1:ringx,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:ringx,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    ylabel('dfof')
    xlabel('distance from cent (pix)')
    axis([0 ringxrange -0.001 0.1])
    set(gca,'xtick',0:10:ringxrange,'xticklabel',0:10*pixbin:ringxrange*pixbin)
    axis square
    title('cross run')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end


    %%
    try
        save(fullfile(outpathname,grpfilename),'grpcyc','grpring','-v7.3','-append');
    catch
        save(fullfile(outpathname,grpfilename),'grpcyc','grpring','-v7.3');
    end

    try
        dos(['ps2pdf ' psfilename ' "' [grpfilename '.pdf'] '"'])
    catch
        display('couldnt generate pdf');
    end

    delete(psfilename);
end


