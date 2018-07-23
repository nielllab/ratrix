%% batchAlignMaskWF
%takes in a bunch of WF experiments, aligns, then masks around brain
close all; clear all;
batchDeniseEnrichment
cd(pathname)

use = find(strcmp({files.notes},'good imaging session'));alluse=use;
% allsubj = unique({files(alluse).subj}); %needed for doTopography
% s=1:1;doTopography
% 
% for f = 1:length(use)
%     xshift = allxshift(f);
%     yshift = allyshift(f);
%     tshift = allthetashift(f);
%     save(files(use(f)).topox,'xshift','yshift','tshift','x0','y0','sz','zoom','-append')
% end

psfile = 'c:\tempPhil2pSize.ps';
% if exist(psfile,'file')==2;delete(psfile);end

%% load darkness data
numAni = length(use);
dt=0.1; %framerate

for f = 1:numAni
    
    sprintf('doing experiment %d/%d',f,numAni)
    
    sprintf('loading data')
    load(files(use(f)).topox,'xshift','yshift','tshift','x0','y0','sz','zoom')
    load(files(use(f)).darkness,'dfof_bg')

    sprintf('aligning and masking')
    clear dF
    dfof_bg = shiftImageRotate(dfof_bg,xshift+x0,yshift+y0,tshift,zoom,sz);
    
    [X,Y] = meshgrid(1:size(dfof_bg,2),1:size(dfof_bg,1));
    dist = sqrt((X - size(dfof_bg,2)/2).^2 + (Y - size(dfof_bg,1)/2).^2);
    
    rad = size(dfof_bg,2)/4;vmid = size(dfof_bg,1)/2;hmid = size(dfof_bg,2)/2;
    dF = nan(rad*2,rad*2,size(dfof_bg,3));
    for frm = 1:size(dfof_bg,3)
        tmp = squeeze(dfof_bg(:,:,frm));
        tmp(dist>(rad)) = NaN;
        dF(:,:,frm) = tmp(vmid-rad:vmid+rad-1,hmid-rad:hmid+rad-1);
    end
    
    %load stim object and get running
    load(files(use(f)).darknessstim,'stimRec')
    speed = get2pSpeed(stimRec,dt,size(dF,3));
    close
    
    rawimg = imread([files(use(f)).darknessdata '_0001.tif']);
    rawimg = shiftImageRotate(fliplr(rawimg(20:end,:)),xshift+x0,yshift+y0,tshift,zoom,sz);
    rawimg(dist>(rad)) = NaN;
    rawimg = rawimg(vmid-rad:vmid+rad-1,hmid-rad:hmid+rad-1);
    figure;colormap jet
    subplot(1,3,1)
    imagesc(nanstd(dF,[],3));axis off;axis image;title('dfof')
    subplot(1,3,2)
    imagesc(rawimg);axis off;axis image;title('raw');
    subplot(1,3,3)
    plot(speed)
    hold on
    plot((speed>20)*3500,'r.')
    xlabel('frame');ylabel('running speed')
    axis square
    mtit(sprintf('%s %s %s darkness',...
        files(use(f)).subj,files(use(f)).expt,files(use(f)).cond))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    sprintf('saving data')
    save(sprintf('%s_%s_%s_darkness',...
        files(use(f)).subj,files(use(f)).expt,files(use(f)).cond),'dF','speed','-v7.3')
end

%% save pdf
try
    dos(['ps2pdf ' psfile ' "' 'batchAlignMaskWF.pdf' '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);