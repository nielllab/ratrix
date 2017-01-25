%%% based on session data and generic points, does pointwise analysis
%%% for topo (periodic spatial) stimuli
% clear all
% close all
% dbstop if error

%%%pull out preferences for each cell and use only those types of trials

% pre = 1; %1 if pre, 0 if post, determines naming of output file
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
    if exist(filename)==0
        files(use(f)).subj
        psfile = 'c:\tempPhil2p.ps';
        if exist(psfile,'file')==2;delete(psfile);end

        clear xph yph phaseVal rfCyc cycAvg rfAmp rf

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

        respthresh=0.025;
        %%% select cells responsive to both topoX and topoY
        dpix = 0.8022; centrad = 10; ycent = 72/2; xcent = 128/2; %%deg/pix, radius of response size cutoff, x and y screen centers
        d = sqrt((rf(:,1)-xcent).^2 + (rf(:,2)-ycent).^2);
        %goodTopo = find(rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01 & (xcent-dpix*centrad)<rf(:,1) & rf(:,1)<(xcent+dpix*centrad)& (ycent-dpix*centrad)<rf(:,2) & rf(:,2)<(ycent+dpix*centrad));
        goodTopo = find(rfAmp(:,1)>respthresh & rfAmp(:,2)>respthresh & d<centrad/dpix);
        goodTopo=goodTopo(goodTopo<=cellCutoff);
        sprintf('%d cells in center with good topo under cutoff',length(goodTopo))

        allgoodTopo = find(~sbc & rfAmp(:,1)>respthresh & rfAmp(:,2)>respthresh); allgoodTopo = allgoodTopo(allgoodTopo<=cellCutoff);
        sprintf('%d cells with good topo under cutoff',length(allgoodTopo))
        %%% plot RF locations
        figure
        hold on
        plot(rf(allgoodTopo,2),rf(allgoodTopo,1),'.','color',[0.5 0.5 0.5],'MarkerSize',10); %%% the rfAmp criterion wasn't being applied here
        plot(rf(goodTopo,2),rf(goodTopo,1),'b.','MarkerSize',10);
        circle(ycent,xcent,centrad/dpix)
        axis equal;
        axis([0 72 0 128]);
        title('Cells w/good topo')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        % load size select points file
        load(files(use(f)).sizepts);
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

        load(files(use(f)).sizestimObj);
        spInterp = get2pSpeed(stimRec,dt,size(dF,2));

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

        spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);
        % figure
        % imagesc(spikeBinned,[ 0 0.1]); title('spikes binned')

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

        ntrials= min(dt*length(dF)/(isi+duration),length(sf));
        onsets = dt + (0:ntrials-1)*(isi+duration);
        timepts = 1:(2*isi+duration)/dt;
        timepts = (timepts-1)*dt;
        dFout = align2onsets(dF,onsets,dt,timepts);
        dFout = dFout(1:end-1,:,:); %%%extra cell at end for some reason
    %     dFout = dFout(goodTopo,:,:);
        spikesOut = align2onsets(spikes*10,onsets,dt,timepts);
    %     spikesOut = spikesOut(goodTopo,:,:);
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

        %stopped here for thetaQuad revision
        dftuningall = zeros(size(dFout,1),size(dFout,2),length(sfrange),length(thetaRange),length(phaserange),length(contrastRange),length(radiusRange),2);
        sptuningall = zeros(size(spikesOut,1),size(spikesOut,2),length(sfrange),length(thetaRange),length(phaserange),length(contrastRange),length(radiusRange),2);
        for h = 1:size(dFout,1)
            for i = 1:length(sfrange)
                for j = 1:length(thetaRange)
                    for k = 1:length(phaserange)
                        for l = 1:length(contrastRange)
                            for m = 1:length(radiusRange)
                                for n = 1:2
                                    dftuningall(h,1:size(dFout,2),i,j,k,l,m,n) = nanmean(dFout2(h,:,find(sf==sfrange(i)&thetaQuad==thetaRange(j)&phase==phaserange(k)&contrasts==contrastRange(l)&radius==m&running==(n-1))),3);
                                    sptuningall(h,1:size(spikesOut,2),i,j,k,l,m,n) = nanmean(spikesOut2(h,:,find(sf==sfrange(i)&thetaQuad==thetaRange(j)&phase==phaserange(k)&contrasts==contrastRange(l)&radius==m&running==(n-1))),3);
                                end
                            end
                        end
                    end
                end
            end
        end

        %%%get sf and ori preference find any cells that respond well to size 20deg
        maxrespdf = nan(size(dFout,1),2); maxrespsp = maxrespdf; bestdf = maxrespdf; bestsp = maxrespdf;
        [maxrespdf(:,1) bestdf(:,1)] = max(squeeze(nanmean(nanmean(nanmean(dftuningall(:,dfWindow,:,:,:,end,4,1),2),4),5)),[],2); %best sf
        [maxrespdf(:,2) bestdf(:,2)] = max(squeeze(nanmean(nanmean(nanmean(dftuningall(:,dfWindow,:,:,:,end,4,1),2),3),5)),[],2); %best ori
        [maxrespsp(:,1) bestsp(:,1)] = max(squeeze(nanmean(nanmean(nanmean(sptuningall(:,spWindow,:,:,:,end,4,1),2),4),5)),[],2);
        [maxrespsp(:,2) bestsp(:,2)] = max(squeeze(nanmean(nanmean(nanmean(sptuningall(:,spWindow,:,:,:,end,4,1),2),3),5)),[],2);

        dftuning = dftuningall;%(goodTopo,:,:,:,:,:,:); %%only cells with good topo
        sptuning = sptuningall;%(goodTopo,:,:,:,:,:,:); %%only cells with good topo
