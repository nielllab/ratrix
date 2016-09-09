%% code from doGratingsNew
deconvplz = 0 %choose if you want deconvolution
fully = 1 %choose if you want full frame (260x260), else scales down by 4
% ptsdir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect'; %directory for points file
% ptsfile = {'G62BB6RT_SizeSelectPtsSaline.mat',...
%           'G62AA3TT_SizeSelectPtsSaline.mat',...
%           'G62BB8TT_SizeSelectPtsSaline.mat',...
%           'G62TX19LT_SizeSelectPtsSaline.mat',...
%           'G62TX210TT_SizeSelectPtsSaline.mat'}; %specific point files for animals
% ptsdir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Pre With Deconvolution';
% ptsfile = {'CALB25B5RT_SizeSelectPoints'}
areas = {'V1','P','LM','AL','RL','AM','PM'}; %list of all visual areas for points   

for f = 1:length(use)
%     load(fullfile(ptsdir,ptsfile{f}));
    load('C:\sizeSelect2sf8sz26min.mat')
    load('C:\mapoverlay.mat')
    imagerate=10;
    acqdurframes = imagerate*(isi+duration);
    if ~fully %scale down map overlay if not using full frame
        xpts = xpts/4;
        ypts = ypts/4;
    end
    useframes = acqdurframes/2:acqdurframes;
    base = 1:acqdurframes/2;
    psfilename = 'c:\temp.ps';
    if exist(psfilename,'file')==2;delete(psfilename);end
    figure
    set(gcf,'Name',[files(use(f)).subj ' ' files(use(f)).expt])

    for i = 1:2  %%%% load in topos for check
        if i==1
            load([pathname files(use(f)).topox],'map');
        elseif i==2
            load([pathname files(use(f)).topoy],'map');
        elseif i==3 && length(files(use(f)).topoyland)>0
            load([pathname files(use(f)).topoyland],'map');
        elseif i==4 &&length(files(use(f)).topoxland)>0
            load([pathname files(use(f)).topoxland],'map');
        end
        subplot(2,2,i);
        imshow(polarMap(shiftImageRotate(map{3},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz),90));
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
    end


    if ~isempty(files(use(f)).sizeselect)
        load ([pathname files(use(f)).sizeselect], 'dfof_bg','sp','stimRec','frameT')
        zoom = 260/size(dfof_bg,1);
        if ~exist('sp','var')
            sp =0;stimRec=[];
        end
        dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
        if ~fully %scale down image if you chose to
            dfof_bg = imresize(dfof_bg,0.25);
        end
        label = [files(use(f)).subj ' ' files(use(f)).expt];
    end

    %% code from analyzeGratingPatch
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

    imageT=(1:size(dfof_bg,3))/imagerate;
    img = imresize(double(dfof_bg),1,'method','box');

