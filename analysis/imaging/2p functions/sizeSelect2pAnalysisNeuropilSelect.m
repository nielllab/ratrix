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
% moviefname = 'C:\src\sizeselectBin22min';
moviefname = 'C:\src\movies\sizeselect4Ctrst24min';
load(moviefname)
xrange = unique(xpos);yrange = unique(ypos);ctrange = unique(contrasts);sfrange = unique(sf);
tfrange = unique(tf);phaserange = unique(phase);thetaRange = unique(theta);
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)*2); end
stlb = {'sit','run'};

for f=1:length(use)
    filename = files(use(f)).sizeanalysis
%     if exist([filename '.mat'])==0 %%comment for redo
        files(use(f)).subj
        psfilei = 'c:\tempPhil2pi.ps';
        if exist(psfilei,'file')==2;delete(psfilei);end

        load(files(use(f)).sizepts);
        load(files(use(f)).sizestimObj);
        spInterp = get2pSpeed(stimRec,dt,size(dF,2));
        spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);

        ntrials= floor(min(dt*length(dF)/(isi+duration),length(sf)));
        sf=sf(1:ntrials); tf=tf(1:ntrials);theta=theta(1:ntrials); phase=phase(1:ntrials);
        radius=radius(1:ntrials); xpos=xpos(1:ntrials); ypos=ypos(1:ntrials); contrasts=contrasts(1:ntrials);
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
            cellCutoff = size(spikes,1)
        else
            spikes = spikes*10;
            cellCutoff = files(use(f)).cutoff
        end

        if exist(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat']))==0 | rerun%%comment for redo
            % load size select points file and stim object and align to stim
            sprintf('realigning to onsets')

            dF = dF(1:cellCutoff,:);spikes = spikes(1:cellCutoff,:);

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
            try
                [eyeAlign] = get2pEyes(files(use(f)).sizeeye,0,dt);
                eyes = align2onsets(eyeAlign',onsets,dt,timepts);
            catch
                eyeAlign = nan(1,1,1);eyes=NaN;avgrad=NaN;histrad=NaN;
            end

            save(fullfile(pathname,filename),'dFout2','spikesOut2','eyes','eyeAlign')
            save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
                'dFout2','spikesOut2','eyes','eyeAlign')
        else
            load(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat']),...
                'dFout2','spikesOut2','eyes','eyeAlign')
        end
        timepts = timepts - isi;%%%shift for plotting to stim onset

    %%

        %%%pixel-wise suppression plots
        load(files(use(f)).sizesession,'frmdata')

        for c = 1:length(ctrange)
            figure
            for i = 1:length(sizes)
                subplot(2,ceil(length(sizes)/2),i)
                resp = imresize(squeeze(nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,c,i,1),3)),0.5);
                respimg = mat2im(resp,jet,[-0.01 0.1]);
                imshow(respimg)
                set(gca,'ytick',[],'xtick',[])
                xlabel(sprintf('%sdeg resp',sizes{i}))
                axis equal
            end
            mtit(sprintf('cntr=%0.3f',ctrange(c)))
        end


        %%%use manual selection of 10 degree pixelwise response for cell selection
        if mod(f,2)~=0 & (~exist(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat'])) | reselect==1)

            resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,end,2,1),3);%-...
                    %nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,1,1),3);

            [gpLUT,P,etheta] = neuropilEllipse(resp,psfilei);

            figure;subplot(1,2,1);imshow(gpLUT);hold on;;set(gca,'ytick',[],'xtick',[]);plot(P(1,2),P(1,1),'ro')
            goodprints = zeros(cellCutoff,1);
            for i = 1:cellCutoff
                [xpt,ypt] = ind2sub(size(meanShiftImg),usePts{i});
                mnxpt=round(mean(xpt));mnypt=round(mean(ypt));
                if gpLUT(mnxpt,mnypt)==1
                    goodprints(i) = 1;
                    plot(ypt,xpt,'g*')
                else
                    plot(ypt,xpt,'r*')
                end
            end
            usecells = find(goodprints==1); %%%pick only cells w/centers inside the ellipse

            %%%calculate response as a function of distance from center
            y0 = P(1,2)+cropy(1);x0 = P(1,1)+cropx(1);
            rx = sqrt((P(1,1)-P(2,1))^2+(P(1,2)-P(2,2))^2);ry = 2*rx;
            [X,Y] = meshgrid(1:size(frmdata,1),1:size(frmdata,2));%%%Y=Y/2;
    %         rx = sqrt((X-x0).^2);ry = sqrt((Y-y0).^2);
    %         rx = 20;ry=20;
    %         dist = ((cos(etheta)*(X-y0)+sin(etheta)*(Y-x0)).^2)./rx.^2+(((sin(etheta)*(X-y0)-cos(etheta)*(Y-x0))).^2)./ry.^2;
            dist = sqrt(((cos(etheta)*(X-y0)+sin(etheta)*(Y-x0)).^2)+(((sin(etheta)*(X-y0)-cos(etheta)*(Y-x0))).^2)/2^2);
            subplot(1,2,2);imshow(mat2im(dist,jet,[0 300]));set(gca,'ytick',[],'xtick',[]);hold on;plot(y0,x0,'ro')
            if exist('psfilei','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilei,'-append');
            end 

            save(fullfile(pathname,filename),...
                'usecells','gpLUT','P','etheta','x0','y0','dist','goodprints','-append')
            save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
                'usecells','gpLUT','P','etheta','x0','y0','dist','goodprints','-append')

        else
            load(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_pre']),...
                'usecells','gpLUT','P','etheta','x0','y0','dist','goodprints')
            figure;subplot(1,2,1);imshow(gpLUT);hold on;;set(gca,'ytick',[],'xtick',[]);plot(P(1,2),P(1,1),'ro')
            for i = 1:cellCutoff
                [xpt,ypt] = ind2sub(size(meanShiftImg),usePts{i});
                mnxpt=round(mean(xpt));mnypt=round(mean(ypt));
                if gpLUT(mnxpt,mnypt)==1
                    plot(ypt,xpt,'g*')
                else
                    plot(ypt,xpt,'r*')
                end
            end
            subplot(1,2,2);imshow(mat2im(dist,jet,[0 300]));set(gca,'ytick',[],'xtick',[]);hold on;plot(y0,x0,'ro')
            if exist('psfilei','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilei,'-append');
            end 

            save(fullfile(pathname,filename),...
                'usecells','gpLUT','P','etheta','x0','y0','dist','goodprints','-append')
            save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
                'usecells','gpLUT','P','etheta','x0','y0','dist','goodprints','-append')
        end

    %%


        %create array w/average responses per stim type
        dftuning = zeros(length(usecells),size(dFout2,2),length(sfrange),length(thetaRange),length(ctrange),length(radiusRange),2);
        sptuning = zeros(length(usecells),size(spikesOut2,2),length(sfrange),length(thetaRange),length(ctrange),length(radiusRange),2);
        for h = 1:length(usecells)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for c = 1:length(ctrange)
                        for k = 1:length(radiusRange)
                            for l = 1:2
                                dftuning(h,1:size(dFout2,2),i,j,c,k,l) = nanmean(dFout2(usecells(h),:,find(sf==sfrange(i)&theta==thetaRange(j)&contrasts==ctrange(c)&radius==k&running==(l-1))),3);
                                sptuning(h,1:size(spikesOut2,2),i,j,c,k,l) = nanmean(spikesOut2(usecells(h),:,find(sf==sfrange(i)&theta==thetaRange(j)&contrasts==ctrange(c)&radius==k&running==(l-1))),3);
                            end
                        end
                    end
                end
            end
        end


        %%%subtract size zero trials
        dftuning2 = dftuning;sptuning2 = sptuning;
        ztrialdf = nan(size(dftuning,1),size(dftuning,2),2);ztrialsp=ztrialdf;
        for i = 1:2
            ztrialdf(:,:,i) = nanmean(nanmean(nanmean(dftuning(:,:,:,:,:,1,i),3),4),5);
            ztrialsp(:,:,i) = nanmean(nanmean(nanmean(sptuning(:,:,:,:,:,1,i),3),4),5);
        end
        for i = 1:length(sfrange)
            for j = 1:length(thetaRange)
                for c = 1:length(ctrange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            dftuning2(:,:,i,j,c,k,l) = dftuning(:,:,i,j,c,k,l) - ztrialdf(:,:,l);
                            sptuning2(:,:,i,j,c,k,l) = sptuning(:,:,i,j,c,k,l) - ztrialsp(:,:,l);
                        end
                    end
                end
            end
        end

        dftuning = dftuning2;
        sptuning = sptuning2;
        
        %create array w/average responses per stim type (all cells)
        dftuningall = zeros(size(dFout2,1),size(dFout2,2),length(sfrange),length(thetaRange),length(ctrange),length(radiusRange),2);
        sptuningall = zeros(size(spikesOut2,1),size(spikesOut2,2),length(sfrange),length(thetaRange),length(ctrange),length(radiusRange),2);
        for h = 1:size(spikesOut2,1)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for c = 1:length(ctrange)
                        for k = 1:length(radiusRange)
                            for l = 1:2
                                dftuningall(h,1:size(dFout2,2),i,j,c,k,l) = nanmean(dFout2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&contrasts==ctrange(c)&radius==k&running==(l-1))),3);
                                sptuningall(h,1:size(spikesOut2,2),i,j,c,k,l) = nanmean(spikesOut2(h,:,find(sf==sfrange(i)&theta==thetaRange(j)&contrasts==ctrange(c)&radius==k&running==(l-1))),3);
                            end
                        end
                    end
                end
            end
        end


        %%%subtract size zero trials
        dftuningall2 = dftuningall;sptuningall2 = sptuningall;
        ztrialdf = nan(size(dftuningall,1),size(dftuningall,2),2);ztrialsp=ztrialdf;
        for i = 1:2
            ztrialdf(:,:,i) = nanmean(nanmean(nanmean(dftuningall(:,:,:,:,:,1,i),3),4),5);
            ztrialsp(:,:,i) = nanmean(nanmean(nanmean(sptuningall(:,:,:,:,:,1,i),3),4),5);
        end
        for i = 1:length(sfrange)
            for j = 1:length(thetaRange)
                for c = 1:length(ctrange)
                    for k = 1:length(radiusRange)
                        for l = 1:2
                            dftuningall2(:,:,i,j,c,k,l) = dftuningall(:,:,i,j,c,k,l) - ztrialdf(:,:,l);
                            sptuningall2(:,:,i,j,c,k,l) = sptuningall(:,:,i,j,c,k,l) - ztrialsp(:,:,l);
                        end
                    end
                end
            end
        end

        dftuningall = dftuningall2;
        sptuningall = sptuningall2;


        if mod(f,2)~=0 & (~exist(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing '.mat'])) | reselect==1)    
            %%%%%cell-wise analysis
            %%%get sf and ori pref for size stimuli
            sizebestsfdf=nan(length(usecells),2);sizebestsfsp=sizebestsfdf;sizebestthetadf=sizebestsfdf;sizebestthetasp=sizebestsfdf;
            for i = 1:length(usecells)
                for j=1:2
                    [tmp, sizebestsfdf(i,j)] = max(squeeze(nanmean(nanmean(dftuning(i,dfWindow,:,:,end,3,j),2),4))); %index of best sf
                    [tmp, sizebestsfsp(i,j)] = max(squeeze(nanmean(nanmean(sptuning(i,spWindow,:,:,end,3,j),2),4)));
                    [tmp, sizebestthetadf(i,j)] = max(squeeze(nanmean(nanmean(dftuning(i,dfWindow,:,:,end,3,j),2),3))); %index of best thetaQuad
                    [tmp, sizebestthetasp(i,j)] = max(squeeze(nanmean(nanmean(sptuning(i,spWindow,:,:,end,3,j),2),3)));
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
        dfsize = nan(length(usecells),size(dftuning,2),length(ctrange),length(radiusRange),2);spsize=dfsize;
        for i = 1:length(usecells)
            for c = 1:length(ctrange)
                for k = 1:length(sizes)
                    for l = 1:2
                    dfsize(i,:,c,k,l) = squeeze(dftuning(i,:,sizebestsfdf(i,1),...
                        sizebestthetadf(i,1),c,k,l));
                    spsize(i,:,c,k,l) = squeeze(sptuning(i,:,sizebestsfsp(i,1),...
                        sizebestthetasp(i,1),c,k,l));
                    end
                end
            end
        end

        dfsize2 = dfsize;spsize2 = spsize;
        ztrialdf = nan(size(dfsize,1),size(dftuning,2),2);ztrialsp=ztrialdf;
        for i = 1:2
            ztrialdf(:,:,i) = squeeze(nanmean(dfsize(:,:,:,1,i),3));
            ztrialsp(:,:,i) = squeeze(nanmean(spsize(:,:,:,1,i),3));
        end
        for c = 1:length(ctrange)
            for i = 1:length(radiusRange)
                for j = 1:2
                    dfsize2(:,:,c,i,j) = dfsize(:,:,c,i,j) - ztrialdf(:,:,j);
                    spsize2(:,:,c,i,j) = spsize(:,:,c,i,j) - ztrialsp(:,:,j);
                end
            end
        end

        dfsize = dfsize2;
        spsize = spsize2;
        
        %%%do same thing for all cells
        sizebestsfdfall=nan(size(dftuningall,1),2);sizebestsfspall=sizebestsfdfall;sizebestthetadfall=sizebestsfdfall;sizebestthetaspall=sizebestsfdfall;
        for i = 1:size(sptuningall,1)
            for j=1:2
                [tmp, sizebestsfdfall(i,j)] = max(squeeze(nanmean(nanmean(dftuningall(i,dfWindow,:,:,end,3,j),2),4))); %index of best sf
                [tmp, sizebestsfspall(i,j)] = max(squeeze(nanmean(nanmean(sptuningall(i,spWindow,:,:,end,3,j),2),4)));
                [tmp, sizebestthetadfall(i,j)] = max(squeeze(nanmean(nanmean(dftuningall(i,dfWindow,:,:,end,3,j),2),3))); %index of best thetaQuad
                [tmp, sizebestthetaspall(i,j)] = max(squeeze(nanmean(nanmean(sptuningall(i,spWindow,:,:,end,3,j),2),3)));
            end
        end
        
        dfsizeall = nan(size(dftuningall,1),size(dftuningall,2),length(ctrange),length(radiusRange),2);spsizeall=dfsizeall;
        for i = 1:size(dftuningall,1)
            for c = 1:length(ctrange)
                for k = 1:length(sizes)
                    for l = 1:2
                    dfsizeall(i,:,c,k,l) = squeeze(dftuningall(i,:,sizebestsfdfall(i,1),...
                        sizebestthetadfall(i,1),c,k,l));
                    spsizeall(i,:,c,k,l) = squeeze(sptuningall(i,:,sizebestsfspall(i,1),...
                        sizebestthetaspall(i,1),c,k,l));
                    end
                end
            end
        end

        dfsizeall2 = dfsizeall;spsizeall2 = spsizeall;
        ztrialdf = nan(size(dfsizeall,1),size(dftuningall,2),2);ztrialsp=ztrialdf;
        for i = 1:2
            ztrialdf(:,:,i) = squeeze(nanmean(dfsizeall(:,:,:,1,i),3));
            ztrialsp(:,:,i) = squeeze(nanmean(spsizeall(:,:,:,1,i),3));
        end
        for c = 1:length(ctrange)
            for i = 1:length(radiusRange)
                for j = 1:2
                    dfsizeall2(:,:,c,i,j) = dfsizeall(:,:,c,i,j) - ztrialdf(:,:,j);
                    spsizeall2(:,:,c,i,j) = spsizeall(:,:,c,i,j) - ztrialsp(:,:,j);
                end
            end
        end

        dfsizeall = dfsizeall2;
        spsizeall = spsizeall2;
        


        %%%calculate response as a function of distance from center
        %%%move the calc from grp analysis here
        binwidth = 20;
        ring = nan(ceil(max(max(dist))/binwidth),size(frmdata,3),size(frmdata,4),size(frmdata,5),size(frmdata,6));
        for j = 1:size(frmdata,3)
            for k = 1:size(frmdata,4)
                for l = 1:size(frmdata,5)
                    for m = 1:size(frmdata,6)
                        resp = squeeze(frmdata(:,:,j,k,l));
                        for i = 1:ceil(max(max(dist)))/binwidth
                            ring(i,j,k,l) = mean(resp(dist>(binwidth*(i-1)) & dist<binwidth*i));
                        end
                    end
                end
            end
        end

    %%
        %%%plot ellipse over image
        N = 100;        %default: 100 points
        th = [0 2*pi];  %default: full ellipse
        th = linspace(th(1),th(2),N);
        rx = sqrt((P(1,1)-P(2,1))^2+(P(1,2)-P(2,2))^2);
        ry = 2*rx;
        %calculate x and y points
        ex = y0 + rx*cos(th)*cos(etheta) - ry*sin(th)*sin(etheta);
        ey = x0 + rx*cos(th)*sin(etheta) + ry*sin(th)*cos(etheta);

        figure
        for c = 1:length(ctrange)
            subplot(1,length(ctrange),c);
            imagesc(nanmean(frmdata(:,:,:,c,3,1),3),[-0.01 0.1]);axis equal;
            hold on
            plot(ex,ey,'g','linewidth',2);
            plot(y0,x0,'ro')
        end
        if exist('psfilei','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilei,'-append');
        end

        %%%compare 5/10deg pixel vs cell footprints
        figure
        subplot(1,3,1)
        resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,end,2,1),3);
        respimg = mat2im(resp,jet,[-0.01 0.1]);
        imshow(respimg)
        set(gca,'ytick',[],'xtick',[])
        xlabel('5deg resp')
        axis equal
        subplot(1,3,2)
        resp = nanmean(frmdata(cropx(1):cropx(2),cropy(1):cropy(2),:,end,3,1),3);
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
        draw2pSegs(usePts,goodprints,parula,size(meanShiftImg),1:cellCutoff,[0 2])
        colorbar off
        xlabel('center footprints')
        set(gca,'LooseInset',get(gca,'TightInset'))
        mtit('Pixel vs. Cell Center Response')
        if exist('psfilei','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilei,'-append');
        end  
    %%
        %%%plot sit dF
        for h = 1:length(sfrange)
            for c = 1:length(ctrange)
                figure;
                colormap jet
                for i = 2:length(sizes)
                    subplot(2,floor(length(sizes)/2),i-1)
                    resp = nanmean(frmdata(:,:,h,c,i,1),3);
                    imagesc(resp,[-0.01 0.1])
                    set(gca,'ytick',[],'xtick',[])
                    xlabel(sprintf('%sdeg',sizes{i}))
                    axis square
                end
                mtit(sprintf('sit dF/size %0.2fcpd cnt=%0.3f',sfrange(h),ctrange(c)))
                if exist('psfilei','var')
                    set(gcf, 'PaperPositionMode', 'auto');
                    print('-dpsc',psfilei,'-append');
                end
                %%%plot run dF
                figure;
                colormap jet
                for i = 2:length(sizes)
                    subplot(2,floor(length(sizes)/2),i-1)
                    resp = nanmean(frmdata(:,:,h,c,i,2),3);
                    imagesc(resp,[-0.01 0.1])
                    set(gca,'ytick',[],'xtick',[])
                    xlabel(sprintf('%sdeg',sizes{i}))
                    axis square
                end
                mtit(sprintf('run dF/size %0.2fcpd cnt=%0.3f',sfrange(h),ctrange(c)))
                if exist('psfilei','var')
                    set(gcf, 'PaperPositionMode', 'auto');
                    print('-dpsc',psfilei,'-append');
                end
            end
        end

        %%%plot sit 20v50deg
        for r = 1:2
            figure
            for c = 1:length(ctrange)
                subplot(1,length(ctrange),c)
                mrg=zeros(size(frmdata,1),size(frmdata,2),3);
                mrg(:,:,2) = squeeze(nanmean(frmdata(:,:,1,c,2,r),3));
                mrg(:,:,1) = squeeze(nanmean(frmdata(:,:,1,c,end,r),3));
                mrg=mrg*10;
                image(mrg)
                set(gca,'ytick',[],'xtick',[])
                xlabel(sprintf('ctr=%0.3f',ctrange(c)))
                axis equal
            end
            mtit(sprintf('20deg (g) vs 50 deg (r) %s',stlb{r}))
            if exist('psfilei','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilei,'-append');
            end
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
        subplot(1,2,1)
        hold on
        for c = 1:length(ctrange)
            sit = squeeze(nanmean(nanmean(dfsize(:,dfWindow,c,:,1),2),1));
            plot(1:length(radiusRange),sit,'-o','Markersize',5)
        end
        xlabel('Stim Size (deg)')
        ylabel('sit dfof')
        axis([0 length(radiusRange)+1 -0.01 0.3])
        axis square
        legend(ctrange)
        set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
        hold off
        subplot(1,2,2)
        hold on
        for c = 1:length(ctrange)
            run = squeeze(nanmean(nanmean(dfsize(:,dfWindow,c,:,2),2),1));
            plot(1:length(radiusRange),run,'-o','Markersize',5)
        end
        xlabel('Stim Size (deg)')
        ylabel('run dfof')
        axis([0 length(radiusRange)+1 -0.01 0.3])
        axis square
        legend(ctrange)
        set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
        mtit('Mean df suppression curve')
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end

        %%%plot cycle averages
        plotmax = max(max(max(max(nanmean(dfsize,1))))) + 0.1;
        plotmin = min(min(min(min(nanmean(dfsize,1))))) - 0.05;
        for c = 1:length(ctrange)
            figure
            for i = 1:length(sizes)
                subplot(2,ceil(length(sizes)/2),i)
                hold on
                sit = dfsize(:,:,c,i,1);
                run = dfsize(:,:,c,i,2);
                shadedErrorBar(timepts,squeeze(nanmean(sit,1)),...
                    squeeze(nanstd(sit,1))/sqrt(length(usecells)),'k',1)
                shadedErrorBar(timepts,squeeze(nanmean(run,1)),...
                    squeeze(nanstd(run,1))/sqrt(length(usecells)),'r',1)
                axis square
                axis([timepts(1) timepts(end) plotmin plotmax])
                set(gca,'LooseInset',get(gca,'TightInset'))
            end
            mtit(sprintf('Mean df cycle avg/size cntr=%0.3f',ctrange(c)))
            if exist('psfilei','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilei,'-append');
            end
        end

        %%%calculate suppression index
        SIdf = nan(size(dfsize,1),length(ctrange),2);
        for c = 1:length(ctrange)
            for i = 1:size(dfsize,1)
                scurve = squeeze(nanmean(dfsize(i,dfWindow,c,:,1)));
                [val ind] = max(scurve);
                if (ind~=length(sizes))&(val~=0)
                    SIdf(i,c,1) = (scurve(ind)-scurve(end))/(scurve(ind)+scurve(end));
                end
                scurve = squeeze(nanmean(dfsize(i,dfWindow,c,:,2)));
                [val ind] = max(scurve);
                if (ind~=length(sizes))&(val~=0)
                    SIdf(i,c,2) = (scurve(ind)-scurve(end))/(scurve(ind)+scurve(end));
                end
            end
        end

        figure
        hold on
        for c = 1:length(ctrange)
            subplot(1,length(ctrange),c)
            plot([1 2],[SIdf(:,c,1) SIdf(:,c,2)],'k.','Markersize',5)
            errorbar([1 2],[nanmean(SIdf(:,c,1)) nanmean(SIdf(:,c,2))],[nanstd(SIdf(:,c,1)) nanstd(SIdf(:,c,2))]/sqrt(size(dfsize,1)),'b','Markersize',20)
            axis([0 3 -2 5])
            axis square
            set(gca,'xtick',[1 2],'xticklabel',stlb)
            ylabel(sprintf('df SI cntr=%0.3f',ctrange(c)))
        end
        if exist('psfilei','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilei,'-append');
        end


        %%%plot group spikes data for size select
        for c = 1:length(ctrange)
            figure
            subplot(1,3,1)
            hold on
            sit = squeeze(nanmean(nanmean(spsize(:,spWindow,c,:,1),2),1));
            run = squeeze(nanmean(nanmean(spsize(:,spWindow,c,:,2),2),1));
            plot(1:length(radiusRange),sit,'k-o','Markersize',5)
            plot(1:length(radiusRange),run,'r-o','Markersize',5)
            xlabel('Stim Size (deg)')
            ylabel('total spikes')
            axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
            axis square
            set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
            subplot(1,3,2)
            hold on
            sit = squeeze(nanmean(nanmean(spsize(:,6:7,c,:,1),2),1));
            run = squeeze(nanmean(nanmean(spsize(:,6:7,c,:,2),2),1));
            plot(1:length(radiusRange),sit,'k-o','Markersize',5)
            plot(1:length(radiusRange),run,'r-o','Markersize',5)
            xlabel('Stim Size (deg)')
            ylabel('early spikes')
            axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
            axis square
            set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
            subplot(1,3,3)
            hold on
            sit = squeeze(nanmean(nanmean(spsize(:,8:10,c,:,1),2),1));
            run = squeeze(nanmean(nanmean(spsize(:,8:10,c,:,2),2),1));
            plot(1:length(radiusRange),sit,'k-o','Markersize',5)
            plot(1:length(radiusRange),run,'r-o','Markersize',5)
            xlabel('Stim Size (deg)')
            ylabel('late spikes')
            axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
            axis square
            set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
            mtit(sprintf('spike size tuning by time period cntr=%0.3f',ctrange(c)))
            if exist('psfilei','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilei,'-append');
            end
        end

        %%%plot cycle averages
        plotmax = max(max(max(max(nanmean(spsize,1))))) + 0.1;
        plotmin = min(min(min(min(nanmean(spsize,1))))) - 0.05;
        for c = 1:length(ctrange)
            figure
            for i = 1:length(sizes)
                subplot(2,ceil(length(sizes)/2),i)
                hold on
                sit = spsize(:,:,c,i,1);
                run = spsize(:,:,c,i,2);
                shadedErrorBar(timepts,squeeze(nanmean(sit,1)),...
                    squeeze(nanstd(sit,1))/sqrt(length(usecells)),'k',1)
                shadedErrorBar(timepts,squeeze(nanmean(run,1)),...
                    squeeze(nanstd(run,1))/sqrt(length(usecells)),'r',1)
                axis square
                axis([timepts(1) timepts(end) plotmin plotmax])
                set(gca,'LooseInset',get(gca,'TightInset'))
            end
            mtit(sprintf('Mean spike cycle avg/size cntr=%0.3f',ctrange(c)))
            if exist('psfilei','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilei,'-append');
            end
        end

        %%%calculate suppression index
        SIsp = nan(size(spsize,1),length(ctrange),2);
        for c = 1:length(ctrange)
            for i = 1:size(spsize,1)
                scurve = squeeze(nanmean(spsize(i,spWindow,c,:,1)));
                [val ind] = max(scurve);
                if (ind~=length(sizes))&(val~=0)
                    SIsp(i,1) = (scurve(ind)-scurve(end))/(scurve(ind)+scurve(end));
                end
                scurve = squeeze(nanmean(spsize(i,spWindow,c,:,2)));
                [val ind] = max(scurve);
                if (ind~=length(sizes))&(val~=0)
                    SIsp(i,2) = (scurve(ind)-scurve(end))/(scurve(ind)+scurve(end));
                end
            end
        end

        figure
        hold on
        for c = 1:length(ctrange)
            subplot(1,length(ctrange),c)
            plot([1 2],[SIsp(:,c,1) SIsp(:,c,2)],'k.','Markersize',5)
            errorbar([1 2],[nanmean(SIsp(:,c,1)) nanmean(SIsp(:,c,2))],[nanstd(SIsp(:,c,1)) nanstd(SIsp(:,c,2))]/sqrt(size(spsize,1)),'b','Markersize',20)
            axis([0 3 -2 5])
            axis square
            set(gca,'xtick',[1 2],'xticklabel',stlb)
            ylabel(sprintf('df SI cntr=%0.3f',ctrange(c)))
        end
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
        if length(eyes)~=1
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
        end

        %%%saving
        save(fullfile(pathname,filename),...
            'avgrad','histrad','spInterp','running','timepts','ntrials','onsets','dt','ring','frmdata','dfsize','spsize','dfsizeall','spsizeall','cellprint','SIdf','SIsp','dftuning','sptuning','dftuningall','sptuningall','sizebestsfdfall','sizebestsfspall','sizebestthetadfall','sizebestthetaspall','-append')
        save(fullfile(altpath,[files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).inject '_'  files(use(f)).timing]),...
            'avgrad','histrad','spInterp','running','timepts','ntrials','onsets','dt','ring','frmdata','dfsize','spsize','dfsizeall','spsizeall','cellprint','SIdf','SIsp','dftuning','sptuning','dftuningall','sptuningall','sizebestsfdfall','sizebestsfspall','sizebestthetadfall','sizebestthetaspall','-append')
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
end
