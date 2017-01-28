%%% uses topox/y and gratings to pick cells and analyze size select data
% % clear all
% % close all
% % dbstop if error

exclude = 0; %0 removes trials above threshold, 1 clips them to the threshold
dfWindow = 9:11;
spWindow = 6:10;
dt = 0.1;
cyclelength = 1/0.1;
xpos=0;sf=0; isi=0; duration=0; theta=0; phase=0; radius=0;
moviefname = 'C:\sizeSelect2sf8sz26min.mat';
load(moviefname)
sizeVals = [0 5 10 20 30 40 50 60];
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end
thetamod = mod(theta,pi)-pi/8;
thetaQuad = zeros(1,length(theta)); %break orientation into quadrants, 1=top,2=right,3=bot,4=left, offset pi/8 CCW
thetaQuad(1,find(-pi/8<=thetamod&thetamod<pi/8))=1;
thetaQuad(1,find(pi/8<=thetamod&thetamod<3*pi/8))=2;
thetaQuad(1,find(3*pi/8<=thetamod&thetamod<5*pi/8))=3;
thetaQuad(1,find(5*pi/8<=thetamod&thetamod<=7*pi/8))=4;
thetaRange = unique(thetaQuad);

for f=1:length(use)
    filename = files(use(f)).sizeanalysis
