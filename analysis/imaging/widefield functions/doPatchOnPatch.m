%%%doPatchOnPatch
%%% called from analyzePatchOnPatch for batch analysis of individual sessions

%trial types for patchonpatch
% 1 = blank
% 2 = center only
% 3 = surround only
% 4 = both, iso or cross

%%

downsample = 0.5; %downsample ratio
pixbin = 5 %choose binning for gaussian analysis of spread
dfrangesit = [-0.01 0.05]; %%%range for imagesc visualization
dfrangerun = [-0.01 0.15]; %%%range for imagesc visualization

for f = 1:length(use)
    clear x y dist trialcycavg ring deconvimg
    filename = sprintf('%s_%s_%s_%s_patchonpatch.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).timing,files(use(f)).inject);
    if (exist(fullfile(outpathname,filename),'file')==0 | redoani==1)
        load(moviename)
        imagerate=10;
        cyclength = imagerate*(isi+duration);
        timepts = 0:1/imagerate:(2*isi+duration);timepts = timepts - isi;timepts = timepts(1:end-1);
        trnames = {'blank','center','surround','iso/cross'};aniState={'sit','run'};
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


        load(fullfile(pathname,files(use(f)).patchonpatch),'dfof_bg','sp','stimRec','frameT')
%         load(fullfile(outpathname,filename),'img')
        
        zoom = 260/size(dfof_bg,1);
        dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
        img = imresize(double(dfof_bg),downsample,'method','box');
        
        if ~exist('sp','var')
            sp =0;stimRec=[];
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

        imageT=(1:size(img,3))/imagerate;
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
            imagesc(squeeze(cycavg(:,:,fr)),dfrangesit)
            axis off; axis square
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

%% do deconvolution
        if deconvplz == 1
            try
                sprintf('loading data...')
                load(fullfile(outpathname,filename),'deconvimg')
                size(deconvimg)
                ncut = 3 %# of trials to cut due to deconvolution cutting off end
                trials=trials-ncut; %deconv cuts off last trial
            catch
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
                delete(pp)
                ncut = 3 %# of trials to cut due to deconvolution cutting off end
                trials=trials-ncut; %deconv cuts off last trial
                deconvimg = deconvimg(:,:,1:trials*cyclength);
                %check deconvolution success on one pixel
                figure
                hold on
                plot(squeeze(img(130,130,:)))
                plot(squeeze(deconvimg(130,130,:)),'g')
                hold off
                if exist('psfilename','var')
                    set(gcf, 'PaperPositionMode', 'auto');
                    print('-dpsc',psfilename,'-append');
                end
                
                sprintf('saving...')
                try
                    save(fullfile(outpathname,filename),'deconvimg','-append','-v7.3');
                catch
                    save(fullfile(outpathname,filename),'deconvimg','-v7.3');
                end
            end
        else
            deconvimg = img;
            try
                save(fullfile(outpathname,filename),'deconvimg','-append','-v7.3');
            catch
                save(fullfile(outpathname,filename),'deconvimg','-v7.3');
            end
        end
        
        
        
%%
        %%% separate responses by trials
        sprintf('separating responses by trial')
        speedcut = 20;
%         trialdata = zeros(size(deconvimg,1),size(deconvimg,2),trials);
        trialspeed = zeros(trials,1);
        trialcyc = zeros(size(deconvimg,1),size(deconvimg,2),cyclength+isi*imagerate,trials);
        for tr=1:trials-1;
            t0 = round((tr-1)*cyclength);
            baseframes = base+t0; baseframes=baseframes(baseframes>0);
%             trialdata(:,:,tr)=mean(deconvimg(:,:,peakWindow+t0),3) -mean(deconvimg(:,:,baseframes),3);
            try
                trialspeed(tr) = mean(sp(peakWindow+t0));
            catch
                trialspeed(tr)=20;
            end
            trialcyc(:,:,:,tr) = deconvimg(:,:,t0+(1:cyclength+isi*imagerate));%each cycle is frames 6-26, stim comes on at frame 11
        end

        trialID = trialID(:,1:trials);
        isocross = zeros(1,trials);isocross(trialID(2,:)==trialID(3,:))=1;isocross(trialID(2,:)~=trialID(3,:))=2;
        behavState = {'stationary','running'};
    %     xrange = unique(xpos); sfrange=unique(sf); tfrange=unique(tf);
        running = zeros(1,trials); %pull out stationary vs. runnning (0 vs. 1)
        for i = 1:trials
            running(i) = trialspeed(i)>speedcut;
        end
        trialtypes = length(unique(trialID));
        
        %%plot percent time running
        sp = conv(sp,ones(50,1),'same')/20;
        mv = sum(sp>20)/length(sp);
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
        allinds = {};cnt=1;
        trialcycavg=nan(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),trialtypes,length(unique(isocross)),2);
        for i = 1:trialtypes
            for j = 1:length(unique(isocross))
                for k = 1:2
                    inds = find(trialID(1,:)==i&isocross==j&running==(k-1));allinds{cnt} = inds;
                    trialcycavg(:,:,:,i,j,k) = squeeze(nanmean(trialcyc(:,:,:,inds),4));
                    cnt=cnt+1;
                end
            end
        end


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
        if mod(f,2)==1
            if reselect==1
                sprintf('Pick center of visual response')

                figure;
                colormap jet
                subplot(1,2,1)
                imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),dfrangesit)
                axis off; axis equal
                title('center sit')
                subplot(1,2,2)
                imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,3,:,1),3),5)),dfrangesit)
                axis off; axis equal
                title('surround sit')

                figure;
                colormap jet
                subplot(1,2,1)
                imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),dfrangesit)
                axis off; axis equal
                title('select center point of response')
                [y x] = ginput(1);
                hold on
                plot(y,x,'wo','MarkerSize',15)
                x=round(x); y=round(y);

                [X,Y] = meshgrid(1:size(trialcycavg,2),1:size(trialcycavg,1));X=X/2; %divide X by two for cortical magnification factor
                dist =sqrt((X - y/2).^2 + (Y - x).^2);
                subplot(1,2,2)
                imagesc(dist)
                axis off;axis equal
                if exist('psfilename','var')
                    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                    print('-dpsc',psfilename,'-append');
                end

                save(fullfile(outpathname,filename),'x','y','dist','-append','-v7.3');
            else
                try
                    load(fullfile(outpathname,filename),'x','y','dist')
