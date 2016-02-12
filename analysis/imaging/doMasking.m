deconvplz = 1 %do you want to deconvolve the image data?
pointsfile = '\\langevin\backup\widefield\DOI_experiments\Matlab Widefield Analysis\SalinePoints.mat'

%% code from doGratingsNew
for f = 1:length(use)
    clear img deconvimg trialcyc trials xpos sf lag dOri sfcombo
    load('C:\metamask2sf2theta4soa15min');
    load('C:\mapoverlay.mat')
    xpts = xpts/4;
    ypts = ypts/4;
    useframes = 3;
    base = 1;
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


    if ~isempty(files(use(f)).masking)
        load ([pathname files(use(f)).masking], 'dfof_bg','sp','stimRec','frameT')
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

    imagerate=10; isi=0;

    imageT=(1:size(dfof_bg,3))/imagerate;
    img = imresize(double(dfof_bg),1,'method','box');
 
    trials = length(sf);
    % trials = floor(min(trials,size(dfof_bg,3)/(imagerate*(duration+isi)))-1);

    acqdurframes = (duration+isi)*imagerate; %%% length of each cycle in frames;
    nx=ceil(sqrt(acqdurframes+1)); %%% how many rows in figure subplot

    %%% mean amplitude map across cycle
    figure
    map=0;
    for a=1:acqdurframes
        cycavg(:,:,a) = mean(img(:,:,(a+trials*acqdurframes/2):acqdurframes:end),3);
        subplot(nx,nx,a)
        imagesc(squeeze(cycavg(:,:,a)),[-0.02 0.02])
        axis off
        set(gca,'LooseInset',get(gca,'TightInset'))
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        map = map+squeeze(cycavg(:,:,a))*exp(2*pi*sqrt(-1)*(0.5 +a/acqdurframes));
    end

    %%% add timecourse
    subplot(nx,nx,a+1)
    plot(squeeze(mean(mean(cycavg,2),1)))
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

%     %subtract off minimum value for every pixel
%     minimg = min(img,[],3);
%     for i = 1:size(img,3)
%         img(:,:,i) = img(:,:,i)-minimg;
%     end
    
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
    deconvimg = deconvimg(:,:,11:end); %remove first trial
    img = img(:,:,11:end); %remove first trial since it has no baseline
    %check deconvolution success on one pixel
    figure
    hold on
    plot(squeeze(img(25,25,:)))
    plot(squeeze(deconvimg(25,25,:)),'g')
    hold off
else
    img = img(:,:,11:end); %remove first trial since it has no baseline
    deconvimg = img;