%     if exist(filename)==0 %%comment for redo
        files(use(f)).subj
        psfile = 'c:\tempPhil2p.ps';
        if exist(psfile,'file')==2;delete(psfile);end

        clear xph yph phaseVal rfCyc cycAvg rfAmp rf dftuning dftuningall sptuning sptuningall

        %%% get topo stimuli

        %%% read topoX (spatially periodic white noise)
        %%% long axis of monitor, generally vertical
        load(files(use(f)).topoxpts);
        %%% extract phase and amplitude from complex fourier varlue at 0.1Hz
        xph = phaseVal; rfCyc(:,:,1) = cycAvg;  %%%cycle averaged timecourse (10sec period)
        rfAmp(:,1) = abs(xph); rf(:,1) = mod(angle(xph)-(2*pi*0.25/10),2*pi)*128/(2*pi); %%% convert phase to pixel position, subtract 0.25sec from phase for gcamp delay
        topoxUse = mean(dF,2)~=0;  %%% find cells that were successfully extracted

        %%% read topoY (spatially periodic white noise)
        %%% short axis of monitor, generally horizontal
        load(files(use(f)).topoypts);
        %%% extract phase and amplitude from complex fourier varlue at 0.1Hz
        yph = phaseVal; rfCyc(:,:,2) = cycAvg;
        rf(:,2) = mod(angle(yph)-(2*pi*0.25/10),2*pi)*72/(2*pi); rfAmp(:,2) = abs(yph);
        topoyUse = mean(dF,2)~=0;

        cellCutoff = files(use(f)).cutoff

        %%% find sbc? use distance from center?
        d1 = sqrt((mod(angle(xph),2*pi)-pi).^2 + (mod(angle(yph),2*pi)-pi).^2);
        d2 = sqrt((mod(angle(xph)+pi,2*pi)-pi).^2 + (mod(angle(yph)+pi,2*pi)-pi).^2);
        sbc = (d1>d2);

        %%% select cells responsive to both topoX and topoY
        dpix = 0.8022; centrad = 10; ycent = 72/2; xcent = 128/2; %%deg/pix, radius of response size cutoff, x and y screen centers
        d = sqrt((rf(:,1)-xcent).^2 + (rf(:,2)-ycent).^2);

        %%% plot good topo cells trying different threshold values
        toporespthreshlist = [0.01 0.02 0.03 0.04 0.05 0.06];
        figure
        for i = 1:length(toporespthreshlist)
            subplot(2,3,i)
            allgoodTopo = find(~sbc & rfAmp(:,1)>toporespthreshlist(i) & rfAmp(:,2)>toporespthreshlist(i)); allgoodTopo = allgoodTopo(allgoodTopo<=cellCutoff);
            goodTopo = find(~sbc & rfAmp(:,1)>toporespthreshlist(i) & rfAmp(:,2)>toporespthreshlist(i) & d<centrad/dpix); goodTopo=goodTopo(goodTopo<=cellCutoff);
            hold on
            plot(rf(allgoodTopo,2),rf(allgoodTopo,1),'.','color',[0.5 0.5 0.5],'MarkerSize',5); %%% the rfAmp criterion wasn't being applied here
            plot(rf(goodTopo,2),rf(goodTopo,1),'b.','MarkerSize',5);
            circle(ycent,xcent,centrad/dpix)
            axis equal;
            axis([0 72 0 128]);
            set(gca,'xticklabel','','yticklabel','')
            xlabel(sprintf('%.2f dfof',toporespthreshlist(i)))
        end
        mtit('Good topo cells/threshold')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end
        
        %%%set actual topo threshold
        toporespthresh = toporespthreshlist(1);
        allgoodTopo = find(~sbc & rfAmp(:,1)>toporespthresh & rfAmp(:,2)>toporespthresh); allgoodTopo = allgoodTopo(allgoodTopo<=cellCutoff);
        goodTopo = find(~sbc & rfAmp(:,1)>toporespthresh & rfAmp(:,2)>toporespthresh & d<centrad/dpix); goodTopo=goodTopo(goodTopo<=cellCutoff);
        sprintf('%d cells with good topo under cutoff',length(allgoodTopo))
        sprintf('%d cells in center with good topo under cutoff',length(goodTopo))
        
        % load size select points file and stim object and align to stim
        load(files(use(f)).sizepts);
        load(files(use(f)).sizestimObj);
        spInterp = get2pSpeed(stimRec,dt,size(dF,2));
        spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);
        
        %%%plot rasters for dfof and spikes
        figure
        imagesc(dF(goodTopo,:),[0 1]); ylabel('cell #'); xlabel('frame'); title('dF');
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end
        figure
        imagesc(spikeBinned(goodTopo,:),[0 0.1]); ylabel('cell #'); xlabel('frame'); title('spikes');
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        ntrials= min(dt*length(dF)/(isi+duration),length(sf));
        onsets = dt + (0:ntrials-1)*(isi+duration);
        timepts = 1:(2*isi+duration)/dt;
        timepts = (timepts-1)*dt;
        dFout = align2onsets(dF,onsets,dt,timepts);
        dFout = dFout(1:end-1,:,:); %%%extra cell at end for some reason
        spikesOut = align2onsets(spikes*10,onsets,dt,timepts);
        timepts = timepts - isi;
        running = zeros(1,ntrials);
        for i = 1:ntrials
            running(i) = mean(spInterp(1,1+cyclelength*(i-1):cyclelength+cyclelength*(i-1)),2)>20;
        end

        if exclude
            %threshold big guys out
            sigthresh = 10;
            for i=1:size(dFout,1)
                for j=1:size(dFout,3)
                    if squeeze(max(dFout2(i,1:10,j),[],2))>sigthresh
                        dFout2(i,:,j) = nan(1,size(dFout2,2));
                    end
                end
            end 
        end
        % else
        %     %re-size big guys down to a max threshold
        %     sigthresh = 10;
        %     for i=1:size(dFout,1)
        %         for j=1:size(dFout,3)
        %             if squeeze(max(dFout(i,1:10,j),[],2))>sigthresh
        %                 vals = dFout(i,:,j);
        %                 vals(vals>sigthresh) = sigthresh;
        %                 dFout(i,:,j) = vals;
        %             end
        %         end
        %     end
        % end

        %%%subtract baseline period
        dFout2 = dFout;
        spikesOut2 = spikesOut;
        for i = 1:size(dFout,1)
            for j = 1:size(dFout,3)
                dFout2(i,:,j) = dFout(i,:,j)-nanmean(dFout(i,1:4,j));
                spikesOut2(i,:,j) = spikesOut(i,:,j)-nanmean(spikesOut(i,1:4,j));
            end
        end
        
        %%%use output from PRE gratings analysis to pick cells
        if mod(f,2)
            gratfile = files(use(f)).gratinganalysis;
            openfig([gratfile '.fig'])
            if exist('psfile','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfile,'-append');
            end
        else
            gratfile = files(use(f-1)).gratinganalysis;
        end
        load(gratfile,'dfgrat','dirrange','prefdir','prefthetaQuad','bestsftf','respcells','dfori','osi','dsi')
        
        %%%find usable cells, change arrays to match/decrease file size
        usecells = intersect(goodTopo,respcells); %%%use only cells in center w/good resp to gratings
        sprintf('%d cells with good topo in center & good gratings response',length(usecells))
        usedfori = dfori(usecells,:);
        useosi=osi(usecells); usedsi=dsi(usecells);
        usebestsftf = bestsftf(usecells,:); useprefthetaQuad = prefthetaQuad(usecells);
        userf = rf(usecells,:);
        dfgrat = dfgrat(usecells,:,:);
        
        %%%the two stimuli are different so adjust cell preferences to try
        %%%to match them from gratings->size select
        usebestsftf(find(usebestsftf(:,1)==2),1)=1; %%combine 0.01 and 0.04 pref, set to index 1
        usebestsftf(find(usebestsftf(:,1)==3),1)=2; %%0.16, change to index 2

        %create array w/average responses per stim type
        dftuning = zeros(length(usecells),size(dFout,2),length(sfrange),length(thetaRange),length(phaserange),length(contrastRange),length(radiusRange),2);
        sptuning = zeros(length(usecells),size(spikesOut,2),length(sfrange),length(thetaRange),length(phaserange),length(contrastRange),length(radiusRange),2);
        for h = 1:length(usecells)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(phaserange)
                        for l = 1:length(contrastRange)
                            for m = 1:length(radiusRange)
                                for n = 1:2
                                    dftuning(h,1:size(dFout,2),i,j,k,l,m,n) = nanmean(dFout2(usecells(h),:,find(sf==sfrange(i)&thetaQuad==thetaRange(j)&phase==phaserange(k)&contrasts==contrastRange(l)&radius==m&running==(n-1))),3);
                                    sptuning(h,1:size(spikesOut,2),i,j,k,l,m,n) = nanmean(spikesOut2(usecells(h),:,find(sf==sfrange(i)&thetaQuad==thetaRange(j)&phase==phaserange(k)&contrasts==contrastRange(l)&radius==m&running==(n-1))),3);
                                end
                            end
                        end
                    end
                end
            end
        end       
               
        %%%plot screen for all six sizes w/threshold label for responsive
        figure
        for i=1:length(sizes)
            subplot(2,4,i)
            sizerespcells=[];
            for j=1:length(usecells)
                goodresp = squeeze(nanmean(nanmean(dftuning(j,dfWindow,usebestsftf(j,1),useprefthetaQuad(j),:,end,i,1),2),5))>=0.1;
                if goodresp
                    sizerespcells = [sizerespcells j];
                end
            end
            hold on
            plot(userf(:,2),userf(:,1),'.','color',[0.5 0.5 0.5],'MarkerSize',10); %%% the rfAmp criterion wasn't being applied here
            plot(userf(sizerespcells,2),userf(sizerespcells,1),'b.','MarkerSize',10);
            circle(ycent,xcent,sizeVals(i)/2/dpix)
            axis equal;
            axis([0 72 0 128]);
            set(gca,'xticklabel','','yticklabel','')
        end
        mtit('Responsive cells for each size')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        %%%plot individual cell data
%         sitcolor = [0.6 0.6 0.6;0.8 0.8 0.8;1 1 1];
%         runcolor = [0.6 0 0;0.8 0 0;1 0 0];
        dfsize = nan(length(usecells),size(dFout,2),length(contrastlist),length(sizeVals),2);
        for i=1:length(usecells)
            figure
            
            %%%direction tuning curve
            subplot(2,3,1)
            curv = usedfori(i,:);
            plot(1:12,curv,'k-')
            xlabel('Direction')
            ylabel('dfof')
            axis([1 12 min(curv)+0.1*min(curv) max(curv)+0.1*max(curv)])
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'))
            
            %%%polar direction tuning curve
            subplot(2,3,2)
            pol = usedfori(i,:);pol(pol<0)=0;
            polarplot([dirrange dirrange(1)],[pol pol(1)],'k-')
            set(gca,'LooseInset',get(gca,'TightInset'))
            
            %%%osi/dsi
            subplot(2,3,3)
            plot([1 2],[useosi(i) usedsi(i)],'k.','Markersize',20)
            axis([0 3 0 1])
            set(gca,'xtick',[1 2],'xticklabel',{'OSI','DSI'})
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'))
            
            %%%avg resp to best grating stim
            subplot(2,3,4)
            hold on
            plot(timepts,dfgrat(i,:,1),'k')
            plot(timepts,dfgrat(i,:,2),'r')
            xlabel('Time(s)')
            ylabel('best grat dfof')
            axis([timepts(1) timepts(end) min(min(dfgrat(i,:,:)))+0.01 max(max(dfgrat(i,:,:)))+0.01])
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'))
            
            %%%size curve
            subplot(2,3,5)
            for j = 1:length(contrastlist)
                for k = 1:length(sizes)
                    dfsize(i,:,j,k,1) = squeeze(nanmean(dftuning(i,:,usebestsftf(i,1),useprefthetaQuad(i),:,j,k,1),5));
                    dfsize(i,:,j,k,2) = squeeze(nanmean(dftuning(i,:,usebestsftf(i,1),useprefthetaQuad(i),:,j,k,2),5));
                end
            end
            hold on
            splotsit = squeeze(nanmean(dfsize(i,dfWindow,end,:,1),2));
            splotrun = squeeze(nanmean(dfsize(i,dfWindow,end,:,2),2));
            plot(1:length(radiusRange),splotsit,'k-o','Markersize',5)
            plot(1:length(radiusRange),splotrun,'r-o','Markersize',5)
            xlabel('Stim Size (deg)')
            ylabel('dfof')
            axis([0 length(radiusRange)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
            set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'))
            
            %%%contrast function
            subplot(2,3,6)
            hold on
            splotsit = squeeze(nanmean(dfsize(i,dfWindow,:,[1 4 7],1),2));
            splotrun = squeeze(nanmean(dfsize(i,dfWindow,:,[1 4 7],2),2));

            plot(1:length(contrastlist),splotsit,'k-o','Markersize',5)
%             set(groot,'defaultAxesColorOrder',sitcolor)
            plot(1:length(contrastlist),splotrun,'r-o','Markersize',5)
%             set(groot,'defaultAxesColorOrder',runcolor)
            xlabel('contrast')
            ylabel('dfof')
            axis([0 length(contrastlist)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
            set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'))
            
            mtit(sprintf('Cell #%d tuning',usecells(i)))
            if exist('psfile','var')
                set(gcf, 'PaperPositionMode', 'auto'); %%%figure out how to make this full page landscape
                print('-dpsc',psfile,'-append');
            end
        end
        
        %%%plot group data for size select
        figure
        hold on
        sit = squeeze(nanmean(nanmean(dfsize(:,dfWindow,:,:,1),2),1));
        run = squeeze(nanmean(nanmean(dfsize(:,dfWindow,:,:,2),2),1));
        subplot(1,2,1)
        plot(1:length(radiusRange),sit,'-o','Markersize',5)
        xlabel('Stim Size (deg)')
        ylabel('sitting dfof')
        axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
        axis square
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))

        subplot(1,2,2)
        plot(1:length(radiusRange),run,'-o','Markersize',5)
        legend(contrastlist,'location','northwest')
        xlabel('Stim Size (deg)')
        ylabel('running dfof')
        axis([0 length(radiusRange)+1 min(min([sit run]))-0.01 max(max([sit run]))+0.01])
        axis square
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
        mtit('Size Suppression Curve')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end
        

        %%%saving
        save(filename,'dftuning','sptuning','userf','dfsize','dfgrat','useosi','usedsi','usedfori')

        try
            dos(['ps2pdf ' psfile ' "' [filename '.pdf'] '"'] )
        catch
            display('couldnt generate pdf');
        end

        delete(psfile);
        close all
%     else
%         sprintf('skipping %s',filename)
%     end
end


%%%old code


%         %%%plot group data for cells
%         figure
%         subplot(1,2,1)
%         hold on
%         for i=1:length(contrastRange)
%             plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,dfWindow,:,:,:,i,:,1),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,5,:,:,:,i,:,1),5),4),3),2),1)));
%         end
%         axis([0 length(radiusRange)+1 -0.2 0.6])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         legend(contrastlist)
%         xlabel('Stim Size (deg)')
%         ylabel('Topo peak stationary dfof')
%         subplot(1,2,2)
%         hold on
%         for i=1:length(contrastRange)
%             plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,dfWindow,:,:,:,i,:,2),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,5,:,:,:,i,:,2),5),4),3),2),1)));
%         end
%         axis([0 length(radiusRange)+1 -0.2 0.6])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         legend(contrastlist)
%         xlabel('Stim Size (deg)')
%         ylabel('Topo peak running dfof')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
%         figure
%         subplot(1,2,1)
%         hold on
%         for i=1:length(contrastRange)
%             plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(goodTopo,dfWindow,:,:,:,i,:,1),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(:,5,:,:,:,i,:,1),5),4),3),2),1)));
%         end
%         axis([0 length(radiusRange)+1 -0.01 0.2])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         legend(contrastlist)
%         xlabel('Stim Size (deg)')
%         ylabel('Topo peak stationary spikes')
%         subplot(1,2,2)
%         hold on
%         for i=1:length(contrastRange)
%             plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(goodTopo,dfWindow,:,:,:,i,:,2),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(:,5,:,:,:,i,:,2),5),4),3),2),1)));
%         end
%         axis([0 length(radiusRange)+1 -0.01 0.2])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         legend(contrastlist)
%         xlabel('Stim Size (deg)')
%         ylabel('Topo peak running spikes')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end

