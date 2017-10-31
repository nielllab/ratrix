%%%doPatchOnPatch
%%% called from analyzePatchOnPatch for batch analysis of individual sessions

%trial types for patchonpatch
% 1 = blank
% 2 = smCent
% 3 = lgcent
% 4 = smIsoCross
% 5 = lgIsoCross
% 6 = smDonut
% 7 = lgDonut
%%

deconvplz = 0 %choose if you want deconvolution
fully = 0 %choose if you want full frame (260x260), else scales down by 4
% areas = {'V1','P','LM','AL','RL','AM','PM','RSP'}; %list of all visual areas for points

for f = 1:length(use)
    filename = sprintf('%s_%s_%s_%s',files(use(f)).expt,files(use(f)).subj,files(use(f)).timing,files(use(f)).inject);
    if exist([filename '.mat'])==0
        load('C:\patchonpatch14min')
%         load('C:\mapoverlay.mat')
%         load('C:\areamaps.mat')
        imagerate=10;
        cyclength = imagerate*(isi+duration);
        base = 1:isi*imagerate;
        peakWindow = base(end)+1:base(end)+duration*imagerate;
        psfilename = 'c:\tempPhilWF.ps';
        if exist(psfilename,'file')==2;delete(psfilename);end
        
%         figure
%         set(gcf,'Name',[files(use(f)).subj ' ' files(use(f)).expt])
%         for i = 1:2  %%%% load in topos for check
%             if i==1
%                 load([pathname files(use(f)).topox],'map');
%             elseif i==2
%                 load([pathname files(use(f)).topoy],'map');
%             elseif i==3 && length(files(use(f)).topoyland)>0
%                 load([pathname files(use(f)).topoyland],'map');
%             elseif i==4 &&length(files(use(f)).topoxland)>0
%                 load([pathname files(use(f)).topoxland],'map');
%             end
%             subplot(2,2,i);
%             imshow(polarMap(shiftImageRotate(map{3},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz),90));
%             hold on; plot(ypts,xpts,'w.','Markersize',2)
%             set(gca,'LooseInset',get(gca,'TightInset'))
%         end


        if ~isempty(files(use(f)).patchonpatch)
            load([pathname files(use(f)).patchonpatch], 'dfof_bg','sp','stimRec','frameT')
%             zoom = 260/size(dfof_bg,1);
            if ~exist('sp','var')
                sp =0;stimRec=[];
            end
%             dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
            if ~fully %scale down image if you chose to
                dfof_bg = imresize(dfof_bg,0.5);
            end
        end

