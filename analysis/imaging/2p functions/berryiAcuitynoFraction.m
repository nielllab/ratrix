%%% compiles data from sinusoidal gratings
%%% based on full-image weighted dF/F
%%% cmn 2019

close all; clear all

%%% select files to analyze based on compile file
%stimname = '8 way gratings';
stimname = ['8 way gratings 2ISI']
[sbx_fname acq_fname mat_fname quality] = compileFilenames('BerryiBatchFile.xlsx',stimname);

Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigs.ps';
if Opt.SaveFigs
    psfile = Opt.psfile
    if exist(psfile,'file')==2;delete(psfile);end
end

%%% select files to use based on quality
for i = 1: length(quality);
    usefile(i) = strcmp(quality{i},'Y');
end

useN = find(usefile); clear goodfile
for i = 1:length(useN)
    base = mat_fname{useN(i)}(1:end-4);
    goodfile{i} = dir([base '*']).name;
end
mat_fname = goodfile;


% %%% selectall files in directory
% files = dir('*.mat');
% for i = 1:nfiles
%     mat_fname{i} = files(i).name;
% end

rLabels = {'OGL','Plex','IGL','Med'};
nfiles = length(mat_fname);
ncond = 17;
cycDur=20;
if strcmp(stimname,'sin gratings smaller 2ISI') | strcmp(stimname,'8 way gratings 2ISI') | strcmp(stimname,'sin gratings 7 steps 2ISI');
    cycDur = 30;
end

if strcmp(stimname,'8 way gratings') || strcmp(stimname,'8 way gratings 2ISI')
    nOri = 8;
    nSF = 2;
    sfs = zeros(16,1);
    thetas = zeros(16,1);
    sfs(1:2:end) = 0.01; sfs(2:2:end) = 0.16;
    thetas(1:2) = 0; thetas(3:4) = 45; thetas(5:6) = 90; thetas(7:8) = 135; thetas(9:10) = 180; thetas(11:12) = 225; thetas(13:14)=270; thetas(15:16) = 315;
else
    nOri = 4;
    nSF = 4;
    sfs = zeros(16,1);
    thetas = zeros(16,1);
    sfs(1:4:end) = 0.01; sfs(2:4:end) = 0.04; sfs(3:4:end) = 0.16; sfs(4:4:end) = 0.64;
    thetas(1:4) = 0; thetas(5:8) = 90; thetas(9:12) = 180; thetas(13:16) = 270;
end

if strcmp(stimname,'sin gratings 7 steps 2ISI')
    ncond = 29;
    nSF = 7;
    sfs = zeros(28,1);
    thetas = zeros(28,1);
    for i = 1:7
        sfs(i:7:end) = 0.01*2^(i-1);
    end
    thetas(1:7) = 0; thetas(8:14) = 90; thetas(15:21) = 180; thetas(22:28) = 270;
end

th = unique(thetas);
for i = 1:length(th); oriLabels{i} = sprintf('%0.0f',th(i)); end

sf = unique(sfs);
for i = 1:length(sf); sfLabels{i} = sprintf('%0.02f',sf(i)); end