%         %cell-by-cell analysis
%         clear tcourse
%         clear spcourse
%         for i = 1:length(radiusRange)
%             for j=1:2
%                 tcourse(:,:,i,j) = median(dFout2(goodTopo,:,find(radius==i&contrasts==contrastRange(end)&running==(j-1))),3);
%                 spcourse(:,:,i,j) = mean(spikesOut2(goodTopo,:,find(radius==i&contrasts==contrastRange(end)&running==(j-1))),3); %spikes/size average
%             end
%         end
%         stimper = size(tcourse,2)/3; %epoch duration
% 
%     %     for i=1:size(tcourse,3);
%     %         for j= 1:size(tcourse,1);
%     %             for k=1:2
%     %                 tcourse(j,:,i,k) = tcourse(j,:,i,k)-squeeze(nanmean(tcourse(j,stimper+1,i,k),2));
%     %                 %%%subtract off timepoint 6
%     %             end
%     %         end
%     %     end
%     % 
%     %     for i=1:size(spcourse,3);
%     %         for j= 1:size(spcourse,1);
%     %             for k=1:2
%     %                 spcourse(j,:,i,k) = spcourse(j,:,i,k)-squeeze(nanmean(spcourse(j,stimper+1,i,k),2));
%     %             end
%     %         end
%     %     end
% 
%         respPos = (nanmean(nanmean(tcourse(:,stimper+1:2*stimper,3,:),2),4)-nanmean(nanmean(tcourse(:,1:stimper,3,:),2),4)) > 0;
%         tcourse = tcourse(respPos,:,:,:);
%         spcourse = spcourse(respPos,:,:,:);
%         dFout = dFout(respPos,:,:);
% 
%         figure
%         for i = 1:size(tcourse,3)
%             subplot(2,ceil(size(tcourse,3)/2),i)
%             hold on
%             plot(timepts,squeeze(nanmean(tcourse(:,:,i,1),1)),'k')
%             plot(timepts,squeeze(nanmean(tcourse(:,:,i,2),1)),'r')
%             axis([timepts(1) timepts(end) -0.05 0.2])
%         end
%         mtit('Topo Mean dfof per size')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
%         figure
%         hold on
%         plot(timepts,squeeze(nanmean(nanmean(tcourse(:,:,:,1),1),3)),'k')
%         plot(timepts,squeeze(nanmean(nanmean(tcourse(:,:,:,2),1),3)),'r')
%         axis([timepts(1) timepts(end) -0.05 0.2])
%         legend('stationary','running')
%         title('Topo Total mean dfof')
%         xlabel('Time (s)')
%         ylabel('dfof')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
% 
%     %     for i = 1:floor(size(tcourse,1)/10):size(tcourse,1)
%     %         figure
%     %         for j=1:length(radiusRange)
%     %             subplot(2,length(radiusRange)/2,j)
%     %             hold on
%     %             plot(timepts,squeeze(dFout(i,:,find(radius==j&contrasts==contrastRange(end)))))
%     %             plot(timepts,squeeze(nanmean(dFout(i,:,find(radius==j&contrasts==contrastRange(end))),3)),'LineWidth',5,'Color','k')
%     %             axis([timepts(1) timepts(end) 0 1])
%     %         end
%     %         mtit(sprintf('Cell #%d dfof',i))
%     %         if exist('psfile','var')
%     %             set(gcf, 'PaperPositionMode', 'auto');
%     %             print('-dpsc',psfile,'-append');
%     %         end
%     %     end
% 
%         % peaks = max(dFout(:,1+stimper:stimper*2,:),[],2)-nanmean(dFout(:,1:stimper,:),2);
%         for i = 1:2
%             avgpeaks(:,i) = squeeze(nanmean(nanmean(tcourse(:,dfWindow,:,i),2),1));%-tcourse(usenonzero,stimper,:),1));
%             sepeaks(:,i) = squeeze(nanstd(nanmean(tcourse(:,dfWindow,:,i),2),1))/sqrt(length(goodTopo));%-tcourse(usenonzero,stimper,:),[],1));
%             avgspikes(:,i) = squeeze(nanmean(nanmean(spcourse(:,spWindow,:,i),2),1));
%             sespikes(:,i) = squeeze(nanstd(nanmean(spcourse(:,spWindow,:,i),2),1))/sqrt(length(goodTopo));
%         end
% 
%         % figure
%         % errorbar(1:length(radiusRange),avgpeaks,sepeaks)
%         % xlabel('Stim Size (deg)')
%         % ylabel('dfof')
%         % axis([0 length(radiusRange)+1 -0.01 0.1])
%         % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         % title('Peak response')
%         % if exist('psfile','var')
%         %     set(gcf, 'PaperPositionMode', 'auto');
%         %     print('-dpsc',psfile,'-append');
%         % end
% 
%         % avgpeaks = avgpeaks - avgpeaks(1);
% 
%         figure
%         hold on
%         errorbar(1:length(radiusRange),avgpeaks(:,1),sepeaks(:,1),'k')
%         errorbar(1:length(radiusRange),avgpeaks(:,2),sepeaks(:,2),'r')
%         legend('stationary','running')
%         xlabel('Stim Size (deg)')
%         ylabel('dfof')
%         axis([0 length(radiusRange)+1 -0.05 0.2])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         title('Topo Peak response');
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
%         figure
%         subplot(1,2,1)
%         plot(timepts,squeeze(nanmean(tcourse(:,:,:,1),1)))
%         legend(sizes)
%         xlabel('Time (s)')
%         ylabel('Topo stationary dfof')
%         axis([timepts(1) timepts(end) -0.05 0.2])
%         subplot(1,2,2)
%         plot(timepts,squeeze(nanmean(tcourse(:,:,:,2),1)))
%         legend(sizes)
%         xlabel('Time (s)')
%         ylabel('Topo running dfof')
%         axis([timepts(1) timepts(end) -0.05 0.2])
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
%         for i=1:2
%             grpavgpeaks(:,i) = squeeze(nanmean(nanmean(tcourse(:,dfWindow,:,i),1),2));
%         end
%         figure
%         hold on
%         plot(1:length(radiusRange),grpavgpeaks(:,1),'k')
%         plot(1:length(radiusRange),grpavgpeaks(:,2),'r')
%         legend('stationary','running')
%         xlabel('Stim Size (deg)')
%         ylabel('dfof')
%         axis([0 length(radiusRange)+1 -0.1 0.2])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         title('Topo Group avg peak resp');
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
% 
%         %spike stuff
%         figure
%         for i = 1:size(spcourse,3)
%             subplot(2,ceil(size(spcourse,3)/2),i)
%             hold on
%             plot(timepts,squeeze(nanmean(spcourse(:,:,i,1),1)),'k')
%             plot(timepts,squeeze(nanmean(spcourse(:,:,i,2),1)),'r')
%             axis([timepts(1) timepts(end) -0.1 0.5])
%         end
%         mtit('Topo Mean spikes per size')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
%         figure
%         hold on
%         plot(timepts,squeeze(nanmean(nanmean(spcourse(:,:,:,1),1),3)),'k')
%         plot(timepts,squeeze(nanmean(nanmean(spcourse(:,:,:,2),1),3)),'r')
%         axis([timepts(1) timepts(end) -0.1 0.5])
%         legend('stationary','running')
%         xlabel('Time (s)')
%         ylabel('Topo Total mean spikes')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
% %         for i = 1:floor(size(tcourse,1)/10):size(tcourse,1)
% %             figure
% %             for j=1:length(radiusRange)
% %                 subplot(2,length(radiusRange)/2,j)
% %                 hold on
% %                 plot(timepts,squeeze(spikesOut(i,:,find(radius==j&contrasts==contrastRange(end)))))
% %                 plot(timepts,squeeze(nanmean(spikesOut(i,:,find(radius==j&contrasts==contrastRange(end))),3)),'LineWidth',5,'Color','k')
% %                 axis([timepts(1) timepts(end) 0 5])
% %             end
% %             mtit(sprintf('Cell #%d Spikes',i))
% %             if exist('psfile','var')
% %                 set(gcf, 'PaperPositionMode', 'auto');
% %                 print('-dpsc',psfile,'-append');
% %             end
% %         end
% 
%         % figure
%         % errorbar(1:length(radiusRange),avgspikes,sespikes)
%         % xlabel('Stim Size (deg)')
%         % ylabel('Firing Rate')
%         % axis([0 length(radiusRange)+1 -0.1 0.5])
%         % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         % title('Peak response')
%         % if exist('psfile','var')
%         %     set(gcf, 'PaperPositionMode', 'auto');
%         %     print('-dpsc',psfile,'-append');
%         % end
% 
%         % avgspikes = avgspikes - avgspikes(1);
% 
%         figure
%         hold on
%         errorbar(1:length(radiusRange),avgspikes(:,1),sespikes(:,1))
%         errorbar(1:length(radiusRange),avgspikes(:,2),sespikes(:,2))
%         xlabel('Stim Size (deg)')
%         ylabel('Firing Rate')
%         axis([0 length(radiusRange)+1 -0.1 0.5])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         title('Topo Peak response')
%         legend('stationary','running')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
%         figure
%         subplot(1,2,1)
%         plot(timepts,squeeze(nanmean(spcourse(:,:,:,1),1)))
%         legend(sizes)
%         xlabel('Time (s)')
%         ylabel('Stationary Firing Rate')
%         axis([timepts(1) timepts(end) -0.1 0.5])
%         subplot(1,2,2)
%         plot(timepts,squeeze(nanmean(spcourse(:,:,:,2),1)))
%         legend(sizes)
%         xlabel('Time (s)')
%         ylabel('Topo Running Firing Rate')
%         axis([timepts(1) timepts(end) -0.1 0.5])
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
%         %%%%%
%         
%         
%         
%         figure
%         subplot(1,2,1)
%         hold on
%         for i=1:length(contrastRange)
%             plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(respcells,dfWindow,:,:,:,i,:,1),5),4),3),2),1)));%-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,5,:,:,:,i,:,1),5),4),3),2),1)));
%         end
%         axis([0 length(radiusRange)+1 -0.1 0.5])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         legend(contrastlist)
%         xlabel('Stim Size (deg)')
%         ylabel('Grating peak stationary dfof')
%         subplot(1,2,2)
%         hold on
%         for i=1:length(contrastRange)
%             plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(respcells,dfWindow,:,:,:,i,:,2),5),4),3),2),1)));%-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,5,:,:,:,i,:,2),5),4),3),2),1)));
%         end
%         axis([0 length(radiusRange)+1 -0.1 0.5])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         legend(contrastlist)
%         xlabel('Stim Size (deg)')
%         ylabel('Grating peak running dfof')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
% 
%         figure
%         subplot(1,2,1)
%         hold on
%         for i=1:length(contrastRange)
%             plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(respcells,dfWindow,:,:,:,i,:,1),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(:,5,:,:,:,i,:,1),5),4),3),2),1)));
%         end
%         axis([0 length(radiusRange)+1 -0.01 0.2])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         legend(contrastlist)
%         xlabel('Stim Size (deg)')
%         ylabel('Grating peak stationary spikes')
%         subplot(1,2,2)
%         hold on
%         for i=1:length(contrastRange)
%             plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(respcells,dfWindow,:,:,:,i,:,2),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(:,5,:,:,:,i,:,2),5),4),3),2),1)));
%         end
%         axis([0 length(radiusRange)+1 -0.01 0.2])
%         set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%         legend(contrastlist)
%         xlabel('Stim Size (deg)')
%         ylabel('Grating peak running spikes')
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
        
        
        
        

 % load(ptsfname,'meandfofInterp'); %load meandfofInterp
        % % if ~exist('polarImg','var')
        % %     [f p] = uigetfile('*.mat','session data');
        % %     load(fullfile(p,f),'polarImg')
        % % end
        % 
        % figure
        % hold on
        % plot(meandfofInterp-median(meandfofInterp),'g')
        % plot(mean(dF,1)-median(mean(dF,1)),'b')
        % legend('dF','dfofInterp')
        % hold off
        % if exist('psfile','var')
        %     set(gcf, 'PaperPositionMode', 'auto');
        %     print('-dpsc',psfile,'-append');
        % end

        % mouseT = stimRec.ts- stimRec.ts(2)+0.0001; %%% first is sometimes off
        %     figure
        %     plot(diff(mouseT));
        %     
        %     figure
        %     plot(mouseT - stimRec.f/60)
        %     ylim([-0.5 0.5])
        %     
        %     dt = diff(mouseT);
        %     use = [1<0; dt>0];
        %     mouseT=mouseT(use);
        %     
        %     posx = cumsum(stimRec.pos(use,1)-900);
        %     posy = cumsum(stimRec.pos(use,2)-500);
        %    if isnan(frameT)
        %        frameT = 0.1*(1:size(dfof_bg,3))';
        %    end
        %    frameT = frameT - frameT(1)+0.02;
        %     vx = diff(interp1(mouseT,posx,frameT));
        %     vy = diff(interp1(mouseT,posy,frameT));
        %     vx(end+1)=0; vy(end+1)=0;
        % 
        % figure
        % imagesc(dF,[0 1]); title('dF')

        
        % figure
        % imagesc(spikeBinned,[ 0 0.1]); title('spikes binned')

        

        % usenonzero = find(mean(spikes,2)~=0); %%% gets rid of generic points that were not identified in this session
        % usenonzero = 1:size(dF,1);
        % cellCutoff = input('cell cutoff : ');
        % usenonzero=usenonzero(usenonzero<cellCutoff);



        % 
        % 
        % useOld = input('auto select based on generic pts (1) or manually select points (2) or read in prev points (3) : ')
        % if useOld ==1
        % 
        %     getAnalysisPts;
        %     
        % elseif useOld==2
        %     [pts dF neuropil ptsfname] = get2pPtsManual(dfofInterp,greenframe);
        % else
        %     ptsfname = uigetfile('*.mat','pts file');
        %     load(ptsfname);
        % end
        % 
        % % usenonzero = find(mean(dF,2)~=0); %%% gets rid of generic points that were not identified in this session
        % usenonzero = 1:size(dF,1);
        % 
        % figure
        % % imagesc(dF(usenonzero,:),[0 1]); ylabel('cell #'); xlabel('frame'); colormap jet
        % imagesc(dF(usenonzero,:),[0 1]); ylabel('cell #'); xlabel('frame'); colormap jet
        
        

