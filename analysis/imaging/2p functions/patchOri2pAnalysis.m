%patchOri2pAnalysis

dfWindow = 9:11;
spWindow = 6:10;
dt = 0.1;
cyclelength = 1/0.1;
exclude=0;

%%%load gratings movie
orimoviename = 'C:\patchOrientations15min.mat';
%%%info for this movie: contrast=1, phase=random, radius = 20deg, nx/ny=1, sf = 3x, tf= 2x
load(orimoviename);

%%%set parameters for stimuli
contrastrange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
radiusrange=unique(radius); tfrange=unique(tf); dirrange=unique(theta);
thetamod = mod(theta,pi)-pi/8;
thetaQuad = zeros(1,length(theta)); %break orientation into quadrants, 1=top,2=right,3=bot,4=left, offset pi/8 CCW
thetaQuad(1,find(-pi/8<=thetamod&thetamod<pi/8))=1;
thetaQuad(1,find(pi/8<=thetamod&thetamod<3*pi/8))=2;
thetaQuad(1,find(3*pi/8<=thetamod&thetamod<5*pi/8))=3;
thetaQuad(1,find(5*pi/8<=thetamod&thetamod<=7*pi/8))=4;
orirange = unique(thetaQuad);

%%%loop through individual animal files
for f=1:length(use)
    filename = files(use(f)).gratinganalysis
%     if exist(filename)==0 %%%only perform analysis if file doesn't already exist
        files(use(f)).subj