%         rf = rf(goodTopo,:)
        allCells = ~sbc; %starting group of cells %topoxUse(1:end-1)&topoyUse(1:end-1)&
        allCellsind = find(allCells==1);
        
        %%%plot screen for all six sizes w/threshold label for reponsive
        figure
        hold on
        for i=1:length(sizes)
            subplot(2,4,i)
            respCells = find(allCells&squeeze(nanmean(nanmean(nanmean(nanmean(dftuningall(:,dfWindow,:,:,:,end,i,1),2),3),4),5))>respthresh); %%%respCells = respCells(respCells<=cellCutoff);
            hold on
            plot(rf(allCells,2),rf(allCells,1),'.','color',[0.5 0.5 0.5],'MarkerSize',10); %%% the rfAmp criterion wasn't being applied here
            plot(rf(respCells,2),rf(respCells,1),'b.','MarkerSize',10);
            circle(ycent,xcent,centrad/dpix)
            axis equal;
            axis([0 72 0 128]);
        end
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

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

        %%%goodTopo cell plotting
        figure
        subplot(1,2,1)
        hold on
        for i=1:length(contrastRange)
            plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(goodTopo,dfWindow,:,:,:,i,:,1),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,5,:,:,:,i,:,1),5),4),3),2),1)));
        end
        axis([0 length(radiusRange)+1 -0.01 0.05])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        legend(contrastlist)
        xlabel('Stim Size (deg)')
        ylabel('peak stationary dfof')
        subplot(1,2,2)
        hold on
        for i=1:length(contrastRange)
            plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(goodTopo,dfWindow,:,:,:,i,:,2),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,5,:,:,:,i,:,2),5),4),3),2),1)));
        end
        axis([0 length(radiusRange)+1 -0.01 0.05])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        legend(contrastlist)
        xlabel('Stim Size (deg)')
        ylabel('peak running dfof')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        figure
        subplot(1,2,1)
        hold on
        for i=1:length(contrastRange)
            plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(goodTopo,dfWindow,:,:,:,i,:,1),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(:,5,:,:,:,i,:,1),5),4),3),2),1)));
        end
        axis([0 length(radiusRange)+1 -0.01 0.2])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        legend(contrastlist)
        xlabel('Stim Size (deg)')
        ylabel('peak stationary spikes')
        subplot(1,2,2)
        hold on
        for i=1:length(contrastRange)
            plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(goodTopo,dfWindow,:,:,:,i,:,2),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(:,5,:,:,:,i,:,2),5),4),3),2),1)));
        end
        axis([0 length(radiusRange)+1 -0.01 0.2])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        legend(contrastlist)
        xlabel('Stim Size (deg)')
        ylabel('peak running spikes')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        %cell-by-cell analysis
        clear tcourse
        clear spcourse
        for i = 1:length(radiusRange)
            for j=1:2
                tcourse(:,:,i,j) = median(dFout2(goodTopo,:,find(radius==i&contrasts==contrastRange(end)&running==(j-1))),3);
                spcourse(:,:,i,j) = mean(spikesOut2(goodTopo,:,find(radius==i&contrasts==contrastRange(end)&running==(j-1))),3); %spikes/size average
            end
        end
        stimper = size(tcourse,2)/3; %epoch duration

    %     for i=1:size(tcourse,3);
    %         for j= 1:size(tcourse,1);
    %             for k=1:2
    %                 tcourse(j,:,i,k) = tcourse(j,:,i,k)-squeeze(nanmean(tcourse(j,stimper+1,i,k),2));
    %                 %%%subtract off timepoint 6
    %             end
    %         end
    %     end
    % 
    %     for i=1:size(spcourse,3);
    %         for j= 1:size(spcourse,1);
    %             for k=1:2
    %                 spcourse(j,:,i,k) = spcourse(j,:,i,k)-squeeze(nanmean(spcourse(j,stimper+1,i,k),2));
    %             end
    %         end
    %     end

        respPos = (nanmean(nanmean(tcourse(:,stimper+1:2*stimper,3,:),2),4)-nanmean(nanmean(tcourse(:,1:stimper,3,:),2),4)) > 0;
        tcourse = tcourse(respPos,:,:,:);
        spcourse = spcourse(respPos,:,:,:);
