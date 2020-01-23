%%% compiles data from sinusoidal gratings
%%% based on full-image weighted dF/F
%%% cmn 2019

close all; clear all

%%% select files to analyze based on compile file
stimname = 'sin gratings smaller 2ISI';
[sbx_fname acq_fname mat_fname quality] = compileFilenames('For Batch File.xlsx',stimname);

Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigs.ps';

if Opt.SaveFigs
    psfile = Opt.psfile
    if exist(psfile,'file')==2;delete(psfile);end
end

%%% select files to use based on quality
for i = 1: length(quality);
    usefile(i) = ~strcmp(quality{i},'N');
end

useN = find(usefile);
for i = 1:length(useN)
    goodfile{i} = mat_fname{useN(i)};
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
if strcmp(stimname,'sin gratings smaller 2ISI')
    cycDur = 30;
end

sfs = zeros(16,1);
thetas = zeros(16,1);
sfs(1:4:end) = 0.01; sfs(2:4:end) = 0.04; sfs(3:4:end) = 0.16; sfs(4:4:end) = 0.64;
thetas(1:4) = 0; thetas(5:8) = 90; thetas(9:12) = 180; thetas(13:16) = 270;

for f = 1:nfiles
    
    %%% read in weighted timecourse (from pixelmap, weighted by baseline fluorescence
    clear xb yb
    load(mat_fname{f},'stimOrder','weightTcourse','dFrepeats','xpts','ypts','xb','yb','meanGreenImg','trialmean','cycPolarImg')
    
    figure
    imshow(cycPolarImg); title('timecourse polar img');
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
    bins = -0.2:0.025:0.5;
    ampHist(:,f) = hist(maxResp,bins)/length(maxResp);
    figure
    plot(bins,ampHist(:,f)); xlabel('max resp'); ylabel('fraction');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% select responsive cells (can add more interesting criteria)
    responsive = maxResp>0.09;
    
    figure
    imagesc(dFmean,[-0.1 0.1]); title(['response of all cells ' mat_fname{f}])
    
    
    figure
    plot(nanmean(dFmean,1))
    
    %%% region-specific analysis
    if exist('xb','var');
        
        col = 'rgbc';
        figure
        imagesc(meanGreenImg); hold on
        for r = 1:length(xb)
            inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
            plot(xpts(inRegion),ypts(inRegion),'.','Color',col(r));
        end
        axis equal
        
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        figure
        region = zeros(size(xpts)); %%% empty variable for which region each cell is
        
        for r = 1:4
            if r>length(xb) || sum(inpolygon(xpts,ypts,xb{r},yb{r}))==0;
                regionResp(r,:,:,f)=NaN;
                regionAmp(r,:,f) = NaN;
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
    for c = 1:17;  %%% loop over conditions
        %%% timecourse of response
        resp(c,:,f) = nanmedian(weightTcourse(:,stimOrder==c),2);
  
        %%% amplitude of response over timewindow
        amp(c,f) = nanmean(resp(c,9:20,f),2);
        respMap(:,:,c) =  nanmedian(trialmean(:,:,stimOrder==c),3);
        
    end
    
    sfLabel = {'0.01','0.04','0.16','0.64'}
    figure
    for sf = 1:4;
        subplot(2,2,sf);
        plot(resp(sf:4:end,:,f)');
        title(['sf = ' sfLabel{sf}]);ylim([-0.025 0.1])
    end
    
    
    figure
    for c = 1:16
        subplot(4,4,c);
        imagesc(respMap(:,:,c),[-0.05 0.1]);
        axis equal; axis off; title(sprintf('sf = %0.02f th = %0.0f',sfs(c), thetas(c)));
    end
    
    %%% average over SFs to get orientation tuning
    clear mapOriTuning
    for ori = 1:4
        range = (ori-1)*4 + (1:4); %%% only low sf
        range
        oriTuning(ori,f) = nanmean(amp(range,f));
        oriResp(ori,:,f) = nanmean(resp(range,:,f),1);
        
        mapOriTuning(:,:,ori) = nanmean(respMap(:,:,range),3);
        
        regionOriTuning(ori,:,f) = nanmean(regionAmp(:,range,f),2);
        regionOriResp(ori,:,:,f) = nanmean(regionResp(:,range,:,f),2);
    end
    
    %%% view orientations, and compute polar map
    oriMap = 0;
    figure
    for ori = 1:4
        subplot(2,2,ori);
        imagesc(mapOriTuning(:,:,ori),[-0.1 0.2]);
        oriMap = oriMap + mapOriTuning(:,:,ori)*exp(2*pi*sqrt(-1)*ori/4);
    end
    
    figure
    imagesc(abs(oriMap),[0 0.1]);
    title('orientation amplitude map')
    
    figure
    imagesc(angle(oriMap)); colormap(hsv);
    title('orientation phase map');
    
    ampMap = abs(oriMap); ampMap = ampMap/0.1; ampMap(ampMap>1)=1;orimap(isnan(oriMap))=0;
    phMap = mat2im(angle(oriMap),hsv,[-pi pi]);
    figure
    imshow(phMap.*repmat(ampMap,[1 1 3]));
    title('orientation polar map')
    
    
    %%%% average across orientations (4) for each sf
    for sf = 1:4;
        tuning(sf+1,f) = nanmean(amp(sf:4:end,f));
        sfResp(sf+1,:,f) = nanmean(resp(sf:4:end,:,f),1);
        
        regionTuning(sf+1,:,f) = nanmean(regionAmp(:,sf:4:end,f),2);
        regionSFresp(sf+1,:,:,f) = nanmean(regionResp(:,sf:4:end,:,f),2);
        
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
        plot(1:cycDur,squeeze(regionSFresp(:,r,:,f))); ylim([-0.025 0.075])
        title(rLabels{r});
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    %
    figure
    plot(sfResp(:,:,f)'); title(mat_fname{f}); xlabel('time'); legend({'0','0.005','0.02','0.08','0.32'})
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% Judit added this, was hoping for the curves for only the cells over threshold, but I don't think that's what this actually does?
    
    figure
    plot(regionSFresp(:,:,f)'); title(mat_fname{f}); xlabel('time')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    plot(tuning(:,f))
    title(mat_fname{f}); ylim([0 0.05])
    xlabel('SF'); ylabel('resp')
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
end

%%% mean across sessions for each condition
figure
plot(mean(resp,3)'); title('mean of all recordings for each condition');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% orientations broked out by spatial frequency
    sfLabel = {'0.01','0.04','0.16','0.64'}
    figure
    for sf = 1:4;
        subplot(2,2,sf);
        plot(mean(resp(sf:4:end,:,:),3)');
        title(['sf = ' sfLabel{sf}]);ylim([-0.01 0.05])
    end
    
      sfLabel = {'0.01','0.04','0.16','0.64'}
    figure
    for sf = 1:4;
        subplot(2,2,sf);
        plot(squeeze(mean(nanmean(regionResp(:,sf:4:end,:,:),4),1))');
        title(['cells sf = ' sfLabel{sf}]);ylim([-0.01 0.05])
    end  
    
          sfLabel = {'0.01','0.04','0.16','0.64'}

   for r = 1:4
       figure
       for sf = 1:4;
        subplot(2,2,sf);
        plot(squeeze(nanmean(regionResp(r,sf:4:end,:,:),4))');
        title([rLabels{r} ' ' sfLabel{sf}]);ylim([-0.01 0.05])
       end  
   end
    
    

figure
plot(mean(sfResp,3)'); title('resp vs SF');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% SF tuning curves
figure
hold on
plot(2:5,mean(tuning(2:end,:),2),'bo')
errorbar(2:5,mean(tuning(2:end,:),2), std(tuning(2:end,:),[],2)/sqrt(nfiles),'k');
plot(1.5,mean(tuning(1,:),2),'bo')
errorbar(1.5,mean(tuning(1,:),2), std(tuning(1,:),[],2)/sqrt(nfiles),'k');
ylabel('mean dF/F');xlabel('cyc / deg'); title('SF tuning')
set(gca,'Xtick',[ 1.5 2:5]);
set(gca,'XtickLabel',{'0','0.005','0.02','0.08','0.32'});
xlim([1 5.5])
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% SF tuning curves
figure
for r = 1:4
    subplot(2,2,r)
    hold on
    plot(2:5,nanmean(regionTuning(2:end,r,:),3),'bo')
    errorbar(2:5,nanmean(regionTuning(2:end,r,:),3), nanstd(regionTuning(2:end,r,:),[],3)/sqrt(nfiles),'k');
    plot(1.5,nanmean(regionTuning(1,r,:),3),'bo')
    errorbar(1.5,nanmean(regionTuning(1,r,:),3), nanstd(regionTuning(1,r,:),[],3)/sqrt(nfiles),'k');
    ylabel('mean dF/F');xlabel('cyc / deg'); title(rLabels{r})
    set(gca,'Xtick',[ 1.5 2:5]);
    set(gca,'XtickLabel',{'0','0.005','0.02','0.08','0.32'});
    xlim([1 5.5]); ylim([0 0.05])
end

figure
for r = 1:4
    subplot(2,2,r)
    hold on
    plot(1:5,squeeze((regionTuning(1:end,r,:))))
    ylabel('mean dF/F');xlabel('cyc / deg'); title(rLabels{r})
    set(gca,'Xtick',[ 1.5 2:5]);
    set(gca,'XtickLabel',{'0','0.005','0.02','0.08','0.32'});
    xlim([1 5.5]); ylim([-0.025 0.1])
end

if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end



figure
for r = 1:4
    subplot(2,2,r);
    plot(1:cycDur,squeeze(nanmean(regionSFresp(:,r,:,:),4)));
    ylim([-0.01 0.05])
    title(rLabels{r})
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

figure
plot(bins,ampHist); xlim([-0.1 0.5]); hold on; plot(bins,mean(ampHist,2),'g','Linewidth',2)
xlabel('amp dF/F'); title('amplitude distribution across sessions');
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
