%%%doGratingPatch
%%% called from analyzeGratingPatch for batch analysis of individual sessions

%%

deconvplz = 1 %choose if you want deconvolution
downsample = 0.5; %downsample ratio
pixbin = 5 %choose binning for gaussian analysis of spread
dfrange = [-0.01 0.05;-0.01 0.15]; %%%range for imagesc visualization, row is running/stationary

for f = 1:length(use)
    clear x y dist trialcycavg ring deconvimg
    filename = sprintf('%s_%s_%s_gratingpatch.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).cond);
    if (exist(fullfile(outpathname,filename),'file')==0 | redoani==1)
        load('C:\gratingpatch3sf2tf8dir')
        sfrange = unique(sf);tfrange = unique(tf);thetarange = unique(theta);xrange = unique(xpos);
        imagerate=10;
        cyclength = imagerate*(isi+duration);
        timepts = 0:1/imagerate:(2*isi+duration);timepts = timepts - isi;timepts = timepts(1:end-1);
        psfilename = 'c:\tempDeniseWF.ps';
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


        load(fullfile(pathname,files(use(f)).patchgratings),'dfof_bg','sp','stimRec','frameT')
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
            imagesc(squeeze(cycavg(:,:,fr)),dfrange(1,:))
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
            if redoani==0
                try
                    load(fullfile(outpathname,filename),'deconvimg')
                    size(deconvimg)
                    base = isi*imagerate-4:isi*imagerate-1;
                    peakWindow = isi*imagerate+1:isi*imagerate+3;
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
                    delete(pp)
                    ncut = 3 %# of trials to cut due to deconvolution cutting off end
                    trials=trials-ncut; %deconv cuts off last trial
                    deconvimg = deconvimg(:,:,1:trials*cyclength);

                    base = isi*imagerate-4:isi*imagerate-1;
                    peakWindow = isi*imagerate+1:isi*imagerate+3;

                    sprintf('saving...')
                    try
                        save(fullfile(outpathname,filename),'deconvimg','-append','-v7.3');
                    catch
                        save(fullfile(outpathname,filename),'deconvimg','-v7.3');
                    end
                end
            else
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
                if exist('psfilename','var')
                    set(gcf, 'PaperPositionMode', 'auto');
                    print('-dpsc',psfilename,'-append');
                end
                delete(pp)
                ncut = 3 %# of trials to cut due to deconvolution cutting off end
                trials=trials-ncut; %deconv cuts off last trial
                deconvimg = deconvimg(:,:,1:trials*cyclength);

                base = isi*imagerate-4:isi*imagerate-1;
                peakWindow = isi*imagerate+1:isi*imagerate+3;

                sprintf('saving...')
                try
                    save(fullfile(outpathname,filename),'deconvimg','-append','-v7.3');
                catch
                    save(fullfile(outpathname,filename),'deconvimg','-v7.3');
                end
            end
        else
            deconvimg = img;
            base = isi*imagerate-4:isi*imagerate-1;
            peakWindow = isi*imagerate+8:isi*imagerate+10;
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

        behavState = {'stationary','running'};
    %     xrange = unique(xpos); sfrange=unique(sf); tfrange=unique(tf);
        running = zeros(1,trials); %pull out stationary vs. runnning (0 vs. 1)
        for i = 1:trials
            running(i) = trialspeed(i)>speedcut;
        end
        
        
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
        trialcycavg=nan(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),length(xrange),length(sfrange),length(tfrange),length(thetarange)-1,2); %x pix, y pix, timecourse, xpos, sf, tf, theta, running
        for i = 1:length(xrange)
            for j = 1:length(sfrange)
                for k = 1:length(tfrange)
                    for l = 1:length(thetarange)-1
                        for m = 1:2
                            inds = find(xpos==xrange(i)&sf==sfrange(j)&tf==tfrange(k)&theta==thetarange(l)&running==(m-1));
                            trialcycavg(:,:,:,i,j,k,l,m) = squeeze(nanmean(trialcyc(:,:,:,inds),4));
                        end
                    end
                end
            end
        end


        %%%baseline and zero trial subtraction
        %get average map with no stimulus
        mintrialcyc = zeros(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),2);
        for i = 1:2
            mintrialcyc(:,:,:,i) = squeeze(nanmean(nanmean(nanmean(trialcycavg(:,:,:,:,:,:,end,i),4),5),6)); %min map for stationary and running
        end
        %subtract average map with no stimulus from trialcycavg and baseline each trial
        for i = 1:length(xrange)
            for j = 1:length(sfrange)
                for k = 1:length(tfrange)
                    for l = 1:length(thetarange)-1
                        for m = 1:2
                            trialcycavg(:,:,:,i,j,k,l,m) = trialcycavg(:,:,:,i,j,k,l,m)-mintrialcyc(:,:,:,m); %subtract min map
                            for t = 1:size(trialcycavg,3)
                                trialcycavg(:,:,t,i,j,k,l,m) = trialcycavg(:,:,t,i,j,k,l,m)-squeeze(nanmean(trialcycavg(:,:,base,i,j,k,l,m),3)); %subtract baseline
                            end
                        end
                    end
                end
            end
        end
        
        
    