%         dFout = dFout(respPos,:,:);

        figure
        for i = 1:size(tcourse,3)
            subplot(2,ceil(size(tcourse,3)/2),i)
            hold on
            plot(timepts,squeeze(nanmean(tcourse(:,:,i,1),1)),'k')
            plot(timepts,squeeze(nanmean(tcourse(:,:,i,2),1)),'r')
            axis([timepts(1) timepts(end) -0.05 0.2])
        end
        mtit('Mean dfof per size')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end
        figure
        hold on
        plot(timepts,squeeze(nanmean(nanmean(tcourse(:,:,:,1),1),3)),'k')
        plot(timepts,squeeze(nanmean(nanmean(tcourse(:,:,:,2),1),3)),'r')
        axis([timepts(1) timepts(end) -0.05 0.2])
        legend('stationary','running')
        title('Total mean dfof')
        xlabel('Time (s)')
        ylabel('dfof')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end


    %     for i = 1:floor(size(tcourse,1)/10):size(tcourse,1)
    %         figure
    %         for j=1:length(radiusRange)
    %             subplot(2,length(radiusRange)/2,j)
    %             hold on
    %             plot(timepts,squeeze(dFout(i,:,find(radius==j&contrasts==contrastRange(end)))))
    %             plot(timepts,squeeze(nanmean(dFout(i,:,find(radius==j&contrasts==contrastRange(end))),3)),'LineWidth',5,'Color','k')
    %             axis([timepts(1) timepts(end) 0 1])
    %         end
    %         mtit(sprintf('Cell #%d dfof',i))
    %         if exist('psfile','var')
    %             set(gcf, 'PaperPositionMode', 'auto');
    %             print('-dpsc',psfile,'-append');
    %         end
    %     end

        % peaks = max(dFout(:,1+stimper:stimper*2,:),[],2)-nanmean(dFout(:,1:stimper,:),2);
        for i = 1:2
            avgpeaks(:,i) = squeeze(nanmean(nanmean(tcourse(:,dfWindow,:,i),2),1));%-tcourse(usenonzero,stimper,:),1));
            sepeaks(:,i) = squeeze(nanstd(nanmean(tcourse(:,dfWindow,:,i),2),1))/sqrt(length(goodTopo));%-tcourse(usenonzero,stimper,:),[],1));
            avgspikes(:,i) = squeeze(nanmean(nanmean(spcourse(:,spWindow,:,i),2),1));
            sespikes(:,i) = squeeze(nanstd(nanmean(spcourse(:,spWindow,:,i),2),1))/sqrt(length(goodTopo));
        end

        % figure
        % errorbar(1:length(radiusRange),avgpeaks,sepeaks)
        % xlabel('Stim Size (deg)')
        % ylabel('dfof')
        % axis([0 length(radiusRange)+1 -0.01 0.1])
        % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        % title('Peak response')
        % if exist('psfile','var')
        %     set(gcf, 'PaperPositionMode', 'auto');
        %     print('-dpsc',psfile,'-append');
        % end

        % avgpeaks = avgpeaks - avgpeaks(1);

        figure
        hold on
        errorbar(1:length(radiusRange),avgpeaks(:,1),sepeaks(:,1),'k')
        errorbar(1:length(radiusRange),avgpeaks(:,2),sepeaks(:,2),'r')
        legend('stationary','running')
        xlabel('Stim Size (deg)')
        ylabel('dfof')
        axis([0 length(radiusRange)+1 -0.05 0.2])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        title('Peak response');
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        figure
        subplot(1,2,1)
        plot(timepts,squeeze(nanmean(tcourse(:,:,:,1),1)))
        legend(sizes)
        xlabel('Time (s)')
        ylabel('stationary dfof')
        axis([timepts(1) timepts(end) -0.05 0.2])
        subplot(1,2,2)
        plot(timepts,squeeze(nanmean(tcourse(:,:,:,2),1)))
        legend(sizes)
        xlabel('Time (s)')
        ylabel('running dfof')
        axis([timepts(1) timepts(end) -0.05 0.2])
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        for i=1:2
            grpavgpeaks(:,i) = squeeze(nanmean(nanmean(tcourse(:,dfWindow,:,i),1),2));
        end
        figure
        hold on
        plot(1:length(radiusRange),grpavgpeaks(:,1),'k')
        plot(1:length(radiusRange),grpavgpeaks(:,2),'r')
        legend('stationary','running')
        xlabel('Stim Size (deg)')
        ylabel('dfof')
        axis([0 length(radiusRange)+1 -0.1 0.2])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        title('Group avg peak resp');
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end


        %spike stuff
        figure
        for i = 1:size(spcourse,3)
            subplot(2,ceil(size(spcourse,3)/2),i)
            hold on
            plot(timepts,squeeze(nanmean(spcourse(:,:,i,1),1)),'k')
            plot(timepts,squeeze(nanmean(spcourse(:,:,i,2),1)),'r')
            axis([timepts(1) timepts(end) -0.1 0.5])
        end
        mtit('Mean spikes per size')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        figure
        hold on
        plot(timepts,squeeze(nanmean(nanmean(spcourse(:,:,:,1),1),3)),'k')
        plot(timepts,squeeze(nanmean(nanmean(spcourse(:,:,:,2),1),3)),'r')
        axis([timepts(1) timepts(end) -0.1 0.5])
        legend('stationary','running')
        xlabel('Time (s)')
        ylabel('Total mean spikes')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