%     acqdurframes = (duration+isi)*imagerate; %%% length of each cycle in frames;
    nx=ceil(sqrt(acqdurframes+1)); %%% how many rows in figure subplot
    
    trials = length(sf); %in case movie stopped early
    % trials = floor(min(trials,size(dfof_bg,3)/(imagerate*(duration+isi)))-1);
    % xpos=xpos(1:trials); sf=sf(1:trials); tf=tf(1:trials); radius=radiusRange(radius); radius=radius(1:trials); %PRLP

    
    %%% mean amplitude map across cycle
    figure
    map=0;
    p=1:acqdurframes;p=circshift(p,acqdurframes/2-1,2);
    colormap(jet)
    for fr=1:acqdurframes
        cycavg(:,:,fr) = mean(img(:,:,(fr:acqdurframes:end)),3);
        subplot(nx,nx,p(fr))
        imagesc(squeeze(cycavg(:,:,fr)),[-0.001 0.01])
        axis off
        set(gca,'LooseInset',get(gca,'TightInset'))
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        map = map+squeeze(cycavg(:,:,fr))*exp(2*pi*sqrt(-1)*(0.5 +fr/acqdurframes));
    end

    %%% add timecourse
    subplot(nx,nx,fr+1)
    plot(circshift(squeeze(mean(mean(cycavg,2),1)),acqdurframes/2-1))
    axis off
    set(gca,'LooseInset',get(gca,'TightInset'))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end

    %%% calculate phase of cycle response
    %%% good for detectime framedrops or other problems
    tcourse = squeeze(mean(mean(img,2),1));

    fourier = tcourse'.*exp((1:length(tcourse))*2*pi*sqrt(-1)/(10*duration + 10*isi));
    figure(timingfig)
    subplot(2,2,4)
    plot((1:length(tcourse))/600,angle(conv(fourier,ones(1,600),'same')));
    ylim([-pi pi])
    ylabel('phase'); xlabel('mins')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end

    %deconvolution
    if deconvplz == 1
        %do deconvolution on the raw data
        img = shiftdim(img+0.2,2); %shift dimesions for decon lucy and add 0.2 to get away from 0
        tic
        deconvimg = deconvg6s(img,0.1); %deconvolve
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
    else
        deconvimg = img;
    end
    ncut = 2 %# of trials to cut due to deconvolution cutting off end
    trials=trials-ncut; %deconv cuts off last trial
    deconvimg = deconvimg(:,:,1:trials*acqdurframes);

    %%% separate responses by trials
    speedcut = 500;
    trialdata = zeros(size(deconvimg,1),size(deconvimg,2),trials);
    trialspeed = zeros(trials,1);
    trialcyc = zeros(size(deconvimg,1),size(deconvimg,2),acqdurframes+acqdurframes/2,trials);
    for tr=1:trials-1;
        t0 = round((tr-1)*acqdurframes);
        baseframes = base+t0; baseframes=baseframes(baseframes>0);
        trialdata(:,:,tr)=mean(deconvimg(:,:,useframes+t0),3) -mean(deconvimg(:,:,baseframes),3);
        try
            trialspeed(tr) = mean(sp(useframes+t0));
        catch
            trialspeed(tr)=500;
        end
    %     trialcourse(tr,:) = squeeze(mean(mean(deconvimg(:,:,t0+(1:20)),2),1));
        trialcyc(:,:,:,tr) = deconvimg(:,:,t0+(1:acqdurframes+acqdurframes/2));%each cycle is frames 6-26, stim comes on at frame 11
    end
    %frames 1-5 are baseline, 6-10 stim on
    sizeVals = [0 5 10 20 30 40 50 60];
    sf=sf(1:trials);contrasts=contrasts(1:trials);phase=phase(1:trials);radius=radius(1:trials);
    order=order(1:trials);tf=tf(1:trials);theta=theta(1:trials);xpos=xpos(1:trials);
    contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
    for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
    for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end
%     xrange = unique(xpos); sfrange=unique(sf); tfrange=unique(tf);
    running = zeros(1,trials); %pull out stationary vs. runnning (0 vs. 1)
    for i = 1:trials
        running(i) = trialspeed(i)>speedcut;
    end
    behavState = {'stationary','running'};
    