%         psfile = 'c:\tempPhil2p.ps';
%         if exist(psfile,'file')==2;delete(psfile);end
        
        respthresh=0.01; %%%set topox/topoy response threshold %%change to match sizeSelect
        clear xph yph phaseVal rfCyc cycAvg rfAmp rf
        load(files(use(f)).topoxpts);
        %%% extract phase and amplitude from complex fourier varlue at 0.1Hz
        xph = phaseVal; rfCyc(:,:,1) = cycAvg;  %%%cycle averaged timecourse (10sec period)
        rfAmp(:,1) = abs(xph); rf(:,1) = mod(angle(xph)-(2*pi*0.25/10),2*pi)*128/(2*pi); %%% convert phase to pixel position, subtract 0.25sec from phase for gcamp delay
        topoxUse = mean(dF,2)~=0;  %%% find cells that were successfully extracted
        load(files(use(f)).topoypts);
        %%% extract phase and amplitude from complex fourier varlue at 0.1Hz
        yph = phaseVal; rfCyc(:,:,2) = cycAvg;
        rf(:,2) = mod(angle(yph)-(2*pi*0.25/10),2*pi)*72/(2*pi); rfAmp(:,2) = abs(yph);
        topoyUse = mean(dF,2)~=0;

        cellCutoff = files(use(f)).cutoff %%%use cell cutoff from batch file

        %%% find sbc? use distance from center?
        d1 = sqrt((mod(angle(xph),2*pi)-pi).^2 + (mod(angle(yph),2*pi)-pi).^2);
        d2 = sqrt((mod(angle(xph)+pi,2*pi)-pi).^2 + (mod(angle(yph)+pi,2*pi)-pi).^2);
        sbc = (d1>d2);

        %%% select cells responsive to both topoX and topoY
        dpix = 0.8022; centrad = 10; ycent = 72/2; xcent = 128/2; %%deg/pix, radius of response size cutoff, x and y screen centers
        d = sqrt((rf(:,1)-xcent).^2 + (rf(:,2)-ycent).^2);
        %goodTopo = find(rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01 & (xcent-dpix*centrad)<rf(:,1) & rf(:,1)<(xcent+dpix*centrad)& (ycent-dpix*centrad)<rf(:,2) & rf(:,2)<(ycent+dpix*centrad));
        goodTopo = find(rfAmp(:,1)>respthresh & rfAmp(:,2)>respthresh & d<centrad/dpix);
        goodTopo=goodTopo(goodTopo<=cellCutoff); %%%these are cells with good receptive fields in the center 20deg of the screen
        sprintf('%d cells in center with good topo under cutoff',length(goodTopo))

        allgoodTopo = find(~sbc & rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01); allgoodTopo = allgoodTopo(allgoodTopo<=cellCutoff);
        sprintf('%d cells with good topo under cutoff',length(allgoodTopo)) %%%these are cells with good receptive fields
        
        %%%load patch gratings data
        load(files(use(f)).gratingpts);
        load(files(use(f)).gratingstimObj);
        spInterp = get2pSpeed(stimRec,dt,size(dF,2));
        spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);
        
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
        
        %%%subtract baseline period
        dFout2 = dFout;
        spikesOut2 = spikesOut;
        for i = 1:size(dFout,1)
            for j = 1:size(dFout,3)
                dFout2(i,:,j) = dFout(i,:,j)-nanmean(dFout(i,1:4,j));
                spikesOut2(i,:,j) = spikesOut(i,:,j)-nanmean(spikesOut(i,1:4,j));
            end
        end
        
        %%%create arrays with trial averaged responses for diff stim
        %%%parameters for dfof and deconvolved spike data
        dfgratuning = zeros(size(dFout,1),size(dFout,2),length(sfrange),length(tfrange),length(dirrange),2);
        spgratuning = zeros(size(spikesOut,1),size(spikesOut,2),length(sfrange),length(tfrange),length(dirrange),2);
        for h = 1:size(dFout,1)
            for i = 1:length(sfrange)
                for j = 1:length(tfrange)
                    for k = 1:length(dirrange)
                        for l = 1:2
                            dfgratuning(h,1:size(dFout2,2),i,j,k,l) = nanmean(dFout2(h,:,find(sf==sfrange(i)&tf==tfrange(j)&theta==dirrange(k)&running==(l-1))),3);
                            spgratuning(h,1:size(spikesOut2,2),i,j,k,l) = nanmean(spikesOut2(h,:,find(sf==sfrange(i)&tf==tfrange(j)&theta==dirrange(k)&running==(l-1))),3);
                        end
                    end
                end
            end
        end
             
        %%%get best sf and tf for each cell
        bestsftfresp = nan(size(dFout,1),2,2); bestsftf = bestsftfresp; 
        [bestsftfresp(:,1,1) bestsftf(:,1,1)] = max(squeeze(nanmean(nanmean(nanmean(nanmean(dfgratuning(:,dfWindow,:,:,:,1),2),4),5),6)),[],2); %best sf
        [bestsftfresp(:,2,1) bestsftf(:,2,1)] = max(squeeze(nanmean(nanmean(nanmean(nanmean(dfgratuning(:,dfWindow,:,:,:,1),2),3),5),6)),[],2); %best tf
        [bestsftfresp(:,1,2) bestsftf(:,1,2)] = max(squeeze(nanmean(nanmean(nanmean(nanmean(dfgratuning(:,dfWindow,:,:,:,2),2),4),5),6)),[],2); %best sf
        [bestsftfresp(:,2,2) bestsftf(:,2,2)] = max(squeeze(nanmean(nanmean(nanmean(nanmean(dfgratuning(:,dfWindow,:,:,:,2),2),3),5),6)),[],2); %best tf
        dfori = nan(size(dFout2,1),12,2);
        for i=1:size(dFout2,1)
            dfori(i,:,1) = squeeze(nanmean(dfgratuning(i,dfWindow,bestsftf(i,1,1),bestsftf(i,2,1),:,1),2));
            dfori(i,:,2) = squeeze(nanmean(dfgratuning(i,dfWindow,bestsftf(i,1,1),bestsftf(i,2,1),:,2),2));
            [osi(i,1) prefori(i,1)] = calcOSI(dfori(i,:,1)',0);
            [dsi(i,1) prefdir(i,1)] = calcOSI(dfori(i,:,1)',1);
            [osi(i,2) prefori(i,2)] = calcOSI(dfori(i,:,2)',0);
            [dsi(i,2) prefdir(i,2)] = calcOSI(dfori(i,:,2)',1);
        end
        thetaresp=nan(size(dFout,1),2);preftheta=thetaresp;
        %%%get preferred direction for each cell
        [thetaresp(:,1) preftheta(:,1)] = max(dfori(:,:,1),[],2);
        [thetaresp(:,2) preftheta(:,2)] = max(dfori(:,:,2),[],2);
        for i = 1:size(preftheta,1)
            preftheta(i,1) = dirrange(preftheta(i,1));
            preftheta(i,2) = dirrange(preftheta(i,2));
        end
        %%%transform preferred direction into quadrants to match up with
        %%%size select stimulus
        preftheta = mod(preftheta,pi)-pi/8;
        prefthetaQuad = nan(length(preftheta),2); %break orientation into quadrants, 1=top,2=right,3=bot,4=left, offset pi/8 CCW
        prefthetaQuad(find(-pi/8<=preftheta&preftheta<pi/8))=1;
        prefthetaQuad(find(pi/8<=preftheta&preftheta<3*pi/8))=2;
        prefthetaQuad(find(3*pi/8<=preftheta&preftheta<5*pi/8))=3;
        prefthetaQuad(find(5*pi/8<=preftheta&preftheta<=7*pi/8))=4;
        
        %%%plot cells responsive at different thresholds to the gratings
        %%%compared to all cells with good topo and not sbc
        gratthreshlist = [0.025, 0.05, 0.1, 0.2, 0.5, 1.0];
        gratrespfig = figure;
        for i = 1:length(gratthreshlist)
            respcells = find(max(dfori(:,:,1),[],2)>=gratthreshlist(i)); respcells=intersect(respcells(respcells<cellCutoff),allgoodTopo);
    %         sprintf('%d responsive cells under cutoff',length(respcells))  
            %%%plot responsive cells on screen w/non-responsive
            subplot(2,3,i)
            hold on
            plot(rf(allgoodTopo,2),rf(allgoodTopo,1),'.','color',[0.5 0.5 0.5],'MarkerSize',5); %%% the rfAmp criterion wasn't being applied here
            plot(rf(respcells,2),rf(respcells,1),'b.','MarkerSize',5);
            circle(ycent,xcent,centrad/dpix)
            axis equal;
            axis([0 72 0 128]);
            set(gca,'xticklabel','')
            xlabel(sprintf('%.1f dfof',gratthreshlist(i)*100))
        end
        mtit('Cells responsive above threshold')
        savefig([filename '.fig'])
%         if exist('psfile','var')
%             set(gcf, 'PaperPositionMode', 'auto');
%             print('-dpsc',psfile,'-append');
%         end
        
        %%%average response for every cell to their best stim params
        dfgrat = nan(size(dFout,1),size(dFout,2),2);
        for i = 1:size(dFout,1)
            [respmax respmaxi] = max(dfori(i,:,1));
            dfgrat(i,:,1) = squeeze(dfgratuning(i,:,bestsftf(i,1,1),bestsftf(i,2,1),respmaxi,1));
            dfgrat(i,:,2) = squeeze(dfgratuning(i,:,bestsftf(i,1,1),bestsftf(i,2,1),respmaxi,2));
        end

        %%%pick a threshold here to use for responsive cells, plot all of
        %%%their tuning properties
        respcells = find(max(dfori,[],2)>=gratthreshlist(3)); respcells=intersect(respcells(respcells<cellCutoff),allgoodTopo);
        for i=1:length(respcells)
            figure
            subplot(2,2,1)
            hold on
            sitcurv = dfori(respcells(i),:,1);
            runcurv = dfori(respcells(i),:,2);          
            plot(1:12,sitcurv,'k-')
            plot(1:12,runcurv,'r-')
            xlabel('Direction')
            ylabel('dfof')
            axis([1 12 min([sitcurv runcurv])-0.01 max([sitcurv runcurv])+0.01])
            axis square
            hold off
            subplot(2,2,2)
            sitpol = dfori(respcells(i),:,1);sitpol(sitpol<0)=0;
            runpol = dfori(respcells(i),:,2);runpol(runpol<0)=0;
            polarplot([dirrange dirrange(1)],[sitpol sitpol(1)],'k-')
            hold on
            polarplot([dirrange dirrange(1)],[runpol runpol(1)],'r-')
            hold off
            subplot(2,2,3)
            hold on
            plot([1 2],[osi(respcells(i),1) dsi(respcells(i),1)],'k.','Markersize',20)
            plot([1 2],[osi(respcells(i),2) dsi(respcells(i),2)],'r.','Markersize',20)
            axis([0 3 0 1])
            set(gca,'xtick',[1 2],'xticklabel',{'OSI','DSI'})
            axis square
            hold off
            subplot(2,2,4)
            hold on
            plot(timepts,dfgrat(i,:,1),'k')
            plot(timepts,dfgrat(i,:,2),'r')
            xlabel('Time(s)')
            ylabel('pref dfof')
            axis([timepts(1) timepts(end) min(min(dfgrat(i,:,:)))-0.01 max(max(dfgrat(i,:,:)))+0.01])
            axis square
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold off
            mtit(sprintf('Cell #%d tuning',respcells(i)))
            if exist('psfile','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfile,'-append');
            end
        end
        
        %%%save out cell preferences for analysis with size select stim
        save(filename,'dfgrat','dirrange','dfori','osi','dsi','prefori','prefdir','bestsftf','preftheta','prefthetaQuad','respcells')

%         try
%             dos(['ps2pdf ' psfile ' "' [filename '.pdf'] '"'] )
%         catch
%             display('couldnt generate pdf');
%         end

%         delete(psfile);
        close all    
        
%     else
%         sprintf('skipping %s',filename)
%     end
end