close all
clear all
batchOctoNLW

n = length(files);
sessions = unique({files.expt})

psfile = 'c:\temp\temp.ps';if exist(psfile,'file')==2;delete(psfile);end

[fPDF, pPDF] = uiputfile('*.pdf','save pdf file');

for s = 1:length(sessions)
    sess = find(strcmp({files.expt}, sessions{s}));
    locs = unique([files(sess).loc])
    for l = 1:length(locs)
        
        f  = find(strcmp({files.expt}, sessions{s}) & strcmp({files.stim}, '6x4') & [files.loc] ==locs(l)); f = f(1);
        fp = fullfile(pathname,files(f).path,sprintf('loc%d_acq%d_%s.mat',files(f).loc,files(f).acq,files(f).stim))
        load(fp,'meanGreenImg','topoOverlayImg','xpolarImg','ypolarImg');
        figure
        imshow(meanGreenImg); title(sprintf(sprintf('%s loc%d acq%d %s',files(f).expt,files(f).loc,files(f).acq,files(f).stim)))
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        figure
        subplot(2,2,1); imshow(meanGreenImg); title(sprintf('%s loc%d %s', files(f).expt,files(f).loc,files(f).stim))
        subplot(2,2,2); imshow(topoOverlayImg{2});
        subplot(2,2,3); imshow(xpolarImg{2});
        subplot(2,2,4); imshow(ypolarImg{2});
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        try
            f = find(strcmp({files.expt}, sessions{s}) & strcmp({files.stim}, '5x5') & [files.loc] ==locs(l)); f= f(1)
            fp = fullfile(pathname,files(f).path,sprintf('loc%d_acq%d_%s.mat',files(f).loc,files(f).acq,files(f).stim))
            load(fp,'meanGreenImg','topoOverlayImg','xpolarImg','ypolarImg');
            figure
            subplot(2,2,1); imshow(meanGreenImg); title(sprintf('%s loc%d %s', files(f).expt,files(f).loc,files(f).stim))
            subplot(2,2,2); imshow(topoOverlayImg{2});
            subplot(2,2,3); imshow(xpolarImg{2});
            subplot(2,2,4); imshow(ypolarImg{2});
            if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        catch
            display('couldnt do 5x5')
        end
        
        try
            f= find(strcmp({files.expt}, sessions{s}) & strcmp({files.stim}, 'Gratings3sf') & [files.loc] ==locs(l)); f = f(1);
            fp = fullfile(pathname,files(f).path,sprintf('loc%d_acq%d_%s.mat',files(f).loc,files(f).acq,files(f).stim))
            load(fp,'meanGreenImg','overlayImg','cycPolarImg','hvImg');
            figure
            subplot(2,2,1); imshow(meanGreenImg); title(sprintf('%s loc%d %s', files(f).expt,files(f).loc,files(f).stim))
            subplot(2,2,2); imshow(overlayImg);
            subplot(2,2,3); imshow(cycPolarImg); title('timecourse')
            subplot(2,2,4); imshow(hvImg); title('h vs v')
            if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

        catch
            display('couldnt do gratings')
        end
    end
end



newpdfFile = fullfile(pPDF,fPDF);
try
    dos(['ps2pdf ' psfile ' "' newpdfFile '"'] )
    
catch
    display('couldnt generate pdf');
end

