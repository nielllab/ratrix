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
fully = 0 %choose if you want full frame (260x260), else scales down by 2
pixbin = 5 %choose binning for gaussian analysis of spread

for f = 1:length(use)
    filename = sprintf('%s_%s_%s_%s',files(use(f)).expt,files(use(f)).subj,files(use(f)).timing,files(use(f)).inject);
    if exist([filename '.mat'])==0
        load('C:\patchonpatch14min')
%         load('C:\mapoverlay.mat')
%         load('C:\areamaps.mat')
        imagerate=10;
        cyclength = imagerate*(isi+duration);
        base = isi*imagerate-4:isi*imagerate-1;
        peakWindow = base(end):base(end)+duration*imagerate-1;
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
        sprintf('checking experiment quality')
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
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
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
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end

%%
        %deconvolution
        if deconvplz == 1
            sprintf('doing deconvolution')
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
        sprintf('separating responses by trial')
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
        trialtypes = length(unique(trialID));
        
        %%plot percent time running
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

        %%%create array w/responses for trial types
        trialcycavg=nan(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),trialtypes,length(unique(isocross)),2);
        for i = 1:trialtypes
            for j = 1:length(unique(isocross))
                for k = 1:2
                    inds = find(trialID(1,:)==i&isocross==j&running==(k-1));
                    trialcycavg(:,:,:,i,j,k) = squeeze(nanmean(trialcyc(:,:,:,inds),4));
                end
            end
        end
        toc

        %%%baseline and zero trial subtraction
        %get average map with no stimulus
        mintrialcyc = zeros(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),2);
        for i = 1:2
            mintrialcyc(:,:,:,i) = squeeze(nanmean(trialcycavg(:,:,:,1,:,i),5)); %min map for stationary and running
        end
        %subtract average map with no stimulus from trialcycavg and baseline each trial
        for i = 1:trialtypes
            for j = 1:length(unique(isocross))
                for k = 1:2
                    trialcycavg(:,:,:,i,j,k) = trialcycavg(:,:,:,i,j,k)-mintrialcyc(:,:,:,k); %subtract min map
                    for t = 1:size(trialcycavg,3)
                        trialcycavg(:,:,t,i,j,k) = trialcycavg(:,:,t,i,j,k)-squeeze(nanmean(trialcycavg(:,:,base,i,j,k),3)); %subtract baseline
                    end
                end
            end
        end
        
    
%%
        %manual/loading point selection
        [files(use(f)).subj ' ' files(use(f)).inject]
        if ~exist(files(use(f)).patchpts)
            sprintf('Pick center of visual response')
            
            amos=figure;
            colormap jet
            subplot(2,2,1)
            imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),[-0.001 0.01])
            axis off
            title('small center sit')
            subplot(2,2,2)
            imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,3,:,1),3),5)),[-0.001 0.01])
            axis off
            title('large center sit')

            andy=figure;
            colormap jet
            imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),[-0.001 0.01])
            axis off
            title('select center point of response')
            [y x] = ginput(1);
            hold on
            plot(y,x,'wo','MarkerSize',15)
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
            x=round(x); y=round(y);
            pause(1)
            [X,Y] = meshgrid(1:size(trialcycavg,1),1:size(trialcycavg,2));X=X/2; %divide X by two for cortical magnification factor
            dist =sqrt((X - x/2).^2 + (Y - y).^2);
            hold off
            imagesc(dist)
            pause(1)
            close(amos,andy)
            save(files(use(f)).patchpts,'x','y','dist');
        else
            load(files(use(f)).patchpts)
        end
        

%%
        %%get response vs distance for all conditions using manually selected point
        sprintf('analyzing spread of response')
        ring = nan(ceil(max(max(dist))/pixbin),trialtypes,length(unique(isocross)),2);
        for i = 1:trialtypes
            for j = 1:length(unique(isocross))
                for k = 1:2
                    resp = squeeze(nanmean(trialcycavg(:,:,peakWindow,i,j,k),3));
                    for d = 1:ceil(max(max(dist)))/pixbin
                        ring(d,i,j,k) = mean(resp(dist>(pixbin*(d-1)) & dist<pixbin*d));
                    end
                end
            end
        end
