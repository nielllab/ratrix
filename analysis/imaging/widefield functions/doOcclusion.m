%doOcclusion
close all
clear all
dbstop if error

%% things you can adjust
%select batch file
% batchPhilOcclusion
batchKristenOcclusion
cd(pathname)

downsample = 0.5; %downsample ratio
plotrange = [-0.01 0.05]; %range for imagesc plots

%select deconvolution
deconvplz = 1   %choose if you want deconvolution
if deconvplz
    outpathname = [outpathname 'decon\sitrun\'];
else
    outpathname = [outpathname 'nodecon\sitrun\'];
end

%select animals to use
use = find(strcmp({files.label},'camk2 gc6')); 

%movie info
% moviename = 'C:\occludeStim10cond_22min.mat';
moviename = 'C:\occludeStim5cond_2theta_24min.mat';
load(moviename)
imagerate=10;
cyclength = imagerate*(isi+duration);
timepts = 0:1/imagerate:(2*isi+duration);timepts = timepts - isi;timepts = timepts(1:end-1);
condRange = unique(cond);
aniState={'sit','run'};
sprintf('%d experiments for individual analysis',length(use))

%% run doTopography
alluse = use;%needed for doTopography
allsubj = unique({files(alluse).subj}); %needed for doTopography
for s=1:1 %needed for doTopography
    doTopography; %%%align across animals second
end

%% loop through experiments
for f = 1:length(use)
    filename = sprintf('%s_%s_%s_%s_occlusion.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).inject,files(use(f)).timing);
%     if exist(fullfile(outpathname,filename),'file')==0
        psfilename = 'C:\tempPhilWF.ps';
        if exist(psfilename,'file')==2;delete(psfilename);end
        
        sprintf('loading...')
        load(fullfile(pathname,files(use(f)).occlusion),'dfof_bg','sp','stimRec','frameT')
        
        zoom = 260/size(dfof_bg,1);
        dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
        
        dfof_bg = imresize(double(dfof_bg),downsample,'method','box');
        
        if ~exist('sp','var')
            sp =0;stimRec=[];
        end
        
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
        if slipframes<1 %%%cut frames from beginning to account for slippage
            slipframes=1
        elseif slipframes>5
            slepframes=5
        end
        dfof_bg = dfof_bg(:,:,slipframes:end);
        nx=ceil(sqrt(cyclength+1)); %%% how many rows in figure subplot
        trials = length(cond); %in case movie stopped early
        %%% mean amplitude map across cycle
        figure
        map=0;
        p=1:cyclength;p=circshift(p,ceil(cyclength/2)-1,2);
        colormap(jet)
        for fr=1:cyclength
            cycavg(:,:,fr) = mean(dfof_bg(:,:,(fr:cyclength:end)),3);
            subplot(nx,nx,p(fr))
            imagesc(squeeze(cycavg(:,:,fr)),plotrange)
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
                dfof_bg = shiftdim(dfof_bg+0.2,2); %shift dimesions for decon lucy and add 0.2 to get away from 0
                tic
                pp = gcp %start parallel pool
                deconvimg = deconvg6sParallel(dfof_bg,0.1); %deconvolve
                toc
                deconvimg = shiftdim(deconvimg,1); %shift back
                deconvimg = deconvimg - mean(mean(mean(deconvimg))); %subtract min value
                dfof_bg = shiftdim(dfof_bg,1); %shift dfof_bg back
                dfof_bg = dfof_bg - 0.2; %subtract 0.2 back off
                delete(pp)
                ncut = 3 %# of trials to cut due to deconvolution cutting off end
                trials=trials-ncut; %deconv cuts off last trial
                deconvimg = deconvimg(:,:,1:trials*cyclength);
                %check deconvolution success on one pixel
                figure
                hold on
                plot(squeeze(dfof_bg(130,130,:)))
                plot(squeeze(deconvimg(130,130,:)),'g')
                hold off
                if exist('psfilename','var')
                    set(gcf, 'PaperPositionMode', 'auto');
                    print('-dpsc',psfilename,'-append');
                end
                
%                 sprintf('saving...')
%                 try
%                     save(fullfile(outpathname,filename),'deconvimg','-append','-v7.3');
%                 catch
%                     save(fullfile(outpathname,filename),'deconvimg','-v7.3');
%                 end
            end
            cond = cond(1:end-ncut);
        else
            deconvimg = dfof_bg;
%             sprintf('saving...')
%             try
%                 save(fullfile(outpathname,filename),'deconvimg','-append','-v7.3');
%             catch
%                 save(fullfile(outpathname,filename),'deconvimg','-v7.3');
%             end
        end
        
        
        
%% separate into trials, pull out running, make cycle averages
        %%% separate responses by trials
        sprintf('separating responses by trial')
        speedcut = 20;
        base = isi*imagerate-3:isi*imagerate-1;
        peakWindow = isi*imagerate:(isi+duration)*imagerate;
        trialspeed = zeros(trials,1);
        trialcyc = zeros(size(deconvimg,1),size(deconvimg,2),cyclength+isi*imagerate,trials);
        for tr=1:trials-1;
            t0 = round((tr-1)*cyclength);
            baseframes = base+t0; baseframes=baseframes(baseframes>0);
            try
                trialspeed(tr) = mean(sp(peakWindow+t0));
            catch
                trialspeed(tr)=20;
            end
            trialcyc(:,:,:,tr) = deconvimg(:,:,t0+(1:cyclength+isi*imagerate));%each cycle is frames 6-26, stim comes on at frame 11
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
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end

        %%%create array w/responses for trial types
        alltrials = {};%trial indices for each particular condition
        cnt=1;
        trialcycavg=nan(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),length(condRange)-1,2);
        for i = 1:length(condRange)-1
            for j = 1:2 %sit/run
                inds = find(cond==i & running==(j-1));alltrials{cnt} = inds;
                trialcycavg(:,:,:,i,j) = squeeze(nanmean(trialcyc(:,:,:,inds),4));
                cnt=cnt+1;
            end
        end


        %%%baseline and zero trial subtraction
        %get average map with no stimulus
        blanktr = condRange(end);
        mintrialcyc = zeros(size(trialcyc,1),size(trialcyc,2),size(trialcyc,3),2);
        for j = 1:2
            mintrialcyc(:,:,:,j) = squeeze(nanmean(trialcyc(:,:,:,find(cond==blanktr & running==(j-1))),4)); %min map for stationary and running
        end
        %subtract average map with no stimulus from trialcycavg and baseline each trial
        for i = 1:size(trialcycavg,4)
            for j = 1:2
                trialcycavg(:,:,:,i,j) = trialcycavg(:,:,:,i,j)-mintrialcyc(:,:,:,j); %subtract min map
                for t = 1:size(trialcycavg,3)
                    trialcycavg(:,:,t,i,j) = trialcycavg(:,:,t,i,j)-squeeze(nanmean(trialcycavg(:,:,base,i,j),3)); %subtract baseline
                end
            end
        end
        
%% select a center point
        sprintf('Pick center of visual response')
        midpt = isi*imagerate + round(imagerate*duration/2);
        if mod(f,2)==1
            figure;
            colormap jet
            imagesc(squeeze(trialcycavg(:,:,midpt,2,1)),plotrange)
            axis off; axis equal
            title('select center of response @ midpoint time of moving spot')
            [y x] = ginput(1);
            hold on
            plot(y,x,'wo','MarkerSize',15)
            x=round(x); y=round(y);
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
        else
            load(fullfile(outpathname,sprintf('%s_%s_%s_%s_occlusion.mat',...
                files(use(f)).expt,files(use(f)).subj,files(use(f)).inject,files(use(f-1)).timing)),'x','y');
            figure;
            colormap jet
            imagesc(squeeze(trialcycavg(:,:,midpt,2,1)),plotrange)
            axis off; axis equal
            title('select center of response @ midpoint time of moving spot')
            plot(y,x,'wo','MarkerSize',15)
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
        end
            
        
%         load(fullfile('D:\Phil\occlusion\decon\sitrun',filename),'x','y')
%         figure;
%         colormap jet
%         imagesc(squeeze(trialcycavg(:,:,midpt,2,1)),plotrange)
%         axis off; axis equal
%         title('select center of response @ midpoint time of moving spot')
%         hold on
%         plot(y,x,'wo','MarkerSize',15)
%         x=round(x); y=round(y);
%         if exist('psfilename','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfilename,'-append');
%         end
        
%% plot responses and make movies for each stimulus condition
        f1=figure;f2=figure;
        spr = 2; %half-length of square used to pull out local response amplitude
        for i = 1:size(trialcycavg,4)
            for r = 1:2 %sit/run
                if isnan(squeeze(trialcycavg(1,1,1,i,r)))
                    continue
                else
                    figure
                    cnt=1;
                    for j = 1:2:imagerate*duration %plot every other stimulus time point
                        subplot(duration,imagerate/2,cnt)
                        imagesc(squeeze(trialcycavg(:,:,isi*imagerate+j,i,r)),plotrange)
                        axis off;axis equal
                        cnt=cnt+1;
                    end
                    mtit(sprintf('%s %s',aniState{r},condList{i}))
                    if exist('psfilename','var')
                        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                        print('-dpsc',psfilename,'-append');
                    end
                    
                    if r==1
                        figure(f1)
                        subplot(2,round(size(trialcycavg,4)/2),i)
                        plot(timepts,squeeze(nanmean(nanmean(trialcycavg(x-spr:x+spr,y-spr:y+spr,:,i,r),2),1)),'k')
                        xlabel('time (s)');ylabel('sit dfof');title(sprintf('%s',condList{i}));
                        axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
                    else
                        figure(f2)
                        subplot(2,round(size(trialcycavg,4)/2),i)
                        plot(timepts,squeeze(nanmean(nanmean(trialcycavg(x-spr:x+spr,y-spr:y+spr,:,i,r),2),1)),'k')
                        xlabel('time (s)');ylabel('run dfof');title(sprintf('%s',condList{i}));
                        axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
                    end

                    %make the movie
                    movname = sprintf('%s_%s_%s_%s',files(use(f)).expt,files(use(f)).subj,aniState{r},condList{i});
                    cycle_mov = squeeze(trialcycavg(:,:,:,i,r));
        %             cycle_mov = imresize(double(cycle_mov),downsample,'method','box');
                    baseline = prctile(cycle_mov,1,3);
                    cycle_mov = cycle_mov - repmat(baseline,[1 1 size(cycle_mov,3)]);
                    lowthresh= prctile(cycle_mov(:),2);
                    upperthresh = prctile(cycle_mov(:),98)*1.5;
                    cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
                    mov = immovie(permute(cycMov,[1 2 4 3]));
                    vid = VideoWriter(fullfile(outpathname,movname));
                    vid.FrameRate=imagerate;
                    open(vid);
                    writeVideo(vid,mov);
                    close(vid)
                end
            end
        end
        figure(f1)
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        figure(f2)
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end

%% save data
        sprintf('saving...')
        save(fullfile(outpathname,filename),'trialcyc','alltrials','trialcycavg','running','condList','x','y','-v7.3') %change to append if doing decon

%% save pdf
        try
            dos(['ps2pdf ' psfilename ' "' [fullfile(outpathname,filename) '.pdf'] '"'])
        catch
            display('couldnt generate pdf');
        end
        delete(psfilename);
        
%     else
%         sprintf('skipping %s',filename)
%     end
end


%% group analysis
% psfilename = 'C:\tempPhilWF.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
%         
% numAni = length(use);
% spr = 2; %half-length of square used to pull out local response amplitude
% filename = sprintf('%s_%s_occlusion.mat',files(use(1)).expt,files(use(1)).subj);
% load(fullfile(outpathname,filename),'trialcycavg')
% cyc = nan(numAni,size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5));
% mapcyc = nan(numAni,size(trialcycavg,1),size(trialcycavg,2),size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5));
% for f = 1:length(use)
%     clear trialcycavg x y
%     filename = sprintf('%s_%s_occlusion.mat',files(use(f)).expt,files(use(f)).subj);
%     load(fullfile(outpathname,filename),'trialcycavg','x','y')
%     
%     cyc(f,:,:,:) = squeeze(nanmean(nanmean(trialcycavg(x-spr:x+spr,y-spr:y+spr,:,:,:),2),1));
%     mapcyc(f,:,:,:,:,:) = trialcycavg;
% end
% 
% f3=figure;f4=figure;
% for r = 1:2 %stationary running
%     for i = 1:size(cyc,3)
%         figure
%         cnt=1;
%         for j = 1:2:imagerate*duration %plot every other stimulus time point
%             subplot(duration,imagerate/2,cnt)
%             imagesc(squeeze(nanmean(mapcyc(:,:,:,isi*imagerate+j,i,r),1)),plotrange)
%             axis off;axis equal
%             cnt=cnt+1;
%         end
%         mtit(sprintf('%s %s',aniState{r},condList{i}))
%         if exist('psfilename','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfilename,'-append');
%         end
%         
%         if r==1
%             figure(f3)
%             subplot(2,round(size(trialcycavg,4)/2),i)
%             shadedErrorBar(timepts,squeeze(nanmean(cyc(:,:,i,r),1)),...
%                 squeeze(nanstd(cyc(:,:,i,r),[],1))/sqrt(numAni),'k')
%             xlabel('time (s)');ylabel('sit dfof');title(sprintf('%s',condList{i}));
%             axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
%         else
%             figure(f4)
%             subplot(2,round(size(trialcycavg,4)/2),i)
%             shadedErrorBar(timepts,squeeze(nanmean(cyc(:,:,i,r),1)),...
%                 squeeze(nanstd(cyc(:,:,i,r),[],1))/sqrt(numAni),'k')
%             xlabel('time (s)');ylabel('run dfof');title(sprintf('%s',condList{i}));
%             axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
%         end
%     end
% 
%     selpts = [20 30 40 50];
%     figure
%     cnt=1;
%     for j = selpts %plot just four time points
%         subplot(4,4,cnt)
%         imagesc(squeeze(nanmean(mapcyc(:,:,:,j,3,r),1)),plotrange)
%         axis off;axis equal;title('patch behind square');
%         cnt=cnt+1;
%     end
%     for j = selpts %plot just four time points
%         subplot(4,4,cnt)
%         imagesc(squeeze(nanmean(mapcyc(:,:,:,j,1,r),1)+...
%             nanmean(mapcyc(:,:,:,j,2,r),1)),plotrange)
%         axis off;axis equal;title('patch alone plus square alone');
%         cnt=cnt+1;
%     end
%     for j = selpts %plot just four time points
%         subplot(4,4,cnt)
%         imagesc(squeeze(nanmean(mapcyc(:,:,:,j,4,r),1)+...
%             nanmean(mapcyc(:,:,:,j,2,r),1)),plotrange)
%         axis off;axis equal;title('patch blink plus square alone');
%         cnt=cnt+1;
%     end
%     for j = selpts %plot just four time points
%         subplot(4,4,cnt)
%         imagesc(squeeze(nanmean(mapcyc(:,:,:,j,5,r),1)+...
%             nanmean(mapcyc(:,:,:,j,2,r),1)),plotrange)
%         axis off;axis equal;title('patch gradual plus square alone');
%         cnt=cnt+1;
%     end
%     mtit(sprintf('%s',aniState{r}))
%     if exist('psfilename','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfilename,'-append');
%     end
%     
%     figure
%     cnt=1;
%     for j = selpts %plot just four time points
%         subplot(2,4,cnt)
%         imagesc(squeeze(nanmean(mapcyc(:,:,:,j,1,r),1)),plotrange)
%         axis off;axis equal;title('patch only');
%         cnt=cnt+1;
%     end
%     for j = selpts %plot just four time points
%         subplot(2,4,cnt)
%         imagesc(squeeze(nanmean(mapcyc(:,:,:,j,3,r),1)-...
%             nanmean(mapcyc(:,:,:,j,2,r),1)),plotrange)
%         axis off;axis equal;title('patch behind square minus square');
%         cnt=cnt+1;
%     end
%     mtit(sprintf('%s',aniState{r}))
%     if exist('psfilename','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfilename,'-append');
%     end
%     
%     figure
%     subplot(3,2,1)
%     shadedErrorBar(timepts,squeeze(nanmean(cyc(:,:,3,r),1)),...
%         squeeze(nanstd(cyc(:,:,i,r),[],1))/sqrt(numAni),'k')
%     xlabel('time (s)');ylabel(sprintf('%s dfof',aniState{r}));title('patch behind square');
%     axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
%     
%     subplot(3,2,2)
%     shadedErrorBar(timepts,squeeze(nanmean(cyc(:,:,1,r)+cyc(:,:,2,r),1)),...
%         squeeze(nanstd(cyc(:,:,1,r)+cyc(:,:,2,r),[],1))/sqrt(numAni),'k')
%     xlabel('time (s)');ylabel(sprintf('%s dfof',aniState{r}));title('patch alone plus square alone');
%     axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
%     
%     subplot(3,2,3)
%     shadedErrorBar(timepts,squeeze(nanmean(cyc(:,:,4,r)+cyc(:,:,2,r),1)),...
%         squeeze(nanstd(cyc(:,:,4,r)+cyc(:,:,2,r),[],1))/sqrt(numAni),'k')
%     xlabel('time (s)');ylabel(sprintf('%s dfof',aniState{r}));title('patch blink plus square alone');
%     axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
%     
%     subplot(3,2,4)
%     shadedErrorBar(timepts,squeeze(nanmean(cyc(:,:,5,r)+cyc(:,:,2,r),1)),...
%         squeeze(nanstd(cyc(:,:,5,r)+cyc(:,:,2,r),[],1))/sqrt(numAni),'k')
%     xlabel('time (s)');ylabel(sprintf('%s dfof',aniState{r}));title('patch gradual plus square alone');
%     axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
%     
%     subplot(3,2,5)
%     shadedErrorBar(timepts,squeeze(nanmean(cyc(:,:,1,r),1)),...
%         squeeze(nanstd(cyc(:,:,1,r),[],1))/sqrt(numAni),'k')
%     xlabel('time (s)');ylabel(sprintf('%s dfof',aniState{r}));title('patch only');
%     axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
%     
%     subplot(3,2,6)
%     shadedErrorBar(timepts,squeeze(nanmean(cyc(:,:,3,r)-cyc(:,:,2,r),1)),...
%         squeeze(nanstd(cyc(:,:,3,r)-cyc(:,:,2,r),[],1))/sqrt(numAni),'k')
%     xlabel('time (s)');ylabel(sprintf('%s dfof',aniState{r}));title('patch behind square minus square');
%     axis([timepts(1) timepts(end) -0.01 0.25]);axis square;
%     
%     if exist('psfilename','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfilename,'-append');
%     end
%     
% end
% 
% figure(f3)
% if exist('psfilename','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfilename,'-append');
% end
% figure(f4)
% if exist('psfilename','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfilename,'-append');
% end
% 
% try
%     dos(['ps2pdf ' psfilename ' "' [fullfile(outpathname,'OcclusionGroupAnalysis') '.pdf'] '"'])
% catch
%     display('couldnt generate pdf');
% end
% delete(psfilename);