%                     load(fullfile(altpathname,filename),'x','y','dist')
                    figure;
                    colormap jet
                    subplot(1,2,1)
                    imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),dfrangesit)
                    axis off; axis equal
                    title('select center point of response')
                    hold on
                    plot(y,x,'wo','MarkerSize',15)

                    subplot(1,2,2)
                    imagesc(dist)
                    axis off;axis equal
                    if exist('psfilename','var')
                        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                        print('-dpsc',psfilename,'-append');
                    end
                catch
                    sprintf('Pick center of visual response')

                    figure;
                    colormap jet
                    subplot(1,2,1)
                    imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),dfrangesit)
                    axis off; axis equal
                    title('center sit')
                    subplot(1,2,2)
                    imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,3,:,1),3),5)),dfrangesit)
                    axis off; axis equal
                    title('surround sit')

                    figure;
                    colormap jet
                    subplot(1,2,1)
                    imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),dfrangesit)
                    axis off; axis equal
                    title('select center point of response')
                    [y x] = ginput(1);
                    hold on
                    plot(y,x,'wo','MarkerSize',15)
                    x=round(x); y=round(y);

                    [X,Y] = meshgrid(1:size(trialcycavg,2),1:size(trialcycavg,1));X=X/2; %divide X by two for cortical magnification factor
                    dist =sqrt((X - y/2).^2 + (Y - x).^2);
                    subplot(1,2,2)
                    imagesc(dist)
                    axis off;axis equal
                    if exist('psfilename','var')
                        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                        print('-dpsc',psfilename,'-append');
                    end

                    save(fullfile(outpathname,filename),'x','y','dist','-append','-v7.3');
                end
            end
        else
%             try
%                 load(fullfile(outpathname,filename),'x','y','dist')
%                 figure;
%                 colormap jet
%                 subplot(1,2,1)
%                 imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),dfrangesit)
%                 axis off; axis equal
%                 title('select center point of response')
%                 hold on
%                 plot(y,x,'wo','MarkerSize',15)
% 
%                 subplot(1,2,2)
%                 imagesc(dist)
%                 axis off;axis equal
%                 if exist('psfilename','var')
%                     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%                     print('-dpsc',psfilename,'-append');
%                 end
%             catch
                load(fullfile(outpathname,sprintf('%s_%s_%s_%s_patchonpatch.mat',files(use(f)).expt,files(use(f)).subj,files(use(f-1)).timing,files(use(f)).inject)),...
                    'x','y','dist')
%                 load(fullfile(altpathname,filename),'x','y','dist')
                figure;
                colormap jet
                subplot(1,2,1)
                imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),dfrangesit)
                axis off; axis equal
                title('select center point of response')
                hold on
                plot(y,x,'wo','MarkerSize',15)

                subplot(1,2,2)
                imagesc(dist)
                axis off;axis equal
                if exist('psfilename','var')
                    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                    print('-dpsc',psfilename,'-append');
                end

                save(fullfile(outpathname,filename),'x','y','dist','-append','-v7.3');
%             end
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
        

