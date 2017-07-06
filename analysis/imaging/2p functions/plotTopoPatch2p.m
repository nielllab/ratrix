%%%plotTopoPatch2p

close all
clear all
dbstop if error

psfile = 'c:\tempPhil2pSize.ps';
if exist(psfile,'file')==2;delete(psfile);end
filename = 'GroupTopoPatchMaps';

%select batch file
batchPhil2pSizeSelect22min

%%%create figures
txfig = figure;
tyfig = figure;
sz10fig = figure;
footfig = figure;

%%%populate the figures
numAni=length(files)/2; %for subplots
if mod(numAni,2)~=0
    numAni = numAni+1;
end
cnt=1;
for z = 1:2:length(files)
    
    load(files(z).topoxsession,'polarImg')
    figure(txfig)
    subplot(2,numAni/2,cnt)
    imshow(polarImg)
    colormap(hsv); %colorbar
    xlabel(sprintf('%s %s',files(z).expt,files(z).subj))
    
    load(files(z).topoysession,'polarImg')
    figure(tyfig)
    subplot(2,numAni/2,cnt)
    imshow(polarImg)
    colormap(hsv); %colorbar
    xlabel(sprintf('%s %s',files(z).expt,files(z).subj))
    
    load(files(z).sizesession,'frmdata','goodprints')
    if length(size(frmdata))==4
        img10 = squeeze(frmdata(:,:,3,1));
        img20 = squeeze(frmdata(:,:,4,1));
    else
        img10 = squeeze(nanmean(frmdata(:,:,:,3,1),3));
        img20 = squeeze(nanmean(frmdata(:,:,:,4,1),3));
    end
    figure(sz10fig)
    subplot(2,numAni/2,cnt)
    imagesc(img10,[-0.01,0.1])
    colormap jet
    xlabel(sprintf('%s %s',files(z).expt,files(z).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    load(files(z).sizepts,'usePts','meanShiftImg');
    figure(footfig)        
    subplot(2,numAni/2,cnt)
    draw2pSegs(usePts,goodprints,parula,size(meanShiftImg),1:length(usePts),[0 2])
    colorbar off
    xlabel(sprintf('%s %s',files(z).expt,files(z).subj))
    
    cnt=cnt+1;
end

figure(txfig)
mtit('topoX maps')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(tyfig)
mtit('topoY maps')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(sz10fig)
mtit('10deg response')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(footfig)
mtit('10deg footprints')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

try
    dos(['ps2pdf ' psfile ' "' [fullfile(pathname,filename) '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end