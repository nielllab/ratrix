%%%this is a standalone size suppression analysis for 2p, does not
%%%incorporate gratings into cell selection

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
% thetamod = mod(theta,pi)-pi/8;
% thetaQuad = zeros(1,length(theta)); %break orientation into quadrants, 1=top,2=right,3=bot,4=left, offset pi/8 CCW
% thetaQuad(1,find(-pi/8<=thetamod&thetamod<pi/8))=1;
% thetaQuad(1,find(pi/8<=thetamod&thetamod<3*pi/8))=2;
% thetaQuad(1,find(3*pi/8<=thetamod&thetamod<5*pi/8))=3;
% thetaQuad(1,find(5*pi/8<=thetamod&thetamod<=7*pi/8))=4;
thetaRange = unique(theta);

for f=1:length(use)
    filename = files(use(f)).sizeanalysis
%     if exist([filename '.mat'])==0 %%comment for redo
        files(use(f)).subj
        psfilei = 'c:\tempPhil2pi.ps';
        if exist(psfilei,'file')==2;delete(psfilei);end

        clear xph yph phaseVal rfCyc cycAvg rfAmp rf dftuning dftuningall sptuning sptuningall

        %%% get topo stimuli

        %%% read topoX (spatially periodic white noise)
        %%% long axis of monitor, generally vertical
        load(files(use(f)).topoxpts);
        %%% extract phase and amplitude from complex fourier varlue at 0.1Hz
        xph = phaseVal; rfCyc(:,:,1) = cycAvg;  %%%cycle averaged timecourse (10sec period)
        rfAmp(:,1) = abs(xph); rf(:,1) = mod(angle(xph)-(2*pi*0.25/10),2*pi)*128/(2*pi); %%% convert phase to pixel position, subtract 0.25sec from phase for gcamp delay
        topoxUse = mean(dF,2)~=0;  %%% find cells that were successfully extracted

        %%% read topoY (spatially periodic white noise)
        %%% short axis of monitor, generally horizontal
        load(files(use(f)).topoypts);
        %%% extract phase and amplitude from complex fourier varlue at 0.1Hz
        yph = phaseVal; rfCyc(:,:,2) = cycAvg;
        rf(:,2) = mod(angle(yph)-(2*pi*0.25/10),2*pi)*72/(2*pi); rfAmp(:,2) = abs(yph);
        topoyUse = mean(dF,2)~=0;

        cellCutoff = size(spikes,1)

        %%% find sbc? use distance from center?
        d1 = sqrt((mod(angle(xph),2*pi)-pi).^2 + (mod(angle(yph),2*pi)-pi).^2);
        d2 = sqrt((mod(angle(xph)+pi,2*pi)-pi).^2 + (mod(angle(yph)+pi,2*pi)-pi).^2);
        sbc = (d1>d2);

        %%% select cells responsive to both topoX and topoY
        dpix = 0.8022; centrad = 10; ycent = 72/2; xcent = 128/2; %%deg/pix, radius of response size cutoff, x and y screen centers
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
            axis([0 72 0 128]);
            set(gca,'xticklabel','','yticklabel','')
            xlabel(sprintf('%.2f dfof',toporespthreshlist(i)))
        end
        mtit('Good topo cells/threshold')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        %%%set actual topo threshold
        toporespthresh = 0.025;
        allgoodTopo = find(~sbc & rfAmp(:,1)>toporespthresh & rfAmp(:,2)>toporespthresh); allgoodTopo = allgoodTopo(allgoodTopo<=cellCutoff);
        goodTopo = find(~sbc & rfAmp(:,1)>toporespthresh & rfAmp(:,2)>toporespthresh & d<centrad/dpix); goodTopo=goodTopo(goodTopo<=cellCutoff);
        sprintf('%d cells with good topo under cutoff',length(allgoodTopo))
        sprintf('%d cells in center with good topo under cutoff',length(goodTopo))
        usecells = goodTopo;
        
        % load size select points file and stim object and align to stim
        load(files(use(f)).sizepts);
        load(files(use(f)).sizestimObj);
        spInterp = get2pSpeed(stimRec,dt,size(dF,2));
        spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);
        
        %%%plot rasters for dfof and spikes
        figure
        imagesc(dF(goodTopo,:),[0 1]); ylabel('cell #'); xlabel('frame'); title('dF');
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        figure
        imagesc(spikeBinned(goodTopo,:),[0 0.1]); ylabel('cell #'); xlabel('frame'); title('spikes');
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end

        ntrials= min(dt*length(dF)/(isi+duration),length(sf));
        onsets = dt + (0:ntrials-1)*(isi+duration);
        timepts = 1:(2*isi+duration)/dt;
        timepts = (timepts-1)*dt;
        
        %%%PCA%%% add in first 10 components to end of dF variable
        %%coeff, score, latent
        
        spikes=spikes/2; %%%spikes scaling factor

        [Cdf,Sdf,Ldf] = pca(dF');
        [Csp,Ssp,Lsp] = pca(spikes');

        figure
        subplot(1,2,1)
        plot(Ldf/sum(Ldf))
        xlim([1 10])
        xlabel('Principle Component')
        ylabel('dF Explained Variance')
        axis square
        subplot(1,2,2)
        plot(Lsp/sum(Lsp))
        xlim([1 10])
        xlabel('Principle Component')
        ylabel('spikes Explained Variance')
        axis square
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end

        % figure
        % hold on
        % for i = 2:size(S,1)
        %     col = cmapVar(i,1,size(S,1),jet);
        %     plot(S(i-1:i,1),S(i-1:i,2),'.-','color',col)
        % end

        pcdf = Sdf(:,1:10)';
        pcsp = Ssp(:,1:10)';
        
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
        
        
        timepts = timepts - isi;
        running = zeros(1,ntrials);
        for i = 1:ntrials
            running(i) = mean(spInterp(1,1+cyclelength*(i-1):cyclelength+cyclelength*(i-1)),2)>20;
        end

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

        %create array w/average responses per stim type
        dftuning = zeros(length(usecells),size(dFout,2),length(sfrange),length(thetaRange),length(radiusRange),2);
        sptuning = zeros(length(usecells),size(spikesOut,2),length(sfrange),length(thetaRange),length(radiusRange),2);
        for h = 1:length(usecells)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            dftuning(h,1:size(dFout,2),i,j,k,l) = nanmean(dFout2(usecells(h),:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                            sptuning(h,1:size(spikesOut,2),i,j,k,l) = nanmean(spikesOut2(usecells(h),:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                        end
                    end
                end
            end
        end
       
        %%%avg across all zeros instead of by trials
        dftuning2 = dftuning;
        sptuning2 = sptuning;
        %%%subtract size zero trials
        for h = 1:length(usecells)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            dftuning2(h,:,i,j,k,l) = dftuning(h,:,i,j,k,l) - dftuning(h,:,i,j,1,l);
                            sptuning2(h,:,i,j,k,l) = sptuning(h,:,i,j,k,l) - sptuning(h,:,i,j,1,l);
                        end
                    end
                end
            end
        end
        
        dftuning = dftuning2;
        sptuning = sptuning2;
        
                
        pcdftuning = zeros(size(pcdfOut,1),size(pcdfOut,2),length(sfrange),length(thetaRange),length(radiusRange),2); pcsptuning = pcdftuning;
        for h = 1:size(pcdfOut,1)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            pcdftuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pcdfOut2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                            pcsptuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pcspOut2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                        end
                    end
                end
            end
        end
        
        pcdftuning2 = pcdftuning; pcsptuning2 = pcsptuning;
        %%%subtract size zero trials
        for h = 1:size(pcdftuning2,1)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            pcdftuning2(h,:,i,j,k,l) = pcdftuning(h,:,i,j,k,l) - pcdftuning(h,:,i,j,1,l);
                            pcsptuning2(h,:,i,j,k,l) = pcsptuning(h,:,i,j,k,l) - pcsptuning(h,:,i,j,1,l);
                        end
                    end
                end
            end
        end
        pcdftuning = pcdftuning2; pcsptuning = pcsptuning2;
        
        %%%plot first two pca components for dF
        cnt=1;
        figure
        for i = 1:size(pcdftuning,4)
            for j = 2:size(pcdftuning,5)
                pc1 = squeeze(nanmean(pcdftuning(1,:,:,i,j,1),3));
                pc2 = squeeze(nanmean(pcdftuning(2,:,:,i,j,1),3));
                subplot(size(pcdftuning,4),size(pcdftuning,5)-1,cnt)
                hold on
                for k = 2:length(pc1)
                    col = cmapVar(k,1,length(pc1),jet);
                    plot(pc1(k-1:k),pc2(k-1:k),'.-','color',col)
                end
                axis square
                cnt=cnt+1;
            end
        end
        mtit('dfPC1 vs dfPC2 by orientation/size')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        %%%plot first two pca components for spikes
        cnt=1;
        figure
        for i = 1:size(pcsptuning,4)
            for j = 2:size(pcsptuning,5)
                pc1 = squeeze(nanmean(pcsptuning(1,:,:,i,j,1),3));
                pc2 = squeeze(nanmean(pcsptuning(2,:,:,i,j,1),3));
                subplot(size(pcsptuning,4),size(pcsptuning,5)-1,cnt)
                hold on
                for k = 2:length(pc1)
                    col = cmapVar(k,1,length(pc1),jet);
                    plot(pc1(k-1:k),pc2(k-1:k),'.-','color',col)
                end
                axis square
                cnt=cnt+1;
            end
        end
        mtit('spPC1 vs spPC2 by orientation/size')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        %%%%%cell-wise analysis
        %%%get sf and ori pref for size stimuli
        sizebestsf=nan(length(usecells),2);sizebesttheta=sizebestsf;
        sizebestsfresp=sizebestsf;sizebestthetaresp=sizebestsf;
        for i = 1:length(usecells)
            [sizebestsfresp(i,1) sizebestsf(i,1)] = max(squeeze(nanmean(nanmean(sptuning(i,dfWindow,:,:,3,1),2),4))); %index of best sf
            [sizebestsfresp(i,2) sizebestsf(i,2)] = max(squeeze(nanmean(nanmean(sptuning(i,dfWindow,:,:,3,2),2),4)));
            [sizebestthetaresp(i,1) sizebesttheta(i,1)] = max(squeeze(nanmean(sptuning(i,dfWindow,sizebestsf(i,1),:,3,1),2))); %index of best thetaQuad
            [sizebestthetaresp(i,2) sizebesttheta(i,2)] = max(squeeze(nanmean(sptuning(i,dfWindow,sizebestsf(i,1),:,3,2),2)));
        end
        
        %%%pull out best traces here
        dfsize = nan(length(usecells),size(dFout,2),length(radiusRange),2);
        dfsizebest = nan(length(usecells),size(dFout,2),length(sizes),2);
        for i = 1:length(usecells)
            for k = 1:length(sizes)
                for l = 1:2
                dfsize(i,:,k,l) = squeeze(nanmean(sptuning(i,:,sizebestsf(i,1),...
                    sizebesttheta(i,1),k,l),5));
                end
            end
        end
               
        %%%plot screen for all six sizes w/threshold label for responsive
        userf = rf(usecells,:);
        figure
        for i=1:length(sizes)
            subplot(2,ceil(length(sizes)/2),i)
            sizerespcells=[];
            for j=1:length(usecells)
                goodresp = squeeze(nanmean(sptuning(j,dfWindow,sizebestsf(j,1),sizebesttheta(j,1),i,1),2))>=0.1;
                if goodresp
                    sizerespcells = [sizerespcells j];
                end
            end
            hold on
            plot(userf(:,2),userf(:,1),'.','color',[0.5 0.5 0.5],'MarkerSize',5); %%% the rfAmp criterion wasn't being applied here
            plot(userf(sizerespcells,2),userf(sizerespcells,1),'b.','MarkerSize',5);
            circle(ycent,xcent,radiusRange(i)/dpix)
            axis equal;
            axis([0 72 0 128]);
            set(gca,'xticklabel','','yticklabel','')
        end
        mtit('Responsive cells for each size')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        
        %%%redo pca for cells in center vs outside
        allcells = 1:size(dF,1);
        nusecells = setdiff(allcells,usecells);
        
        [Cusedf,Susedf,Lusedf] = pca(dF(usecells,:)');
        [Cusesp,Susesp,Lusesp] = pca(spikes(usecells,:)');
        [Cnusedf,Snusedf,Lnusedf] = pca(dF(nusecells,:)');
        [Cnusesp,Snusesp,Lnusesp] = pca(spikes(nusecells,:)');

        figure
        subplot(1,2,1)
        plot(Lusedf/sum(Lusedf))
        xlim([1 10])
        xlabel('Principle Component')
        ylabel('dF Explained Variance')
        axis square
        subplot(1,2,2)
        plot(Lusesp/sum(Lusesp))
        xlim([1 10])
        xlabel('Principle Component')
        ylabel('spikes Explained Variance')
        axis square
        mtit('PCA center cells')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        figure
        subplot(1,2,1)
        plot(Lnusedf/sum(Lnusedf))
        xlim([1 10])
        xlabel('Principle Component')
        ylabel('dF Explained Variance')
        axis square
        subplot(1,2,2)
        plot(Lnusesp/sum(Lnusesp))
        xlim([1 10])
        xlabel('Principle Component')
        ylabel('spikes Explained Variance')
        axis square
        mtit('PCA surround cells')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end

        % figure
        % hold on
        % for i = 2:size(S,1)
        %     col = cmapVar(i,1,size(S,1),jet);
        %     plot(S(i-1:i,1),S(i-1:i,2),'.-','color',col)
        % end

        pCusedf = Susedf(:,1:10)';
        pCusesp = Susesp(:,1:10)';
        pCnusedf = Snusedf(:,1:10)';
        pCnusesp = Snusesp(:,1:10)';
        
        pcAlign = [pCusedf;pCusesp;pCnusedf;pCnusesp];
        
        pcAlignout = align2onsets(pcAlign,onsets,dt,timepts);
        pCusedfout = pcAlignout(1:10,:,:);
        pCusespout = pcAlignout(11:20,:,:);
        pCnusedfout = pcAlignout(21:30,:,:);
        pCnusespout = pcAlignout(31:40,:,:);
        
        %%%subtract baseline period
        pCusedfout2 = pCusedfout;
        pCusespout2 = pCusespout;
        pCnusedfout2 = pCnusedfout;
        pCnusespout2 = pCnusespout;
        for i = 1:size(pCusedfout2,1)
            for j = 1:size(pCusedfout2,3)
                pCusedfout2(i,:,j) = pCusedfout(i,:,j)-nanmean(pCusedfout(i,1:4,j));
                pCusespout2(i,:,j) = pCusespout(i,:,j)-nanmean(pCusespout(i,1:4,j));
                pCnusedfout2(i,:,j) = pCnusedfout(i,:,j)-nanmean(pCnusedfout(i,1:4,j));
                pCnusespout2(i,:,j) = pCnusespout(i,:,j)-nanmean(pCnusespout(i,1:4,j));
            end
        end        
        
        pCusedftuning = zeros(size(pCusedfout2,1),size(pCusedfout2,2),length(sfrange),length(thetaRange),length(radiusRange),2);
        pCusesptuning = pCusedftuning; pCnusedftuning = pCusedftuning; pCnusesptuning = pCusedftuning;
        for h = 1:size(pCusedftuning,1)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            pCusedftuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pCusedfout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                            pCusesptuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pCusespout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                            pCnusedftuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pCnusedfout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                            pCnusesptuning(h,1:size(pcdfOut,2),i,j,k,l) = nanmean(pCnusespout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&radius==k&running==(l-1))),3);
                        end
                    end
                end
            end
        end
        
        pCusedftuning2 = pCusedftuning; pCusesptuning2 = pCusesptuning; pCnusedftuning2 = pCnusedftuning; pCnusesptuning2 = pCnusesptuning;
        %%%subtract size zero trials
        for h = 1:size(pCusedftuning2,1)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            pCusedftuning2(h,:,i,j,k,l) = pCusedftuning(h,:,i,j,k,l) - pCusedftuning(h,:,i,j,1,l);
                            pCusesptuning2(h,:,i,j,k,l) = pCusesptuning(h,:,i,j,k,l) - pCusesptuning(h,:,i,j,1,l);
                            pCnusedftuning2(h,:,i,j,k,l) = pCnusedftuning(h,:,i,j,k,l) - pCnusedftuning(h,:,i,j,1,l);
                            pCnusesptuning2(h,:,i,j,k,l) = pCnusesptuning(h,:,i,j,k,l) - pCnusesptuning(h,:,i,j,1,l);
                        end
                    end
                end
            end
        end
        pCusedftuning = pCusedftuning2; pCusesptuning = pCusesptuning2; pCnusedftuning = pCnusedftuning2; pCnusesptuning = pCnusesptuning2;
        
        %%%plot first two pca components for usedF
        cnt=1;
        figure
        for i = 1:size(pCusedftuning,4)
            for j = 2:size(pCusedftuning,5)
                pc1 = squeeze(nanmean(pCusedftuning(1,:,:,i,j,1),3));
                pc2 = squeeze(nanmean(pCusedftuning(2,:,:,i,j,1),3));
                subplot(size(pCusedftuning,4),size(pCusedftuning,5)-1,cnt)
                hold on
                for k = 2:length(pc1)
                    col = cmapVar(k,1,length(pc1),jet);
                    plot(pc1(k-1:k),pc2(k-1:k),'.-','color',col)
                end
                axis square
                cnt=cnt+1;
            end
        end
        mtit('center dfPC1 vs dfPC2 orientation/size')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        %%%plot first two pca components for usespikes
        cnt=1;
        figure
        for i = 1:size(pCusesptuning,4)
            for j = 2:size(pCusesptuning,5)
                pc1 = squeeze(nanmean(pCusesptuning(1,:,:,i,j,1),3));
                pc2 = squeeze(nanmean(pCusesptuning(2,:,:,i,j,1),3));
                subplot(size(pCusesptuning,4),size(pCusesptuning,5)-1,cnt)
                hold on
                for k = 2:length(pc1)
                    col = cmapVar(k,1,length(pc1),jet);
                    plot(pc1(k-1:k),pc2(k-1:k),'.-','color',col)
                end
                axis square
                cnt=cnt+1;
            end
        end
        mtit('center spPC1 vs spPC2 orientation/size')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        %%%plot first two pca components for nusedF
        cnt=1;
        figure
        for i = 1:size(pCnusedftuning,4)
            for j = 2:size(pCnusedftuning,5)
                pc1 = squeeze(nanmean(pCnusedftuning(1,:,:,i,j,1),3));
                pc2 = squeeze(nanmean(pCnusedftuning(2,:,:,i,j,1),3));
                subplot(size(pCnusedftuning,4),size(pCnusedftuning,5)-1,cnt)
                hold on
                for k = 2:length(pc1)
                    col = cmapVar(k,1,length(pc1),jet);
                    plot(pc1(k-1:k),pc2(k-1:k),'.-','color',col)
                end
                axis square
                cnt=cnt+1;
            end
        end
        mtit('surround dfPC1 vs dfPC2 orientation/size')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        %%%plot first two pca components for nusespikes
        cnt=1;
        figure
        for i = 1:size(pCnusesptuning,4)
            for j = 2:size(pCnusesptuning,5)
                pc1 = squeeze(nanmean(pCnusesptuning(1,:,:,i,j,1),3));
                pc2 = squeeze(nanmean(pCnusesptuning(2,:,:,i,j,1),3));
                subplot(size(pCnusesptuning,4),size(pCnusesptuning,5)-1,cnt)
                hold on
                for k = 2:length(pc1)
                    col = cmapVar(k,1,length(pc1),jet);
                    plot(pc1(k-1:k),pc2(k-1:k),'.-','color',col)
                end
                axis square
                cnt=cnt+1;
            end
        end
        mtit('surround spPC1 vs spPC2 orientation/size')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        
        
        
        %%%plot individual cell data
%         sitcolor = [0.6 0.6 0.6;0.8 0.8 0.8;1 1 1];
%         runcolor = [0.6 0 0;0.8 0 0;1 0 0];
        cellprint = {};
        for i=1:length(usecells)
            figure
            
%             %%%direction tuning curve
%             subplot(2,4,1)
%             hold on
%             sitcurv = usedfori(i,:,1);
%             runcurv = usedfori(i,:,2);
%             plot(1:12,sitcurv,'k-')
%             plot(1:12,runcurv,'r-')
%             xlabel('Direction')
%             ylabel('dfof')
%             axis([1 12 min([sitcurv runcurv])-0.01 max([sitcurv runcurv])+0.01])
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%             hold off
%             
%             %%%polar direction tuning curve
%             subplot(2,4,2)
%             sitpol = usedfori(i,:,1);sitpol(sitpol<0)=0;
%             runpol = usedfori(i,:,2);runpol(runpol<0)=0;
%             polarplot([dirrange dirrange(1)],[sitpol sitpol(1)],'k-')
%             hold on
%             polarplot([dirrange dirrange(1)],[runpol runpol(1)],'r-')
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%             hold off
%             
%             %%%osi/dsi
%             subplot(2,4,3)
%             hold on
%             plot([1 2],[useosi(i,1) usedsi(i,1)],'k.','Markersize',20)
%             plot([1 2],[useosi(i,2) usedsi(i,2)],'r.','Markersize',20)
%             axis([0 3 0 1])
%             set(gca,'xtick',[1 2],'xticklabel',{'OSI','DSI'})
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%             hold off
            
            %%%avg resp to best stim for each size stationary
            subplot(1,4,1)
            hold on
            traces = squeeze(dfsize(i,:,:,1));
            plot(timepts,traces)
            xlabel('Time(s)')
            ylabel('sit dfof')
            if isnan(min(min(traces)))
                axis([0 1 0 1])
            else
                axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
            end
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
            
            %%%avg resp to best stim for each size running
            subplot(1,4,2)
            hold on
            traces = squeeze(dfsize(i,:,:,2));
            plot(timepts,traces)
            xlabel('Time(s)')
            ylabel('run dfof')
            if isnan(min(min(traces)))
                axis([0 1 0 1])
            else
                axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
            end
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
            
            %%%size curve based on gratings parameters
            subplot(1,4,3)
            hold on
            splotsit = squeeze(nanmean(dfsize(i,dfWindow,:,1),2));
            splotrun = squeeze(nanmean(dfsize(i,dfWindow,:,2),2));
            plot(1:length(radiusRange),splotsit,'k-o','Markersize',5)
            plot(1:length(radiusRange),splotrun,'r-o','Markersize',5)
            xlabel('Stim Size (deg)')
            ylabel('dfof')
            axis([0 length(radiusRange)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
            set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes)
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
            
            %%%size curve based on gratings parameters
            subplot(1,4,4)
            acell = usePts{usecells(i)};
            cellpts = nan(length(acell),2);
            for j = 1:length(acell)
                [cellpts(j,1) cellpts(j,2)] = ind2sub(size(meanShiftImg),acell(j));
            end
            cellprint{i} = meanShiftImg(min(cellpts(:,1)):max(cellpts(:,1)),min(cellpts(:,2)):max(cellpts(:,2)),:);
            cellprint{i} = cellprint{i}/max(max(max(cellprint{i})));
            imagesc(cellprint{i},[0.5 1]);
            axis square
            axis off
            
%             %%%size curve based on size parameters
%             subplot(2,4,6)
%             hold on
%             splotsit = squeeze(nanmean(dfsizebest(i,dfWindow,end,:,1),2));
%             splotrun = squeeze(nanmean(dfsizebest(i,dfWindow,end,:,2),2));
%             plot(1:length(radiusRange),splotsit,'k-o','Markersize',5)
%             plot(1:length(radiusRange),splotrun,'r-o','Markersize',5)
%             xlabel('Stim Size (deg)')
%             ylabel('size params dfof')
%             axis([0 length(radiusRange)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
%             set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes)
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%             
%             %%%contrast function based on gratings params
%             subplot(2,4,7)
%             hold on
%             splotsit = squeeze(nanmean(dfsize(i,dfWindow,:,[1 4 7],1),2));
%             splotrun = squeeze(nanmean(dfsize(i,dfWindow,:,[1 4 7],2),2));
% 
%             plot(1:length(contrastlist),splotsit,'k-o','Markersize',5)
% %             set(groot,'defaultAxesColorOrder',sitcolor)
%             plot(1:length(contrastlist),splotrun,'r-o','Markersize',5)
% %             set(groot,'defaultAxesColorOrder',runcolor)
%             xlabel('contrast')
%             ylabel('grat params dfof')
%             axis([0 length(contrastlist)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
%             set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%             
%             %%%contrast function based on size params
%             subplot(2,4,8)
%             hold on
%             splotsit = squeeze(nanmean(dfsizebest(i,dfWindow,:,[1 4 7],1),2));
%             splotrun = squeeze(nanmean(dfsizebest(i,dfWindow,:,[1 4 7],2),2));
% 
%             plot(1:length(contrastlist),splotsit,'k-o','Markersize',5)
% %             set(groot,'defaultAxesColorOrder',sitcolor)
%             plot(1:length(contrastlist),splotrun,'r-o','Markersize',5)
% %             set(groot,'defaultAxesColorOrder',runcolor)
%             xlabel('contrast')
%             ylabel('size params dfof')
%             axis([0 length(contrastlist)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
%             set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
            
            mtit(sprintf('Cell #%d tuning',usecells(i)))
            if exist('psfilei','var')
                set(gcf, 'PaperPositionMode', 'auto'); %%%figure out how to make this full page landscape
                print('-dpsc',psfilei,'-append');
            end
        end
        
        %%%plot group data for size select
        figure
        hold on
        sit = squeeze(nanmedian(nanmean(dfsize(:,dfWindow,:,1),2),1));
        run = squeeze(nanmedian(nanmean(dfsize(:,dfWindow,:,2),2),1));
        plot(1:length(radiusRange),sit,'k-o','Markersize',5)
        plot(1:length(radiusRange),run,'r-o','Markersize',5)
        xlabel('Stim Size (deg)')
        ylabel('sitting dfof grat params')
        axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
        axis square
        set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
        title('Median size suppression curve')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end
        
        %%%plot cycle averages
        figure
        plotmax = max(max(max(nanmedian(dfsize,1)))) + 0.1;
        plotmin = min(min(min(nanmedian(dfsize,1)))) - 0.05;
        for i = 1:length(sizes)
            subplot(2,ceil(length(sizes)/2),i)
            hold on
            sit = dfsize(:,:,i,1);
            run = dfsize(:,:,i,2);
            shadedErrorBar(timepts,squeeze(nanmedian(sit,1)),...
                squeeze(nanstd(sit,1))/sqrt(length(usecells)),'k',1)
            shadedErrorBar(timepts,squeeze(nanmedian(run,1)),...
                squeeze(nanstd(run,1))/sqrt(length(usecells)),'r',1)
            axis square
            axis([timepts(1) timepts(end) plotmin plotmax])
            set(gca,'LooseInset',get(gca,'TightInset'))
        end
        mtit('Median cycle avg/size')
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
        axis([0 3 0 2])
        set(gca,'xtick',[1 2],'xticklabel',{'sit','run'})
        ylabel('SI')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end    

        %%%saving
        save(fullfile(pathname,filename),'sptuning','sptuning','userf','dfsize','usecells','cellprint','SI')

        try
            dos(['ps2pdf ' psfilei ' "' [fullfile(pathname,filename) '.pdf'] '"'] )
        catch
            display('couldnt generate pdf');
        end

        delete(psfilei);
        close all
%     else
%         sprintf('skipping %s',filename)
%     end
end