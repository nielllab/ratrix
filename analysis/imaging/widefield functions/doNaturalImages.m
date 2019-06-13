%% doNaturalImages

%%%cycle through animals
for f = 1:length(use)
    
    %%%load the movie from batch file name
    load(files(use(f)).movienameNaturalImages)
    %%%get imaging rate from batch file
    imagerate = files(use(f)).imagerate;
    
    %%%get indices of videos
    stimuli = unique(fileidx);
    cyclength = (isi+duration)*imagerate;
    base = 3:5; %indices for baseline
    peak = 13:15; %indices for peak response
    imrange = [0 0.05]; %range to display images at
    ptsrange = 2; %+/- pixels from selected point to average over
    
    %%%load imaging data from batch file info
    load(fullfile(pathname,files(use(f)).naturalimages),'dfof_bg','sp','stimRec','frameT')
    zoom = 260/size(dfof_bg,1);
    if ~exist('sp','var')
        sp=0;stimRec=[];
    end
    dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);  
    dfof_bg = imresize(dfof_bg,0.25); %%%spatial downsample dfof

    %% check experiment quality
    %%%make timing figure
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
    for fr=1:cyclength
        cycavg(:,:,fr) = mean(dfof_bg(:,:,(fr:cyclength:end)),3);
        subplot(nx,nx,fr)
        imagesc(squeeze(cycavg(:,:,fr)),imrange)
        axis off; axis square
        set(gca,'LooseInset',get(gca,'TightInset'))
%             hold on; plot(ypts,xpts,'w.','Markersize',2)
        map = map+squeeze(cycavg(:,:,fr))*exp(2*pi*sqrt(-1)*(0.5 +fr/cyclength));
    end

    %%% add timecourse
    subplot(nx,nx,fr+1)
    plot(squeeze(mean(mean(cycavg,2),1)))
    axis off
    set(gca,'LooseInset',get(gca,'TightInset'))
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
    
    %%%plot the peak response to each stimulus
    figure; colormap jet
    for i = 1:length(stimuli)
        subplot(5,ceil(length(stimuli)/5),i)
        im = nanmean(nanmean(trialcycavg(:,:,13:15,i,:),3),5);%-nanmean(nanmean(trialcycavg(:,:,base,i,:),3),5);
        imagesc(im,imrange)
        axis off
        axis image
    end
    mtit('peak response to each stimulus')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    figure;colormap jet
    im = nanmean(nanmean(nanmean(trialcycavg(:,:,peak,:,:),3),4),5);
    imagesc(im,imrange)
    title('select V1 peak')
    axis off
    [x,y] = ginput(1)
    x=round(x);y=round(y);
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    close
    
    figure
    fam = find(familiar==1);
    unfam = find(familiar==0);
    trace = squeeze(nanmean(nanmean(nanmean(trialcyc(x-ptsrange:x+ptsrange,y-ptsrange:y+ptsrange,:,fam),1),2),4));
    plot(0:1/imagerate:cyclength/imagerate-1/imagerate,trace-mean(trace(8:10)),'k')
    hold on
    trace = squeeze(nanmean(nanmean(nanmean(trialcyc(x-ptsrange:x+ptsrange,y-ptsrange:y+ptsrange,:,unfam),1),2),4));
    plot(0:1/imagerate:cyclength/imagerate-1/imagerate,trace-mean(trace(8:10)),'r')
    legend('familiar','unfamiliar')
    xlabel('time (s)')
    ylabel('dfof')
    mtit('cycavg familiar vs. unfamiliar')
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    save([files(use(f)).subj '_' files(use(f)).expt '_' files(use(f)).condition '_NatIm.mat'],'trialcyc','trialcycavg','fileidx','familiar','allfiles','-v7.3')
    
end