% %         %%%plot for each cell the responses at preferred sf/ori for each size,
% %         %%%and ori tuning curve at best sf       
% %         for i = 1:length(allCellsind)
% %             figure
% %             for j = 1:length(sizes)
% %                 subplot(2,4,j)
% %                 hold on
% %                 plot(timepts,squeeze(dftuning(allCellsind(i),:,bestdf(allCellsind(i),1),bestdf(allCellsind(i),2),:,end,j,1)))
% %                 plot(timepts,squeeze(dftuning(allCellsind(i),:,bestdf(allCellsind(i),1),bestdf(allCellsind(i),2),:,end,j,2)))
% %                 axis([-0.5 1.5 -0.2 1.5])
% %             end
% %             mtit(sprintf('Best sf/ori responses Cell #%s',num2str(allCellsind(i))))
% %             if exist('psfile','var')
% %                 set(gcf, 'PaperPositionMode', 'auto');
% %                 print('-dpsc',psfile,'-append');
% %             end
% %             figure
% %             subplot(2,2,1)
% %             hold on
% %             plot(1:length(thetaRange),squeeze(nanmean(nanmean(dftuning(allCellsind(i),dfWindow,bestdf(allCellsind(i),1),:,:,end,4,1),5),2)),'k') %plot runing
% %             plot(1:length(thetaRange),squeeze(nanmean(nanmean(dftuning(allCellsind(i),dfWindow,bestdf(allCellsind(i),1),:,:,end,4,2),5),2)),'r')
% %             xlabel('Ori Quadrant')
% %             ylabel('dfof')
% % %             axis([0 5 -0.2 1.5])
% %             subplot(2,2,2)
% %             resp = squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(allCellsind(i),:,:,:,:,:,3:end,:),3),4),5),6),7),8)); %%try plotting all to see if beggining=end 0.5sec
% %             plot(timepts,resp,'k-')
% %             axis([-0.5 0.9 min(resp)+0.1*min(resp) max(resp)+0.1*max(resp)])
% %             xlabel('time(s)')
% %             ylabel('dfof')
% %             subplot(2,2,3)
% %             hold on
% %             plot(1:length(thetaRange),squeeze(nanmean(nanmean(sptuning(allCellsind(i),spWindow,bestsp(allCellsind(i),1),:,:,end,4,1),5),2)),'k') %plot runing
% %             plot(1:length(thetaRange),squeeze(nanmean(nanmean(sptuning(allCellsind(i),spWindow,bestsp(allCellsind(i),1),:,:,end,4,2),5),2)),'r')
% %             xlabel('Ori Quadrant')
% %             ylabel('spikes')
% % %             axis([0 5 -0.2 1.5])
% %             subplot(2,2,4)
% %             resp = squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(allCellsind(i),:,:,:,:,:,3:end,:),3),4),5),6),7),8)); %%try plotting all to see if beggining=end 0.5sec
% %             plot(timepts,resp,'k-')
% %             axis([-0.5 0.9 min(resp)+0.1*min(resp) max(resp)+0.1*max(resp)])
% %             xlabel('time(s)')
% %             ylabel('spikes')
% %             mtit(sprintf('Ori tuning Cell #%s',num2str(allCellsind(i))))
% %             if exist('psfile','var')
% %                 set(gcf, 'PaperPositionMode', 'auto');
% %                 print('-dpsc',psfile,'-append');
% %             end
% %         end

%%%get sf and ori preference find any cells that respond well to size 20deg
%         maxrespdf = nan(size(dFout,1),2); maxrespsp = maxrespdf; bestdf = maxrespdf; bestsp = maxrespdf;
%         [maxrespdf(:,1) bestdf(:,1)] = max(squeeze(nanmean(nanmean(nanmean(dftuningall(:,dfWindow,:,:,:,end,4,1),2),4),5)),[],2); %best sf
%         [maxrespdf(:,2) bestdf(:,2)] = max(squeeze(nanmean(nanmean(nanmean(dftuningall(:,dfWindow,:,:,:,end,4,1),2),3),5)),[],2); %best ori
%         [maxrespsp(:,1) bestsp(:,1)] = max(squeeze(nanmean(nanmean(nanmean(sptuningall(:,spWindow,:,:,:,end,4,1),2),4),5)),[],2);
%         [maxrespsp(:,2) bestsp(:,2)] = max(squeeze(nanmean(nanmean(nanmean(sptuningall(:,spWindow,:,:,:,end,4,1),2),3),5)),[],2);
        

%         allCells = ~sbc; %starting group of cells %topoxUse(1:end-1)&topoyUse(1:end-1)&
%         allCellsind = find(allCells==1);