%% save data
        try
            save(fullfile(outpathname,filename),'trialcycavg','ring','-v7.3','-append');
        catch
            save(fullfile(outpathname,filename),'trialcycavg','ring','-v7.3');
        end
        
%% plot all trials for all stimuli
        cnt=1;
        figure
        for i = 1:trialtypes
            for j = 1:length(unique(isocross))
                for k = 1:2
                    subplot(4,4,cnt)
                    resp = squeeze(nanmean(nanmean(trialcyc(x-2:x+2,y-2:y+2,:,allinds{cnt}),2),1));
                    hold on
                    plot(resp)
                    plot(nanmean(resp,2),'r','linewidth',3)
                    xlabel(sprintf('%s theta%d %s',trnames{i},j,aniState{k}))
                    axis([1 30 -0.2 0.6]);axis square
                    cnt=cnt+1;
                end
            end
        end
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        figure;
        hold on
        plot(squeeze(nanmean(nanmean(mintrialcyc(x-2:x+2,y-2:y+2,:,1),2),1)),'k')
        plot(squeeze(nanmean(nanmean(mintrialcyc(x-2:x+2,y-2:y+2,:,2),2),1)),'r')
        legend('sit','run')
        axis([1 30 -0.2 0.6]);axis square
        title('zero trial for subtraction')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end

        %% plot averages for the different stimulus parameters
        sprintf('plotting responses')
        
        %%%center or surround only
        figure
        colormap jet
        subplot(2,2,1)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,1),3),5)),dfrangesit)
        axis off;axis square;
        title('center sit')
        subplot(2,2,2)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,2,:,2),3),5)),dfrangesit)
        axis off;axis square;
        title('center run')
        subplot(2,2,3)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,3,:,1),3),5)), dfrangerun)
        axis off;axis square;
        title('surround sit')
        subplot(2,2,4)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,3,:,2),3),5)), dfrangerun)
        axis off;axis square;
        title('surround run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        figure
        subplot(2,2,1)
        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,2,:,1),1),2),5)))
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.1 0.1])
        axis square
        title('center sit')
        subplot(2,2,2)
        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,2,:,2),1),2),5)))
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.01 0.1])
        axis square
        title('center run')
        subplot(2,2,3)
        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,3,:,1),1),2),5)))
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.01 0.1])
        axis square
        title('surround sit')
        subplot(2,2,4)
        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,3,:,2),1),2),5)))
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.01 0.1])
        axis square
        title('surround run')
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
        title('center sit')
        subplot(2,2,2)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,2,:,2),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('center run')
        subplot(2,2,3)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,3,:,1),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('surround sit')
        subplot(2,2,4)
        plot(1:size(ring,1),squeeze(nanmean(ring(:,3,:,2),3)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('surround run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end

        
        %%%iso and cross oriented stimuli
        figure
        colormap jet
        subplot(2,2,1)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,4,1,1),3),5)),dfrangesit)
        axis off;axis square;
        title('iso sit')
        subplot(2,2,2)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,4,1,2),3),5)),dfrangesit)
        axis off;axis square;
        title('iso run')
        subplot(2,2,3)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,4,2,1),3),5)),dfrangesit)
        axis off;axis square;
        title('cross sit')
        subplot(2,2,4)
        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,4,2,2),3),5)),dfrangesit)
        axis off;axis square;
        title('cross run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        figure
        subplot(2,2,1)
        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,4,1,1),1),2),5)))
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.01 0.1])
        axis square
        title('iso sit')
        subplot(2,2,2)
        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,4,1,2),1),2),5)))
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.01 0.1])
        axis square
        title('iso run')
        subplot(2,2,3)
        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,4,2,1),1),2),5)))
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.01 0.1])
        axis square
        title('cross sit')
        subplot(2,2,4)
        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x-2:x+2,y-2:y+2,:,4,2,2),1),2),5)))
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.01 0.1])
        axis square
        title('cross run')
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
        title('iso sit')
        subplot(2,2,2)
        plot(1:size(ring,1),squeeze(ring(:,4,1,2)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('iso run')
        subplot(2,2,3)
        plot(1:size(ring,1),squeeze(ring(:,4,2,1)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('cross sit')
        subplot(2,2,4)
        plot(1:size(ring,1),squeeze(ring(:,4,2,2)))
        ylabel('dfof')
        xlabel('distance from cent (pix)')
        axis([0 ceil(size(ring,1)/10)*10 -0.001 0.1])
        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*10,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*10*pixbin)
        axis square
        title('cross run')
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
  
%% save pdf
        try
            dos(['ps2pdf ' psfilename ' "' [fullfile(outpathname,filename) '.pdf'] '"'])
        catch
            display('couldnt generate pdf');
        end
        delete(psfilename);

    else
        sprintf('skipping %s',filename)
    end
end