%%
        %manual/loading point selection
        files(use(f)).subj
        if reselect==1
            satisfied = 0;
            while satisfied==0
                dist = nan(size(trialcycavg,1),size(trialcycavg,2),length(xrange));
                for i = 1:length(xrange)
                    sprintf('Pick center of visual response')

                    figure;
                    colormap jet
                    subplot(1,2,1)
                    imagesc(squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,peakWindow,i,:,:,:,1),3),5),6),7)),dfrange(1,:))
                    axis off; axis equal
                    title('stationary')
                    subplot(1,2,2)
                    imagesc(squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,peakWindow,i,:,:,:,2),3),5),6),7)),dfrange(1,:))
                    axis off; axis equal
                    title('running')

                    figure;
                    colormap jet
                    subplot(1,2,1)
                    imagesc(squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,peakWindow,i,:,:,:,1),3),5),6),7)),dfrange(1,:))
                    axis off; axis equal
                    title('select center point of response')
                    [y(i) x(i)] = ginput(1);
                    hold on
                    plot(y(i),x(i),'wo','MarkerSize',15)
                    x=round(x); y=round(y);

                    [X,Y] = meshgrid(1:size(trialcycavg,2),1:size(trialcycavg,1));X=X/2; %divide X by two for cortical magnification factor
                    dist(:,:,i) = sqrt((X - y(i)/2).^2 + (Y - x(i)).^2);
                    subplot(1,2,2)
                    imagesc(squeeze(dist(:,:,i)))
                    axis off;axis equal
                end
                satisfied = input('satisfied with your selection? 0=heck no!, 1=booya!: ')
                if isempty(satisfied)
                    satisfied = input('try again: satisfied with your selection? 0=heck no!, 1=booya!: ')
                end
            end
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
            save(fullfile(outpathname,filename),'x','y','dist','-append','-v7.3');
        else
            try
                load(fullfile(outpathname,filename),'x','y','dist')
                for i = 1:length(xrange)
                    figure;
                    colormap jet
                    subplot(1,2,1)
                    imagesc(squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,peakWindow,i,:,:,:,1),3),5),6),7)),dfrange(1,:))
                    axis off; axis equal
                    title('select center point of response')
                    hold on
                    plot(y(i),x(i),'wo','MarkerSize',15)

                    subplot(1,2,2)
                    imagesc(squeeze(dist(:,:,i)))
                    axis off;axis equal
                    if exist('psfilename','var')
                        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                        print('-dpsc',psfilename,'-append');
                    end
                end
            catch
                satisfied = 0;
                while satisfied==0
                    dist = nan(size(trialcycavg,1),size(trialcycavg,2),length(xrange));
                    for i = 1:length(xrange)
                        sprintf('Pick center of visual response')

                        figure;
                        colormap jet
                        subplot(1,2,1)
                        imagesc(squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,peakWindow,i,:,:,:,1),3),5),6),7)),dfrange(1,:))
                        axis off; axis equal
                        title('stationary')
                        subplot(1,2,2)
                        imagesc(squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,peakWindow,i,:,:,:,2),3),5),6),7)),dfrange(1,:))
                        axis off; axis equal
                        title('running')

                        figure;
                        colormap jet
                        subplot(1,2,1)
                        imagesc(squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,peakWindow,i,:,:,:,1),3),5),6),7)),dfrange(1,:))
                        axis off; axis equal
                        title('select center point of response')
                        [y(i) x(i)] = ginput(1);
                        hold on
                        plot(y(i),x(i),'wo','MarkerSize',15)
                        x=round(x); y=round(y);

                        [X,Y] = meshgrid(1:size(trialcycavg,2),1:size(trialcycavg,1));X=X/2; %divide X by two for cortical magnification factor
                        dist(:,:,i) = sqrt((X - y(i)/2).^2 + (Y - x(i)).^2);
                        subplot(1,2,2)
                        imagesc(squeeze(dist(:,:,i)))
                        axis off;axis equal
                    end
                    satisfied = input('satisfied with your selection? 0=heck no!, 1=booya!: ')
                    if isempty(satisfied)
                        satisfied = input('try again: satisfied with your selection? 0=heck no!, 1=booya!: ')
                    end
                end
                if exist('psfilename','var')
                    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                    print('-dpsc',psfilename,'-append');
                end
                save(fullfile(outpathname,filename),'x','y','dist','-append','-v7.3');
            end
        end
        
        

