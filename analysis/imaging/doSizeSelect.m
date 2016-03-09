%% code from doGratingsNew
deconvplz = 1; %choose if you want deconvolution
% pointsfile = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\GroupSizeSelectPoints';
for f = 1:length(use)
    load('C:\sizeSelect2sf5sz14min.mat')
    load('C:\mapoverlay.mat')
    xpts = xpts/4;
    ypts = ypts/4;
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
        dfof_bg = imresize(dfof_bg,0.25);
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

    trials = length(sf); %why are there only 384 trials when there should be 420 based on 8400 frames?
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
        plot(squeeze(img(25,25,:)))
        plot(squeeze(deconvimg(25,25,:)),'g')
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
    
    tuning=nan(size(trialdata,1),size(trialdata,2),length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    %%% separate out responses by stim parameter
    cond = 0;
    run = find(trialspeed>=speedcut);
    sit = find(trialspeed<speedcut);
    trialcycavg=nan(size(trialdata,1),size(trialdata,2),shift+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    trialcycavgRun=nan(size(trialdata,1),size(trialdata,2),shift+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    trialcycavgSit=nan(size(trialdata,1),size(trialdata,2),shift+10,length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    for i = 1:length(xrange)
        for j= 1:length(radiusRange)
            for k = 1:length(sfrange)
                for l=1:length(tfrange)
                    cond = cond+1;
                    inds = find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l));
                    avgtrialdata(:,:,cond) = squeeze(median(trialdata(:,:,inds),3));%  length(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))
    %                 avgtrialcourse(i,j,k,l,:) = squeeze(median(trialcourse(inds,:),1));
    %                 avgcondtrialcourse(cond,:) = avgtrialcourse(i,j,k,l,:);
    %                 avgspeed(cond)=0;
    %                 avgx(cond) = xrange(i); avgradius(cond)=radiusRange(j); avgsf(cond)=sfrange(k); avgtf(cond)=tfrange(l);
                    tuning(:,:,i,j,k,l) = avgtrialdata(:,:,cond);
    %                 meanspd(i,j,k,l) = squeeze(mean(trialspeed(inds)>500));
                    trialcycavg(:,:,:,i,j,k,l) = squeeze(mean(trialcyc(:,:,:,inds),4));
                    trialcycavgRun(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,run)),4));
                    trialcycavgSit(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,sit)),4));
                end
            end
        end
    end

    %%baseline subtraction code
    %get average map with no stimulus
    minmap = zeros(size(deconvimg,1),size(deconvimg,2),length(xrange));
    mintrialcyc = zeros(size(deconvimg,1),size(deconvimg,2),shift+10,length(xrange));
    for i = 1:length(xrange)
        minmap(:,:,i) = squeeze(mean(mean(tuning(:,:,i,1,:,:),5),6));
        mintrialcyc(:,:,:,i) = squeeze(mean(mean(trialcycavg(:,:,:,i,1,:,:),6),7));
    end
    %subtract average map with no stimulus from every map in tuning and
    %trialcycavg
    for i = 1:length(xrange)
        for j = 1:length(radiusRange)
            for k = 1:length(sfrange)
                for l = 1:length(tfrange)
                    tuning(:,:,i,j,k,l) = tuning(:,:,i,j,k,l)-minmap(:,:,i);
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
    
%     load(pointsfile); 
    files(use(f)).subj
    [fname pname] = uigetfile('*.mat','points file');
    if fname~=0
        load(fullfile(pname, fname));
    else
        figure
        imagesc(squeeze(mean(trialcyc(:,:,12,find(xpos==xrange(1)&radius==2)),4)),[-0.05 0.05])
        colormap(jet)
        axis square
        hold on
        plot(ypts,xpts,'w.','Markersize',2)
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
    
        %%get peak response - baseline for all conditions
    peaks = nan(length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    for i = 1:length(xrange)
        for j = 1:length(radiusRange)
            for k = 1:length(sfrange)
                for l = 1:length(tfrange)
                    peaks(i,j,k,l) = mean(trialcyc(y(1),x(1),12,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);
                end
            end
        end
    end
    
    cnt=0;
    figure
    for k = 1:length(sfrange)
        for l = 1:length(tfrange)
            cnt = cnt+1;
            subplot(2,2,cnt)
            plot(peaks(1,:,k,l),'ko')
            set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
            xlabel('radius')
            ylabel('dfof')
            axis square
            axis([1 6 -0.05 0.5])
            legend(sprintf('%0.2fsf %0.0ftf',sfrange(k),tfrange(l)),'Location','northoutside')
        end
    end
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
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

    xstim = [11 11];
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
%%make a map for each area that has ones for values to keep and zeros for
%%values to ignore
a = ones(65,65);
for i = 1:length(xpts)
    a(round(ypts(i)),round(xpts(i))) = 0;
end

% figure
% imagesc(a,[0 1])
% colormap(gray)

imwrite(a,'map.tif')

V1map = imread('V1map.tif');
Pmap = imread('Pmap.tif');
LMmap = imread('LMmap.tif');
ALmap = imread('ALmap.tif');
RLmap = imread('RLmap.tif');
AMmap = imread('AMmap.tif');
PMmap = imread('PMmap.tif');

areamaps = zeros(65,65,7);
areamaps(:,:,1) = V1map(:,:,1);
areamaps(:,:,2) = Pmap(:,:,1);
areamaps(:,:,3) = LMmap(:,:,1);
areamaps(:,:,4) = ALmap(:,:,1);
areamaps(:,:,5) = RLmap(:,:,1);
areamaps(:,:,6) = AMmap(:,:,1);
areamaps(:,:,7) = PMmap(:,:,1);

areamaps = permute(areamaps,[2 1 3]);
areamaps(areamaps==0) = 1;
areamaps(areamaps==255) = 0;

% figure %plot individual area boundaries
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
%%area's response (using peak frame #6)
areas = {'V1','P','LM','AL','RL','AM','PM'};
activezone = zeros(size(trialcycavg,1),size(trialcycavg,2),length(areas),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7));
gauSigma = zeros(size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),length(areas),2);
halfMax = zeros(size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),length(areas));
for i = 1:length(xrange)
    for j = 1:length(radiusRange)
        for k = 1:length(sfrange)
            for l = 1:length(tfrange)
                for m = 1:length(areas)
                    findminframe = trialcycavg(:,:,6,i,j,k,l).*areamaps(:,:,m);
                    halfMax(i,j,k,l,m) = length(find(findminframe>=(max(max(findminframe))/2))); %# pixels above half max
                    minframe = min(findminframe(findminframe~=0))*areamaps(:,:,m);
                    findminframe = findminframe - minframe; %subtract min value
                    activezone(:,:,m,i,j,k,l) = findminframe;
                    [gauSigma(i,j,k,l,m,1) gauSigma(i,j,k,l,m,2)] = imgGauss(findminframe);
                end
            end
        end
    end
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
        save(fullfile(p,filename),'trialcycavg','peaks','mv','gauSigma','halfMax','xrange','radiusRange','sfrange','tfrange');
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