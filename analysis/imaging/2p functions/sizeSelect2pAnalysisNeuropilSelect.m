%%%sizeSelect2pAnalysisNeuropilSelect
%%%this is a condensed, cleaned up version of the size suppression analysis
%%%that uses manual selection of neuropil regions instead of topox/y data
%%%to select the cells to use

%%%this is a standalone size suppression analysis for 2p, does not
%%%incorporate gratings into cell selection

global S2P
dfWindow = 9:11;spWindow = 6:10;
spthresh = 0.1;%dfthresh = 0.05;
dt = 0.1;
cyclelength = 1/0.1;
moviefname = 'C:\sizeselectBin22min';
load(moviefname)
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)*2); end
thetaRange = unique(theta);

for f=1:length(use)
    filename = files(use(f)).sizeanalysis
    files(use(f)).subj
    psfilei = 'c:\tempPhil2pi.ps';
    if exist(psfilei,'file')==2;delete(psfilei);end

    load(files(use(f)).sizepts);
    load(files(use(f)).sizestimObj);
    spInterp = get2pSpeed(stimRec,dt,size(dF,2));
    spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);

    ntrials= floor(min(dt*length(dF)/(isi+duration),length(sf)));
    sf=sf(1:ntrials); theta=theta(1:ntrials); phase=phase(1:ntrials); radius=radius(1:ntrials); xpos=xpos(1:ntrials);
    onsets = dt + (0:ntrials-1)*(isi+duration);
    timepts = 1:(2*isi+duration)/dt;
    timepts = (timepts-1)*dt;
    running = zeros(1,ntrials);
    for i = 1:ntrials
        running(i) = mean(spInterp(1,1+cyclelength*(i-1):cyclelength+cyclelength*(i-1)),2)>20;
    end

    %%%scale spikes
    if (exist('S2P','var')&S2P==1)
        spikes = spikes/2;
    else
        spikes = spikes*10;
    end

    if exist(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat']))==0 | rerun%%comment for redo
        % load size select points file and stim object and align to stim
        sprintf('realigning to onsets')
        
        dfspcells = min([size(dF,1) size(spikes,1)]);
        dF = dF(1:dfspcells,:);spikes = spikes(1:dfspcells,:);

        dFout = align2onsets(dF,onsets,dt,timepts);
        spikesOut = align2onsets(spikes,onsets,dt,timepts);

        %%%subtract baseline period
        dFout2 = dFout;
        spikesOut2 = spikesOut;

        for i = 1:size(dFout,1)
            for j = 1:size(dFout,3)
                dFout2(i,:,j) = dFout(i,:,j)-nanmean(dFout(i,1:4,j));
                spikesOut2(i,:,j) = spikesOut(i,:,j)-nanmean(spikesOut(i,1:4,j));
            end
        end
        
        %%%get eye data
        [eyeAlign] = get2pEyes(files(use(f)).sizeeye,0,dt);
        eyes = align2onsets(eyeAlign',onsets,dt,timepts);
        
        save(fullfile(pathname,filename),'dFout2','spikesOut2','eyes','eyeAlign')
        save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
            'dFout2','spikesOut2','eyes','eyeAlign')
    else
        load(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat']),...
            'dFout2','spikesOut2','eyes','eyeAlign')
    end
    timepts = timepts - isi;%%%shift for plotting to stim onset
    
    %%%pixel-wise suppression plots
    load(files(use(f)).sizesession,'frmdata')

    figure
    for i = 1:length(sizes)
        subplot(2,ceil(length(sizes)/2),i)
        resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,i,1),3);
        respimg = mat2im(resp,jet,[-0.01 0.1]);
        imshow(respimg)
        set(gca,'ytick',[],'xtick',[])
        xlabel(sprintf('%sdeg resp',sizes{i}))
        axis equal
    end
    

    %%%use manual selection of 10 degree pixelwise response for cell selection
    if mod(f,2)~=0 & (~exist(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat'])) | reselect==1)
        figure
        title('select 10deg activated region')
        if length(size(frmdata))==5
            resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,3,1),3)-...
                nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,1,1),3);
        else
            resp = frmdata(cropx(1):cropx(2),cropy(1):cropy(2),3,1);
        end
        respimg = mat2im(resp,jet,[-0.01 0.1]);
        imshow(respimg)
        set(gca,'ytick',[],'xtick',[])
        [limy limx] = ginput(2);
        limx = sort(round(limx)); limy= sort(round(limy));
        hold on
        plot([limy(1) limy(1) limy(2) limy(2) limy(1)], [limx(1) limx(2) limx(2) limx(1) limx(1)],'g','linewidth',2);
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end

        goodprints = zeros(length(usePts),1);
        for i = 1:length(usePts)
            [xpt ypt] = ind2sub(size(meanShiftImg),usePts{i});
            xpt=mean(xpt);ypt=mean(ypt);
            if xpt>limx(1)&xpt<limx(2)&ypt>limy(1)&ypt<limy(2)
                goodprints(i) = 1;
            end
        end
        
        if (exist('S2P','var')&S2P==1)
            cellCutoff = size(spikes,1)
        else
            cellCutoff = files(use(f)).cutoff;
        end
        
        usecells = find(goodprints==1);usecells = usecells(usecells<cellCutoff);
        
        %%%calculate response as a function of distance from center
        y0 = round(mean(limy))+cropy(1);x0 = round(mean(limx))+cropx(1);
        limy=limy+cropy(1);limx=limx+cropx(1);
        [X,Y] = meshgrid(1:size(frmdata,1),1:size(frmdata,2));Y=Y/2;
        dist =sqrt((Y - x0/2).^2 + (X - y0).^2);
        
        goodprints = zeros(length(usePts),1);goodprints(usecells)=1;
        
        save(fullfile(pathname,filename),...
            'usecells','limx','limy','x0','y0','dist','goodprints','-append')
        save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
            'usecells','limx','limy','x0','y0','dist','goodprints','-append')
        
    else
        load(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_pre']),...
            'usecells','limx','limy','x0','y0','dist','goodprints')
        figure
        title('select 10deg activated region')
        resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,3,1),3);
        respimg = mat2im(resp,jet,[-0.01 0.1]);
        imshow(respimg)
        set(gca,'ytick',[],'xtick',[])
        hold on
        plot([limy(1) limy(1) limy(2) limy(2) limy(1)]-cropy(1), [limx(1) limx(2) limx(2) limx(1) limx(1)]-cropx(1),'g','linewidth',2);
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        save(fullfile(pathname,filename),...
            'usecells','limx','limy','x0','y0','dist','goodprints','-append')
        save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
            'usecells','limx','limy','x0','y0','dist','goodprints','-append')
    end
        
        
    %create array w/average responses per stim type
    dftuning = zeros(length(usecells),size(dFout2,2),length(sfrange),length(thetaRange),length(radiusRange),2);
    sptuning = zeros(length(usecells),size(spikesOut2,2),length(sfrange),length(thetaRange),length(radiusRange),2);
    for h = 1:length(usecells)
        for i = 1:length(sfrange)
            for j = 1:length(thetaRange)
                for k = 1:length(radiusRange)
                    for l = 1:2
                        dftuning(h,1:size(dFout2,2),i,j,k,l) = nanmean(dFout2(usecells(h),:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                        sptuning(h,1:size(spikesOut2,2),i,j,k,l) = nanmean(spikesOut2(usecells(h),:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                    end
                end
            end
        end
    end


    %%%subtract size zero trials
    dftuning2 = dftuning;sptuning2 = sptuning;
    ztrialdf = nan(size(dftuning,1),size(dftuning,2),2);ztrialsp=ztrialdf;
    for i = 1:2
        ztrialdf(:,:,i) = nanmean(nanmean(dftuning(:,:,:,:,1,i),3),4);
        ztrialsp(:,:,i) = nanmean(nanmean(sptuning(:,:,:,:,1,i),3),4);
    end
    for i = 1:length(sfrange)
        for j = 1:length(thetaRange)
            for k = 1:length(radiusRange)
                for l = 1:2
                    dftuning2(:,:,i,j,k,l) = dftuning(:,:,i,j,k,l) - ztrialdf(:,:,l);
                    sptuning2(:,:,i,j,k,l) = sptuning(:,:,i,j,k,l) - ztrialsp(:,:,l);
                end
            end
        end
    end

    dftuning = dftuning2;
    sptuning = sptuning2;
    
    
    if mod(f,2)~=0 & (~exist(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat'])) | reselect==1)    
        %%%%%cell-wise analysis
        %%%get sf and ori pref for size stimuli
        sizebestsfdf=nan(length(usecells),2);sizebestsfsp=sizebestsfdf;sizebestthetadf=sizebestsfdf;sizebestthetasp=sizebestsfdf;
        for i = 1:length(usecells)
            for j=1:2
                [tmp, sizebestsfdf(i,j)] = max(squeeze(nanmean(nanmean(dftuning(i,dfWindow,:,:,3,j),2),4))); %index of best sf
                [tmp, sizebestsfsp(i,j)] = max(squeeze(nanmean(nanmean(sptuning(i,spWindow,:,:,3,j),2),4)));
                [tmp, sizebestthetadf(i,j)] = max(squeeze(nanmean(nanmean(dftuning(i,dfWindow,:,:,3,j),2),3))); %index of best thetaQuad
                [tmp, sizebestthetasp(i,j)] = max(squeeze(nanmean(nanmean(sptuning(i,spWindow,:,:,3,j),2),3)));
            end
        end
        save(fullfile(pathname,filename),...
            'sizebestsfdf','sizebestsfsp','sizebestthetadf','sizebestthetasp','-append')
        save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
            'sizebestsfdf','sizebestsfsp','sizebestthetadf','sizebestthetasp','-append')
    else
        load(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_pre']),...
            'sizebestsfdf','sizebestsfsp','sizebestthetadf','sizebestthetasp')
    end
        

    %%%pull out best traces here
    dfsize = nan(length(usecells),size(dftuning,2),length(radiusRange),2);spsize=dfsize;
    for i = 1:length(usecells)
        for k = 1:length(sizes)
            for l = 1:2
            dfsize(i,:,k,l) = squeeze(dftuning(i,:,sizebestsfdf(i,1),...
                sizebestthetadf(i,1),k,l));
            spsize(i,:,k,l) = squeeze(sptuning(i,:,sizebestsfsp(i,1),...
                sizebestthetasp(i,1),k,l));
            end
        end
    end

    dfsize2 = dfsize;spsize2 = spsize;
    ztrialdf = nan(size(dfsize,1),size(dftuning,2),2);ztrialsp=ztrialdf;
    for i = 1:2
        ztrialdf(:,:,i) = squeeze(dfsize(:,:,1,i));
        ztrialsp(:,:,i) = squeeze(spsize(:,:,1,i));
    end
    for i = 1:length(radiusRange)
        for j = 1:2
            dfsize2(:,:,i,j) = dfsize(:,:,i,j) - ztrialdf(:,:,j);
            spsize2(:,:,i,j) = spsize(:,:,i,j) - ztrialsp(:,:,j);
        end
    end

    dfsize = dfsize2;
    spsize = spsize2;
        

    %%%calculate response as a function of distance from center
    %%%move the calc from grp analysis here
    binwidth = 20;
    ring = nan(ceil(max(max(dist))/binwidth),size(frmdata,3),size(frmdata,4),size(frmdata,5));
    for j = 1:size(frmdata,3)
        for k = 1:size(frmdata,4)
            for l = 1:size(frmdata,5)
                resp = squeeze(frmdata(:,:,j,k,l));
                for i = 1:ceil(max(max(dist)))/binwidth
                    ring(i,j,k,l) = mean(resp(dist>(binwidth*(i-1)) & dist<binwidth*i));
                end
            end
        end
    end

    figure
    subplot(1,2,1);imagesc(nanmean(frmdata(:,:,:,3,1),3),[-0.01 0.1]);axis equal;
    hold on
    plot([limy(1) limy(1) limy(2) limy(2) limy(1)], [limx(1) limx(2) limx(2) limx(1) limx(1)],'g','linewidth',2);
    plot(y0,x0,'ro')
    subplot(1,2,2);imagesc(dist);axis equal;hold on;plot(y0,x0,'ro')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end

    %%%compare 5/10deg pixel vs cell footprints
    figure
    subplot(1,3,1)
    resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,2,1),3);
    respimg = mat2im(resp,jet,[-0.01 0.1]);
    imshow(respimg)
    set(gca,'ytick',[],'xtick',[])
    xlabel('5deg resp')
    axis equal
    subplot(1,3,2)
    resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,3,1),3);
    respimg = mat2im(resp,jet,[-0.01 0.1]);
    imshow(respimg)
    set(gca,'ytick',[],'xtick',[])
    xlabel('10deg resp')
    axis equal
    subplot(1,3,3)
%         prints={};
%         for i=1:length(usecells)
%             prints{i} = usePts{usecells(i)};
%         end
    draw2pSegs(usePts,goodprints,parula,size(meanShiftImg),1:length(usePts),[0 2])
    colorbar off
    xlabel('center footprints')
    set(gca,'LooseInset',get(gca,'TightInset'))
    mtit('Pixel vs. Cell Center Response')
    if exist('psfilei','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilei,'-append');
    end       


    %%%plot sit dF
    for h = 1:length(sfrange)
        figure;
        colormap jet
        for i = 2:length(sizes)
            subplot(2,floor(length(sizes)/2),i-1)
            resp = nanmean(frmdata(:,:,h,i,1),3);
            imagesc(resp,[-0.01 0.1])
            set(gca,'ytick',[],'xtick',[])
            xlabel(sprintf('%sdeg',sizes{i}))
            axis square
        end
        mtit(sprintf('sit dF/size %0.2fcpd',sfrange(h)))
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        %%%plot run dF
        figure;
        colormap jet
        for i = 2:length(sizes)
            subplot(2,floor(length(sizes)/2),i-1)
            resp = nanmean(frmdata(:,:,h,i,2),3);
            imagesc(resp,[-0.01 0.1])
            set(gca,'ytick',[],'xtick',[])
            xlabel(sprintf('%sdeg',sizes{i}))
            axis square
        end
        mtit(sprintf('run dF/size %0.2fcpd',sfrange(h)))
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
    end

    %%%plot sit 20v50deg
    figure
    subplot(2,2,1)
    mrg=zeros(size(frmdata,1),size(frmdata,2),3);
    mrg(:,:,2) = nanmean(frmdata(:,:,1,4,1),3);
    mrg(:,:,1) = nanmean(frmdata(:,:,1,end,1),3);
    mrg=mrg*10;
    image(mrg)
    set(gca,'ytick',[],'xtick',[])
    xlabel(sprintf('sit %0.2fcpd',sfrange(1)))
    subplot(2,2,2)
    mrg=zeros(size(frmdata,1),size(frmdata,2),3);
    mrg(:,:,2) = nanmean(frmdata(:,:,1,4,2),3);
    mrg(:,:,1) = nanmean(frmdata(:,:,1,end,2),3);
    mrg=mrg*10;
    image(mrg)
    set(gca,'ytick',[],'xtick',[])
    xlabel(sprintf('run %0.2fcpd',sfrange(1)))
    subplot(2,2,3)
    mrg=zeros(size(frmdata,1),size(frmdata,2),3);
    mrg(:,:,2) = nanmean(frmdata(:,:,2,4,1),3);
    mrg(:,:,1) = nanmean(frmdata(:,:,2,end,1),3);
    mrg=mrg*10;
    image(mrg)
    set(gca,'ytick',[],'xtick',[])
    xlabel(sprintf('sit %0.2fcpd',sfrange(2)))
    subplot(2,2,4)
    mrg=zeros(size(frmdata,1),size(frmdata,2),3);
    mrg(:,:,2) = nanmean(frmdata(:,:,2,4,2),3);
    mrg(:,:,1) = nanmean(frmdata(:,:,2,end,2),3);
    mrg=mrg*10;
    image(mrg)
    set(gca,'ytick',[],'xtick',[])
    xlabel(sprintf('run %0.2fcpd',sfrange(2)))
    mtit('20deg (g) vs 50 deg (r)')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end


    %%%plot rasters for dfof and spikes
    load(files(use(f)).sizepts,'dF','spikes');
    figure
    imagesc(dF(usecells,:),[0 1]); ylabel('cell #'); xlabel('frame'); title('dF');
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end
    figure
    imagesc(spikes(usecells,:),[0 0.1]); ylabel('cell #'); xlabel('frame'); title('spikes');
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end

    %%%plot group df data for size select
    figure
    hold on
    sit = squeeze(nanmean(nanmean(dfsize(:,dfWindow,:,1),2),1));
    run = squeeze(nanmean(nanmean(dfsize(:,dfWindow,:,2),2),1));
    plot(1:length(radiusRange),sit,'k-o','Markersize',5)
    plot(1:length(radiusRange),run,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('sitting dfof grat params')
    axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    title('Mean df suppression curve')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end

    %%%plot cycle averages
    figure
    plotmax = max(max(max(nanmean(dfsize,1)))) + 0.1;
    plotmin = min(min(min(nanmean(dfsize,1)))) - 0.05;
    for i = 1:length(sizes)
        subplot(2,ceil(length(sizes)/2),i)
        hold on
        sit = dfsize(:,:,i,1);
        run = dfsize(:,:,i,2);
        shadedErrorBar(timepts,squeeze(nanmean(sit,1)),...
            squeeze(nanstd(sit,1))/sqrt(length(usecells)),'k',1)
        shadedErrorBar(timepts,squeeze(nanmean(run,1)),...
            squeeze(nanstd(run,1))/sqrt(length(usecells)),'r',1)
        axis square
        axis([timepts(1) timepts(end) plotmin plotmax])
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
    mtit('Mean df cycle avg/size')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end

    %%%calculate suppression index
    SIdf = nan(size(dfsize,1),2);
    for i = 1:size(dfsize,1)
        scurve = squeeze(nanmean(dfsize(i,dfWindow,:,1)));
        [val ind] = max(scurve);
        if (ind~=length(sizes))&(val~=0)
            SIdf(i,1) = (scurve(ind)-scurve(end))/(scurve(ind)+scurve(end));
        end
        scurve = squeeze(nanmean(dfsize(i,dfWindow,:,2)));
        [val ind] = max(scurve);
        if (ind~=length(sizes))&(val~=0)
            SIdf(i,2) = (scurve(ind)-scurve(end))/(scurve(ind)+scurve(end));
        end
    end

    figure
    hold on
    plot([1 2],[SIdf(:,1) SIdf(:,2)],'k.','Markersize',5)
    errorbar([1 2],[nanmean(SIdf(:,1)) nanmean(SIdf(:,2))],[nanstd(SIdf(:,1)) nanstd(SIdf(:,2))]/sqrt(size(dfsize,1)),'b','Markersize',20)
    axis([0 3 -2 5])
    set(gca,'xtick',[1 2],'xticklabel',{'sit','run'})
    ylabel('df SI')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end

    
    %%%plot group spikes data for size select
    figure
    subplot(1,3,1)
    hold on
    sit = squeeze(nanmean(nanmean(spsize(:,spWindow,:,1),2),1));
    run = squeeze(nanmean(nanmean(spsize(:,spWindow,:,2),2),1));
    plot(1:length(radiusRange),sit,'k-o','Markersize',5)
    plot(1:length(radiusRange),run,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('total spikes')
    axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    subplot(1,3,2)
    hold on
    sit = squeeze(nanmean(nanmean(spsize(:,6:7,:,1),2),1));
    run = squeeze(nanmean(nanmean(spsize(:,6:7,:,2),2),1));
    plot(1:length(radiusRange),sit,'k-o','Markersize',5)
    plot(1:length(radiusRange),run,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('early spikes')
    axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    subplot(1,3,3)
    hold on
    sit = squeeze(nanmean(nanmean(spsize(:,8:10,:,1),2),1));
    run = squeeze(nanmean(nanmean(spsize(:,8:10,:,2),2),1));
    plot(1:length(radiusRange),sit,'k-o','Markersize',5)
    plot(1:length(radiusRange),run,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('late spikes')
    axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    mtit('spike size tuning by time period')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end

    %%%plot cycle averages
    figure
    plotmax = max(max(max(nanmean(spsize,1)))) + 0.1;
    plotmin = min(min(min(nanmean(spsize,1)))) - 0.05;
    for i = 1:length(sizes)
        subplot(2,ceil(length(sizes)/2),i)
        hold on
        sit = spsize(:,:,i,1);
        run = spsize(:,:,i,2);
        shadedErrorBar(timepts,squeeze(nanmean(sit,1)),...
            squeeze(nanstd(sit,1))/sqrt(length(usecells)),'k',1)
        shadedErrorBar(timepts,squeeze(nanmean(run,1)),...
            squeeze(nanstd(run,1))/sqrt(length(usecells)),'r',1)
        axis square
        axis([timepts(1) timepts(end) plotmin plotmax])
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
    mtit('Mean spike cycle avg/size')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end

    %%%calculate suppression index
    SIsp = nan(size(spsize,1),2);
    for i = 1:size(spsize,1)
        scurve = squeeze(nanmean(spsize(i,spWindow,:,1)));
        [val ind] = max(scurve);
        if (ind~=length(sizes))&(val~=0)
            SIsp(i,1) = (scurve(ind)-scurve(end))/(scurve(ind)+scurve(end));
        end
        scurve = squeeze(nanmean(spsize(i,spWindow,:,2)));
        [val ind] = max(scurve);
        if (ind~=length(sizes))&(val~=0)
            SIsp(i,2) = (scurve(ind)-scurve(end))/(scurve(ind)+scurve(end));
        end
    end


    figure
    hold on
    plot([1 2],[SIsp(:,1) SIsp(:,2)],'k.-','Markersize',5)
    errorbar([1 2],[nanmean(SIsp(:,1)) nanmean(SIsp(:,2))],[nanstd(SIsp(:,1)) nanstd(SIsp(:,2))]/sqrt(size(dfsize,1)),'r','Markersize',20)
    axis([0 3 -2 5])
    set(gca,'xtick',[1 2],'xticklabel',{'sit','run'})
    ylabel('spike SI')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end


    %%%pull out cell footprints
    cellprint = {};
    for i = 1:length(usecells)
        acell = usePts{usecells(i)};
        cellpts = nan(length(acell),2);
        for j = 1:length(acell)
            [cellpts(j,1) cellpts(j,2)] = ind2sub(size(meanShiftImg),acell(j));
        end
        cellprint{i} = meanShiftImg(min(cellpts(:,1)):max(cellpts(:,1)),min(cellpts(:,2)):max(cellpts(:,2)),:);
        cellprint{i} = cellprint{i}/max(max(max(cellprint{i})));
    end
    
    %%%plot eye data
    figure
    plot(eyeAlign); legend('x','y','r');
    xlabel('frame')
    ylabel('position/diameter')
    title('eye data')
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end
    %%%calculate running/eye correlation
    rad = squeeze(eyeAlign(:,3));
    radbins = [0:5:50];
    avgrad = nanmean(rad);
    histrad = hist(rad,radbins);
    rad(find(isnan(rad))) = nanmean(rad);
    speed = spInterp';
    speed(find(isnan(speed))) = 0;
    cut = min(length(speed),length(rad));
    speed = speed(1:cut);rad = rad(1:cut);
    radsp = corr(rad,speed);
    %%%plot running vs. pupil diameter
    figure
    hold on
    plot(eyeAlign(:,3),'r')
    plot(spInterp,'b')
    set(gca,'ylim',[0 50],'ytick',[0:10:50])
    xlabel('frame')
    legend('pupil diam','speed')
    title(sprintf('pupil vs. running corr=%0.3f',radsp))
    if exist('psfilei','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilei,'-append');
    end

    %%%saving
    save(fullfile(pathname,filename),...
        'avgrad','histrad','spInterp','running','timepts','ntrials','onsets','dt','ring','frmdata','dfsize','spsize','cellprint','SIdf','SIsp','dftuning','sptuning','dfsize','spsize','sizebestsfdf','sizebestsfsp','sizebestthetadf','sizebestthetasp','-append')
    save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
        'avgrad','histrad','spInterp','running','timepts','ntrials','onsets','dt','ring','frmdata','dfsize','spsize','cellprint','SIdf','SIsp','dftuning','sptuning','dfsize','spsize','sizebestsfdf','sizebestsfsp','sizebestthetadf','sizebestthetasp','-append')
    try
        dos(['ps2pdf ' psfilei ' "' [fullfile(pathname,filename) '.pdf'] '"'] )
        dos(['ps2pdf ' psfilei ' "' [fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]) '.pdf'] '"'] )
    catch
        display('couldnt generate pdf');
    end

    delete(psfilei);
    close all
end
