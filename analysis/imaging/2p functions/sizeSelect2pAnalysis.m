%%%this is a standalone size suppression analysis for 2p, does not
%%%incorporate gratings into cell selection

%%%add in code to label all trials to include every trial for each cell to
%%%caclulate variance and Fano Factor

global S2P
exclude = 0; %0 removes trials above threshold, 1 clips them to the threshold
dfWindow = 9:11;
spWindow = 6:10;
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
%     if exist([filename '.mat'])==0 %%comment for redo
        files(use(f)).subj
        psfilei = 'c:\tempPhil2pi.ps';
        if exist(psfilei,'file')==2;delete(psfilei);end

        clear xph yph phaseVal rfCyc cycAvg rfAmp rf dftuning dftuningall sptuning sptuningall

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
        
        %%PCA coeff, score, latent
        [Cdf,Sdf,Ldf] = pca(dF');
        [Csp,Ssp,Lsp] = pca(spikes');
        pcdf = Sdf(:,1:10)';
        pcsp = Ssp(:,1:10)';


         if exist(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat']))==0 | rerun%%comment for redo
            % load size select points file and stim object and align to stim
            sprintf('realigning to onsets')
            
            %%%PCA%%% add in first 10 components to end of dF/spikes variable
    %         exvar = L/sum(L); exvar = exvar(1:10);
            cells=1:size(dF,1);
            pci = max(cells)+1:max(cells)+10;
            dF(pci,:) = pcdf; %%%add PCs to dF
            spikes(pci,:) = pcsp; %%%add PCs to spikes

            dFout = align2onsets(dF,onsets,dt,timepts);
    %         dFout = dFout(1:end-1,:,:); %%%extra cell at end for some reason
            pcdfOut = dFout(pci,:,:);
            dFout = dFout(cells,:,:);

            spikesOut = align2onsets(spikes,onsets,dt,timepts);
            pcspOut = spikesOut(pci,:,:);
            spikesOut = spikesOut(cells,:,:);

            %%%subtract baseline period
            dFout2 = dFout;
            spikesOut2 = spikesOut;
            pcdfOut2 = pcdfOut;
            pcspOut2 = pcspOut;

            for i = 1:size(dFout,1)
                for j = 1:size(dFout,3)
                    dFout2(i,:,j) = dFout(i,:,j)-nanmean(dFout(i,1:4,j));
                    spikesOut2(i,:,j) = spikesOut(i,:,j)-nanmean(spikesOut(i,1:4,j));
    %                 pcaOut2(i,:,j) = pcaOut(i,:,j)-nanmean(pcaOut(i,1:4,j));
    %                 %% subtract baseline for pcs???
                end
            end

            for i = 1:size(pcdfOut2,1)
                for j = 1:size(pcdfOut2,3)
                    pcdfOut2(i,:,j) = pcdfOut(i,:,j)-nanmean(pcdfOut(i,1:4,j));
                    pcspOut2(i,:,j) = pcspOut(i,:,j)-nanmean(pcspOut(i,1:4,j));
                end
            end
            
            

            
            %create array w/average responses per stim type
            dftuning = zeros(size(dFout2,1),size(dFout2,2),length(sfrange),length(thetaRange),length(radiusRange),2);
            sptuning = zeros(size(spikesOut2,1),size(spikesOut2,2),length(sfrange),length(thetaRange),length(radiusRange),2);
            for h = 1:size(dFout2,1)
                for i = 1:length(sfrange)
                    for j = 1:length(thetaRange)
                        for k = 1:length(radiusRange)
                            for l = 1:2
                                dftuning(h,1:size(dFout2,2),i,j,k,l) = nanmean(dFout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                                sptuning(h,1:size(spikesOut2,2),i,j,k,l) = nanmean(spikesOut2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
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


            pcdftuning = zeros(size(pcdfOut2,1),size(pcdfOut2,2),length(sfrange),length(thetaRange),length(radiusRange),2); pcsptuning = pcdftuning;
            for h = 1:size(pcdfOut2,1)
                for i = 1:length(sfrange)
                    for j = 1:length(thetaRange)
                        for k = 1:length(radiusRange)
                            for l = 1:2
                                pcdftuning(h,1:size(pcdfOut2,2),i,j,k,l) = nanmean(pcdfOut2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                                pcsptuning(h,1:size(pcdfOut2,2),i,j,k,l) = nanmean(pcspOut2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                            end
                        end
                    end
                end
            end


            %%%subtract size zero trials
            pcdftuning2 = pcdftuning; pcsptuning2 = pcsptuning;
            ztrialdf = nan(size(pcdftuning,1),size(pcdftuning,2),2);ztrialsp=ztrialdf;
            for i = 1:2
                ztrialdf(:,:,i) = nanmean(nanmean(pcdftuning(:,:,:,:,1,i),3),4);
                ztrialsp(:,:,i) = nanmean(nanmean(pcsptuning(:,:,:,:,1,i),3),4);
            end
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            pcdftuning2(:,:,i,j,k,l) = pcdftuning(:,:,i,j,k,l) - ztrialdf(:,:,l);
                            pcsptuning2(:,:,i,j,k,l) = pcsptuning(:,:,i,j,k,l) - ztrialsp(:,:,l);
                        end
                    end
                end
            end
            pcdftuning = pcdftuning2; pcsptuning = pcsptuning2;
            
            
            %%%get eye data
            [eyeAlign] = get2pEyes(files(use(f)).sizeeye,0,dt);
            eyes = align2onsets(eyeAlign',onsets,dt,timepts);
            
            updated = 1;
        else
            load(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat']),'sptuning','dftuning','pcdftuning','pcsptuning','eyeAlign','eyes')
        end
        timepts = timepts - isi;%%%shift for plotting to stim onset
        
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
        
        
        %%% get topo stimuli

        %%% read topoX (spatially periodic white noise)
        %%% long axis of monitor, generally vertical
        load(files(use(f)).sizepts);
        
        %%% extract phase and amplitude from complex fourier varlue at 0.1Hz
        load(files(use(f)).topoxsession,'map');
        load(files(use(f)).topoxpts);
        xph = phaseVal; rfCyc(:,:,1) = cycAvg;  %%%cycle averaged timecourse (10sec period)
        mapx = getMapPhase(map,cropx,cropy,usePts)'; close(gcf); %%% get topography based on neuropil
        lagvarX = 0.08; %%in sec, adjust for topox lag
        rfAmp(:,1) = abs(xph); rf(:,1) = mapx*128/(2*pi) - (lagvarX*128); %%% convert phase to pixel position, subtract 0.25sec from phase for gcamp delay
%         rfAmp(:,1) = abs(xph); rf(:,1) = mod(angle(xph)-(2*pi*lagvarX/10),2*pi)*128/(2*pi); %%% convert phase to pixel position, subtract 0.25sec from phase for gcamp delay
        topoxUse = mean(dF,2)~=0;  %%% find cells that were successfully extracted

        %%% read topoY (spatially periodic white noise)
        %%% short axis of monitor, generally horizontal
        load(files(use(f)).topoysession,'map');
        load(files(use(f)).topoypts);
        %%% extract phase and amplitude from complex fourier varlue at 0.1Hz
        yph = phaseVal; rfCyc(:,:,2) = cycAvg;
        mapy = getMapPhase(map,cropx,cropy,usePts)'; close(gcf); %%% get topography based on neuropil
        lagvarY = 0.05; %%in sec, adjust for topoy lag
        rfAmp(:,2) = abs(yph); rf(:,2) = mapy*72/(2*pi) - (lagvarY*72);
%         rfAmp(:,2) = abs(yph); rf(:,2) = mod(angle(yph) -(2*pi*lagvarY/10),2*pi)*72/(2*pi);
        topoyUse = mean(dF,2)~=0;

        if (exist('S2P','var')&S2P==1)
            cellCutoff = size(spikes,1)
        else
            cellCutoff = files(use(f)).cutoff;
        end
        
        %%% find sbc? use distance from center?
        d1 = sqrt((mod(angle(xph),2*pi)-pi).^2 + (mod(angle(yph),2*pi)-pi).^2);
        d2 = sqrt((mod(angle(xph)+pi,2*pi)-pi).^2 + (mod(angle(yph)+pi,2*pi)-pi).^2);
        sbc = (d1>d2 & rfAmp(:,1)>0.025 & rfAmp(:,2)>0.025);

        %%% select cells responsive to both topoX and topoY
        dpix = 0.8022; centrad = 5; ycent = 72/2; xcent = 128/2; %%deg/pix, radius of response size cutoff, x and y screen centers
        d = sqrt((rf(:,1)-xcent).^2 + (rf(:,2)-ycent).^2);

        %%% plot good topo cells trying different threshold values
        toporespthreshlist = [0.01 0.02 0.03 0.04 0.05 0.06];
        figure
        for i = 1:length(toporespthreshlist)
            subplot(2,3,i)
            allgoodTopo = find(~sbc & rfAmp(:,1)>toporespthreshlist(i) & rfAmp(:,2)>toporespthreshlist(i)); allgoodTopo = allgoodTopo(allgoodTopo<=cellCutoff);
            goodTopo = find(~sbc & rfAmp(:,1)>toporespthreshlist(i) & rfAmp(:,2)>toporespthreshlist(i) & d<centrad/dpix); goodTopo=goodTopo(goodTopo<=cellCutoff);
            hold on
            plot(rf(allgoodTopo,2),rf(allgoodTopo,1),'.','color',[0.5 0.5 0.5],'MarkerSize',5); %%% the rfAmp criterion wasn't being applied here
            plot(rf(goodTopo,2),rf(goodTopo,1),'b.','MarkerSize',5);
            circle(ycent,xcent,centrad/dpix)
            axis equal;
            box on
            axis([0 72 0 128]);
            set(gca,'xticklabel','','yticklabel','','xtick',[],'ytick',[])
            xlabel(sprintf('%.2f dfof',toporespthreshlist(i)))
        end
        mtit('Good topo cells/threshold')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        %%%set actual topo threshold
        toporespthresh = 0;
        allgoodTopo = find(~sbc & rfAmp(:,1)>toporespthresh & rfAmp(:,2)>toporespthresh); allgoodTopo = allgoodTopo(allgoodTopo<=cellCutoff); %%%~sbc & 
        goodTopo = find(~sbc & rfAmp(:,1)>toporespthresh & rfAmp(:,2)>toporespthresh & d<centrad/dpix); goodTopo=goodTopo(goodTopo<=cellCutoff);
        sprintf('%d cells with good topo under cutoff',length(allgoodTopo))
        sprintf('%d cells in center with good topo under cutoff',length(goodTopo))
        usecells = goodTopo; %%nusecells = setdiff(allgoodTopo,usecells);
%         if isempty(usecells)
%             continue
%         end
        
        
        %%%pixel-wise suppression plots
        load(files(use(f)).sizesession,'frmdata')
        
        figure
        subplot(1,2,1)
        resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,2,1),3);
        respimg = mat2im(resp,jet,[-0.01 0.1]);
        imshow(respimg)
        set(gca,'ytick',[],'xtick',[])
        xlabel('5deg resp')
        axis equal
        subplot(1,2,2)
        resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,3,1),3);
        respimg = mat2im(resp,jet,[-0.01 0.1]);
        imshow(respimg)
        set(gca,'ytick',[],'xtick',[])
        xlabel('10deg resp')
        axis equal
        
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
            usecells = find(goodprints==1);usecells = usecells(usecells<cellCutoff);
            %%%calculate response as a function of distance from center
            y0 = round(mean(limy))+cropy(1);x0 = round(mean(limx))+cropx(1);
            limy=limy+cropy(1);limx=limx+cropx(1);
            [X,Y] = meshgrid(1:size(frmdata,1),1:size(frmdata,2));Y=Y/2;
            dist =sqrt((Y - x0/2).^2 + (X - y0).^2);
        else
%             if mod(f,2)~=0
%                 load(files(use(f)).sizeanalysis,'usecells','limx','limy','x0','y0','dist','goodprints')
%             else
%                 load(files(use(f-1)).sizeanalysis,'usecells','limx','limy','x0','y0','dist','goodprints')
%             end
            load(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_pre']),'usecells','limx','limy','x0','y0','dist','goodprints')
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
        end
        
        %%%calculate response as a function of distance from center
        binwidth = 5;
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
%         goodprints = zeros(1,length(usePts));goodprints(allgoodTopo)=1;goodprints(goodTopo)=2;
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
        
        
        
        
        %%%%%cell-wise analysis
        %%%get sf and ori pref for size stimuli
        sizebestsf=nan(length(usecells),2);sizebesttheta=sizebestsf;
        sizebestsfresp=sizebestsf;sizebestthetaresp=sizebestsf;
        for i = 1:length(usecells)
            for j=1:2
                [sizebestsfrespdf(i,j) sizebestsfdf(i,j)] = max(squeeze(nanmean(nanmean(dftuning(usecells(i),dfWindow,:,:,3,j),2),4))); %index of best sf
                [sizebestsfrespsp(i,j) sizebestsfsp(i,j)] = max(squeeze(nanmean(nanmean(sptuning(usecells(i),spWindow,:,:,3,j),2),4)));
                [sizebestthetarespdf(i,j) sizebestthetadf(i,j)] = max(squeeze(nanmean(dftuning(usecells(i),dfWindow,sizebestsfdf(i,1),:,3,j),2))); %index of best thetaQuad
                [sizebestthetarespsp(i,j) sizebestthetasp(i,j)] = max(squeeze(nanmean(sptuning(usecells(i),spWindow,sizebestsfsp(i,1),:,3,j),2)));
            end
        end
        
        %%%pull out best traces here
        dfsize = nan(length(usecells),size(dftuning,2),length(radiusRange),2);spsize=dfsize;
        for i = 1:length(usecells)
            for k = 1:length(sizes)
                for l = 1:2
                dfsize(i,:,k,l) = squeeze(dftuning(usecells(i),:,sizebestsfdf(i,1),...
                    sizebestthetadf(i,1),k,l));
                spsize(i,:,k,l) = squeeze(sptuning(usecells(i),:,sizebestsfsp(i,1),...
                    sizebestthetasp(i,1),k,l));
                end
            end
        end
        
        %%%i do this thresholding at the group stage now since you need
        %%%pre+post data
% % %         %%%threshold out non-responding cells (only done for pre)
% % %         if mod(f,2)~=0
% % %             respcells = max(max(nanmean(spsize(:,dfWindow,:,:),2),[],3),[],4)>0.1;
% % %             usecells = usecells(respcells);
% % %             dfsize = dfsize(respcells,:,:,:);
% % %             spsize = spsize(respcells,:,:,:);
% % %         else
% % % %             load(files(use(f-1)).sizeanalysis,'respcells')
% % %             load(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_pre']),'respcells')
% % % %             usecells = usecells(respcells);
% % % %             dfsize = dfsize(respcells,:,:,:);
% % % %             spsize = spsize(respcells,:,:,:);
% % %         end
% % %         
% % %         if respcells==0
% % %             continue
% % %         end
      
        
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
        SI = nan(size(dfsize,1),2);
        for i = 1:size(dfsize,1)
            scurve = squeeze(nanmean(dfsize(i,dfWindow,:,1)));
            [val ind] = max(scurve);
            if (ind~=length(sizes))&(val~=0)
                SI(i,1) = (scurve(ind)-scurve(end))/scurve(ind);
            end
            scurve = squeeze(nanmean(dfsize(i,dfWindow,:,2)));
            [val ind] = max(scurve);
            if (ind~=length(sizes))&(val~=0)
                SI(i,2) = (scurve(ind)-scurve(end))/scurve(ind);
            end
        end
        
        SI(SI>1)=1;
        
        figure
        hold on
        plot([1 2],[SI(:,1) SI(:,2)],'k.','Markersize',5)
        errorbar([1 2],[nanmean(SI(:,1)) nanmean(SI(:,2))],[nanstd(SI(:,1)) nanstd(SI(:,2))]/sqrt(size(dfsize,1)),'b','Markersize',20)
        axis([0 3 0 1])
        set(gca,'xtick',[1 2],'xticklabel',{'sit','run'})
        ylabel('df SI')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        
        %%%x10 and ceil for max
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
        sit = squeeze(nanmean(nanmean(spsize(:,5:7,:,1),2),1));
        run = squeeze(nanmean(nanmean(spsize(:,5:7,:,2),2),1));
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
        SI = nan(size(spsize,1),2);
        for i = 1:size(spsize,1)
            scurve = squeeze(nanmean(spsize(i,spWindow,:,1)));
            [val ind] = max(scurve);
            if (ind~=length(sizes))&(val~=0)
                SI(i,1) = (scurve(ind)-scurve(end))/scurve(ind);
            end
            scurve = squeeze(nanmean(spsize(i,spWindow,:,2)));
            [val ind] = max(scurve);
            if (ind~=length(sizes))&(val~=0)
                SI(i,2) = (scurve(ind)-scurve(end))/scurve(ind);
            end
        end
        
        SI(SI>1)=1;
        
        figure
        hold on
        plot([1 2],[SI(:,1) SI(:,2)],'k.-','Markersize',5)
        errorbar([1 2],[nanmean(SI(:,1)) nanmean(SI(:,2))],[nanstd(SI(:,1)) nanstd(SI(:,2))]/sqrt(size(dfsize,1)),'r','Markersize',20)
        axis([0 3 0 1])
        set(gca,'xtick',[1 2],'xticklabel',{'sit','run'})
        ylabel('spike SI')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        
        
        
                
% %         %%%plot pca EV
% %         %%%pca all cells
% %         figure
% %         subplot(1,2,1)
% %         plot(Ldf/sum(Ldf))
% %         xlim([1 10])
% %         xlabel('Principle Component')
% %         ylabel('all dF Explained Variance')
% %         axis square
% %         axis([1 10 0 0.25])
% %         subplot(1,2,2)
% %         plot(Lsp/sum(Lsp))
% %         xlim([1 10])
% %         xlabel('Principle Component')
% %         ylabel('all spikes Explained Variance')
% %         axis square
% %         axis([1 10 0 0.25])
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperPositionMode', 'auto');
% %             print('-dpsc',psfilei,'-append');
% %         end
% % 
% %         % figure
% %         % hold on
% %         % for i = 2:size(S,1)
% %         %     col = cmapVar(i,1,size(S,1),jet);
% %         %     plot(S(i-1:i,1),S(i-1:i,2),'.-','color',col)
% %         % end
% %         
% %         %%%plot overall time course for pca
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             hold on
% %             plot(pcdf(i,:),'k')
% %             plot(spInterp/1000-5,'b')
% %             axis([1 length(spInterp) -5 10])
% %             axis square
% %             ylabel(sprintf('pc%d',i))
% %             xlabel('frame')
% %         end
% %         legend('PC','running','location','northeast')
% %         mtit('dF principle components')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             hold on
% %             plot(pcsp(i,:),'k')
% %             plot(spInterp/1000-5,'b')
% %             axis([1 length(spInterp) -5 10])
% %             axis square
% %             ylabel(sprintf('pc%d',i))
% %             xlabel('frame')
% %         end
% %         legend('PC','running','location','northeast')
% %         mtit('spike principle components')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% % 
% %         
% %         %%%plot pca time course for spikes
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(nanmean(pcsptuning(i,:,:,:,[4 7],:),6),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -2 2])
% %             xlabel(sprintf('pc%d',i))
% %         end
% %         legend('20deg','50deg','location','northwest')
% %         mtit('spike pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot first two pca components for spikes ori vs. size
% %         cnt=1;
% %         figure
% %         for i = 1:size(pcsptuning,4)
% %             for j = 2:size(pcsptuning,5)
% %                 pc1 = squeeze(nanmean(nanmean(pcsptuning(1,:,:,i,j,:),6),3));
% %                 pc2 = squeeze(nanmean(nanmean(pcsptuning(2,:,:,i,j,:),6),3));
% %                 subplot(size(pcsptuning,4),size(pcsptuning,5)-1,cnt)
% %                 hold on
% %                 for k = 2:length(pc1)
% % %                     col = cmapVar(k,1,length(pc1),jet);
% %                     if k<5|k>9
% %                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
% %                     else
% %                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
% %                     end
% %                 end
% %                 axis square
% %                 axis([-2 2 -2 2])
% %                 cnt=cnt+1;
% %             end
% %         end
% %         mtit('spPC1 vs spPC2 by orientation(row)/size(col)')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot first two pca components for spikes sf vs. run
% %         cnt=1;
% %         figure
% %         for i = 1:size(pcsptuning,3)
% %             for j = 1:size(pcsptuning,6)
% %                 pc1 = squeeze(nanmean(nanmean(pcsptuning(1,:,i,:,:,j),5),4));
% %                 pc2 = squeeze(nanmean(nanmean(pcsptuning(2,:,i,:,:,j),5),4));
% %                 subplot(size(pcsptuning,3),size(pcsptuning,6),cnt)
% %                 hold on
% %                 for k = 2:length(pc1)
% % %                     col = cmapVar(k,1,length(pc1),jet);
% %                     if k<5|k>9
% %                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
% %                     else
% %                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
% %                     end
% %                 end
% %                 axis square
% %                 axis([-2 2 -2 2])
% %                 cnt=cnt+1;
% %             end
% %         end
% %         mtit('spPC1 vs spPC2 by sf(row)/run(col)')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot first pc3 vs pc4 for spikes ori vs. size
% %         cnt=1;
% %         figure
% %         for i = 1:size(pcsptuning,4)
% %             for j = 2:size(pcsptuning,5)
% %                 pc1 = squeeze(nanmean(nanmean(pcsptuning(3,:,:,i,j,:),6),3));
% %                 pc2 = squeeze(nanmean(nanmean(pcsptuning(4,:,:,i,j,:),6),3));
% %                 subplot(size(pcsptuning,4),size(pcsptuning,5)-1,cnt)
% %                 hold on
% %                 for k = 2:length(pc1)
% % %                     col = cmapVar(k,1,length(pc1),jet);
% %                     if k<5|k>9
% %                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
% %                     else
% %                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
% %                     end
% %                 end
% %                 axis square
% %                 axis([-2 2 -2 2])
% %                 cnt=cnt+1;
% %             end
% %         end
% %         mtit('spPC3 vs spPC4 by orientation(row)/size(col)')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot PC3 vs PC4 for spikes sf vs. run
% %         cnt=1;
% %         figure
% %         for i = 1:size(pcsptuning,3)
% %             for j = 1:size(pcsptuning,6)
% %                 pc1 = squeeze(nanmean(nanmean(pcsptuning(3,:,i,:,:,j),5),4));
% %                 pc2 = squeeze(nanmean(nanmean(pcsptuning(4,:,i,:,:,j),5),4));
% %                 subplot(size(pcsptuning,3),size(pcsptuning,6),cnt)
% %                 hold on
% %                 for k = 2:length(pc1)
% % %                     col = cmapVar(k,1,length(pc1),jet);
% %                     if k<5|k>9
% %                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
% %                     else
% %                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
% %                     end
% %                 end
% %                 axis square
% %                 axis([-2 2 -2 2])
% %                 cnt=cnt+1;
% %             end
% %         end
% %         mtit('spPC3 vs spPC4 by sf(row)/run(col)')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
        
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
            
%         %%%plot individual cell data
%         for i=1:length(usecells)
%             figure
%             
%            
%             %%%avg resp to best stim for each size stationary
%             subplot(1,4,1)
%             hold on
%             traces = squeeze(dfsize(i,:,:,1));
%             plot(timepts,traces)
%             xlabel('Time(s)')
%             ylabel('sit dfof')
%             if isnan(min(min(traces)))
%                 axis([0 1 0 1])
%             else
%                 axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
%             end
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%             
%             %%%avg resp to best stim for each size running
%             subplot(1,4,2)
%             hold on
%             traces = squeeze(dfsize(i,:,:,2));
%             plot(timepts,traces)
%             xlabel('Time(s)')
%             ylabel('run dfof')
%             if isnan(min(min(traces)))
%                 axis([0 1 0 1])
%             else
%                 axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
%             end
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%             
%             %%%size curve based on gratings parameters
%             subplot(1,4,3)
%             hold on
%             splotsit = squeeze(nanmean(dfsize(i,dfWindow,:,1),2));
%             splotrun = squeeze(nanmean(dfsize(i,dfWindow,:,2),2));
%             plot(1:length(radiusRange),splotsit,'k-o','Markersize',5)
%             plot(1:length(radiusRange),splotrun,'r-o','Markersize',5)
%             xlabel('Stim Size (deg)')
%             ylabel('dfof')
%             axis([0 length(radiusRange)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
%             set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes)
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%             
%             %%%size curve based on gratings parameters
%             subplot(1,4,4)
%             imagesc(cellprint{i},[0.5 1]);
%             axis square
%             axis off
%      
%             mtit(sprintf('Cell #%d tuning',usecells(i)))
%             if exist('psfilei','var')
%                 set(gcf, 'PaperPositionMode', 'auto'); %%%figure out how to make this full page landscape
%                 print('-dpsc',psfilei,'-append');
%             end
%         end
        
        
        updated=1;
        %%%saving
        if ~exist(fullfile(pathname,[filename '.mat']))
            save(fullfile(pathname,filename),'avgrad','histrad','spInterp','running','eyes','eyeAlign','timepts','ntrials','onsets','dt','updated','ring','dist','limx','limy','x0','y0','frmdata','pcdftuning','pcsptuning','dftuning','sptuning','dfsize','spsize','usecells','cellprint','SI','goodprints')
            save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),'avgrad','histrad','spInterp','running','eyes','eyeAlign','timepts','ntrials','onsets','dt','updated','ring','dist','limx','limy','x0','y0','frmdata','pcdftuning','pcsptuning','dftuning','sptuning','dfsize','spsize','usecells','cellprint','SI','goodprints')
        else
            save(fullfile(pathname,filename),'avgrad','histrad','spInterp','running','eyes','eyeAlign','timepts','ntrials','onsets','dt','updated','ring','dist','limx','limy','x0','y0','frmdata','pcdftuning','pcsptuning','dftuning','sptuning','dfsize','spsize','usecells','cellprint','SI','goodprints','-append')
            save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),'avgrad','histrad','spInterp','running','eyes','eyeAlign','timepts','ntrials','onsets','dt','updated','ring','dist','limx','limy','x0','y0','frmdata','pcdftuning','pcsptuning','dftuning','sptuning','dfsize','spsize','usecells','cellprint','SI','goodprints','-append')
        end
        
        try
            dos(['ps2pdf ' psfilei ' "' [fullfile(pathname,filename) '.pdf'] '"'] )
            dos(['ps2pdf ' psfilei ' "' [fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]) '.pdf'] '"'] )
        catch
            display('couldnt generate pdf');
        end

        delete(psfilei);
        close all
%     else
%         sprintf('skipping %s',filename)
%     end

% keyboard
end







%         %%%plot average response of center pixels for 2 SFs
%         cwidth=[size(frmdata,1)/2 size(frmdata,2)/2];
%         centresp = zeros(length(sfrange),length(sizes),2);
%         for h = 1:length(sfrange)
%             for i = 1:length(sizes)
%                 for j = 1:2
%                 centresp(h,i,j) = nanmean(nanmean(frmdata(cwidth(1)-50:cwidth(1)+50,cwidth(2)-50:cwidth(2)+50,h,i,j)));
%                 end
%             end
%         end
%         figure
%         subplot(1,2,1)
%         hold on
%         plot(centresp(1,:,1))
%         plot(centresp(2,:,1))
%         legend(sprintf('%0.2fcpd',sfrange(1)),sprintf('%0.2fcpd',sfrange(2)),'location','northwest')
%         xlabel('size')
%         ylabel('sit dfof')
%         axis([0 length(radiusRange)+1 -0.02 0.12])
%         axis square
%         set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%         subplot(1,2,2)
%         hold on
%         plot(centresp(1,:,2))
%         plot(centresp(2,:,2))
%         legend(sprintf('%0.2fcpd',sfrange(1)),sprintf('%0.2fcpd',sfrange(2)),'location','northwest')
%         xlabel('size')
%         ylabel('run dfof')
%         axis([0 length(radiusRange)+1 -0.02 0.12])
%         axis square
%         set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%         mtit('Center Response')
%         if exist('psfilei','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfilei,'-append');
%         end
        
        
%         %%%compare 1st half of experiment to 2nd
%         figure;
%         colormap jet
%         for i = 2:length(sizes)
%             subplot(2,length(sizes)-1,i-1)
%             imagesc(frmdata1(:,:,i,1),[-0.01 0.1])
%             set(gca,'ytick',[],'xtick',[])
%             xlabel(sprintf('%sdeg 1st',sizes{i}))
%             axis square
%         end
%         for i = 2:length(sizes)
%             subplot(2,length(sizes)-1,length(sizes)+i-2)
%             imagesc(frmdata2(:,:,i,1),[-0.01 0.1])
%             set(gca,'ytick',[],'xtick',[])
%             xlabel(sprintf('%sdeg 2nd',sizes{i}))
%             axis square
%         end
%         mtit('1st vs 2nd half responses (sit)')
%         if exist('psfilei','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfilei,'-append');
%         end



%         if exclude
%             %threshold big guys out
%             sigthresh = 10;
%             for i=1:size(dFout,1)
%                 for j=1:size(dFout,3)
%                     if squeeze(max(dFout2(i,1:10,j),[],2))>sigthresh
%                         dFout2(i,:,j) = nan(1,size(dFout2,2));
%                     end
%                 end
%             end 
%         end
        % else
        %     %re-size big guys down to a max threshold
        %     sigthresh = 10;
        %     for i=1:size(dFout,1)
        %         for j=1:size(dFout,3)
        %             if squeeze(max(dFout(i,1:10,j),[],2))>sigthresh
        %                 vals = dFout(i,:,j);
        %                 vals(vals>sigthresh) = sigthresh;
        %                 dFout(i,:,j) = vals;
        %             end
        %         end
        %     end
        % end

        
        % thetamod = mod(theta,pi)-pi/8;
% thetaQuad = zeros(1,length(theta)); %break orientation into quadrants, 1=top,2=right,3=bot,4=left, offset pi/8 CCW
% thetaQuad(1,find(-pi/8<=thetamod&thetamod<pi/8))=1;
% thetaQuad(1,find(pi/8<=thetamod&thetamod<3*pi/8))=2;
% thetaQuad(1,find(3*pi/8<=thetamod&thetamod<5*pi/8))=3;
% thetaQuad(1,find(5*pi/8<=thetamod&thetamod<=7*pi/8))=4;


      
%         %%%use output from PRE and POST gratings analysis to pick cells
%         if mod(f,2)
%             gratfile = files(use(f)).gratinganalysis;
%             gratfile2 = files(use(f+1)).gratinganalysis;
%             openfig([gratfile '.fig'])
%             if exist('psfilei','var')
%                 set(gcf, 'PaperPositionMode', 'auto');
%                 print('-dpsc',psfilei,'-append');
%             end
%         else
%             gratfile = files(use(f-1)).gratinganalysis;
%             gratfile2 = files(use(f)).gratinganalysis;
%         end
%         load(gratfile,'dfgrat','dirrange','prefdir','prefthetaQuad','bestsftf','respcells','dfori','osi','dsi')
%         
%         %%%find usable cells, change arrays to match/decrease file size
%         usecells1 = intersect(goodTopo,respcells); %%%use only cells in center w/good resp to gratings
%         load(gratfile2,'respcells')
%         usecells2 = intersect(goodTopo,respcells);

%         usecells = union(usecells1,usecells2);
%         sprintf('%d cells with good topo in center & good gratings response',length(usecells))
%         usedfori = dfori(usecells,:,:);
%         useosi=osi(usecells,:); usedsi=dsi(usecells,:);
%         usebestsftf = bestsftf(usecells,:,:); useprefthetaQuad = prefthetaQuad(usecells,:);
%         userf = rf(usecells,:);
%         dfgrat = dfgrat(usecells,:,:);
        
        %%%the two stimuli are different so adjust cell preferences to try
        %%%to match them from gratings->size select
%         usebestsftf(find(usebestsftf==2))=1; %%combine 0.01 and 0.04 pref, set to index 1
%         usebestsftf(find(usebestsftf==3))=2; %%0.16, change to index 2




        
% %         %%%redo pca for cells in center vs outside     
% %         [Cusedf,Susedf,Lusedf] = pca(dF(usecells,:)');
% %         [Cusesp,Susesp,Lusesp] = pca(spikes(usecells,:)');
% %         [Cnusedf,Snusedf,Lnusedf] = pca(dF(nusecells,:)');
% %         [Cnusesp,Snusesp,Lnusesp] = pca(spikes(nusecells,:)');
% % 
% %         figure
% %         subplot(1,2,1)
% %         plot(Lusedf/sum(Lusedf))
% %         xlim([1 10])
% %         xlabel('Principle Component')
% %         ylabel('dF Explained Variance')
% %         axis square
% %         axis([1 10 0 0.25])
% %         subplot(1,2,2)
% %         plot(Lusesp/sum(Lusesp))
% %         xlim([1 10])
% %         xlabel('Principle Component')
% %         ylabel('spikes Explained Variance')
% %         axis square
% %         axis([1 10 0 0.25])
% %         mtit('PCA center cells')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperPositionMode', 'auto');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         figure
% %         subplot(1,2,1)
% %         plot(Lnusedf/sum(Lnusedf))
% %         xlim([1 10])
% %         xlabel('Principle Component')
% %         ylabel('dF Explained Variance')
% %         axis square
% %         axis([1 10 0 0.25])
% %         subplot(1,2,2)
% %         plot(Lnusesp/sum(Lnusesp))
% %         xlim([1 10])
% %         xlabel('Principle Component')
% %         ylabel('spikes Explained Variance')
% %         axis square
% %         axis([1 10 0 0.25])
% %         mtit('PCA surround cells')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperPositionMode', 'auto');
% %             print('-dpsc',psfilei,'-append');
% %         end
% % 
% %         % figure
% %         % hold on
% %         % for i = 2:size(S,1)
% %         %     col = cmapVar(i,1,size(S,1),jet);
% %         %     plot(S(i-1:i,1),S(i-1:i,2),'.-','color',col)
% %         % end
% % 
% %         pCusedf=zeros(10,size(Susedf,1));pCusesp=pCusedf;
% %         if length(usecells)<10
% %             pCusedf(1:length(usecells),:) = Susedf(:,1:length(usecells))';
% %             pCusesp(1:length(usecells),:) = Susesp(:,1:length(usecells))';
% %         else
% %             pCusedf = Susedf(:,1:10)';
% %             pCusesp = Susesp(:,1:10)';
% %         end
% %         pCnusedf = Snusedf(:,1:10)';
% %         pCnusesp = Snusesp(:,1:10)';
% %         
% %         pcAlign = [pCusedf;pCusesp;pCnusedf;pCnusesp];
% %         
% %         timepts = timepts+isi;
% %         pcAlignout = align2onsets(pcAlign,onsets,dt,timepts);
% %         timepts = timepts-isi;
% %         
% %         pCusedfout = pcAlignout(1:10,:,:);
% %         pCusespout = pcAlignout(11:20,:,:);
% %         pCnusedfout = pcAlignout(21:30,:,:);
% %         pCnusespout = pcAlignout(31:40,:,:);
% %         
% %         %%%subtract baseline period
% %         pCusedfout2 = pCusedfout;
% %         pCusespout2 = pCusespout;
% %         pCnusedfout2 = pCnusedfout;
% %         pCnusespout2 = pCnusespout;
% %         for i = 1:size(pCusedfout2,1)
% %             for j = 1:size(pCusedfout2,3)
% %                 pCusedfout2(i,:,j) = pCusedfout(i,:,j)-nanmean(pCusedfout(i,1:4,j));
% %                 pCusespout2(i,:,j) = pCusespout(i,:,j)-nanmean(pCusespout(i,1:4,j));
% %                 pCnusedfout2(i,:,j) = pCnusedfout(i,:,j)-nanmean(pCnusedfout(i,1:4,j));
% %                 pCnusespout2(i,:,j) = pCnusespout(i,:,j)-nanmean(pCnusespout(i,1:4,j));
% %             end
% %         end        
% %         
% %         pCusedftuning = zeros(size(pCusedfout2,1),size(pCusedfout2,2),length(sfrange),length(thetaRange),length(radiusRange),2);
% %         pCusesptuning = pCusedftuning; pCnusedftuning = pCusedftuning; pCnusesptuning = pCusedftuning;
% %         for h = 1:size(pCusedftuning,1)
% %             for i = 1:length(sfrange)
% %                 for j = 1:length(thetaRange)
% %                     for k = 1:length(radiusRange)
% %                         for l = 1:2
% %                             pCusedftuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pCusedfout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
% %                             pCusesptuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pCusespout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
% %                             pCnusedftuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pCnusedfout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
% %                             pCnusesptuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pCnusespout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
% %                         end
% %                     end
% %                 end
% %             end
% %         end
% %         
% %         pCusedftuning2 = pCusedftuning; pCusesptuning2 = pCusesptuning; pCnusedftuning2 = pCnusedftuning; pCnusesptuning2 = pCnusesptuning;
% %         %%%subtract size zero trials
% %         ztrialdfuse = nan(size(pCusedftuning,1),size(pCusedftuning,2),2);ztrialspuse=ztrialdfuse;ztrialdfnuse=ztrialdfuse;ztrialspnuse=ztrialdfuse;
% %         for i = 1:2
% %             ztrialdfuse(:,:,i) = nanmean(nanmean(pCusedftuning(:,:,:,:,1,i),3),4);
% %             ztrialspuse(:,:,i) = nanmean(nanmean(pCusesptuning(:,:,:,:,1,i),3),4);
% %             ztrialdfnuse(:,:,i) = nanmean(nanmean(pCnusedftuning(:,:,:,:,1,i),3),4);
% %             ztrialspnuse(:,:,i) = nanmean(nanmean(pCnusesptuning(:,:,:,:,1,i),3),4);
% %         end
% %         for i = 1:length(sfrange)
% %             for j = 1:length(thetaRange)
% %                 for k = 1:length(radiusRange)
% %                     for l = 1:2
% %                         pCusedftuning2(:,:,i,j,k,l) = pCusedftuning(:,:,i,j,k,l) - ztrialdfuse(:,:,l);
% %                         pCusesptuning2(:,:,i,j,k,l) = pCusesptuning(:,:,i,j,k,l) - ztrialspuse(:,:,l);
% %                         pCnusedftuning2(:,:,i,j,k,l) = pCnusedftuning(:,:,i,j,k,l) - ztrialdfnuse(:,:,l);
% %                         pCnusesptuning2(:,:,i,j,k,l) = pCnusesptuning(:,:,i,j,k,l) - ztrialspnuse(:,:,l);
% %                     end
% %                 end
% %             end
% %         end
% %         pCusedftuning = pCusedftuning2; pCusesptuning = pCusesptuning2; pCnusedftuning = pCnusedftuning2; pCnusesptuning = pCnusesptuning2;
% %         
% %         %%%plot pca time course for usedF
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(pCusedftuning(i,:,:,:,[4 7],1),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -0.5 2])
% %             legend(sprintf('pc%d 20deg',i),sprintf('50deg',i),'location','northwest')
% %         end
% %         mtit('sit cent-dF pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(pCusedftuning(i,:,:,:,[4 7],2),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -0.5 2])
% %             legend(sprintf('pc%d 20deg',i),sprintf('50deg',i),'location','northwest')
% %         end
% %         mtit('run cent-dF pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot first two pca components for usedF
% %         cnt=1;
% %         figure
% %         for i = 1:size(pCusedftuning,4)
% %             for j = 2:size(pCusedftuning,5)
% %                 pc1 = squeeze(nanmean(pCusedftuning(1,:,:,i,j,1),3));
% %                 pc2 = squeeze(nanmean(pCusedftuning(2,:,:,i,j,1),3));
% %                 subplot(size(pCusedftuning,4),size(pCusedftuning,5)-1,cnt)
% %                 hold on
% %                 for k = 2:length(pc1)
% % %                     col = cmapVar(k,1,length(pc1),jet);
% %                     if k<5|k>9
% %                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
% %                     else
% %                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
% %                     end
% %                 end
% %                 axis square
% %                 axis([-0.1 0.1 -0.1 0.1])
% %                 cnt=cnt+1;
% %             end
% %         end
% %         mtit('center dfPC1 vs dfPC2 orientation/size')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot pca time course for usespikes
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(pCusesptuning(i,:,:,:,[4 7],1),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -0.5 2])
% %             legend(sprintf('pc%d 20deg',i),sprintf('50deg',i),'location','northwest')
% %         end
% %         mtit('sit cent-spikes pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(pCusesptuning(i,:,:,:,[4 7],2),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -0.5 2])
% %             legend(sprintf('pc%d 20deg',i),sprintf('50deg',i),'location','northwest')
% %         end
% %         mtit('run cent-spikes pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot first two pca components for usespikes
% %         cnt=1;
% %         figure
% %         for i = 1:size(pCusesptuning,4)
% %             for j = 2:size(pCusesptuning,5)
% %                 pc1 = squeeze(nanmean(pCusesptuning(1,:,:,i,j,1),3));
% %                 pc2 = squeeze(nanmean(pCusesptuning(2,:,:,i,j,1),3));
% %                 subplot(size(pCusesptuning,4),size(pCusesptuning,5)-1,cnt)
% %                 hold on
% %                 for k = 2:length(pc1)
% % %                     col = cmapVar(k,1,length(pc1),jet);
% %                     if k<5|k>9
% %                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
% %                     else
% %                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
% %                     end
% %                 end
% %                 axis square
% %                 axis([-0.2 0.2 -0.2 0.2])
% %                 cnt=cnt+1;
% %             end
% %         end
% %         mtit('center spPC1 vs spPC2 orientation/size')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot pca time course for nusedF
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(pCnusedftuning(i,:,:,:,[4 7],1),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -0.5 2])
% %             legend(sprintf('pc%d 20deg',i),sprintf('50deg',i),'location','northwest')
% %         end
% %         mtit('sit surr-dF pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(pCnusedftuning(i,:,:,:,[4 7],2),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -0.5 2])
% %             legend(sprintf('pc%d 20deg',i),sprintf('50deg',i),'location','northwest')
% %         end
% %         mtit('run surr-dF pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot first two pca components for nusedF
% %         cnt=1;
% %         figure
% %         for i = 1:size(pCnusedftuning,4)
% %             for j = 2:size(pCnusedftuning,5)
% %                 pc1 = squeeze(nanmean(pCnusedftuning(1,:,:,i,j,1),3));
% %                 pc2 = squeeze(nanmean(pCnusedftuning(2,:,:,i,j,1),3));
% %                 subplot(size(pCnusedftuning,4),size(pCnusedftuning,5)-1,cnt)
% %                 hold on
% %                 for k = 2:length(pc1)
% % %                     col = cmapVar(k,1,length(pc1),jet);
% %                     if k<5|k>9
% %                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
% %                     else
% %                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
% %                     end
% %                 end
% %                 axis square
% %                 axis([-0.1 0.1 -0.1 0.1])
% %                 cnt=cnt+1;
% %             end
% %         end
% %         mtit('surround dfPC1 vs dfPC2 orientation/size')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot pca time course for nusespikes
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(pCnusesptuning(i,:,:,:,[4 7],1),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -0.5 2])
% %             legend(sprintf('pc%d 20deg',i),sprintf('50deg',i),'location','northwest')
% %         end
% %         mtit('sit surr-spikes pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         figure
% %         for i=1:10
% %             subplot(2,5,i)
% %             plot(timepts,squeeze(nanmean(nanmean(pCnusesptuning(i,:,:,:,[4 7],2),4),3)))
% %             axis square
% %             axis([timepts(1) timepts(end) -0.5 2])
% %             legend(sprintf('pc%d 20deg',i),sprintf('50deg',i),'location','northwest')
% %         end
% %         mtit('run surr-spikes pc timecourses')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end
% %         
% %         %%%plot first two pca components for nusespikes
% %         cnt=1;
% %         figure
% %         for i = 1:size(pCnusesptuning,4)
% %             for j = 2:size(pCnusesptuning,5)
% %                 pc1 = squeeze(nanmean(pCnusesptuning(1,:,:,i,j,1),3));
% %                 pc2 = squeeze(nanmean(pCnusesptuning(2,:,:,i,j,1),3));
% %                 subplot(size(pCnusesptuning,4),size(pCnusesptuning,5)-1,cnt)
% %                 hold on
% %                 for k = 2:length(pc1)
% % %                     col = cmapVar(k,1,length(pc1),jet);
% %                     if k<5|k>9
% %                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
% %                     else
% %                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
% %                     end
% %                 end
% %                 axis square
% %                 axis([-0.2 0.2 -0.2 0.2])
% %                 cnt=cnt+1;
% %             end
% %         end
% %         mtit('surround spPC1 vs spPC2 orientation/size')
% %         if exist('psfilei','var')
% %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %             print('-dpsc',psfilei,'-append');
% %         end



%%%plot screen for all six sizes w/threshold label for responsive
%         %%%df
%         userf = rf(usecells,:);
%         figure
%         for i=2:length(sizes)
%             subplot(2,floor(length(sizes)/2),i-1)
%             sizerespcells=[];
%             for j=1:length(usecells)
%                 goodresp = squeeze(nanmean(dfsize(j,dfWindow,i,1),2))>=0.05;
%                 if goodresp
%                     sizerespcells = [sizerespcells j];
%                 end
%             end
%             hold on
%             plot(userf(:,2),userf(:,1),'.','color',[0.5 0.5 0.5],'MarkerSize',5); %%% the rfAmp criterion wasn't being applied here
%             plot(userf(sizerespcells,2),userf(sizerespcells,1),'b.','MarkerSize',5);
%             circle(ycent,xcent,radiusRange(i)/dpix)
%             axis equal;
%             axis([0 72 0 128]);
%             box on
%             set(gca,'xticklabel','','yticklabel','','xtick',[],'ytick',[])
%         end
%         mtit('Responsive for each size (dF)')
%         if exist('psfilei','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfilei,'-append');
%         end
        
%         %%%plot screen for all six sizes w/threshold label for responsive
%         %%%spikes
%         figure
%         for i=2:length(sizes)
%             subplot(2,floor(length(sizes)/2),i-1)
%             sizerespcells=[];
%             for j=1:length(usecells)
%                 goodresp = squeeze(nanmean(spsize(j,spWindow,i,1),2))>=0.1;
%                 if goodresp
%                     sizerespcells = [sizerespcells j];
%                 end
%             end
%             hold on
%             plot(userf(:,2),userf(:,1),'.','color',[0.5 0.5 0.5],'MarkerSize',5); %%% the rfAmp criterion wasn't being applied here
%             plot(userf(sizerespcells,2),userf(sizerespcells,1),'b.','MarkerSize',5);
%             circle(ycent,xcent,radiusRange(i)/dpix)
%             axis equal;
%             axis([0 72 0 128]);
%             box on
%             set(gca,'xticklabel','','yticklabel','','xtick',[],'ytick',[])
%         end
%         mtit('Responsive for each size (spikes)')
%         if exist('psfilei','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfilei,'-append');
%         end


%         %%%plot pca time course for dF
%         figure
%         for i=1:10
%             subplot(2,5,i)
%             plot(timepts,squeeze(nanmean(nanmean(pcdftuning(i,:,:,:,[4 7],1),4),3)))
%             axis square
%             axis([timepts(1) timepts(end) -1 1])
%         end
%         legend('20deg','50deg','location','northwest')
%         mtit('dF pc timecourses')
%         if exist('psfilei','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfilei,'-append');
%         end
%         
%         %%%plot first two pca components for dF
%         cnt=1;
%         figure
%         for i = 1:size(pcdftuning,4)
%             for j = 2:size(pcdftuning,5)
%                 pc1 = squeeze(nanmean(pcdftuning(1,:,:,i,j,1),3));
%                 pc2 = squeeze(nanmean(pcdftuning(2,:,:,i,j,1),3));
%                 subplot(size(pcdftuning,4),size(pcdftuning,5)-1,cnt)
%                 hold on
%                 for k = 2:length(pc1)
% %                     col = cmapVar(k,1,length(pc1),jet);
%                     if k<5|k>9
%                         plot(pc1(k-1:k),pc2(k-1:k),'k.-')
%                     else
%                         plot(pc1(k-1:k),pc2(k-1:k),'b.-')
%                     end
%                 end
%                 axis square
%                 axis([-0.5 0.5 -0.5 0.5])
%                 cnt=cnt+1;
%             end
%         end
%         mtit('dfPC1 vs dfPC2 by orientation/size')
%         if exist('psfilei','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfilei,'-append');
%         end


        
%         %%%pull out trial-trial eye data
%         eyetuning = zeros(size(eyes,1),size(eyes,2),length(sfrange),length(thetaRange),length(radiusRange),2);
%         for h = 1:size(eyetuning,1)
%             for i = 1:length(sfrange)
%                 for j = 1:length(thetaRange)
%                     for k = 1:length(radiusRange)
%                         for l = 1:2
%                             eyetuning(h,:,i,j,k,l) = nanmean(eyes(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
%                         end
%                     end
%                 end
%             end
%         end
% 
%         %%%plot pupil diameter per size
%         avgrad = nan(length(sizes),2);
%         for i = 1:length(sizes)
%             for j = 1:2
%                 avgrad(i,j) = nanmean(nanmean(nanmean(eyetuning(3,:,:,:,i,j),4),3),2);
%             end
%         end
% 
%         figure
%         subplot(1,2,1)
%         plot(1:length(sizes),avgrad(:,1),'ko')
%         axis([0 length(sizes) 15 25])
%         xlabel('size')
%         ylabel('sit pupil diameter')
%         set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%         subplot(1,2,2)
%         plot(1:length(sizes),avgrad(:,2),'ko')
%         axis([0 length(sizes) 20 30])
%         xlabel('size')
%         ylabel('run pupil diameter')
%         set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%         mtit('pupil size per stim size')
%         if exist('psfilei','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfilei,'-append');
%         end