%%
        %%%plot averages for the different stimulus parameters
        sprintf('plotting responses')
        %%%center stimuli
        figure
        colormap jet
        subplot(2,2,1)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),[-0.001 0.01])
        axis off
        title('small center sit')
        subplot(2,2,2)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,3,:,1),3),5)),[-0.001 0.01])
        axis off
        title('large center sit')
        subplot(2,2,3)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,2),3),5)),[-0.001 0.01])
        axis off
        title('small center run')
        subplot(2,2,4)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,3,:,2),3),5)),[-0.001 0.01])
        axis off
        title('large center run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        figure
        subplot(2,2,1)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,2,:,1),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('small center sit')
        subplot(2,2,2)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,3,:,1),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('large center sit')
        subplot(2,2,3)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,2,:,2),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('small center run')
        subplot(2,2,4)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,3,:,2),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('large center run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        %%%surround stimuli
        figure
        colormap jet
        subplot(2,2,1)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,6,:,1),3),5)),[-0.001 0.01])
        axis off
        title('small donut sit')
        subplot(2,2,2)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,7,:,1),3),5)),[-0.001 0.01])
        axis off
        title('large donut sit')
        subplot(2,2,3)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,6,:,2),3),5)),[-0.001 0.01])
        axis off
        title('small donut run')
        subplot(2,2,4)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,7,:,2),3),5)),[-0.001 0.01])
        axis off
        title('large donut run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        figure
        subplot(2,2,1)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,6,:,1),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('small donut sit')
        subplot(2,2,2)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,7,:,1),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('large donut sit')
        subplot(2,2,3)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,6,:,2),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('small donut run')
        subplot(2,2,4)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,7,:,2),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('large donut run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        %%%iso and cross oriented stimuli
        figure
        colormap jet
        subplot(2,2,1)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,4,1,1),3),5)),[-0.001 0.01])
        axis off
        title('small iso sit')
        subplot(2,2,2)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,4,2,1),3),5)),[-0.001 0.01])
        axis off
        title('small cross sit')
        subplot(2,2,3)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,5,1,1),3),5)),[-0.001 0.01])
        axis off
        title('large iso sit')
        subplot(2,2,4)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,5,2,1),3),5)),[-0.001 0.01])
        axis off
        title('large cross sit')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        figure
        subplot(2,2,1)
        plot(1:size(ring,1),squeeze(ring(:,4,1,1)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('small iso sit')
        subplot(2,2,2)
        plot(1:size(ring,1),squeeze(ring(:,4,2,1)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('small cross sit')
        subplot(2,2,3)
        plot(1:size(ring,1),squeeze(ring(:,5,1,1)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('large iso sit')
        subplot(2,2,4)
        plot(1:size(ring,1),squeeze(ring(:,5,2,1)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('large cross sit')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        figure
        colormap jet
        subplot(2,2,1)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,4,1,2),3),5)),[-0.001 0.01])
        axis off
        title('small iso run')
        subplot(2,2,2)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,4,2,2),3),5)),[-0.001 0.01])
        axis off
        title('small cross run')
        subplot(2,2,3)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,5,1,2),3),5)),[-0.001 0.01])
        axis off
        title('large iso run')
        subplot(2,2,4)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,5,2,2),3),5)),[-0.001 0.01])
        axis off
        title('large cross run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        figure
        subplot(2,2,1)
        plot(1:size(ring,1),squeeze(ring(:,4,1,2)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('small iso run')
        subplot(2,2,2)
        plot(1:size(ring,1),squeeze(ring(:,4,2,2)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('small cross run')
        subplot(2,2,3)
        plot(1:size(ring,1),squeeze(ring(:,5,1,2)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('large iso run')
        subplot(2,2,4)
        plot(1:size(ring,1),squeeze(ring(:,5,2,2)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('large cross run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
 %%       
        sprintf('plotting cycle averages for response types')
%         %plot traces for responses to each stim type
%         xstim = [cyclength/2 cyclength/2];
%         ystim = [-0.1 0.5];
%         for i=1:length(contrastRange)
%             figure
%             cnt=1;
%             for k=1:length(radiusRange)
%                 subplot(ceil(length(radiusRange)/4),ceil(length(radiusRange)/2),cnt)
%                 hold on
%                 shadedErrorBar([1:cyclength+cyclength/2]',squeeze(nanmean(nanmean(nanmean(trialcycavg(y(1)-2:y(1)+2,x(1)-2:x(1)+2,:,:,i,k,1),1),2),4)),...
%                     squeeze(nanstd(nanstd(nanstd(trialcycavg(y(1)-2:y(1)+2,x(1)-2:x(1)+2,:,:,i,k,1),1),2),4))/sqrt(length(find(radius==k&running==0))),'k')
%                 shadedErrorBar([1:cyclength+cyclength/2]',squeeze(nanmean(nanmean(nanmean(trialcycavg(y(1)-2:y(1)+2,x(1)-2:x(1)+2,:,:,i,k,2),1),2),4)),...
%                     squeeze(nanstd(nanstd(nanstd(trialcycavg(y(1)-2:y(1)+2,x(1)-2:x(1)+2,:,:,i,k,2),1),2),4))/sqrt(length(find(radius==k&running==1))),'r')
%                 plot(xstim,ystim,'g-')
%                 set(gca,'LooseInset',get(gca,'TightInset'))
%                 cnt=cnt+1;
%                 axis([1 cyclength+cyclength/2 -0.1 0.5])
%                 legend(sprintf('%sdeg stationary',sizes{k}),sprintf('%sdeg running',sizes{k}),'Location','northeast')
%             end
%             mtit(sprintf('%s %scontrast',[files(use(f)).subj ' ' files(use(f)).expt],contrastlist{i}))
%             if exist('psfilename','var')
%                 set(gcf, 'PaperPositionMode', 'auto');
%                 print('-dpsc',psfilename,'-append');
%             end
%         end
  
%%
        try
            save(fullfile(outpathname,filename),'trialcycavg','ring','-v7.3','-append');
        catch
            save(fullfile(outpathname,filename),'trialcycavg','ring','-v7.3');
        end

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