%% code from doGratingsNew
deconvplz = 1 %choose if you want deconvolution
fully = 1 %choose if you want full frame (260x260), else scales down by 4
% ptsdir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Trained Pre'; %directory for points file
% ptsfile = {'G62TX2.6LT_SizeSelectPoints.mat',...
%           'G62TX2.6RT_SizeSelectPoints.mat',...
%           'G62BB2RT_SizeSelectPoints.mat',...
%           'G62T6LT_SizeSelectPoints.mat',...
%           'G62W7LN_SizeSelectPoints.mat',...
%           'G62W7TT_SizeSelectPoints.mat'}; %specific point files for animals
ptsdir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Pre With Deconvolution';
ptsfile = {'CALB25B5RT_SizeSelectPoints'}
areas = {'V1','P','LM','AL','RL','AM','PM'}; %list of all visual areas for points   

for f = 1:length(use)
    load(fullfile(ptsdir,ptsfile{f}));
    load('C:\sizeSelect2sf5sz14min.mat')
    load('C:\mapoverlay.mat')
    if ~fully %scale down map overlay if not using full frame
        xpts = xpts/4;
        ypts = ypts/4;
    end
    useframes = 11:12;
    base = 9:10;
    psfilename = 'C:\tempPS.ps';
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

    imagerate=10;

    imageT=(1:size(dfof_bg,3))/imagerate;
    img = imresize(double(dfof_bg),1,'method','box');

    trials = length(sf); %there are only 384 trials but should be 420 based on 8400 frames so clipping data
    % trials = floor(min(trials,size(dfof_bg,3)/(imagerate*(duration+isi)))-1);
    % xpos=xpos(1:trials); sf=sf(1:trials); tf=tf(1:trials); radius=radiusRange(radius); radius=radius(1:trials); %PRLP

    acqdurframes = (duration+isi)*imagerate; %%% length of each cycle in frames;
    nx=ceil(sqrt(acqdurframes+1)); %%% how many rows in figure subplot

    %%% mean amplitude map across cycle
    figure
    map=0;
    for fr=1:acqdurframes
        cycavg(:,:,fr) = mean(img(:,:,(fr+trials*acqdurframes/2):acqdurframes:end),3);
        subplot(nx,nx,fr)
        imagesc(squeeze(cycavg(:,:,fr)),[-0.02 0.02])
        axis off
        set(gca,'LooseInset',get(gca,'TightInset'))
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        map = map+squeeze(cycavg(:,:,fr))*exp(2*pi*sqrt(-1)*(0.5 +fr/acqdurframes));
    end

    %%% add timecourse
    subplot(nx,nx,fr+1)
    plot(circshift(squeeze(mean(mean(cycavg,2),1)),10))
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

    shift = (duration+isi)*imagerate;
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

    deconvimg = deconvimg(:,:,1:trials*shift);

    %%% separate responses by trials
    speedcut = 500;
    trialdata = zeros(size(deconvimg,1),size(deconvimg,2),trials);
    trialspeed = zeros(trials,1);
    trialcyc = zeros(size(deconvimg,1),size(deconvimg,2),shift+10,trials);
    for tr=1:trials-1;
        t0 = round((tr-1)*shift);
        baseframes = base+t0; baseframes=baseframes(baseframes>0);
        trialdata(:,:,tr)=mean(deconvimg(:,:,useframes+t0),3) -mean(deconvimg(:,:,baseframes),3);
        try
            trialspeed(tr) = mean(sp(useframes+t0));
        catch
            trialspeed(tr)=500;
        end
    %     trialcourse(tr,:) = squeeze(mean(mean(deconvimg(:,:,t0+(1:20)),2),1));
        trialcyc(:,:,:,tr) = deconvimg(:,:,t0+(1:30));%each cycle is frames 6-26, stim comes on at frame 11
    end
    %frames 1-10 are baseline, 11-20 stim on
    
    xrange = unique(xpos); sfrange=unique(sf); tfrange=unique(tf);
    
