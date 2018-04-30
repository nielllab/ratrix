%%%analyzeS2PPhil
%%%MAKE SURE YOU HAVE THE CORRECT EXPERIMENT SELECTED IN make_db_Phil
close all
clear all

make_db_Phil

%%%option to rerun deconvolution - change settings in
%%%add_deconvolution_Phil under ops.deconvType
decon = input('redo deconvolution? 0=no, 1=yes: ');

%%%cycle over sessions in make_db_Phil
for z=1:length(db)
    
    sprintf('analyzing %d of %d',z,length(db))
    
    %%%load the data
    cd(db(z).procdir)
    load(db(z).procfile)

    %%%figure out how many actual cells there are take out any with nan values
    for h = 1:length(db(z).expname)
        baddies = find(isnan(dat.Fcell{h}));
        [idx val] = ind2sub(size(dat.Fcell{h}),baddies);
        baddie = unique(idx);
        if ~isempty(baddie)
            sprintf('found %d bad cells in block %d',length(baddie),h)
            for i=1:length(baddie)
                dat.stat(baddie(i)).iscell = 0;
            end
            dat.Fcell{h}(baddies) = rand(length(baddies),1)/1000;
            dat.FcellNeu{h}(baddies) = rand(length(baddies),1)/1000;
        else
            sprintf('no bad cells in block %d',h)
        end
    end

    %%%rerun deconvolution if there were bad cells w/no data or if user
    %%%chose to, save data back into proc file
    if ~isempty(baddie)|decon==1
        save(db(z).procfile,'dat','-append')
        sprintf('rerunning deconvolution')
        add_deconvolution_Phil(dat.ops,db(z));
        clear dat
        load(db(z).procfile)
        dat = {};
        dat.cl = cl;
        dat.clustrules = clustrules;
        dat.F = F;
        dat.Fcell = Fcell;
        dat.FcellNeu = FcellNeu;
        dat.figure = figure;
        dat.filename = filename;
        dat.map = map;
        dat.maxmap = maxmap;
        dat.mimg = mimg;
        dat.mimg_proc = mimg_proc;
        dat.ops = ops;
        dat.procmap = 0;
        dat.res = res;
        dat.stat = stat;
        dat.xlim = xlim;
        dat.ylim = ylim;
        save(db(z).procfile,'dat')
        
        clearvars -except z
        close all
        make_db_Phil
        load(db(z).procfile)
    end

    %%%make pdf file
    psfilename = 'C:\tempS2PPhil.ps';
    if exist(psfilename,'file')==2;delete(psfilename);end
    newpdfFile = fullfile(db(z).procdir,[db(z).aniname '_' db(z).expdate '_S2P.pdf']);

    %%%pull out data only for classified cells
    iscell = zeros(size(dat.Fcell{1},1),1);
    for i = 1:length(iscell)
        if dat.stat(i).iscell
            iscell(i) = 1;
        end
    end
    cells = find(iscell);
    
    %%%generate pts/imgs needed for 2p analysis functions
    usePts = {};
    meanImg = squeeze(dat.mimg(:,:,2));meanShiftImg=meanImg;
    cImage = squeeze(dat.mimg(:,:,5));
    cropx = [1;size(meanImg,2)];
    cropy = [50;750];
    for k = 1:length(cells)
        usePts{k} = sub2ind(size(meanImg),dat.stat(cells(k)).ypix,dat.stat(cells(k)).xpix);
    end

    %%%make mean image of entire recording session
    figure;
    subplot(1,2,1)
    imagesc(meanImg)
    title('Mean Image')
    axis off;axis image
%     if exist('psfilename','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfilename,'-append');
%     end

    %%%draw footprints of all classified cells
    subplot(1,2,2)
    usecells = usePts;
    draw2pSegs(usePts,1:length(usecells),jet,size(meanShiftImg),1:length(usecells),[1 length(usecells)])
    title('Cell Footprints')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end

    %%%save dF/F and spikes for each experiment only for classified cells
    for j = 1:size(dat.Fcell,2)
        spikes = zeros(length(cells),size(dat.Fcell{j},2));dF=spikes;
        for k = 1:length(cells)
            %%%make spike time/amp array
            times = find((dat.stat(cells(k)).st>dat.stat(cells(k)).blockstarts(j)&...
                (dat.stat(cells(k)).st<=dat.stat(cells(k)).blockstarts(j+1))));
            amps = dat.stat(cells(k)).c(times);
            times = dat.stat(cells(k)).st(times) - dat.stat(cells(k)).blockstarts(j);
            spikes(k,times) = amps;

            %%%make dF/F array
            F = dat.Fcell{j}(cells(k),:) - dat.FcellNeu{j}(cells(k),:)*dat.stat(cells(k)).neuropilCoefficient;
            F = F + (mean(dat.Fcell{j}(cells(k),:))-mean(F));
            F0 = prctile(F,10);
            dF(k,:) = (F-F0)/F0;
        end

        %%%plot spike data
        figure
        imagesc(spikes,[0 10])
        title(sprintf('spikes %s',db(z).expname{j}))
        colorbar
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end

        %%%plot dF/F data
        figure
        imagesc(dF,[0 10])
        title(sprintf('dF/F %s',db(z).expname{j}))
        colorbar
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end

        %%%load in green frame from sbx data and save out results
        thisSession = fullfile(db(z).expdir,[db(z).expname{j}(1:strfind(db(z).expname{j},'V2')+1) '.mat']);
%         load(thisSession,'greenframe');
        save(db(z).expname{j},'dF','meanImg','usePts','spikes','meanShiftImg','cropx','cropy','thisSession','cImage');%'greenframe',
    end

    %%%make pdf file for this session
    dos(['ps2pdf ' psfilename ' "' newpdfFile '"'] )
    if exist(newpdfFile,'file')
    %     ['ps2pdf ' psfilename ' "' psfilenameFinal(1:(end-2)) 'pdf"']
        display('generated pdf using dos ps2pdf')
    else
        try
            ps2pdf('psfile', psfilename, 'pdffile', newpdfFile)
            newpdfFile
            display('generated pdf using builtin matlab ps2pdf')
        catch
            display('couldnt generate pdf');
            keyboard
        end
    end

    delete(psfilename);
end


% for z = 1:10
% figure
% subplot(1,2,1)
% hold on
% plot(Fcell{1}(z,:));
% plot(FcellNeu{1}(z,:));
% plot(Fcell{1}(z,:)-FcellNeu{1}(z,:)*stat(z).neuropilCoefficient);
% xlim([1 3000])
% legend('cell F','neuropil','diff')
% hold off
% subplot(1,2,2)
% hold on
% plot(dF(z,:))
% plot(stat(z).st,stat(z).c/100,'r.','Markersize',5)
% legend('dF/F','spikes')
% xlim([1 3000])
% hold off
% mtit(sprintf('cell %d neuropilcoeff %0.2f',stat(z).iscell,stat(z).neuropilCoefficient))
% set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',8)
% end