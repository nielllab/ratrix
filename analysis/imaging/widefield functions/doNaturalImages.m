%% doNaturalImages
x=0; %clear points
%%%cycle through animals
for f = 1:length(use)
    
    %%%choose downsample factor
    downsample = 1;
    %%%load the movie from batch file name
    load(files(use(f)).movienameNaturalImages)
    %%%get imaging rate from batch file
    imagerate = files(use(f)).imagerate;
    %%%load map overlay
    load('C:\mapOverlay5mm.mat');xpts=xpts/downsample;ypts=ypts/downsample;
    visareas = {'V1','P','LM','AL','RL','AM','PM','MM'};
    aniexpt = [files(use(f)).subj '_' files(use(f)).expt]
    
    %%%get indices of videos
    stimuli = unique(fileidx);
    cyclength = (isi+duration)*imagerate;
    base = 8:10; %indices for baseline
    peak = 11:13; %indices for peak response
    imrange = [0 0.05]; %range to display images at
    ptsrange = 2; %+/- pixels from selected point to average over
    timepts = 0:1/imagerate:cyclength/imagerate-1/imagerate; %cycle time points
    
    %%%load imaging data from batch file info
    load(fullfile(pathname,files(use(f)).naturalimages),'dfof_bg','sp','stimRec','frameT')
    zoom = 260/size(dfof_bg,1);
    if ~exist('sp','var')
        sp=0;stimRec=[];
    end
    dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);  
    dfof_bg = imresize(dfof_bg,1/downsample); %%%spatial downsample dfof

    %% check experiment quality
    %%%make timing figure
    sprintf('checking natural images quality')
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
    if slipframes<1 %%%cut frames from beginning to account for slippage
        slipframes=1
    elseif slipframes>5
        slepframes=5
    end
%     dfof_bg = dfof_bg(:,:,slipframes:end);
    nx=ceil(sqrt(cyclength+1)); %%% how many rows in figure subplot
    trials = length(fileidx); %in case movie stopped early
    %%% mean amplitude map across cycle
    figure
    map=0;
%     p=1:cyclength;p=circshift(p,ceil(cyclength/2)-1,2);
    colormap jet
    clear cyc
    for fr=1:cyclength
        cyc(:,:,fr) = mean(dfof_bg(:,:,(fr:cyclength:end)),3);
        subplot(nx,nx,fr)
        imagesc(squeeze(cyc(:,:,fr)),imrange)
        axis off; axis square
        set(gca,'LooseInset',get(gca,'TightInset'))
%             hold on; plot(ypts,xpts,'w.','Markersize',2)
        map = map+squeeze(cyc(:,:,fr))*exp(2*pi*sqrt(-1)*(0.5 +fr/cyclength));
    end

    %%% add timecourse
    subplot(nx,nx,fr+1)
    plot(squeeze(mean(mean(cyc,2),1)))
    axis off
    set(gca,'LooseInset',get(gca,'TightInset'))
    mtit(sprintf('%s cycavg natural images',aniexpt))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end

    %%% calculate phase of cycle response
    %%% good for detectime framedrops or other problems
    tcourse = squeeze(mean(mean(dfof_bg,2),1));
    fourier = tcourse'.*exp((1:length(tcourse))*2*pi*sqrt(-1)/(imagerate*duration + imagerate*isi));
    figure(timingfig)
    subplot(2,2,4)
    plot((1:length(tcourse))/600,angle(conv(fourier,ones(1,600),'same')));
    ylim([-pi pi])
    ylabel('phase'); xlabel('mins')
    mtit(sprintf('%s natural images',aniexpt))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    %% break responses up by trial and get running data
    
    sprintf('separating responses by trial')
    speedcut = 20;
    trialspeed = zeros(trials,1);
    trialcyc = zeros(size(dfof_bg,1),size(dfof_bg,2),cyclength,trials);
    for tr=1:trials;
        t0 = round((tr-1)*cyclength);
        baseframes = base+t0; baseframes=baseframes(baseframes>0);
        try
            trialspeed(tr) = mean(sp(peak+t0));
        catch
            trialspeed(tr)=20;
        end
        trialcyc(:,:,:,tr) = dfof_bg(:,:,t0+(1:cyclength));%each cycle is frames 6-26, stim comes on at frame 11
    end
    
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
    mtit(sprintf('%s natural images',aniexpt))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    %%%get average response to each stimulus, stationary vs. running
    trialcycavg=nan(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),length(stimuli),2);
    for i = 1:length(stimuli)
        for j = 1:2