end
    trials = trials-1; %remove first trial
       
    %%% separate responses by trials
    speedcut = 500;
    trialdata = zeros(size(deconvimg,1),size(deconvimg,2),trials);
    trialspeed = zeros(trials,1);
    shift = (duration+isi)*imagerate;
    trialcourse = zeros(trials,shift);
    trialcyc = zeros(size(deconvimg,1),size(deconvimg,2),shift,trials);
    for tr=1:trials;
        t0 = round((tr-1)*shift);
        baseframes = base+t0; baseframes=baseframes(baseframes>0);
        trialdata(:,:,tr)=mean(deconvimg(:,:,useframes+t0),3) -mean(deconvimg(:,:,baseframes),3);
        try
            trialspeed(tr) = mean(sp(useframes+t0));
        catch
            trialspeed(tr)=500;
        end
            trialcourse(tr,:) = squeeze(mean(mean(deconvimg(:,:,t0+(1:10)),2),1)); %average over whole image
            trialcyc(:,:,:,tr) = deconvimg(:,:,t0+(1:10)); %cycle average by trial)
    end
    
    %subtract off baseline (i.e. first point in each cycle)
    for i = 1:size(trialcyc,4)
        for j = 1:size(trialcyc,3)
            trialcyc(:,:,j,i) = trialcyc(:,:,j,i) - trialcyc(:,:,1,i);
        end
    end
    
    xpos=xpos(:,2:end); sf=sf(2:end,:); lag=lag(:,2:end); dOri=dOri(:,2:end); %remove first trial
    xrange = unique(xpos); sfrange=unique(sf); lagrange = unique(lag); dOrirange = unique(dOri);

    %get indices for 9 different spatial frequency conditions
    sfcombo = zeros(1,trials);
    for n = 1:trials
        if sf(n,1)==0 & sf(n,2)==0
            sfcombo(n) = 1;
        elseif sf(n,1)==0 & sf(n,2)==0.04
             sfcombo(n) = 2;
        elseif sf(n,1)==0 & sf(n,2)==0.16
             sfcombo(n) = 3;
         elseif sf(n,1)==0.04 & sf(n,2)==0
             sfcombo(n) = 4;
         elseif sf(n,1)==0.04 & sf(n,2)==0.04
             sfcombo(n) = 5;
         elseif sf(n,1)==0.04 & sf(n,2)==0.16
             sfcombo(n) = 6;
         elseif sf(n,1)==0.16 & sf(n,2)==0
             sfcombo(n) = 7;
         elseif sf(n,1)==0.16 & sf(n,2)==0.04
             sfcombo(n) = 8;
        elseif sf(n,1)==0.16 & sf(n,2)==0.16
             sfcombo(n) = 9;
        end
    end
    sfcomborange = unique(sfcombo);
     
    %subtract no stimulus conditions
    nostimmap = mean(trialcyc(:,:,:,find(sfcombo==1)),4);
    for i = 1:size(trialcyc,4)
        trialcyc(:,:,:,i) = trialcyc(:,:,:,i) - nostimmap;
    end
    
    %plot average of all blank stim sessions
    load(pointsfile);
    x = floor(x/4); y = floor(y/4);
    figure
    subplot(1,2,1)
    shadedErrorBar([1:10]',squeeze(mean(trialcyc(y(1),x(1),:,find(sfcombo==1)),4)),squeeze(std(trialcyc(y(1),x(1),:,find(sfcombo==1)),[],4))/sqrt(length(find(sfcombo==1))))
    axis([1 10 -0.1 0.2])
        title('No stim')
    subplot(1,2,2)
    shadedErrorBar([1:10]',squeeze(mean(trialcyc(y(1),x(1),:,find(sfcombo==5)),4)),squeeze(std(trialcyc(y(1),x(1),:,find(sfcombo==5)),[],4))/sqrt(length(find(sfcombo==5))))   
    axis([1 10 -0.1 0.2])
    title('Target+Mask Low SF')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end    
    %plot whole image at five time points for all sf combos of target/mask
    %rows are sf combination (see above),columns are time points (frame
    %1,3,5,7,9)
    %plots for dOri=0
%     maxpixval = ceil(10*max(max(max(deconvimg))))/10; %find max pixel
%     value and round up to nearest hundreth
    for i = 1:length(lagrange)
        figure        
        cnt = 1;
        for j = 1:length(sfcomborange)
            for k = 1:10
                subplot(9,10,cnt)
                imagesc(squeeze(mean(trialcyc(:,:,k,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)),[0 0.2])
                colormap(jet)
                axis square
                axis off
                set(gca,'LooseInset',get(gca,'TightInset'))
                hold on; plot(ypts,xpts,'w.','Markersize',2)
                cnt=cnt+1;
            end
        end
        mtit(sprintf('%s 0-dtheta %0.0flag',[files(use(f)).subj ' ' files(use(f)).expt],lagrange(i)))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end

    %plots for dOri=pi
    for i = 1:length(lagrange)
        figure
        cnt = 1;
        for j = 1:length(sfcomborange)
            for k = 1:10
                subplot(9,10,cnt)
                imagesc(squeeze(mean(trialcyc(:,:,k,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)),[0 0.2])
                colormap(jet)
                axis square
                axis off
                set(gca,'LooseInset',get(gca,'TightInset'))
                hold on; plot(ypts,xpts,'w.','Markersize',2)
                cnt=cnt+1;
            end
        end
        mtit(sprintf('%s pi/2-dtheta %0.0flag',[files(use(f)).subj ' ' files(use(f)).expt],lagrange(i)))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end

    %plot V1 point all traces too look for outliers
     for i = 1:length(lagrange)
        figure  
        for j = 1:length(sfcomborange)
            subplot(3,3,j) 
            hold on
            for k = 1:length(x)
                plot(squeeze(trialcyc(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1)))));
                axis([1 10 -0.1 0.2]);
            end
        end
        mtit(sprintf('Trial data 0-dtheta %0.0flag',lagrange(i)))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
     end
    
    %plot V1 point all traces too look for outliers
     for i = 1:length(lagrange)
        figure  
        for j = 1:length(sfcomborange)
            subplot(3,3,j) 
            hold on
            for k = 1:length(x)
                plot(squeeze(trialcyc(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2)))));
                axis([1 10 -0.1 0.2]);
            end
        end
        mtit(sprintf('Trial data pi/2-dtheta %0.0flag',lagrange(i)))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
     end
     
     
    run = find(trialspeed>=speedcut);
    sit = find(trialspeed<speedcut);

    %%get percent time running
    sp = conv(sp,ones(50,1),'same')/50;
    mv = sum(sp>500)/length(sp);
    figure
    subplot(1,2,1)
    bar(mv);
    xlabel('subject')
    ylabel('fraction running')
    ylim([0 1]);
    subplot(1,2,2)
    bar([mean(trialspeed(run)) mean(trialspeed(sit))])
    set(gca,'xticklabel',{'run','sit'})
    ylabel('speed')
    ylim([0 3000]);
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
    
    % 
    % %%% separate out responses by stim parameter
    % cond = 0;
    % tuning=zeros(size(trialdata,1),size(trialdata,2),length(xrange),length(sfrange),length(lagrange),length(dOrirange));
    % for i = 1:length(xrange)
    %     i
    %     for j= 1:length(sfrange)
    %         for k = 1:length(lagrange)
    %             for l=1:length(dOrirange)
    %                 cond = cond+1;
    %                 inds = find(xpos==xrange(i)&sf==sfrange(j)&lag==lagrange(k)&dOri==dOrirange(l));
    %                 avgtrialdata(:,:,cond) = squeeze(median(trialdata(:,:,inds),3));%  length(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))
    %                 avgtrialcourse(i,j,k,l,:) = squeeze(median(trialcourse(inds,:),1));
    %                 avgcondtrialcourse(cond,:) = avgtrialcourse(i,j,k,l,:);
    %                 avgspeed(cond)=0;
    %                 avgx(cond) = xrange(i); avgsf(cond)=sfrange(j); avglag(cond)=lagrange(k); avgdOri(cond)=dOrirange(l);
    %                 tuning(:,:,i,j,k,l) = avgtrialdata(:,:,cond);
    %                 meanspd(i,j,k,l) = squeeze(mean(trialspeed(inds)>500));
    %                 trialcycavg(:,:,:,i,j,k,l) = squeeze(mean(trialcyc(:,:,:,inds),4));
    %                 trialcycavgRun(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,run)),4));
    %                 trialcycavgSit(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,sit)),4));
    %             end
    %         end
    %     end
    % end
    % 
    % % %get average map with no stimulus
    % % for i = 1:length(xrange)
    % %     minmap(:,:,i) = squeeze(mean(mean(tuning(:,:,i,1,:,:),5),6));
    % %     mintrialcyc(:,:,:,i) = squeeze(mean(mean(trialcycavg(:,:,:,i,1,:,:),6),7));
    % % end
    % % %subtract average map with no stimulus from every map
    % % for i = 1:length(xrange)
    % %     for j = 1:length(radiusRange)
    % %         for k = 1:length(sfrange)
    % %             for l = 1:length(tfrange)
    % %                 tuning(:,:,i,j,k,l) = tuning(:,:,i,j,k,l)-minmap(:,:,i);
    % %                 trialcycavg(:,:,:,i,j,k,l) = trialcycavg(:,:,:,i,j,k,l)-mintrialcyc(:,:,:,i);
    % %             end
    % %         end
    % %     end
    % % end
    % 
    % %%% plot response based on previous trial's response
    % %%% this is a check for whether return to baseline is an issue
    % % figure
    % % plot(avgcondtrialcourse(:,1)-avgcondtrialcourse(:,10),avgcondtrialcourse(:,5)-avgcondtrialcourse(:,10),'o');
    % % xlabel('pre dfof'); ylabel('post dfof');
    % 
    % 
    % %%% plot responses at different lags
    % figure %one set of plots for each x position
    % cnt = 0;
    % for i = 1:length(xrange)
    %     for j=1:length(lagrange)
    %         cnt = cnt+1;
    %         subplot(length(xrange),length(lagrange),cnt)
    %         imagesc(squeeze(mean(mean(tuning(:,:,i,:,j,:),4),6)),[ -0.005 0.05]); colormap jet;
    %         title(sprintf('%0.0fxpos %0.0flag',xrange(i),lagrange(j)))
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
    % for i = 1:length(dOrirange)
    %     figure %one plot for each dOri
    %     for j = 1:length(lagrange)
    %         subplot(3,3,j)
    %         imagesc(squeeze(mean(mean(tuning(:,:,:,:,j,i),3),4)),[ -0.02 0.15]); colormap jet;
    %         title(sprintf('%0.0flag',lagrange(j)))
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
    % for i = 1:length(xrange)
    %     d = squeeze(mean(mean(tuning(:,:,i,:,1,:),4),6));
    %     ximg(:,:,i) = (d-min(min(d)))/(max(max(d))-min(min(d)));
    % end
    % ximg(:,:,3) = 0;
    % 
    % [fname pname] = uigetfile('*.mat','points file');
    % if fname~=0
    %     load(fullfile(pname, fname));
    % else
    %     figure
    %     for i = 1:length(xrange)
    %         imshow(ximg(:,:,i));hold on; plot(ypts,xpts,'w.','Markersize',2)
    %         [y(i) x(i)] = ginput(1);
    %         x=round(x); y=round(y);
    %     %     range = floor(size(ximg,1)*0.05); %findmax range is 5% of image size
    %     %     [maxval(i) maxind(i)] =  max(max(ximg(x(i)-range:x(i)+range,y(i)-range:y(i)+range,1)));
    %     %     [xoff(i),yoff(i)] = ind2sub([1+2*range,1+2*range],maxind(i));
    %     end
    %     close(gcf);
    %     [fname pname] = uiputfile('*.mat','save points?');
    %     if fname~=0
    %         save(fullfile(pname,fname),'x','y');
    %     end
    % end
    % % x = x+(xoff'-(1+range));
    % % y = y+(yoff'-(1+range));
    % figure
    % imshow(ximg);hold on;plot(y,x,'o');
    % 
    % 
    % 
    % %% get lag/orientation tuning curves across sf
    % figure
    % for i = 1:length(xrange)
    %     subplot(1,length(xrange),i)
    %     hold on
    %     for j = 1:length(dOrirange)
    %         plot(1:size(tuning,5),squeeze(mean(tuning(x(i),y(i),i,:,:,j),4)))
    %     end
    %     set(gca,'xtick',1:length(lagrange),'xticklabel',lagrange)
    %     xlabel('lag')
    %     axis([1 length(lagrange) 0 0.25])
    % end
    % legend('aligned','perpend','location','northwest')
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
    %     for j = 1:length(lagrange)
    %         plot(circshift(squeeze(mean(mean(trialcycavg(x(i),y(i),:,i,:,j,:),5),7)),5))
    %     end
    % end
    % legend('0','2','4','6')
    % if exist('psfilename','var')
    %     set(gcf, 'PaperPositionMode', 'auto');
    %     print('-dpsc',psfilename,'-append');
    % end
    % 
    % %%plot cycle averages for the different lags at the 2 x positions run vs.
    % %%sit
    % figure
    % for i = 1:length(xrange)
    %     subplot(2,length(xrange),i)
    %     hold on
    %     for j = 1:length(lagrange)
    %         plot(circshift(squeeze(mean(mean(trialcycavgRun(x(i),y(i),:,i,:,j,:),5),7)),5))
    %     end
    %     axis([1 shift -0.1 0.25])
    %     title('run')
    %     hold off
    %     subplot(2,length(xrange),i+length(xrange))
    %     hold on
    %     for j = 1:length(lagrange)
    %         plot(circshift(squeeze(mean(mean(trialcycavgSit(x(i),y(i),:,i,:,j,:),5),7)),5))
    %     end
    %     axis([1 shift -0.05 0.15])
    %     title('sit')
    %     hold off
    % end
    % legend('0','2','4','6')
    % if exist('psfilename','var')
    %     set(gcf, 'PaperPositionMode', 'auto');
    %     print('-dpsc',psfilename,'-append');
    % end
    
%     p = sprintf('%s%s',pathname,files(use(f)).masking);
%     p = fileparts(p);
    p = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect';
    filename = fileparts(fileparts(files(use(f)).masking));
    filename = sprintf('%s_MaskingAnalysis',filename);

    if f~=0
    %     save(fullfile(p,f),'allsubj','sessiondata','shiftData','fit','mnfit','cycavg','mv');
        save(fullfile(p,filename),'trialcyc','deconvimg','sfcombo','xrange','sfrange','lagrange','dOrirange','sfcomborange');
    end
    
    if f~=0
        try
       ps2pdf('psfile', psfilename, 'pdffile', fullfile(p,sprintf('%s.pdf',filename)));
    catch
        display('couldnt generate pdf');
        end
    end
    delete(psfilename);
end