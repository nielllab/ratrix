%%% compiles data from sinusoidal gratings
%%% based on full-image weighted dF/F
%%% cmn 2019

close all; clear all

%%% select files to analyze based on compile file
stimname = 'sin gratings';
[sbx_fname acq_fname mat_fname quality] = compileFilenames('For Batch File.xlsx',stimname);

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

for f = 1:nfiles
    
    %%% read in weighted timecourse (from pixelmap, weighted by baseline fluorescence
    clear xb yb
    load(mat_fname{f},'stimOrder','weightTcourse','dFrepeats','xpts','ypts','xb','yb','meanGreenImg')
    
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
    
    %%% select responsive cells (can add more interesting criteria)
    responsive = maxResp>0.08;
    
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
                regionResp(r,:,:,f) = nanmean(cellResp(inRegion &responsive,:,:),1);
                regionAmp(r,:,f) = nanmean(cellAmp(inRegion & responsive,:),1);
                subplot(2,2,r);
                %             plot(1:size(regionResp,3),squeeze(regionResp(r,:,:)));
                %             xlabel('secs'); title(sprintf('region %d',r))
                imagesc(squeeze(regionResp(r,:,:,f)),[-0.01 0.125])
                title(sprintf('region %d %d pts %d resp',r,sum(inRegion),sum(inRegion & responsive))); xlabel('time'); ylabel('cond')
                fractResponsive(r,f) = sum(inRegion & responsive)/sum(inRegion);
            end
        end
        
        %%% show all responses sorted by region
        [val regionOrder] = sort(region);
        figure
        imagesc(dFmean(regionOrder,:),[-0.01 0.125]); hold on
        borders = find(diff(val)>0);
        for i = 1:length(borders)
            plot([1 size(dFmean,2)], [borders(i) borders(i)],'r')
        end
        xlabel('time and conds'); ylabel('cells'); title(mat_fname{f});
    end
    
    %%% to do - determine response amp or selectivity index
    %%% and color-code these on map of lobe
    
    %%% pixel-level data
    for c = 1:17;  %%% loop over conditions
        %%% timecourse of response
        resp(c,:) = nanmedian(weightTcourse(:,stimOrder==c),2);
        %%% amplitude of response over timewindow
        amp(c,f) = nanmean(resp(c,9:20),2);
        
    end
    
    %%%% average across orientations (4) for each sf
    for sf = 1:4;
        tuning(sf+1,f) = nanmean(amp(sf:4:end,f));
        sfResp(sf+1,:,f) = nanmean(resp(sf:4:end,:),1);
        
        regionTuning(sf+1,:,f) = nanmean(regionAmp(:,sf:4:end,f),2);
        regionSFresp(sf+1,:,:,f) = nanmean(regionResp(:,sf:4:end,:,f),2);
    end
    
    %%% get fullfield flicker (last stim cond)
    tuning(1,f) = amp(end);
    sfResp(1,:,f) = resp(end,:);
    regionTuning(1,:,f) = regionAmp(:,end,f);
    regionSFresp(1,:,:,f) = regionResp(:,end,:,f);
    
    %%% plot SF responses for each region
    figure
    for r = 1:4
        subplot(2,2,r)
        plot(1:cycDur,squeeze(regionSFresp(:,r,:,f))); ylim([-0.025 0.075])
        title(rLabels{r});
    end
    
    %
    figure
    plot(sfResp(:,:,f)'); title(mat_fname{f}); xlabel('time')
    
    figure
    plot(tuning(:,f))
    title(mat_fname{f}); ylim([0 0.05])
    xlabel('SF'); ylabel('resp')
end

%%% mean across sessions for each condition
figure
plot(mean(resp,3)'); title('mean of all recordings for each condition');

figure
plot(mean(sfResp,3)'); title('resp vs SF');

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

figure
for r = 1:4
    subplot(2,2,r);
    plot(1:cycDur,squeeze(nanmean(regionSFresp(:,r,:,:),4)));
    ylim([-0.01 0.1])
    title(rLabels{r})
end


figure
plot(bins,ampHist); xlim([-0.1 0.5]); hold on; plot(bins,mean(ampHist,2),'g','Linewidth',2)
xlabel('amp dF/F'); title('amplitude distribution across sessions');