%         for i = 1:floor(size(tcourse,1)/10):size(tcourse,1)
%             figure
%             for j=1:length(radiusRange)
%                 subplot(2,length(radiusRange)/2,j)
%                 hold on
%                 plot(timepts,squeeze(spikesOut(i,:,find(radius==j&contrasts==contrastRange(end)))))
%                 plot(timepts,squeeze(nanmean(spikesOut(i,:,find(radius==j&contrasts==contrastRange(end))),3)),'LineWidth',5,'Color','k')
%                 axis([timepts(1) timepts(end) 0 5])
%             end
%             mtit(sprintf('Cell #%d Spikes',i))
%             if exist('psfile','var')
%                 set(gcf, 'PaperPositionMode', 'auto');
%                 print('-dpsc',psfile,'-append');
%             end
%         end

        % figure
        % errorbar(1:length(radiusRange),avgspikes,sespikes)
        % xlabel('Stim Size (deg)')
        % ylabel('Firing Rate')
        % axis([0 length(radiusRange)+1 -0.1 0.5])
        % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        % title('Peak response')
        % if exist('psfile','var')
        %     set(gcf, 'PaperPositionMode', 'auto');
        %     print('-dpsc',psfile,'-append');
        % end

        % avgspikes = avgspikes - avgspikes(1);

        figure
        hold on
        errorbar(1:length(radiusRange),avgspikes(:,1),sespikes(:,1))
        errorbar(1:length(radiusRange),avgspikes(:,2),sespikes(:,2))
        xlabel('Stim Size (deg)')
        ylabel('Firing Rate')
        axis([0 length(radiusRange)+1 -0.1 0.5])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        title('Peak response')
        legend('stationary','running')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        figure
        subplot(1,2,1)
        plot(timepts,squeeze(nanmean(spcourse(:,:,:,1),1)))
        legend(sizes)
        xlabel('Time (s)')
        ylabel('Stationary Firing Rate')
        axis([timepts(1) timepts(end) -0.1 0.5])
        subplot(1,2,2)
        plot(timepts,squeeze(nanmean(spcourse(:,:,:,2),1)))
        legend(sizes)
        xlabel('Time (s)')
        ylabel('Running Firing Rate')
        axis([timepts(1) timepts(end) -0.1 0.5])
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        %%%use output from gratings analysis to pick cells
        gratfile = files(use(f)).gratinganalysis;
        load(gratfile,'prefthetaQuad','bestsftf','respcells')
        bestsftf(find(bestsftf(:,1)==2),1)=1; %%combine 0.01 and 0.04 pref, set to index 1
        bestsftf(find(bestsftf(:,1)==3),1)=2; %%0.16, change to index 2
        
        sizecurve = nan(size(dFout,1),length(radiusRange),2);
        for i=1:size(dFout,1)
            sizecurve(i,:,1) = squeeze(nanmean(nanmean(dftuning(i,dfWindow,bestsftf(i,1),prefthetaQuad(i),:,end,:,1),2),5));
            sizecurve(i,:,2) = squeeze(nanmean(nanmean(dftuning(i,dfWindow,bestsftf(i,1),prefthetaQuad(i),:,end,:,2),2),5));
        end
        figure
        hold on
        errorbar(1:length(radiusRange),nanmean(sizecurve(respcells,:,1)),'k')
        errorbar(1:length(radiusRange),nanmean(sizecurve(respcells,:,2)),'r')
        legend('stationary','running')
        xlabel('Stim Size (deg)')
        ylabel('dfof')
        axis([0 length(radiusRange)+1 -0.1 0.2])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        
        
        figure
        subplot(1,2,1)
        hold on
        for i=1:length(contrastRange)
            plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(respcells,dfWindow,:,:,:,i,:,1),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,5,:,:,:,i,:,1),5),4),3),2),1)));
        end
        axis([0 length(radiusRange)+1 -0.01 0.05])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        legend(contrastlist)
        xlabel('Stim Size (deg)')
        ylabel('peak stationary dfof')
        subplot(1,2,2)
        hold on
        for i=1:length(contrastRange)
            plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(respcells,dfWindow,:,:,:,i,:,2),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(dftuning(:,5,:,:,:,i,:,2),5),4),3),2),1)));
        end
        axis([0 length(radiusRange)+1 -0.01 0.05])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        legend(contrastlist)
        xlabel('Stim Size (deg)')
        ylabel('peak running dfof')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end

        figure
        subplot(1,2,1)
        hold on
        for i=1:length(contrastRange)
            plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(respcells,dfWindow,:,:,:,i,:,1),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(:,5,:,:,:,i,:,1),5),4),3),2),1)));
        end
        axis([0 length(radiusRange)+1 -0.01 0.2])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        legend(contrastlist)
        xlabel('Stim Size (deg)')
        ylabel('peak stationary spikes')
        subplot(1,2,2)
        hold on
        for i=1:length(contrastRange)
            plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(respcells,dfWindow,:,:,:,i,:,2),5),4),3),2),1))-squeeze(nanmean(nanmean(nanmean(nanmean(nanmean(sptuning(:,5,:,:,:,i,:,2),5),4),3),2),1)));
        end
        axis([0 length(radiusRange)+1 -0.01 0.2])
        set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
        legend(contrastlist)
        xlabel('Stim Size (deg)')
        ylabel('peak running spikes')
        if exist('psfile','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfile,'-append');
        end
        
        
        
        
        %%%saving
        save(filename,'dftuning','sptuning','rf','goodTopo')

        try
            dos(['ps2pdf ' psfile ' "' [filename '.pdf'] '"'] )
        catch
            display('couldnt generate pdf');
        end

        delete(psfile);
        close all
    else
        sprintf('skipping %s',filename)
    end
end