%             blanktr = find(fileidx==stimuli(1)&running==(j-1));
            inds = find(fileidx==stimuli(i)&running==(j-1));
            trialcycavg(:,:,:,i,j) = squeeze(nanmean(trialcyc(:,:,:,inds),4));%-squeeze(nanmean(trialcyc(:,:,:,blanktr),4));
        end
    end
    
    %%%pick points to analyze
    try
        load(files(use(f)).ptsfile)
    catch
        disp('no points file designated in batch file')
    end
    if x==0
        [fname pname] = uigetfile('*.mat','select points file? cancel to pick points');
        if fname~=0
            load(fullfile(pname, fname));
        else
            figure;colormap jet
            im = nanmean(nanmean(nanmean(trialcycavg(:,:,peak,:,:),3),4),5);
            imagesc(im,imrange)
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            title('pick 8 points: V1, clockwise around, then MM (outside lines below V1')
            for i = 1:8
                [y(i) x(i)] =ginput(1);
                plot(y(i),x(i),'o');
            end

            x=round(x); y=round(y);
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end

            close(gcf);
            [fname pname] = uiputfile('*.mat','save points?');
            if fname~=0
                save(fullfile(pname,fname),'x','y');
            end
        end
    end
    
    %%%plot the peak response to each stimulus
    figure; colormap jet
    for i = 1:length(stimuli)
        subplot(5,ceil(length(stimuli)/5),i)
        im = nanmean(nanmean(trialcycavg(:,:,peak,i,:),3),5);%-nanmean(nanmean(trialcycavg(:,:,base,i,:),3),5);
        imagesc(im,imrange)
        hold on;plot(ypts,xpts,'w.','Markersize',2)
        axis off
        axis image
    end
    mtit(sprintf('%s peak resp natural images',aniexpt))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    %%%plot familiar vs. unfamiliar average
    figure
    fam = find(familiar==1);
    unfam = find(familiar==0);
    for i = 1:length(x)
        subplot(2,ceil(length(x)/2),i)
        trace = squeeze(nanmean(nanmean(nanmean(trialcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,fam),1),2),4));
        plot(timepts,trace-mean(trace(base)),'k')
        hold on
        trace = squeeze(nanmean(nanmean(nanmean(trialcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,unfam),1),2),4));
        plot(timepts,trace-mean(trace(base)),'r')
        xlabel('time (s)')
        ylabel(sprintf('%s dfof',visareas{i}))
        axis([0 timepts(end) -0.005 0.03])
    end
    legend('familiar','unfamiliar','Location','southeast')
    mtit(sprintf('%s natural images',aniexpt))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    %%%make plots for each natural image
    for i = 1:length(allims)
        figure
        ax1 = subplot(1,3,1);
        imshow(allims{i})
        colormap(ax1,'gray')
        ax2 = subplot(1,3,2);
        im = nanmean(nanmean(trialcycavg(:,:,peak,i+1,:),3),5);%1st idx is blank so add 1
        imagesc(im,imrange)
        hold on;plot(ypts,xpts,'w.','Markersize',2)
        axis image
        axis off
        colormap(ax2,'jet')
        subplot(1,3,3)
        hold on
        for j = 1:length(x)
            trace = squeeze(nanmean(nanmean(nanmean(trialcycavg(x(j)-ptsrange:x(j)+ptsrange,y(j)-ptsrange:y(j)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
            plot(timepts,trace-mean(trace(base)))
        end
        legend(visareas,'Location','Northwest')
        xlabel('time (s)')
        ylabel('dfof')
        axis([0 timepts(end) -0.005 0.1])
        axis square
        mtit(sprintf('%s %s %s %s familiar=%d',files(use(f)).subj,files(use(f)).expt,files(use(f)).condition,allfiles{i},allfam(i)))
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
    end
    
    natimcycavg(:,:,:,:,:,f) = trialcycavg;
    natimcyc(:,:,:,:,f) = trialcyc;
    
end