f = 0; %%% counter for number of sessions included
for nf = 1:nfiles
    
    sprintf('running %d',nf)
    %%% read in weighted timecourse (from pixelmap, weighted by baseline fluorescence
    clear xb yb stimOrder weightTcourse
    load(mat_fname{nf},'stimOrder','weightTcourse','dFrepeats','xpts','ypts','xb','yb','meanGreenImg','stdImg','trialmean','cycPolarImg')
    
    figure
    subplot(1,2,1)
    imshow(cycPolarImg); title('timecourse polar img');
    subplot(1,2,2);
    imagesc(meanGreenImg); axis equal; axis off; 
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    %%% load freq and orient from stimRec
    
    
    %%% get weight tcourse for each orientation. then at the end, colorcode
    %%% each pixel by preferred orientation
    
    %%% also, get orientation tuning for each cell (avg over SF, or peak SF)
    
    
    %%% dFrepeats(cell,conds x timepts, repeats)
    %%% average over repeats
    clear cellResp cellAmp
    dFmean = nanmean(dFrepeats,3);
    
    for c = 1:ncond
        cellResp(:,c,:) = dFmean(:,(c-1)*cycDur+1 : c*cycDur,:);
        cellAmp(:,c) = nanmean(cellResp(:,c,9:20),3);
    end
    
    %%% get max resp for each cell. save out as histogram
    maxResp = max(cellAmp,[],2);
    fractionResponsive = sum(maxResp>0.05)/length(maxResp);
    if fractionResponsive>0.05
        f = f+1;
    else
        break
    end
        
    
    bins = -0.2:0.025:0.5;
    ampHist(:,f) = hist(maxResp,bins)/length(maxResp);
    
    medianResp(f) = nanmedian(maxResp);
    fractionResponsive(f) = sum(maxResp>0.05)/length(maxResp);
    
    figure
    plot(bins,ampHist(:,f)); xlabel('max resp'); ylabel('fraction');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% select responsive cells (can add more interesting criteria)
    responsive = maxResp>0.05;
    
    figure
    imagesc(dFmean,[-0.1 0.1]); title(['response of all cells ' mat_fname{f}])
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    figure
    plot(nanmean(dFmean,1))
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% region-specific analysis
    if exist('xb','var');
        
        col = 'rgbc';
        figure
        imagesc(meanGreenImg); hold on
        for r = 1:length(xb)
            if length(xb{r})>0
                inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
                plot(xpts(inRegion),ypts(inRegion),'.','Color',col(r));
            end
        end
        axis equal
        
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        figure
        region = zeros(size(xpts)); %%% empty variable for which region each cell is
        
        for r = 1:4
            if r>length(xb) ||length(xb{r})==0 || sum(inpolygon(xpts,ypts,xb{r},yb{r}))==0;
                regionResp(r,:,:,f)=NaN;
                regionAmp(r,:,f) = NaN;
                fractResponsive(r,f)=NaN;
            else
                %%% find cells in the region
                inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
                region(inRegion) = r;
                
                %%% select out data for cells in this region
                %%% regionResp(region, cond, time, file) = timecourse
                %%% regionAmp(region,cond,file) = mean response in peak window
                regionResp(r,:,:,f) = nanmean(cellResp(inRegion & responsive,:,:),1);
                regionAmp(r,:,f) = nanmean(cellAmp(inRegion & responsive,:),1);
                subplot(2,2,r);
                %             plot(1:size(regionResp,3),squeeze(regionResp(r,:,:)));
                %             xlabel('secs'); title(sprintf('region %d',r))
                imagesc(squeeze(regionResp(r,:,:,f)),[-0.01 0.125])
                title(sprintf('region %d %d pts %d resp',r,sum(inRegion),sum(inRegion & responsive))); xlabel('time'); ylabel('cond')
                fractResponsive(r,f) = sum(inRegion & responsive)/sum(inRegion);
            end
        end
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% show all responses sorted by region
        [val regionOrder] = sort(region);
        figure
        imagesc(dFmean(regionOrder,:),[-0.01 0.125]); hold on
        borders = find(diff(val)>0);
        for i = 1:length(borders)
            plot([1 size(dFmean,2)], [borders(i) borders(i)],'r')
        end
        xlabel('time and conds'); ylabel('cells'); title(mat_fname{f});
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        [val regionOrder] = sort(region(responsive));
        responsiveList = find(responsive);
        figure
        imagesc(dFmean(responsiveList(regionOrder),:),[-0.01 0.125]); hold on
        borders = find(diff(val)>0);
        for i = 1:length(borders)
            plot([1 size(dFmean,2)], [borders(i) borders(i)],'r')
        end
        xlabel('time and conds'); ylabel('cells'); title([mat_fname{f} ' responsive only']);
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end
    
    %%% to do - determine response amp or selectivity index
    %%% and color-code these on map of lobe
    
    clear respMap
    %%% pixel-level data
    nstim = min(length(stimOrder),size(weightTcourse,2));  %%% sometimes stimorder is too long
    stimOrder = stimOrder(1:nstim);
    for c = 1:ncond;  %%% loop over conditions
        %%% timecourse of response
        resp(c,:,f) = nanmedian(weightTcourse(:,stimOrder==c),2);
        
        %%% amplitude of response over timewindow
        amp(c,f) = nanmean(resp(c,9:20,f),2);
        respMap(:,:,c) =  nanmedian(trialmean(:,:,stimOrder==c),3);
        
    end
    
    
    figure
    for sf = 1:nSF;
        subplot(2,4,sf);
        plot(resp(sf:nSF:nOri*nSF,:,f)');
        title(['sf = ' sfLabels{sf}]);ylim([-0.025 0.1])
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    figure
    if ncond == 17
        xpanels = 4; ypanels = 4;
    else
        xpanels = 7; ypanels = 4;
    end
    for c = 1:ncond-1;
        subplot(ypanels,xpanels,c);
        imagesc(respMap(:,:,c),[-0.05 0.1]);
        axis equal; axis off; title(sprintf('sf = %0.02f th = %0.0f',sfs(c), thetas(c)));
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% average over SFs to get orientation tuning
    clear mapOriTuning
    for ori = 1:nOri
        range = (ori-1)*nSF + (1:nSF);
        range
        oriTuning(ori,f) = nanmean(amp(range,f));
        oriResp(ori,:,f) = nanmean(resp(range,:,f),1);
        
        mapOriTuning(:,:,ori) = nanmean(respMap(:,:,range),3);
        
        regionOriTuning(ori,:,f) = nanmean(regionAmp(:,range,f),2);
        regionOriResp(ori,:,:,f) = nanmean(regionResp(:,range,:,f),2);
    end
    
    %%% pixelwise orientation tuning
    figure
    plot(unique(thetas),oriTuning(:,f))
    xlabel('theta'); title('pixelwise orienation selectivity');
    ylim([-0.025 0.1])
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% region orientation tuning (averaged over SF)
    figure
    for r=1:4
        subplot(2,2,r);
        bar(unique(thetas),regionOriTuning(:,r,f),'b'); hold on
        plot(unique(thetas),regionOriTuning(:,r,f),'k','Linewidth',2);
        
        ylim([-0.025 0.1]); xlim([-25 340]); xlabel('theta'); title(rLabels{r});
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% polar plots of orientation tuning
    figure
    for r=1:4
        subplot(2,2,r);
        %%% make values wrap around for polar plot
        thplot = unique(thetas)*pi/180; thplot(end+1) = thplot(1);
        tuningplot = regionOriTuning(:,r,f); tuningplot(end+1) = tuningplot(1);
        polar(thplot, tuningplot,'b'); hold on
        xlabel('theta'); title(rLabels{r});
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    
    %%% orientation by SF for all regions
    figure
    for r = 1:4
        subplot(2,2,r)
        hold on
        for sf = 1:nSF
            plot(unique(thetas),regionAmp(r,sf:nSF:nOri*nSF,f));
        end
        ylim([-0.025 0.1])
        legend(sfLabels);
        title(rLabels{r}); xlabel('thetas');
        colororder(jet(nSF)*0.75)
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% view orientations, and compute polar map
    oriMap = 0;
    figure
    for ori = 1:nOri
        subplot(2,4,ori);
        imagesc(mapOriTuning(:,:,ori),[-0.1 0.2]); title(oriLabels{ori});
        oriMap = oriMap + mapOriTuning(:,:,ori)*exp(2*pi*sqrt(-1)*ori/nOri);
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    imagesc(abs(oriMap),[0 0.1]);
    title('orientation amplitude map')
    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    imagesc(angle(oriMap)); colormap(hsv);
    title('orientation phase map');
    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    ampMap = abs(oriMap); ampMap = ampMap/0.2; ampMap(ampMap>1)=1;orimap(isnan(oriMap))=0;
    phMap = mat2im(angle(oriMap),hsv,[-pi pi]);
    figure
    imshow(phMap.*repmat(ampMap,[1 1 3]));
    title('orientation polar map')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    
    
    %%%% average across orientations (4) for each sf
    for sf = 1:nSF;
        tuning(sf+1,f) = nanmean(amp(sf:nSF:nSF*nOri,f));
        sfResp(sf+1,:,f) = nanmean(resp(sf:nSF:nSF*nOri,:,f),1);
        
        regionTuning(sf+1,:,f) = nanmean(regionAmp(:,sf:nSF:nSF*nOri,f),2);
        regionSFresp(sf+1,:,:,f) = nanmean(regionResp(:,sf:nSF:nSF*nOri,:,f),2);
        
    end
    
    %%% get fullfield flicker (last stim cond)
    tuning(1,f) = amp(end);
    sfResp(1,:,f) = resp(end,:,f);
    regionTuning(1,:,f) = regionAmp(:,end,f);
    regionSFresp(1,:,:,f) = regionResp(:,end,:,f);
    
    %%% plot SF responses for each region
    figure
    for r = 1:4
        subplot(2,2,r)
        plot(1:cycDur,squeeze(regionSFresp(:,r,:,f))); ylim([-0.025 0.1])
        title([rLabels{r} ' SF tuning']);
        colororder(jet(nSF+1)*0.75);
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    %
    figure
    plot(sfResp(:,:,f)'); title(mat_fname{f}); xlabel('time'); legend(['0', sfLabels]); colororder(jet(nSF+1)*0.75)
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% Judit added this, was hoping for the curves for only the cells over threshold, but I don't think that's what this actually does?
%     
%     figure
%     plot(regionSFresp(:,:,f)'); title(mat_fname{f}); xlabel('time')
%     if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
%     
    figure
    plot(tuning(:,f))
    title(['population sf avg ' mat_fname{f}]); ylim([0 0.05])
    xlabel('SF'); ylabel('resp')
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
end

%%% pixelwise analysis (obsolete)
% %%% mean across sessions for each condition
% figure
% plot(mean(resp,3)'); title('mean of all recordings for each condition (pixel-wise)');
% if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
% 
% 
% %%% orientations broked out by spatial frequency
% 
% figure
% for sf = 1:nSF;
%     subplot(2,2,nSF);
%     plot(mean(resp(sf:nSF:end,:,:),3)');
%     title(['pixelwise sf = ' sfLabels{sf}]);ylim([-0.01 0.05])
% end
% if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
% 
% figure
% plot(mean(sfResp,3)'); title('pixelwise resp vs SF');
% if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
% 
% %%% SF tuning curves
% figure
% hold on
% plot(2:(nSF+1),mean(tuning(2:end,:),2),'bo')
% errorbar(2:(nSF+1),mean(tuning(2:end,:),2), std(tuning(2:end,:),[],2)/sqrt(nfiles),'k');
% plot(1.5,mean(tuning(1,:),2),'bo')
% errorbar(1.5,mean(tuning(1,:),2), std(tuning(1,:),[],2)/sqrt(nfiles),'k');
% ylabel('mean dF/F');xlabel('cyc / deg'); title('pixel wise SF tuning')
% set(gca,'Xtick',[ 1.5 2:5]);
% set(gca,'XtickLabel',{'0','0.005','0.02','0.08','0.32'});
% xlim([1 5.5])
% if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
%%% pixelwise orientation tuning
% figure
% plot(unique(thetas),nanmean(oriTuning(:,:),2))
% xlabel('theta'); title('pixelwise orienation selectivity');
% ylim([-0.025 0.1]);
% if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
% 


%%% SF and orientation all cells pooled
figure
for sf = 1:nSF;
    subplot(2,4,sf);
    plot(squeeze(mean(nanmean(regionResp(:,sf:nSF:end,:,:),4),1))');
    title(['all cells sf = ' sfLabels{sf}]);ylim([-0.01 0.1])
    colororder(jet(nSF+1))
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% SF and orientation for each layer
for r = 1:4;
    figure
    for sf = 1:nSF;
        subplot(2,4,sf);
        plot(squeeze(nanmean(regionResp(r,sf:nSF:end,:,:),4))');
        title([rLabels{r} ' ' sfLabels{sf}]);ylim([-0.02 0.1])
    if sf==1
    legend(oriLabels)
    end
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

end




%%% SF tuning curves
figure
for r = 1:4
    subplot(2,2,r)
    hold on
    plot(2:(nSF+1),nanmean(regionTuning(2:end,r,:),3),'bo')
    errorbar(2:(nSF+1),nanmean(regionTuning(2:end,r,:),3), nanstd(regionTuning(2:end,r,:),[],3)/sqrt(nfiles),'k');
    plot(1.5,nanmean(regionTuning(1,r,:),3),'bo')
    errorbar(1.5,nanmean(regionTuning(1,r,:),3), nanstd(regionTuning(1,r,:),[],3)/sqrt(nfiles),'k');
    ylabel('mean dF/F');xlabel('cyc / deg'); title(rLabels{r})
    set(gca,'Xtick',1:nSF+1);
    set(gca,'XtickLabel',[{'0'} sfLabels]);
    xlim([1 nSF+1.5]); ylim([0 0.05])
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% spatial frequency tuning, for each experiment
figure
for r = 1:4
    subplot(2,2,r)
    hold on
    plot(1:(nSF+1),squeeze((regionTuning(1:end,r,:))))
    ylabel('mean dF/F');xlabel('cyc / deg'); title(rLabels{r})
    set(gca,'Xtick',1:nSF+1);
    set(gca,'XtickLabel',[{'0'} sfLabels]);
    xlim([0.5 (nSF+1.5)]); ylim([-0.025 0.1])
end
sgtitle('SF tuning over all expts')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% timecourse of each SF, in each layer
figure
cmap = jet(nSF+1)*0.75;
for r = 1:4
    subplot(2,2,r);
   % plot(1:cycDur,squeeze(nanmean(regionSFresp(:,r,:,:),4)));
    mn = squeeze(nanmean(regionSFresp(:,r,:,:),4));
    err = squeeze(nanstd(regionSFresp(:,r,:,:),[],4))/sqrt(nfiles);
    hold on
    for i = 1:size(mn,1)
        errorbar(1:cycDur,mn(i,:),err(i,:))
    end
    colororder(jet(nSF+1)*0.75)
    ylim([-0.02 0.1])
    title(rLabels{r})
    if r ==1
        legend([{'0'} sfLabels])
    end
    xlabel('frame')
end
sgtitle('SF timecourses')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% region orientation tuning (averaged over SF)
figure
for r=1:4
    subplot(2,2,r);
    mn = nanmean(regionOriTuning(:,r,:),3);
    err =nanstd(regionOriTuning(:,r,:),[],3)/sqrt(nfiles);
    shadedErrorBar(unique(thetas),mn, err);
    %plot(unique(thetas),nanmean(regionOriTuning(:,r,:),3)); xlabel('theta'); title(rLabels{r});
    ylim([0 0.05]); ylabel('resp avg over SF')
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% orientation by SF for all regions
figure
for r = 1:4
    subplot(2,2,r)
    hold on
    for sf = 1:nSF
        plot(unique(thetas),nanmean(regionAmp(r,sf:nSF:nOri*nSF,:),3));
    end
    colororder(jet(nSF+1)*0.75)
    if r ==1
        legend(sfLabels);
    end
    title(rLabels{r}); xlabel('thetas');
    ylim([-0.025 0.1])
end

if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


figure
plot(bins,ampHist); xlim([-0.1 0.5]); hold on; plot(bins,mean(ampHist,2),'g','Linewidth',2)
xlabel('amp dF/F'); title('amplitude distribution for all cells across sessions');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

responsive = sum(ampHist(bins>0.05,:),1);
figure
plot(responsive);
ylabel('fraction responsive');
xlabel('session');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end



display('saving pdf')
if Opt.SaveFigs
    if ~isfield(Opt,'pPDF')
        [Opt.fPDF, Opt.pPDF] = uiputfile('*.pdf','save pdf file');
    end
    
    newpdfFile = fullfile(Opt.pPDF,Opt.fPDF);
    try
        dos(['ps2pdf ' 'c:\temp\TempFigs.ps "' newpdfFile '"'] )
        
    catch
        display('couldnt generate pdf');
    end
end