%     tuning=nan(size(trialdata,1),size(trialdata,2),length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    %%% separate out responses by stim parameter
    cond = 0;
    run = find(trialspeed>=speedcut);
    sit = find(trialspeed<speedcut);
    trialcycavg=nan(size(trialdata,1),size(trialdata,2),shift+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
%     trialcycavgRun=nan(size(trialdata,1),size(trialdata,2),shift+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
%     trialcycavgSit=nan(size(trialdata,1),size(trialdata,2),shift+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    for i = 1:length(xrange)
        for j= 1:length(radiusRange)
            for k = 1:length(sfrange)
                for l=1:length(tfrange)
                    cond = cond+1;
                    inds = find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l));
                    trialcycavg(:,:,:,i,j,k,l) = squeeze(mean(trialcyc(:,:,:,inds),4));
%                     avgtrialdata(:,:,cond) = squeeze(median(trialdata(:,:,inds),3));%  length(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))
    %                 avgtrialcourse(i,j,k,l,:) = squeeze(median(trialcourse(inds,:),1));
    %                 avgcondtrialcourse(cond,:) = avgtrialcourse(i,j,k,l,:);
    %                 avgspeed(cond)=0;
    %                 avgx(cond) = xrange(i); avgradius(cond)=radiusRange(j); avgsf(cond)=sfrange(k); avgtf(cond)=tfrange(l);
%                     tuning(:,:,i,j,k,l) = avgtrialdata(:,:,cond);
    %                 meanspd(i,j,k,l) = squeeze(mean(trialspeed(inds)>500));
%                     trialcycavgRun(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,run)),4));
%                     trialcycavgSit(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,sit)),4));
                end
            end
        end
    end

    %%baseline subtraction code
    %get average map with no stimulus
    minmap = zeros(size(deconvimg,1),size(deconvimg,2),length(xrange));
    mintrialcyc = zeros(size(deconvimg,1),size(deconvimg,2),shift+10,length(xrange));
    for i = 1:length(xrange)
%         minmap(:,:,i) = squeeze(mean(mean(tuning(:,:,i,1,:,:),5),6));
        mintrialcyc(:,:,:,i) = squeeze(mean(mean(trialcycavg(:,:,:,i,1,:,:),6),7));
    end
    %subtract average map with no stimulus from every map in tuning and
    %trialcycavg
    for i = 1:length(xrange)
        for j = 1:length(radiusRange)
            for k = 1:length(sfrange)
                for l = 1:length(tfrange)
%                     tuning(:,:,i,j,k,l) = tuning(:,:,i,j,k,l)-minmap(:,:,i);
                    trialcycavg(:,:,:,i,j,k,l) = trialcycavg(:,:,:,i,j,k,l)-mintrialcyc(:,:,:,i);
                    for m = 1:size(trialcycavg,3)
                        trialcycavg(:,:,m,i,j,k,l) = trialcycavg(:,:,m,i,j,k,l)-mean(trialcycavg(:,:,1:9,i,j,k,l),3); %subtract baseline
                    end
                end
            end
        end
    end
%     
    %subtract average map with no stimulus from trialcyc
    for tr=1:trials
        if xpos==xrange(1)
            trialcyc(:,:,:,tr) = trialcyc(:,:,:,tr)-mintrialcyc(:,:,:,1);
        else
            trialcyc(:,:,:,tr) = trialcyc(:,:,:,tr)-mintrialcyc(:,:,:,2);
        end
    end

    %zero baseline for each trial
    for  i = 1:size(trialcyc,4)
        for fr=1:size(trialcyc,3)
            trialcyc(:,:,fr,i) = trialcyc(:,:,fr,i) - mean(trialcyc(:,:,1:9,i),3);
        end
    end        
    