%     tuning=nan(size(trialdata,1),size(trialdata,2),length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    %%% separate out responses by stim parameter
%     cond = 0;
%     run = find(trialspeed>=speedcut);
%     sit = find(trialspeed<speedcut);
%     trialcycavg=nan(size(trialdata,1),size(trialdata,2),acqdurframes+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
%     trialcycavgRun=nan(size(trialdata,1),size(trialdata,2),acqdurframes+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
%     trialcycavgSit=nan(size(trialdata,1),size(trialdata,2),acqdurframes+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
%     for i = 1:length(xrange)
%         for j= 1:length(radiusRange)
%             for k = 1:length(sfrange)
%                 for l=1:length(tfrange)
%                     cond = cond+1;
%                     inds = find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l));
%                     trialcycavg(:,:,:,i,j,k,l) = squeeze(mean(trialcyc(:,:,:,inds),4));
% %                     avgtrialdata(:,:,cond) = squeeze(median(trialdata(:,:,inds),3));%  length(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))
%     %                 avgtrialcourse(i,j,k,l,:) = squeeze(median(trialcourse(inds,:),1));
%     %                 avgcondtrialcourse(cond,:) = avgtrialcourse(i,j,k,l,:);
%     %                 avgspeed(cond)=0;
%     %                 avgx(cond) = xrange(i); avgradius(cond)=radiusRange(j); avgsf(cond)=sfrange(k); avgtf(cond)=tfrange(l);
% %                     tuning(:,:,i,j,k,l) = avgtrialdata(:,:,cond);
%     %                 meanspd(i,j,k,l) = squeeze(mean(trialspeed(inds)>500));
% %                     trialcycavgRun(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,run)),4));
% %                     trialcycavgSit(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,sit)),4));
%                 end
%             end
%         end
%     end

    trialcycavg=nan(size(trialdata,1),size(trialdata,2),acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2);
    for i = 1:length(sfrange)
        for j = 1:length(phaserange)
            for k = 1:length(contrastRange)
                for l = 1:length(radiusRange)
                    for m = 1:2
                        inds = find(sf==sfrange(i)&phase==phaserange(j)&contrasts==contrastRange(k)&radius==l&running==(m-1));
                        trialcycavg(:,:,:,i,j,k,l,m) = squeeze(nanmean(trialcyc(:,:,:,inds),4));
                    end
                end
            end
        end
    end
        

    %%baseline subtraction code
    %get average map with no stimulus
%     minmap = zeros(size(deconvimg,1),size(deconvimg,2),2);
    mintrialcyc = zeros(size(deconvimg,1),size(deconvimg,2),acqdurframes+acqdurframes/2,2);
    for i = 1:2
%         minmap(:,:,i) = squeeze(mean(mean(tuning(:,:,i,1,:,:),5),6));
        mintrialcyc(:,:,:,i) = squeeze(nanmean(nanmean(nanmean(trialcycavg(:,:,:,:,:,:,1,i),4),5),6)); %min map for stationary and running
    end
    %subtract average map with no stimulus from every map in tuning and
    %trialcycavg
    for i = 1:length(sfrange)
        for j = 1:length(phaserange)
            for k = 1:length(contrastRange)
                for l = 1:length(radiusRange)
                    for m = 1:2
%                     tuning(:,:,i,j,k,l) = tuning(:,:,i,j,k,l)-minmap(:,:,i);
                        trialcycavg(:,:,:,i,j,k,l,m) = trialcycavg(:,:,:,i,j,k,l,m)-mintrialcyc(:,:,:,m);
                        for o = 1:size(trialcycavg,3)
                            trialcycavg(:,:,o,i,j,k,l,m) = trialcycavg(:,:,o,i,j,k,l,m)-nanmean(trialcycavg(:,:,1:acqdurframes/2,i,j,k,l,m),3); %subtract baseline
                        end
                    end
                end
            end
        end
    end
