%%% compiles data from sparse noise analysis
%%% cmn 2019

close all
clear all

%%% select files to analyze based on compile file
stimname = 'sparse noise';
[sbx_fname acq_fname mat_fname quality] = compileFilenames('For Batch File.xlsx',stimname);

% %%% selectall files in directory
% files = dir('*.mat');
% for i = 1:nfiles
%     mat_fname{i} = files(i).name;
% end

%%% select files to use based on quality
for i = 1: length(quality);
    usefile(i) = ~strcmp(quality{i},'N');
end

useN = find(usefile);
for i = 1:length(useN)
    goodfile{i} = mat_fname{useN(i)};
end
mat_fname = goodfile;

nfiles = length(mat_fname)

rLabels = {'OGL','Plex','IGL','Med'};

for f = 1:nfiles
    
    %%% load data
    mat_fname{f}
    clear xb yb
    load(mat_fname{f},'xpts','ypts','rfx','rfy','tuning','zscore','xb','yb','meanGreenImg')
    
    %%% threshold for good RF
    zthresh = 5.5;
    
    %%% select RFs that have zscore(ON, OFF) greater than zthresh
    use = find(zscore(:,1)>zthresh | zscore(:,2)<-zthresh);
    useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);
    useOnOff = intersect(useOn,useOff);
    notOn = find(zscore(:,1)<zthresh); notOff = find(zscore(:,2)>-zthresh);
    
    %%% calculate amplitude of response based on size response tuning(cells,on/off,size, time)
    %%% average over 3 spot sizes and response time window
    amp = nanmean(nanmean(tuning(:,:,1:3,8:15),4),3);
    
    %%% positive rectify amp, to calculate preference index for ON/OFF
    ampPos = amp; ampPos(ampPos<0)=0;
    onOff = (ampPos(:,1)-ampPos(:,2))./(ampPos(:,1)+ampPos(:,2));
    onOff(notOn)=-1; onOff(notOff)=1;
    
    %%% histogram of On/Off selectivity
    onOffHist = hist(onOff(use),[-1:0.1:1]);
    figure
    bar([-1:0.1:1],onOffHist); xlabel('on off pref')
    
    %%% calculate size tuning curve, by averaging over peak response window
    sz_tune = nanmean(tuning(:,:,:,8:15),4);  %%% sz_tune(cell,on/off,size)
    
    %%% calculate preferred size as weighted average
    szPref = squeeze(sz_tune(:,:,1)+ sz_tune(:,:,2)*2 + sz_tune(:,:,3)*3)./sum(sz_tune(:,:,1:3),3);
    
    %%% calculate distance correlation of on/off pref
    clear szPairs onOffPairs dist
    n=0;
    %%% loop over all pairs of good cells and get pairwise on/off pref, and  size pref
    for i = 1:length(use)-1;
        for j=i+1:length(use)
            n=n+1;
            dist(n) = sqrt((xpts(use(i))-xpts(use(j))).^2 + (ypts(use(i))-ypts(use(j))).^2 );
            onOffpairs(n,1) = onOff(use(i));
            onOffpairs(n,2) = onOff(use(j));
            szPairs(n,1) = szPref(use(i),1);
            szPairs(n,2) = szPref(use(j),2);
        end
    end
    %
    %     figure
    %     plot(dist,abs(onOffpairs(:,1)-onOffpairs(:,2)),'.');
    
    %%% for each range of distances, calculate correlation coeffs
    %%% similarity coeff
    onoffSim = 1 - 0.5*abs(onOffpairs(:,1)-onOffpairs(:,2));
    bins = 0:25:200;  %%% distance bins
    for i = 1:length(bins)-1;
        %%% choose pairs in range
        inrange = dist>bins(i) & dist<bins(i+1);
        %%% similarity coefficient
        simHist(i,f) = mean(onoffSim(inrange));
        %%% correlation coefficient (OnOff)
        cc = corrcoef(onOffpairs(inrange,1),onOffpairs(inrange,2));
        if length(cc)==1
            simCorr(i,f)=NaN;
        else
            simCorr(i,f) = cc(2,1);
        end
        %%% correlation coefficient (size)
        cc = corrcoef(szPairs(inrange,1),szPairs(inrange,2));
        if length(cc)==1
            szCorr(i,f)=NaN;
        else
            szCorr(i,f) = cc(2,1);
        end
    end
    
    %%% do the same thing, but with shuffled distances
    distShuff = dist(ceil(n*rand(n,1)));
    for i = 1:length(bins)-1;
        inrange = distShuff>bins(i) & distShuff<bins(i+1);
        simHistShuff(i,f) = mean(onoffSim(inrange));
        
        cc = corrcoef(onOffpairs(inrange,1),onOffpairs(inrange,2));
        if length(cc)==1
            simCorrShuff(i,f)=NaN;
        else
            simCorrShuff(i,f) = cc(2,1);
        end
        
        cc = corrcoef(szPairs(inrange,1),szPairs(inrange,2));
        if length(cc)==1
            szCorrShuff(i,f)=NaN;
        else
            szCorrShuff(i,f) =cc(2,1);
        end
    end
    
    %     figure
    %     plot(simHist(:,f)); hold on; plot(simHistShuff(:,f));
    %
    
    %%% plot on off correlation vs dist
    figure
    plot(bins(2:end)*2,simCorr(:,f)); hold on; plot(bins(2:end)*2,simCorrShuff(:,f),'r:');
    ylabel('On / Off correlation');
    xlabel('distance (um)');
    title(mat_fname{f})
    
    %%% plot mean size tuning for on and off
    figure
    subplot(2,2,1)
    plot(squeeze(mean(tuning(useOn,1,:,:),1))');
    title('ON')
    
    subplot(2,2,2)
    plot(squeeze(mean(tuning(useOff,2,:,:),1))');
    title(mat_fname{f})
    
    %%% store tuning for all files
    szTuning(1,:,:,f) = nanmean(tuning(useOn,1,:,:),1);
    szTuning(2,:,:,f) = nanmean(tuning(useOff,2,:,:),1);
    
    %%% retinotopy
    figure
    plot(rfx(useOff,2),xpts(useOff),'.'); xlabel('RF location'); ylabel('cell location')
    
    %%% mean rf centers
    mx = mean(rfx(useOn,1),1);
    my = mean(rfy(useOn,1),1);
    
    %%% calculate correlation coeffs for RF location and cell location
    cc = corrcoef(rfx(useOn,1)-mx,xpts(useOn));
    topoCC(1,1,f) = cc(2,1);
    cc = corrcoef(rfy(useOn,1)-my,ypts(useOn));
    topoCC(2,1,f) = -cc(2,1);
    cc = corrcoef(rfx(useOff,2)-mx,xpts(useOff));
    topoCC(1,2,f) = cc(2,1);
    cc = corrcoef(rfy(useOff,2)-my,ypts(useOff));
    topoCC(2,2,f) = -cc(2,1);
    
    %%% create values for shuffle
    n= length(rfx);
    xshuff = xpts(ceil(n*rand(n,1)));
    yshuff = ypts(ceil(n*rand(n,1)));
    
    cc = corrcoef(rfx(useOn,1)-mx,xshuff(useOn));
    topoCCshuff(1,1,f) = cc(2,1);
    cc = corrcoef(rfy(useOn,1)-my,yshuff(useOn));
    topoCCshuff(2,1,f) = -cc(2,1);
    cc = corrcoef(rfx(useOff,2)-mx,xshuff(useOff));
    topoCCshuff(1,2,f) = cc(2,1);
    cc = corrcoef(rfy(useOff,2)-my,yshuff(useOff));
    topoCCshuff(2,2,f) = -cc(2,1);
    
    %%% diagnostic of topography
    figure
    plot(topoCC(:,:,f)); hold on; plot(topoCCshuff(:,:,f),':');
    title(mat_fname{f}); set(gca,'Xtick',[1 2]); set(gca,'Xticklabel',{'x','y'})
    
    
%%% center RF positions
x0 = nanmedian(rfx(useOn,1));
y0 = nanmedian(rfy(useOn,1));

%%% do topographic maps for X and Y, for both On and Off responses
    axLabel = {'X','Y'};
    onoffLabel = {'On','Off'}
    figure
    for ax = 1:2
        for rep = 1:2;
            subplot(2,2,2*(rep-1)+ax)
            
            imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
            hold on
            if rep==1
                data = useOn;
            else data = useOff;
            end
            
            for i = 1:length(data)
                if ax ==1
                    plot(xpts(data(i)),ypts(data(i)),'o','Color',cmapVar(rfx(data(i),rep)-x0,-25, 25, jet));
                else
                    plot(xpts(data(i)),ypts(data(i)),'o','Color',cmapVar(rfy(data(i),rep)-y0,-25, 25, jet));
                end
            end
            title(sprintf('%s %s',axLabel{ax},onoffLabel{rep}))
        end
    end
    
    
    
    %%% map of On/Off ratio
    figure
    imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
    hold on
    for i = 1:length(use)
        plot(xpts(use(i)),ypts(use(i)),'o','Color',cmapVar(onOff(use(i)),-0.5, 0.5, jet));
    end
    title('on off ratio')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% size map for On
    figure
    imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
    hold on
    for i = 1:length(useOn)
        plot(xpts(useOn(i)),ypts(useOn(i)),'o','Color',cmapVar(szPref(useOn(i),1),1.5 , 2.5, jet));
    end
    title('size pref On')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

    %%% size map for Off
    figure
    imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
    hold on
    for i = 1:length(useOff)
        plot(xpts(useOff(i)),ypts(useOff(i)),'o','Color',cmapVar(szPref(useOff(i),2),1.5 , 2.5, jet));
    end
    title('size pref OFF')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

    
    
    %%% region-wise analysis
    if exist('xb','var')
        
        %%% show regions
           col = 'rgbc';
        figure
        imagesc(meanGreenImg); hold on
        for r = 1:length(xb)
            inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
            plot(xpts(inRegion),ypts(inRegion),'.','Color',col(r));
        end 
        axis equal
        
        
        
        %%% compile data
        for r = 1:4
            inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
            fracUsed(r,f) = length(intersect(use, find(inRegion)))/sum(inRegion);
            onSizeDist(r,1:5,f) = hist(szPref(intersect(useOn, find(inRegion)),1),1:5)/length(intersect(useOn, find(inRegion)));
            offSizeDist(r,1:5,f) = hist(szPref(intersect(useOff, find(inRegion)),2),1:5)/length(intersect(useOff, find(inRegion)));
            onOffHistAll(r,:,f) = hist(onOff(intersect(use,find(inRegion))),[-1:0.1:1])/ length(intersect(use,find(inRegion)));
            regionTuning(r,1,:,:,f) = nanmean(tuning(intersect(useOn, find(inRegion)),1,:,:),1);
            regionTuning(r,2,:,:,f) = nanmean(tuning(intersect(useOff, find(inRegion)),2,:,:),1);
            
        end
        
        %%% fraction used figure
        figure
        bar(fracUsed(:,f)); ylabel('fraction'); title('fraction used'); xlabel('region'); ylim([0 1])
        
        %%% on/off preference figure
        figure
        for r = 1:4
        subplot(2,2,r)
        bar(-1:0.1:1,onOffHistAll(r,:,f)); ylim([0 1]); xlabel('on off index'); title(rLabels{r});
        end
        
        %%% ON size preference
        figure
        for r = 1:4
        subplot(2,2,r)
        bar(1:5,onSizeDist(r,:,f)); ylim([0 1]); xlabel('size'); title([rLabels{r} ' ON']);
        end
        
             %%% OFF size preference
        figure
        for r = 1:4
        subplot(2,2,r)
        bar(1:5,offSizeDist(r,:,f)); ylim([0 1]); xlabel('size'); title([rLabels{r} ' OFF']);
        end
        
        %%% ON size tuning
        figure
        for r = 1:4
            subplot(2,2,r);
            plot(squeeze(regionTuning(r,1,:,:,f))'); title([rLabels{r} ' ON']); ylim([-0.1 0.2])
        end
        
                %%% Off size tuning
        figure
        for r = 1:4
            subplot(2,2,r);
            plot(squeeze(regionTuning(r,2,:,:,f))'); title([rLabels{r} ' OFF']); ylim([-0.1 0.2])
        end
        
        
        end
end

%%% plot On/Off correlation as function of distance
centers = 0.5*(bins(1:end-1) + bins(2:end))
figure
errorbar(centers*2,nanmean(simCorr,2),nanstd(simCorr,[],2)/sqrt(nfiles));
hold on
errorbar(centers*2,nanmean(simCorrShuff,2),nanstd(simCorrShuff,[],2)/sqrt(nfiles),'r:');
ylabel('On / Off correlation');
xlabel('distance (um)');
legend('data','shuffle');
xlim([0 400]); ylim([-0.1 0.6])


%%% size prefernce correlation
centers = 0.5*(bins(1:end-1) + bins(2:end))
figure
errorbar(centers*2,nanmean(szCorr,2),nanstd(szCorr,[],2)/sqrt(nfiles));
hold on
errorbar(centers*2,nanmean(szCorrShuff,2),nanstd(szCorrShuff,[],2)/sqrt(nfiles),'r:');
ylabel('size pref correlation');
xlabel('distance (um)');
legend('data','shuffle');
xlim([0 400]); ylim([-0.1 0.6])


%%% plot response timecourses
t = 0.1*((1:21)-3);  %%% time in seconds
labels = {'ON','OFF'};

col = 'bgrk'
for rep = 1:2  %%% on vs off
    figure
    hold on
    for sz = 1:4;
        shadedErrorBar(t, squeeze(mean(szTuning(rep,sz,:,:),4))',squeeze(std(szTuning(rep,sz,:,:),[],4))'/sqrt(nfiles),col(sz) );
        xlabel('sec');
        ylabel('dF/F');
    end
    xlim([-0.2 2]); ylim([-0.03 0.125])
    title(labels{rep})
end


%%% make a legend (since shaded errorbars mess up legend
figure
for i = 1:4
    hold on
    plot(1,1,col(i));
end
legend({'3deg','6deg','12deg','full-field'});

%%% calculate mean values for topography
data(:,1) = mean(topoCC(:,1,:),3);
err(:,1) = std(topoCC(:,1,:),[],3) / sqrt(f);

data(:,2) = mean(topoCCshuff(:,1,:),3);
err(:,2) = std(topoCCshuff(:,1,:),[],3) / sqrt(f);

%%% errorbar plots of topography
figure
barweb(data,err)
set(gca,'Xticklabel',{'azimuth','elevation'});
ylabel('correlation coeff');
legend({'data','shuffle'})
title('topography correlation')