%     %manual/loading point selection
%     files(use(f)).subj
%     [fname pname] = uigetfile('*.mat','points file');
%     if fname~=0
%         load(fullfile(pname, fname));
%     else
%         figure
%         imagesc(squeeze(mean(trialcyc(:,:,12,find(xpos==xrange(1)&radius==3)),4)),[-0.05 0.05])
%         colormap(jet)
%         axis square
%         hold on
%         plot(ypts,xpts,'k.','Markersize',2)
%         [x y] = ginput(7);
%         x=round(x); y=round(y);
%         close(gcf)
%         [fname pname] = uiputfile('*.mat','save points?');
%         if fname~=0
%             save(fullfile(pname,fname),'x','y');
%         end
%     end

    %plot selected points over each radius size
    figure
    for i = 1:length(radiusRange)
        subplot(2,3,i)
        imagesc(squeeze(mean(trialcyc(:,:,12,find(xpos==xrange(1)&radius==i)),4)),[-0.05 0.1])
        colormap(jet)
        axis square
        hold on
        plot(ypts,xpts,'w.','Markersize',2)
        plot(x,y,'m+','Markersize',5)
        axis off
        set(gca,'LooseInset',get(gca,'TightInset'))
        legend(sprintf('%0.0f rad',radiusRange(i)),'Location','northoutside')
    end
    if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
    end
    
    %%get peak response for all conditions using manually selected points
    peaks = nan(length(xrange),length(radiusRange),length(sfrange),length(tfrange),length(areas));
    for i = 1:length(xrange)
        for j = 1:length(radiusRange)
            for k = 1:length(sfrange)
                for l = 1:length(tfrange)
                    for m = 1:length(areas)
                        peaks(i,j,k,l,m) = trialcycavg(y(m),x(m),12,i,j,k,l);
                    end
                end
            end
        end
    end
    
    %plot peak values for the different visual areas
    for m = 1:length(areas)
        cnt=0;
        figure
        for k = 1:length(sfrange)
            for l = 1:length(tfrange)
                cnt = cnt+1;
                subplot(2,2,cnt)
                plot(peaks(1,:,k,l,m),'ko')
                set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
                xlabel('radius')
                ylabel('dfof')
                axis square
                axis([1 6 -0.05 0.5])
                legend(sprintf('%0.2fsf %0.0ftf',sfrange(k),tfrange(l)),'Location','northoutside')
            end
        end
        mtit(sprintf('%s',areas{m}))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end   
    end


    %plot no stim and one stim condition to check
    figure
    subplot(1,2,1)
    shadedErrorBar([1:30]',squeeze(mean(trialcyc(y(1),x(1),:,find(radius==1)),4)),squeeze(std(trialcyc(y(1),x(1),:,find(radius==1)),[],4))/sqrt(length(find(radius==1))))
    axis([1 30 -0.1 0.5])
        title('No stim')
    subplot(1,2,2)
    shadedErrorBar([1:30]',squeeze(mean(trialcyc(y(1),x(1),:,find(radius==6)),4)),squeeze(std(trialcyc(y(1),x(1),:,find(radius==6)),[],4))/sqrt(length(find(radius==6))))
    axis([1 30 -0.1 0.5])
    title('Max Radius')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end    

    %plot activity maps for the different tf/sf combinations, with rows=radius
    for i=1:length(sfrange)
        for j=1:length(tfrange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                for l=10:19
                    subplot(6,10,cnt)
                        imagesc(trialcycavg(:,:,l,1,k,i,j),[0 0.15])
                        colormap(jet)
                        axis square
                        axis off
                        set(gca,'LooseInset',get(gca,'TightInset'))
                        hold on; plot(ypts,xpts,'w.','Markersize',2)
                        cnt=cnt+1;
                end
            end
            mtit(sprintf('%s %0.2fsf %0.0ftf row=size',[files(use(f)).subj ' ' files(use(f)).expt],sfrange(i),tfrange(j)))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end
        end
    end
    
    %plot traces for manually selected V1 point
    xstim = [10 10];
    ystim = [-0.1 0.5];
    for i=1:length(sfrange)
        for j=1:length(tfrange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                subplot(2,3,cnt)
                hold on
                shadedErrorBar([1:30]',squeeze(mean(trialcyc(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4)),...
                    squeeze(std(trialcyc(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),[],4))/...
                    sqrt(length(find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j)))))
                plot(xstim,ystim,'r-')
                set(gca,'LooseInset',get(gca,'TightInset'))
                cnt=cnt+1;
                axis([1 30 -0.1 0.5])
                legend(sprintf('%0.0frad',radiusRange(k)),'Location','south')
            end
            mtit(sprintf('%s %0.2fsf %0.0ftf',[files(use(f)).subj ' ' files(use(f)).expt],sfrange(i),tfrange(j)))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end
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

    % figure %plot individual area boundaries for confirmation
    % colormap(gray)
    % for i = 1:size(areamaps,3)
    %     subplot(2,4,i)
    %     imagesc(areamaps(:,:,i),[0 1])
    %     hold on; plot(ypts,xpts,'r.','Markersize',1)
    %     axis off;axis square;
    %     title(sprintf('%s',areas{i}))
    % end
    % mtit('Area Measurement Zones')

    %%multiply binarized area matrices with average trial data to isolate each
    %%area's response (using peak frame #12)
    gauParams = nan(size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),length(areas),5); %contains a1,x0,y0,sigmax,sigmay for spread fits
    halfMax = zeros(size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),length(areas)); %total # pixels above half the max amplitude, alternative spread measure
    areapeaks = zeros(size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),length(areas)); %automated peak finding
    sprintf('doing peak finding and gaussian fits');
    tic
    for m = 1:length(areas)
        minframe = squeeze(mean(mean(mean(trialcycavg(:,:,12,:,1,:,:),4),6),7));
        minframe = minframe(:);
        spreadthresh(:,m) = mean(minframe) + 2*std(minframe); %calculate threshold for gaussian
    end
    for i = 1:length(xrange)
        for j = 1:length(radiusRange)
            for k = 1:length(sfrange)
                for l = 1:length(tfrange)
                    for m = 1:length(areas)
                        spreadframe = trialcycavg(:,:,12,i,j,k,l).*areamaps(:,:,m);
                        spreadframe = spreadframe - spreadthresh(:,m);
                        spreadframe(spreadframe<0)=0;
                        halfMax(i,j,k,l,m) = length(find(spreadframe>=(max(max(spreadframe))/2))); %# pixels above half max
                        sfit = imgGauss(spreadframe,x,y,sigsize,m); %gaussian parameters
                        if sfit.a1<0.01 %one percent for the bottom threshold
                            gauParams(i,j,k,l,m,:) = 0; %if below threshold, no "response"
                        else
                            gauParams(i,j,k,l,m,1) = sfit.a1;
                            gauParams(i,j,k,l,m,2) = sfit.x0;
                            gauParams(i,j,k,l,m,3) = sfit.y0;
                            gauParams(i,j,k,l,m,4) = sfit.sigmax;
                            gauParams(i,j,k,l,m,5) = sfit.sigmay;
                        end

                        peakmap = trialcycavg(:,:,12,i,j,k,l);
                        peakfilter = fspecial('gaussian',12,3);
                        peakmap = imfilter(peakmap,peakfilter);
                        maxval = max(max(peakmap.*areamaps(:,:,m)));
                        if maxval<=0
                            areapeaks(i,j,k,l,m) = 0;
                        else
                            maxind = find(peakmap==maxval);
                            [I,J]=ind2sub([size(deconvimg,1) size(deconvimg,2)],maxind);
                            areapeaks(i,j,k,l,m) = trialcycavg(I,J,12,i,j,k,l); %individual area peaks found by automation
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
    %     axis([1 shift -0.1 0.25])
    %     title('run')
    %     hold off
    %     subplot(2,length(xrange),i+length(xrange))
    %     hold on
    %     for j = 1:length(radiusRange)
    %         plot(squeeze(mean(mean(trialcycavgSit(x(i),y(i),:,i,j,:,:),6),7)))
    %     end
    %     axis([1 shift -0.1 0.25])
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
    bar([mean(trialspeed(run)) mean(trialspeed(sit))])
    set(gca,'xticklabel',{'run','sit'})
    ylabel('speed')
    ylim([0 3000])
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
    %%
    p = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect';
        filename = fileparts(fileparts(files(use(f)).sizeselect));
        filename = sprintf('%s_SizeSelectAnalysis.mat',filename);

    if f~=0
    %     save(fullfile(p,f),'allsubj','sessiondata','shiftData','fit','mnfit','cycavg','mv');
        save(fullfile(p,filename),'trialcycavg','peaks','areapeaks','gauParams','mv','halfMax','xrange','radiusRange','sfrange','tfrange');
    end

    % [f p] = uiputfile('*.pdf','save pdf');
    if f~=0
        try
        ps2pdf('psfile', psfilename, 'pdffile', fullfile(p,sprintf('%s.pdf',filename)));
    catch
        display('couldnt generate pdf');
        end
    end
    delete(psfilename);
end