%%
        %%%code from analyzeGratingPatch to check stim quality and overall cycle average
        timingfig = figure;
        subplot(2,2,1)
        plot(diff(stimRec.ts));
        xlabel('frame')
        title('stim frames')

        subplot(2,2,2)
        plot(diff(frameT));
        xlabel('frame')
        title('acq frames')

        subplot(2,2,3)
        plot((stimRec.ts-stimRec.ts(1))/60,(stimRec.ts' - stimRec.ts(1)) - (1/60)*(0:length(stimRec.ts)-1));
        hold on
        plot((frameT-frameT(1))/60,(frameT' - frameT(1)) - 0.1*(0:length(frameT)-1),'g');
        legend('stim','acq')
        ylabel('slippage (secs)')
        xlabel('mins')
        stimslip = (stimRec.ts' - stimRec.ts(1)) - (1/60)*(0:length(stimRec.ts)-1);
        acqslip = (frameT' - frameT(1)) - 0.1*(0:length(frameT)-1);
        slip(f) = median(stimslip) - median(acqslip);
        slipframes = round(slip(f)*10)
        title(sprintf('slip = %f',slip(f)));

        imageT=(1:size(dfof_bg,3))/imagerate;
        img = imresize(double(dfof_bg),1,'method','box');
        if slipframes<1 %%%cut frames from beginning to account for slippage
            slipframes=1
        elseif slipframes>5
            slepframes=5
        end
        img = img(:,:,slipframes:end);
        nx=ceil(sqrt(cyclength+1)); %%% how many rows in figure subplot
        trials = length(sf); %in case movie stopped early
        %%% mean amplitude map across cycle
        figure
        map=0;
        p=1:cyclength;p=circshift(p,ceil(cyclength/2)-1,2);
        colormap(jet)
        for fr=1:cyclength
            cycavg(:,:,fr) = mean(img(:,:,(fr:cyclength:end)),3);
            subplot(nx,nx,p(fr))
            imagesc(squeeze(cycavg(:,:,fr)),[-0.001 0.01])
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
%             hold on; plot(ypts,xpts,'w.','Markersize',2)
            map = map+squeeze(cycavg(:,:,fr))*exp(2*pi*sqrt(-1)*(0.5 +fr/cyclength));
        end

        %%% add timecourse
        subplot(nx,nx,fr+1)
        plot(circshift(squeeze(mean(mean(cycavg,2),1)),ceil(cyclength/2)-1))
        axis off
        set(gca,'LooseInset',get(gca,'TightInset'))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end

        %%% calculate phase of cycle response
        %%% good for detectime framedrops or other problems
        tcourse = squeeze(mean(mean(img,2),1));
        fourier = tcourse'.*exp((1:length(tcourse))*2*pi*sqrt(-1)/(imagerate*duration + imagerate*isi));
        figure(timingfig)
        subplot(2,2,4)
        plot((1:length(tcourse))/600,angle(conv(fourier,ones(1,600),'same')));
        ylim([-pi pi])
        ylabel('phase'); xlabel('mins')
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end

%%
        %deconvolution
        if deconvplz == 1
            %do deconvolution on the raw data
            img = shiftdim(img+0.2,2); %shift dimesions for decon lucy and add 0.2 to get away from 0
            tic
            pp = gcp %start parallel pool
            deconvimg = deconvg6sParallel(img,0.1); %deconvolve
            toc
            deconvimg = shiftdim(deconvimg,1); %shift back
            deconvimg = deconvimg - mean(mean(mean(deconvimg))); %subtract min value
            img = shiftdim(img,1); %shift img back
            img = img - 0.2; %subtract 0.2 back off
            %check deconvolution success on one pixel
            figure
            hold on
            plot(squeeze(img(130,130,:)))
            plot(squeeze(deconvimg(130,130,:)),'g')
            hold off
            delete(pp)
            ncut = 3 %# of trials to cut due to deconvolution cutting off end
            trials=trials-ncut; %deconv cuts off last trial
            deconvimg = deconvimg(:,:,1:trials*cyclength);
        else
            deconvimg = img;
        end
        
%%
        %%% separate responses by trials
        speedcut = 500;
        trialdata = zeros(size(deconvimg,1),size(deconvimg,2),trials);
        trialspeed = zeros(trials,1);
        trialcyc = zeros(size(deconvimg,1),size(deconvimg,2),cyclength+isi*imagerate,trials);
        for tr=1:trials-1;
            t0 = round((tr-1)*cyclength);
            baseframes = base+t0; baseframes=baseframes(baseframes>0);
            trialdata(:,:,tr)=mean(deconvimg(:,:,peakWindow+t0),3) -mean(deconvimg(:,:,baseframes),3);
            try
                trialspeed(tr) = mean(sp(peakWindow+t0));
            catch
                trialspeed(tr)=500;
            end
            trialcyc(:,:,:,tr) = deconvimg(:,:,t0+(1:cyclength+isi*imagerate));%each cycle is frames 6-26, stim comes on at frame 11
        end

        isocross = zeros(size(thetaCent));isocross(trialID(2,:)==trialID(3,:))=1;isocross(trialID(2,:)~=trialID(3,:))=2;
        behavState = {'stationary','running'};
    %     xrange = unique(xpos); sfrange=unique(sf); tfrange=unique(tf);
        running = zeros(1,trials); %pull out stationary vs. runnning (0 vs. 1)
        for i = 1:trials
            running(i) = trialspeed(i)>speedcut;
        end

 

        tic
        trialcycavg=nan(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),length(unique(trialID)),length(unique(isocross)),2);
        for i = 1:length(unique(trialID))
            for j = 1:length(unique(isocross))
                for k = 1:2
                    inds = find(trialID(1,:)==i&isocross==j&running==(k-1));
                    trialcycavg(:,:,:,i,j,k) = squeeze(nanmean(trialcyc(:,:,:,inds),4));
                end
            end
        end
        toc

        %%baseline subtraction code
        %get average map with no stimulus
        mintrialcyc = zeros(size(deconvimg,1),size(deconvimg,2),cyclength+cyclength/2,2);
        for i = 1:2
            mintrialcyc(:,:,:,i) = squeeze(nanmean(trialcycavg(:,:,:,1,:,i),5)); %min map for stationary and running
        end
        %subtract average map with no stimulus from trialcycavg and
        %baseline each trial
        for i = 1:length(unique(trialID))
            for j = 1:length(unique(isocross))
                for k = 1:2
                    trialcycavg(:,:,:,i,j,k) = trialcycavg(:,:,:,i,j,k)-mintrialcyc(:,:,:,k);
                    trialcycavg(:,:,:,i,j,k) = trialcycavg(:,:,:,i,j,k)-nanmean(trialcycavg(:,:,1:cyclength/2,i,j,k),3); %subtract baseline
                end
            end
        end
    
%%
        %manual/loading point selection
        files(use(f)).subj
        if ~exist(files(use(f)).ptsfile)
    %     [fname pname] = uigetfile('*.mat','points file');
    %     if fname~=0
    %         load(fullfile(pname, fname));
    %     else
            sprintf('Pick 7 vis areas (start V1, clockwise) + RSP')
            amos=figure;
            for i = 1:length(radiusRange)
                subplot(2,length(radiusRange)/2,i)
                imagesc(squeeze(nanmean(trialcycavg(:,:,cyclength/2+2,:,end,i,1),4)),[-0.01 0.1])
                colormap(jet)
                axis square
                hold on
                plot(ypts,xpts,'w.','Markersize',2)
                axis off
                set(gca,'LooseInset',get(gca,'TightInset'))
                legend([sizes{i} ' deg'],'Location','northoutside')
            end
            andy=figure;
            imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,cyclength,:,end,4,:),4),7)),[-0.01 0.1])
            colormap(jet)
            axis square
            hold on
            plot(ypts,xpts,'k.','Markersize',2)
            [x y] = ginput(8);
            x=round(x); y=round(y);
            close(amos,andy)
            save(files(use(f)).ptsfile,'x','y');
        else
            load(files(use(f)).ptsfile)
        end

        if ~fully %scale down map overlay if not using full frame
            xpts = xpts/4;
            ypts = ypts/4;
        end

        %plot selected points over each radius size
        figure
        for i = 1:length(radiusRange)
            subplot(2,length(radiusRange)/2,i)
            imagesc(squeeze(nanmean(trialcycavg(:,:,cyclength/2+2,:,end,i,1),4)),[-0.01 0.1])
            colormap(jet)
            axis square
            hold on
            plot(ypts,xpts,'w.','Markersize',2)
            plot(x,y,'m+','Markersize',5)
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            legend([sizes{i} ' deg'],'Location','northoutside')
        end
        if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
        end

        %%get peak response for all conditions using manually selected points
        peaks = nan(length(sfrange),length(contrastRange),length(radiusRange),2,length(areas));
        for i = 1:length(sfrange)
    %         for j = 1:length(phaserange)
                for k = 1:length(contrastRange)
                    for l = 1:length(radiusRange)
                        for m = 1:2
                            for n = 1:length(areas)
                            peaks(i,k,l,m,n) = squeeze(nanmean(nanmean(nanmean(trialcycavg(y(n)-1:y(n)+1,x(n)-1:x(n)+1,peakWindow,i,k,l,m),1),2),3));
                            end
                        end
                    end
                end
    %         end
        end

        %plot peak values for the different visual areas
        for m = 1:length(areas)
            cnt=0;
            figure
    %         for k = 1:length(sfrange)
                for l = 1:length(contrastRange)
                    cnt = cnt+1;
                    subplot(length(contrastRange)/2,length(contrastRange)/2,cnt)
                    hold on
                    plot(squeeze(nanmean(peaks(:,l,:,1,m),1)),'ko')
                    plot(squeeze(nanmean(peaks(:,l,:,2,m),1)),'ro')
                    set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
                    xlabel('radius')
                    ylabel('dfof')
                    axis square
                    axis([1 6 -0.01 0.25])
                    legend(sprintf('%s contrast stationary',contrastlist{l}),'running','Location','northoutside')
    %                 legend(sprintf('%0.2fsf %0.00fcontrast stationary',sfrange(k),contrastRange(l)),'running','Location','northoutside')
                end
    %         end
            mtit(sprintf('%s',areas{m}))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end   
        end


        %plot no stim and one stim condition to check
        figure
        subplot(1,2,1)
        hold on
        shadedErrorBar([1:cyclength+cyclength/2]',squeeze(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,1,1),4),5)),squeeze(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,1,1),4),5))/sqrt(length(find(radius==1&running==0))),'k')
        shadedErrorBar([1:cyclength+cyclength/2]',squeeze(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,1,2),4),5)),squeeze(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,1,2),4),5))/sqrt(length(find(radius==1&running==1))),'r')
        axis([1 cyclength+cyclength/2 -0.1 0.25])
        legend('stationary','running') %not sure why colors aren't plotting correctly...
        title('No stim')
        subplot(1,2,2)
        hold on
        shadedErrorBar([1:cyclength+cyclength/2]',squeeze(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,8,1),4),5)),squeeze(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,8,1),4),5))/sqrt(length(find(radius==8&running==0))),'k')
        shadedErrorBar([1:cyclength+cyclength/2]',squeeze(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,8,2),4),5)),squeeze(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,8,2),4),5))/sqrt(length(find(radius==8&running==1))),'r')
        axis([1 cyclength+cyclength/2 -0.1 0.25])
        legend('stationary','running')
        title('Max Radius')
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end    

        %plot activity maps for contrasts averaged over sf/phase with rows=radius
    %     for i=1:length(contrastRange)
    %         for j=1:2
    %             figure
    %             cnt=1;
    %             for k=1:length(radiusRange)
    %                 for l=cyclength/2+1:cyclength
    %                     subplot(length(radiusRange),length(cyclength/2:cyclength-1),cnt)
    %                         imagesc(squeeze(nanmean(trialcycavg(:,:,l,:,i,k,j),4)),[0 0.15])
    %                         colormap(jet)
    %                         axis square
    %                         axis off
    %                         set(gca,'LooseInset',get(gca,'TightInset'))
    %                         hold on; plot(ypts,xpts,'w.','Markersize',2)
    %                         cnt=cnt+1;
    %                 end
    %             end
    %             mtit(sprintf('%s %s %s contrast row=size',[files(use(f)).subj ' ' files(use(f)).expt],behavState{j},contrastlist{i}))
    %             if exist('psfilename','var')
    %                 set(gcf, 'PaperPositionMode', 'auto');
    %                 print('-dpsc',psfilename,'-append');
    %             end
    %         end
    %     end

        %plot traces for manually selected V1 point
        xstim = [cyclength/2 cyclength/2];
        ystim = [-0.1 0.5];
        for i=1:length(contrastRange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                subplot(ceil(length(radiusRange)/4),ceil(length(radiusRange)/2),cnt)
                hold on
                shadedErrorBar([1:cyclength+cyclength/2]',squeeze(nanmean(nanmean(nanmean(trialcycavg(y(1)-2:y(1)+2,x(1)-2:x(1)+2,:,:,i,k,1),1),2),4)),...
                    squeeze(nanstd(nanstd(nanstd(trialcycavg(y(1)-2:y(1)+2,x(1)-2:x(1)+2,:,:,i,k,1),1),2),4))/sqrt(length(find(radius==k&running==0))),'k')
                shadedErrorBar([1:cyclength+cyclength/2]',squeeze(nanmean(nanmean(nanmean(trialcycavg(y(1)-2:y(1)+2,x(1)-2:x(1)+2,:,:,i,k,2),1),2),4)),...
                    squeeze(nanstd(nanstd(nanstd(trialcycavg(y(1)-2:y(1)+2,x(1)-2:x(1)+2,:,:,i,k,2),1),2),4))/sqrt(length(find(radius==k&running==1))),'r')
                plot(xstim,ystim,'g-')
                set(gca,'LooseInset',get(gca,'TightInset'))
                cnt=cnt+1;
                axis([1 cyclength+cyclength/2 -0.1 0.5])
                legend(sprintf('%sdeg stationary',sizes{k}),sprintf('%sdeg running',sizes{k}),'Location','northeast')
            end
            mtit(sprintf('%s %scontrast',[files(use(f)).subj ' ' files(use(f)).expt],contrastlist{i}))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end
        end


        %%%calculate spread of response within each area only need this for
        %%%making tif files
        %%draw boundaries and save image file to manually fill in areas
        % a = ones(size(deconvimg,1),size(deconvimg,2));
        % for i = 1:length(xpts)
        %     a(round(ypts(i)),round(xpts(i))) = 0;
        % end
        % 
        % figure
        % imagesc(a,[0 1])
        % colormap(gray)
        % 
        % imwrite(a,'map.tif')

    %     V1map = imread('V1map.tif'); %read filled-in image files to define areas
    %     Pmap = imread('Pmap.tif');
    %     LMmap = imread('LMmap.tif');
    %     ALmap = imread('ALmap.tif');
    %     RLmap = imread('RLmap.tif');
    %     AMmap = imread('AMmap.tif');
    %     PMmap = imread('PMmap.tif');
    % 
    %     areamaps = zeros(size(deconvimg,1),size(deconvimg,2),7);
    %     areamaps(:,:,1) = V1map(:,:,1); %put image files into a matrix
    %     areamaps(:,:,2) = Pmap(:,:,1);
    %     areamaps(:,:,3) = LMmap(:,:,1);
    %     areamaps(:,:,4) = ALmap(:,:,1);
    %     areamaps(:,:,5) = RLmap(:,:,1);
    %     areamaps(:,:,6) = AMmap(:,:,1);
    %     areamaps(:,:,7) = PMmap(:,:,1);
    % 
    %     areamaps = permute(areamaps,[2 1 3]);
    %     areamaps(areamaps==0) = 1;
    %     areamaps(areamaps==255) = 0; %all points within an area equal 1, everywhere else is 0

        figure %plot individual area boundaries for confirmation
        colormap(gray)
        for i = 1:size(areamaps,3)
            subplot(2,4,i)
            imagesc(areamaps(:,:,i),[0 1])
            hold on; plot(ypts,xpts,'r.','Markersize',1)
            axis off;axis square;
            title(sprintf('%s',areas{i}))
        end
        mtit('Area Measurement Zones')

        for m = 1:7
            sigsize(m) = sqrt(sum(sum(areamaps(:,:,m)))/pi)/4; %sigma guess for gaussian fit of spread
        end

        gauParams = nan(length(contrastRange),length(radiusRange),length(behavState),length(areas)-1,5); %contains a1,x0,y0,sigmax,sigmay for spread fits
        halfMax = nan(length(contrastRange),length(radiusRange),length(behavState),length(areas)-1); %total # pixels above half the max amplitude, alternative spread measure
        areapeaks = halfMax; %automated peak finding
        areameans = halfMax;
        sprintf('doing peak finding and gaussian fits')
        tic
        for m = 1:length(areas)-1
            for j = 1:2
                minframe = squeeze(nanmean(nanmean(nanmean(trialcycavg(:,:,peakWindow,:,:,1,j),3),4),5));
                minframe = minframe(:);
                spreadthresh(j,m) = nanmean(minframe) + 2*std(minframe); %calculate threshold for gaussian
            end
        end

        for k = 1:length(contrastRange)
            for l = 1:length(radiusRange)
                for m = 1:length(areas)-1
                    for n = 1:2
                        spreadframe = squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,:,k,l,n),3),4)).*areamaps(:,:,m);
                        if isnan(nanmean(nanmean(spreadframe)))
                                gauParams(k,l,n,m,1) = NaN;
                                gauParams(k,l,n,m,2) = NaN;
                                gauParams(k,l,n,m,3) = NaN;
                                gauParams(k,l,n,m,4) = NaN;
                                gauParams(k,l,n,m,5) = NaN;
                                halfMax(k,l,n,m) = NaN;
                                areapeaks(k,l,n,m) = NaN;
                        else
                            peakfilter = fspecial('gaussian',12,3);
                            peakmap = imfilter(spreadframe,peakfilter);
                            maxval = max(max(peakmap.*areamaps(:,:,m)));
                            if maxval<=0
                                areapeaks(k,l,n,m) = 0;
                                gauParams(k,l,n,m,:) = 0;
                                halfMax(k,l,n,m) = 0;
                            else
                                maxind = find(peakmap==maxval);
                                [I,J]=ind2sub([size(deconvimg,1) size(deconvimg,2)],maxind);
                                areapeaks(k,l,n,m) = squeeze(nanmean(nanmean(trialcycavg(I,J,peakWindow,:,k,l,n),3),4)); %individual area peaks found by automation
                                spreadframe = spreadframe - spreadthresh(n,m);
                                spreadframe(spreadframe<0)=0;
                                halfMax(k,l,n,m) = length(find((spreadframe>=(max(max(spreadframe))/2))));%&(spreadframe>0.01))); %# pixels above half max
                                areameans(k,l,n,m) = mean(spreadframe(spreadframe>0));
                                sfit = imgGauss(spreadframe,x,y,sigsize,m); %gaussian parameters
                                if sfit.a1<0.01 %one percent for the bottom threshold
                                    gauParams(k,l,n,m,:) = 0; %if below threshold, no "response"
                                else
                                    gauParams(k,l,n,m,1) = sfit.a1;
                                    gauParams(k,l,n,m,2) = sfit.x0;
                                    gauParams(k,l,n,m,3) = sfit.y0;
                                    gauParams(k,l,n,m,4) = sfit.sigmax;
                                    gauParams(k,l,n,m,5) = sfit.sigmay;
                                end
                            end
                        end
                    end
                end
            end
        end
        toc

    %     %multiply binarized area matrices with average trial data to isolate each
    %     %area's response   this is old code
    %     gauParams = nan(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),length(behavState),length(areas),5); %contains a1,x0,y0,sigmax,sigmay for spread fits
    %     halfMax = nan(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),length(behavState),length(areas)); %total # pixels above half the max amplitude, alternative spread measure
    %     areapeaks = halfMax; %automated peak finding
    %     sprintf('doing peak finding and gaussian fits')
    %     tic
    %     for m = 1:length(areas)
    %         minframe = squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,cyclength/2,:,:,:,1,:),4),5),6),8));
    %         minframe = minframe(:);
    %         spreadthresh(:,m) = nanmean(minframe) + 2*std(minframe); %calculate threshold for gaussian
    %     end
    %     for i = 1:length(sfrange)
    %         for j = 1:length(phaserange)
    %             for k = 1:length(contrastRange)
    %                 for l = 1:length(radiusRange)
    %                     for m = 1:length(areas)
    %                         for n = 1:2
    %                             spreadframe = trialcycavg(:,:,cyclength-2,i,j,k,l,n).*areamaps(:,:,m);
    %                             if isnan(nanmean(nanmean(spreadframe)))
    %                                     gauParams(i,j,k,l,n,m,1) = NaN;
    %                                     gauParams(i,j,k,l,n,m,2) = NaN;
    %                                     gauParams(i,j,k,l,n,m,3) = NaN;
    %                                     gauParams(i,j,k,l,n,m,4) = NaN;
    %                                     gauParams(i,j,k,l,n,m,5) = NaN;
    %                                     halfMax(i,j,k,l,n,m) = NaN;
    %                                     areapeaks(i,j,k,l,n,m) = NaN;
    %                             else
    %                                 spreadframe = spreadframe - spreadthresh(:,m);
    %                                 spreadframe(spreadframe<0)=0;
    %                                 halfMax(i,j,k,l,n,m) = length(find(spreadframe>=(max(max(spreadframe))/2))); %# pixels above half max
    %                                 %stopped here, where is imgGauss??
    %                                 sfit = imgGauss(spreadframe,x,y,sigsize,m); %gaussian parameters
    %                                 if sfit.a1<0.01 %one percent for the bottom threshold
    %                                     gauParams(i,j,k,l,n,m,:) = 0; %if below threshold, no "response"
    %                                 else
    %                                     gauParams(i,j,k,l,n,m,1) = sfit.a1;
    %                                     gauParams(i,j,k,l,n,m,2) = sfit.x0;
    %                                     gauParams(i,j,k,l,n,m,3) = sfit.y0;
    %                                     gauParams(i,j,k,l,n,m,4) = sfit.sigmax;
    %                                     gauParams(i,j,k,l,n,m,5) = sfit.sigmay;
    %                                 end
    % 
    %                                 peakmap = trialcycavg(:,:,cyclength/2,i,j,k,l,n);
    %                                 peakfilter = fspecial('gaussian',12,3);
    %                                 peakmap = imfilter(peakmap,peakfilter);
    %                                 maxval = max(max(peakmap.*areamaps(:,:,m)));
    %                                 if maxval<=0
    %                                     areapeaks(i,j,k,l,n,m) = 0;
    %                                 else
    %                                     maxind = find(peakmap==maxval);
    %                                     [I,J]=ind2sub([size(deconvimg,1) size(deconvimg,2)],maxind);
    %                                     areapeaks(i,j,k,l,n,m) = trialcycavg(I,J,cyclength/2,i,j,k,l,n); %individual area peaks found by automation
    %                                 end
    %                             end
    %                         end
    %                     end
    %                 end
    %             end
    %         end
    %     end
    %     toc


        figure
        for i = 1:length(contrastRange)
            subplot(length(contrastRange)/2,length(contrastRange)/2,i)
            hold on
            plot(1:length(radiusRange),squeeze(areapeaks(i,:,1,1)),'ko')
            plot(1:length(radiusRange),squeeze(areapeaks(i,:,2,1)),'ro')
            set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
            xlabel('radius')
            ylabel('dfof')
            axis square
            axis([0 length(radiusRange)+1 -0.01 0.2])
            legend(sprintf('%s contrast',contrastlist{i}),'Location','northoutside')
        end
        mtit('Auto-Find Peaks')
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end

        figure
        for i = 1:length(contrastRange)
            subplot(length(contrastRange)/2,length(contrastRange)/2,i)
            hold on
            plot(1:length(radiusRange),squeeze(halfMax(i,:,1,1)),'ko')
            plot(1:length(radiusRange),squeeze(halfMax(i,:,2,1)),'ro')
            set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
            xlabel('radius')
            ylabel('# pixels')
            axis square
            axis([0 length(radiusRange)+1 0 10000])
            legend(sprintf('%s contrast',contrastlist{i}),'Location','northoutside')
        end
        mtit('Area above Half Max')
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end

        figure
        for i = 1:length(contrastRange)
            subplot(length(contrastRange)/2,length(contrastRange)/2,i)
            hold on
            plot(1:length(radiusRange),(squeeze(gauParams(i,:,1,1,4))+squeeze(gauParams(i,:,1,1,5)))/2,'ko')
            plot(1:length(radiusRange),(squeeze(gauParams(i,:,2,1,4))+squeeze(gauParams(i,:,2,1,5)))/2,'ro')
            set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
            xlabel('radius')
            ylabel('Sigma')
            axis square
            axis([0 length(radiusRange)+1 0 30])
            legend(sprintf('%s contrast',contrastlist{i}),'Location','northoutside')
        end
        mtit('Sigma from Gaussian Fit')
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end





        %%get percent time running
        sp = conv(sp,ones(50,1),'same')/50;
        mv = sum(sp>500)/length(sp);
        figure
        subplot(1,2,1)
        bar(mv);
        xlabel('subject')
        ylabel('fraction running')
        ylim([0 1])
        subplot(1,2,2)
        bar([nanmean(trialspeed(find(running==1))) nanmean(trialspeed(find(running==0)))])
        set(gca,'xticklabel',{'run','sit'})
        ylabel('speed')
        ylim([0 3000])
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
        %%
    %     p = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data';
            filename = sprintf('%s_%s_%s_%s',files(use(f)).expt,files(use(f)).subj,files(use(f)).timing,files(use(f)).inject);
    %         filename = sprintf('%s_SizeSelectAnalysis.mat',filename);

    %     if f~=0
        %     save(fullfile(p,f),'allsubj','sessiondata','shiftData','fit','mnfit','cycavg','mv');
            save(filename,'trialcycavg','peaks','areapeaks','gauParams','mv','halfMax','areameans','-v7.3');
    %     end

        try
            dos(['ps2pdf ' psfilename ' "' [filename '.pdf'] '"'])

        catch
            display('couldnt generate pdf');
        end

        delete(psfilename);
        close all
    else
        sprintf('skipping %s',filename)
    end
end