%     
    %subtract average map with no stimulus from trialcyc
    for tr=1:trials
        if running(tr)==0
            trialcyc(:,:,:,tr) = trialcyc(:,:,:,tr)-mintrialcyc(:,:,:,1);
        else
            trialcyc(:,:,:,tr) = trialcyc(:,:,:,tr)-mintrialcyc(:,:,:,2);
        end
    end

    %zero baseline for each trial
    for  i = 1:size(trialcyc,4)
        for fr=1:size(trialcyc,3)
            trialcyc(:,:,fr,i) = trialcyc(:,:,fr,i) - nanmean(trialcyc(:,:,1:acqdurframes/2,i),3);
        end
    end        
    
    %manual/loading point selection
    files(use(f)).subj
    [fname pname] = uigetfile('*.mat','points file');
    if fname~=0
        load(fullfile(pname, fname));
    else
        figure
        imagesc(squeeze(nanmean(nanmean(nanmean(trialcycavg(:,:,shift-1,:,:,4,4,:),4),5),8)))
        colormap(jet)
        axis square
        hold on
        plot(ypts,xpts,'k.','Markersize',2)
        [x y] = ginput(7);
        x=round(x); y=round(y);
        close(gcf)
        [fname pname] = uiputfile('*.mat','save points?');
        if fname~=0
            save(fullfile(pname,fname),'x','y');
        end
    end

    %plot selected points over each radius size
    figure
    for i = 1:length(radiusRange)
        subplot(2,length(radiusRange)/2,i)
        imagesc(squeeze(nanmean(nanmean(nanmean(trialcycavg(:,:,acqdurframes/2+1,:,:,:,i,1),4),5),6)),[-0.002 0.01])
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
    peaks = nan(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(areas));
    for i = 1:length(sfrange)
        for j = 1:length(phaserange)
            for k = 1:length(contrastRange)
                for l = 1:length(radiusRange)
                    for m = 1:2
                        for n = 1:length(areas)
                        peaks(i,j,k,l,m,n) = trialcycavg(y(n),x(n),acqdurframes/2+1,i,j,k,l,m);
                        end
                    end
                end
            end
        end
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
                plot(squeeze(nanmean(nanmean(peaks(:,:,l,:,1,m),2),1)),'ko')
                plot(squeeze(nanmean(nanmean(peaks(:,:,l,:,2,m),2),1)),'ro')
                set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
                xlabel('radius')
                ylabel('dfof')
                axis square
                axis([1 6 -0.05 0.5])
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
    shadedErrorBar([1:acqdurframes+acqdurframes/2]',squeeze(nanmean(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,:,1,1),4),5),6)),squeeze(nanstd(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,:,1,1),4),5),6))/sqrt(length(find(radius==1&running==0))),'k')
    shadedErrorBar([1:acqdurframes+acqdurframes/2]',squeeze(nanmean(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,:,1,2),4),5),6)),squeeze(nanstd(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,:,1,2),4),5),6))/sqrt(length(find(radius==1&running==1))),'r')
    axis([1 acqdurframes+acqdurframes/2 -0.1 0.5])
    legend('stationary','running') %not sure why colors aren't plotting correctly...
    title('No stim')
    subplot(1,2,2)
    hold on
    shadedErrorBar([1:acqdurframes+acqdurframes/2]',squeeze(nanmean(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,:,8,1),4),5),6)),squeeze(nanstd(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,:,8,1),4),5),6))/sqrt(length(find(radius==8&running==0))),'k')
    shadedErrorBar([1:acqdurframes+acqdurframes/2]',squeeze(nanmean(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,:,8,2),4),5),6)),squeeze(nanstd(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,:,8,2),4),5),6))/sqrt(length(find(radius==8&running==1))),'r')
    axis([1 acqdurframes+acqdurframes/2 -0.1 0.5])
    legend('stationary','running')
    title('Max Radius')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end    

    %plot activity maps for contrasts averaged over sf/phase with rows=radius
    %stopped here
    for i=1:length(contrastRange)
        for j=1:2
            figure
            cnt=1;
            for k=1:length(radiusRange)
                for l=acqdurframes/2:acqdurframes-1
                    subplot(length(radiusRange),length(acqdurframes/2:acqdurframes-1),cnt)
                        imagesc(squeeze(nanmean(nanmean(trialcycavg(:,:,l,:,:,i,k,j),4),5)),[0 0.15])
                        colormap(jet)
                        axis square
                        axis off
                        set(gca,'LooseInset',get(gca,'TightInset'))
                        hold on; plot(ypts,xpts,'w.','Markersize',2)
                        cnt=cnt+1;
                end
            end
            mtit(sprintf('%s %s %s contrast row=size',[files(use(f)).subj ' ' files(use(f)).expt],behavState{j},contrastlist{i}))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end
        end
    end
    
    %plot traces for manually selected V1 point
    xstim = [acqdurframes/2 acqdurframes/2];
    ystim = [-0.1 0.5];
    for i=1:length(contrastRange)
        figure
        cnt=1;
        for k=1:length(radiusRange)
            subplot(ceil(length(radiusRange)/4),ceil(length(radiusRange)/2),cnt)
            hold on
            shadedErrorBar([1:acqdurframes+acqdurframes/2]',squeeze(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,i,k,1),4),5)),...
                squeeze(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,i,k,1),4),5))/sqrt(length(find(radius==k&running==0))),'k')
            shadedErrorBar([1:acqdurframes+acqdurframes/2]',squeeze(nanmean(nanmean(trialcycavg(y(1),x(1),:,:,:,i,k,2),4),5)),...
                squeeze(nanstd(nanstd(trialcycavg(y(1),x(1),:,:,:,i,k,2),4),5))/sqrt(length(find(radius==k&running==1))),'r')
            plot(xstim,ystim,'g-')
            set(gca,'LooseInset',get(gca,'TightInset'))
            cnt=cnt+1;
            axis([1 acqdurframes+acqdurframes/2 -0.1 0.5])
            legend(sprintf('%sdeg stationary',sizes{k}),'running','Location','northeast')
        end
        mtit(sprintf('%s %s %scontrast',[files(use(f)).subj ' ' files(use(f)).expt],behavState{j},contrastlist{i}))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end
    
    
    %%%calculate spread of response within each area
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

    V1map = imread('V1map.tif'); %read filled-in image files to define areas
    Pmap = imread('Pmap.tif');
    LMmap = imread('LMmap.tif');
    ALmap = imread('ALmap.tif');
    RLmap = imread('RLmap.tif');
    AMmap = imread('AMmap.tif');
    PMmap = imread('PMmap.tif');

    areamaps = zeros(size(deconvimg,1),size(deconvimg,2),7);
    areamaps(:,:,1) = V1map(:,:,1); %put image files into a matrix
    areamaps(:,:,2) = Pmap(:,:,1);
    areamaps(:,:,3) = LMmap(:,:,1);
    areamaps(:,:,4) = ALmap(:,:,1);
    areamaps(:,:,5) = RLmap(:,:,1);
    areamaps(:,:,6) = AMmap(:,:,1);
    areamaps(:,:,7) = PMmap(:,:,1);

    areamaps = permute(areamaps,[2 1 3]);
    areamaps(areamaps==0) = 1;
    areamaps(areamaps==255) = 0; %all points within an area equal 1, everywhere else is 0

    for m = 1:length(areas)
        sigsize(m) = sqrt(sum(sum(areamaps(:,:,m)))/pi)/4; %sigma guess for gaussian fit of spread
    end

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

    %multiply binarized area matrices with average trial data to isolate each
    %area's response (using peak frame #12)    
    gauParams = nan(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),length(behavState),length(areas),5); %contains a1,x0,y0,sigmax,sigmay for spread fits
    halfMax = nan(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),length(behavState),length(areas)); %total # pixels above half the max amplitude, alternative spread measure
    areapeaks = halfMax; %automated peak finding
    sprintf('doing peak finding and gaussian fits');
    tic
    for m = 1:length(areas)
        minframe = squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(:,:,acqdurframes/2,:,:,:,1,:),4),5),6),8));
        minframe = minframe(:);
        spreadthresh(:,m) = nanmean(minframe) + 2*std(minframe); %calculate threshold for gaussian
    end
    for i = 1:length(sfrange)
        for j = 1:length(phaserange)
            for k = 1:length(contrastRange)
                for l = 1:length(radiusRange)
                    for m = 1:length(areas)
                        for n = 1:2
                            spreadframe = trialcycavg(:,:,acqdurframes/2,i,j,k,l,n).*areamaps(:,:,m);
                            if isnan(nanmean(nanmean(spreadframe)))
                                    gauParams(i,j,k,l,n,m,1) = NaN;
                                    gauParams(i,j,k,l,n,m,2) = NaN;
                                    gauParams(i,j,k,l,n,m,3) = NaN;
                                    gauParams(i,j,k,l,n,m,4) = NaN;
                                    gauParams(i,j,k,l,n,m,5) = NaN;
                                    halfMax(i,j,k,l,n,m) = NaN;
                                    areapeaks(i,j,k,l,n,m) = NaN;
                            else
                                spreadframe = spreadframe - spreadthresh(:,m);
                                spreadframe(spreadframe<0)=0;
                                halfMax(i,j,k,l,n,m) = length(find(spreadframe>=(max(max(spreadframe))/2))); %# pixels above half max
                                %stopped here, where is imgGauss??
                                sfit = imgGauss(spreadframe,x,y,sigsize,m); %gaussian parameters
                                if sfit.a1<0.01 %one percent for the bottom threshold
                                    gauParams(i,j,k,l,n,m,:) = 0; %if below threshold, no "response"
                                else
                                    gauParams(i,j,k,l,n,m,1) = sfit.a1;
                                    gauParams(i,j,k,l,n,m,2) = sfit.x0;
                                    gauParams(i,j,k,l,n,m,3) = sfit.y0;
                                    gauParams(i,j,k,l,n,m,4) = sfit.sigmax;
                                    gauParams(i,j,k,l,n,m,5) = sfit.sigmay;
                                end

                                peakmap = trialcycavg(:,:,acqdurframes/2,i,j,k,l,n);
                                peakfilter = fspecial('gaussian',12,3);
                                peakmap = imfilter(peakmap,peakfilter);
                                maxval = max(max(peakmap.*areamaps(:,:,m)));
                                if maxval<=0
                                    areapeaks(i,j,k,l,m,n) = 0;
                                else
                                    maxind = find(peakmap==maxval);
                                    [I,J]=ind2sub([size(deconvimg,1) size(deconvimg,2)],maxind);
                                    areapeaks(i,j,k,l,n,m) = trialcycavg(I,J,acqdurframes/2,i,j,k,l,n); %individual area peaks found by automation
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    toc

    
    cnt=0;
    figure
    for i = 1:length(sfrange)
        for j = 1:length(tfrange)
                cnt = cnt+1;
                subplot(2,2,cnt)
                hold on
                plot(1:length(radiusRange),areapeaks(1,:,i,j,1),'ko')
                set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
                xlabel('radius')
                ylabel('dfof')
                axis square
                axis([1 6 -0.05 0.5])
                legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
        end
    end
    mtit('Auto-Found Peaks')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end

    cnt=0;
    figure
    for i = 1:length(sfrange)
        for j = 1:length(tfrange)
                cnt = cnt+1;
                subplot(2,2,cnt)
                hold on
                plot(1:length(radiusRange),halfMax(1,:,i,j,1),'ko')
                set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
                xlabel('radius')
                ylabel('# pixels')
                axis square
                axis([1 6 0 5000])
                legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
        end
    end
    mtit('Area above Half Max')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end

    cnt=0;
    figure
    for i = 1:length(sfrange)
        for j = 1:length(tfrange)
                cnt = cnt+1;
                subplot(2,2,cnt)
                hold on
                plot(1:length(radiusRange),(gauParams(1,:,i,j,1,4)+gauParams(1,:,i,j,1,5))/2,'ko')
                set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
                xlabel('radius')
                ylabel('Sigma')
                axis square
                axis([1 6 0 30])
                legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
        end
    end
    mtit('Sigma from Gaussian Fit')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
    
    
    
    
    
    
    % 
    % %%% plot sf and tf responses
    % figure %averages across the two x positiongs
    % for i = 1:length(sfrange)
    %     for j=1:length(tfrange)
    %         subplot(length(tfrange),length(sfrange),length(sfrange)*(j-1)+i)
    %         imagesc(squeeze(mean(mean(tuning(:,:,:,:,i,j),4),3)),[ -0.005 0.05]); colormap jet;
    %         title(sprintf('%0.2fcpd %0.0fhz',sfrange(i),tfrange(j)))
    %         axis off; axis equal
    %         hold on; plot(ypts,xpts,'w.','Markersize',2)
    %         set(gca,'LooseInset',get(gca,'TightInset'))
    %     end
    % end
    % if exist('psfilename','var')
    %     set(gcf, 'PaperPositionMode', 'auto');
    %     print('-dpsc',psfilename,'-append');
    % end
    % 
    % 
    % for i = 1:length(xrange)
    %     figure %one plot for each x position
    %     for j = 1:length(radiusRange)
    %         subplot(3,3,j)
    %         imagesc(squeeze(mean(mean(tuning(:,:,i,j,:,:),5),6)),[ -0.02 0.15]); colormap jet;
    %         title(sprintf('%0.0frad',radiusRange(j)))
    %         axis off; axis equal
    %         hold on; plot(ypts,xpts,'w.','Markersize',2)
    %         set(gca,'LooseInset',get(gca,'TightInset'))
    %     end
    %     if exist('psfilename','var')
    %         set(gcf, 'PaperPositionMode', 'auto');
    %         print('-dpsc',psfilename,'-append');
    %     end
    % end
    % 
    % 
    % %% get sf and tf tuning curves across sizes
    % figure
    % for i = 1:length(xrange)
    %     subplot(1,length(xrange),i)
    %     hold on
    %     plot(1:size(tuning,4),squeeze(tuning(x(i),y(i),i,:,1,1)),'y')
    %     plot(1:size(tuning,4),squeeze(tuning(x(i),y(i),i,:,2,1)),'c')
    %     plot(1:size(tuning,4),squeeze(tuning(x(i),y(i),i,:,1,2)),'r')
    %     plot(1:size(tuning,4),squeeze(tuning(x(i),y(i),i,:,2,2)),'b')
    %     legend('0.04cpd 0Hz','0.16cpd 0Hz','0.04cpd 2Hz','0.16cpd 2Hz','location','northwest')
    %     set(gca,'xtick',1:6,'xticklabel',radiusRange)
    %     axis([1 6 0 0.25])
    % end
    % if exist('psfilename','var')
    %     set(gcf, 'PaperPositionMode', 'auto');
    %     print('-dpsc',psfilename,'-append');
    % end
    % 
    % %%plot cycle averages for the different radii at the 2 x positions
    % figure
    % for i = 1:length(xrange)
    %     subplot(1,length(xrange),i)
    %     hold on
    %     for j = 1:length(radiusRange)
    %         plot(squeeze(mean(mean(trialcycavg(x(i),y(i),:,i,j,:,:),6),7)))
    %     end
    % end
    % legend('0','1','2','4','8','1000')
    % if exist('psfilename','var')
    %     set(gcf, 'PaperPositionMode', 'auto');
    %     print('-dpsc',psfilename,'-append');
    % end
    % 
    % %%plot cycle averages for the different radii at the 2 x positions run vs.
    % %%sit
    % figure
    % for i = 1:length(xrange)
    %     subplot(2,length(xrange),i)
    %     hold on
    %     for j = 1:length(radiusRange)
    %         plot(squeeze(mean(mean(trialcycavgRun(x(i),y(i),:,i,j,:,:),6),7)))
    %     end
    %     axis([1 acqdurframes -0.1 0.25])
    %     title('run')
    %     hold off
    %     subplot(2,length(xrange),i+length(xrange))
    %     hold on
    %     for j = 1:length(radiusRange)
    %         plot(squeeze(mean(mean(trialcycavgSit(x(i),y(i),:,i,j,:,:),6),7)))
    %     end
    %     axis([1 acqdurframes -0.1 0.25])
    %     title('sit')
    %     hold off
    % end
    % legend('0','1','2','4','8','1000')
    % if exist('psfilename','var')
    %     set(gcf, 'PaperPositionMode', 'auto');
    %     print('-dpsc',psfilename,'-append');
    % end

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
    p = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data';
        filename = fileparts(fileparts(files(use(f)).sizeselect));
        filename = sprintf('%s_SizeSelectAnalysis.mat',filename);

    if f~=0
    %     save(fullfile(p,f),'allsubj','sessiondata','shiftData','fit','mnfit','cycavg','mv');
        save(fullfile(p,filename),'trialcycavg','peaks','areapeaks','gauParams','mv','halfMax','-v7.3');
    end

    try
        dos(['ps2pdf ' 'c:\temp.ps "' fullfile(p,sprintf('%s.pdf',filename)) '"'] )

    catch
        display('couldnt generate pdf');
    end

    delete(psfilename);
end