%%
        %%get response vs distance for all conditions using manually selected point
        sprintf('analyzing spread of response')
        ring = nan(max([ceil(max(max(dist(:,:,1)))/pixbin) ceil(max(max(dist(:,:,2)))/pixbin)]),length(xrange),length(sfrange),length(tfrange),length(thetarange)-1,2);
        for i = 1:length(xrange)
            for j = 1:length(sfrange)
                for k = 1:length(tfrange)
                    for l = 1:length(thetarange)-1
                        for m = 1:2
                            resp = squeeze(nanmean(trialcycavg(:,:,peakWindow,i,j,k,l,m),3));
                            for d = 1:max([ceil(max(max(dist(:,:,1)))/pixbin) ceil(max(max(dist(:,:,2)))/pixbin)])
                                ring(d,i,j,k,l,m) = mean(resp(dist(:,:,i)>(pixbin*(d-1)) & dist(:,:,i)<pixbin*d));
                            end
                        end
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
%% plot averages for the different stimulus parameters
        sprintf('plotting responses')
        
        %%%plot pixelwise responses
        for m = 1:2 %sit/run
            for i = 1:length(xrange)
                figure;colormap jet
                figcnt=1;
                for j = 1:length(sfrange)
                    for k = 1:length(tfrange)
                        subplot(length(sfrange),length(tfrange),figcnt)
                        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,peakWindow,i,j,k,:,m),7),3)),dfrange(1,:))
                        axis off; axis equal
                        title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
                        figcnt=figcnt+1;
                    end
                end
                mtit(sprintf('%s pixelwise xpos%d %s',files(use(f)).subj,i,behavState{m}))
                if exist('psfilename','var')
                    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                    print('-dpsc',psfilename,'-append');
                end
                
                figure;colormap jet
                figcnt=1;
                for j = 1:length(sfrange)
                    for k = 1:length(tfrange)
                        subplot(length(sfrange),length(tfrange),figcnt)
                        plot(timepts,squeeze(nanmean(nanmean(nanmean(trialcycavg(x(i)-2:x(i)+2,y(i)-2:y(i)+2,:,i,j,k,:,m),7),1),2)))
                        ylabel('dfof')
                        xlabel('time(s)')
                        axis([timepts(1) timepts(end) -0.01 0.1]); axis square
                        title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
                        figcnt=figcnt+1;
                    end
                end
                mtit(sprintf('%s cycavg xpos%d %s',files(use(f)).subj,i,behavState{m}))
                if exist('psfilename','var')
                    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                    print('-dpsc',psfilename,'-append');
                end
                
                figure;
                figcnt=1;
                for j = 1:length(sfrange)
                    for k = 1:length(tfrange)
                        subplot(length(sfrange),length(tfrange),figcnt)
                        plot(1:size(ring,1),squeeze(nanmean(ring(:,i,j,k,:,m),5)))
                        ylabel('dfof')
                        xlabel('distance from cent (pix)')
                        axis([0 ceil(size(ring,1)/10)*5 -0.001 0.1])
                        set(gca,'xtick',0:10:ceil(size(ring,1)/10)*5,'xticklabel',0:10*pixbin:ceil(size(ring,1)/10)*5*pixbin)
                        axis square
                        title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
                        figcnt = figcnt+1;
                    end
                end
                mtit(sprintf('%s spread xpos%d %s',files(use(f)).subj,i,behavState{m}))
                if exist('psfilename','var')
                    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                    print('-dpsc',psfilename,'-append');
                end
            end
        end
  
%% save pdf
        try
            dos(['ps2pdf ' psfilename ' "' [fullfile(outpathname,filename(1:end-4)) '.pdf'] '"'])
        catch
            display('couldnt generate pdf');
        end
        delete(psfilename);

    else
        sprintf('skipping %s',filename)
    end
end