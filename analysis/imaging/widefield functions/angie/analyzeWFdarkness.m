

%%%analyzeWFdarkness
close all
clear all
dbstop if error

%select batch file
batchPhilIntactSkull
cd(pathname)
 
%select animals to use
%use = find(strcmp({files.notes},'good darkness and stimulus') | strcmp({files.notes},'good stimulus'))
use = find(strcmp({files.subj}, 'G62XX1_TT') &strcmp({files.expt}, '121917'))
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
        doDarkness; %%%run individual analysis
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

    psfilename = 'c:\tempAngieWF.ps';
    if exist(psfilename,'file')==2;delete(psfilename);end

    %%%load stimulus info
    load('C:\patchonpatch16min')

    imagerate=10;
    cyclength = imagerate*(isi+duration);
    base = isi*imagerate-4:isi*imagerate-1;
    peakWindow = isi*imagerate+1:isi*imagerate+3;
    timepts = 0:1/imagerate:(2*isi+duration);timepts = timepts - isi;timepts = timepts(1:end-1);
    numAni = length(use)/2;
      if redogrp
        cd(outpathname)
        load(sprintf('%s_%s_%s_%s_darkness.mat',files(use(1)).expt,files(use(1)).subj,files(use(1)).timing,files(use(1)).inject));
        grpring = nan(numAni,50,size(ring,2),size(ring,3),size(ring,4),2);
        grpcyc = nan(numAni,size(trialcycavg,1),size(trialcycavg,2),size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),2);
        grptrace = nan(numAni,size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),2);

        anicnt = 1;
        for f = 1:2:length(use)
            aniFile = sprintf('%s_%s_%s_%s_darkness.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).timing,files(use(f)).inject);
            load(aniFile,'ring','trialcycavg','x','y')
            grpring(anicnt,1:size(ring,1),:,:,:,1) = ring;
            grpcyc(anicnt,:,:,:,:,:,:,1) = trialcycavg;
            grptrace(anicnt,:,:,:,:,1) = squeeze(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,:,:,:),1),2));

            aniFile = sprintf('%s_%s_%s_%s_darkness.mat',files(use(f+1)).expt,files(use(f+1)).subj,files(use(f+1)).timing,files(use(f+1)).inject);
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