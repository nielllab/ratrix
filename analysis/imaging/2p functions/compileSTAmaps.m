%%% compiles data from sparse noise analysis in Octo data
%%% cmn 2019

close all
clear all

%%% select files to analyze based on compile file

%%% select files to analyze based on compile file
stimlist = {'sparse noise 1','sparse noise 2'};  %%% add others here
for i = 1:length(stimlist)
    display(sprintf('%d) %s',i,stimlist{i}))
end
stimnum = input('which stim : ');
stimname = stimlist{stimnum};

xyswap = 1;  %%% swap x and y for retinotopy?

if strcmp(stimname,'sparse noise 2')
    nsz = 4;
else
    nsz = 3;
end

%batch_file = 'ForBatchFileAngeliquewregioned.xlsx';

[batch_fname batch_pname] = uigetfile('*.xlsx','.xls batch file');
batch_file = fullfile(batch_pname,batch_fname);

[sbx_fname acq_fname mat_fname quality] = compileFilenames(batch_file,stimname);

Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigs.ps';

if Opt.SaveFigs
    psfile = Opt.psfile;
    if exist(psfile,'file')==2;delete(psfile);end
end

% %%% selectall files in directory
% files = dir('*.mat');
% for i = 1:nfiles
%     mat_fname{i} = files(i).name;
% end

%%% select files to use based on quality
for i = 1: length(quality);
    usefile(i) = strcmp(quality{i},'Y');
end


useN = find(usefile); clear goodfile
n=0;
display(sprintf('%d recordings, %d labeled good',length(usefile),length(useN)));

%%% collect filenames and make sure the files are there
for i = 1:length(useN)
    try
        base = mat_fname{useN(i)}(1:end-4);
        goodfile{n+1} = dir([base '*']).name;
        n= n+1;
    catch
        sprintf('cant do %s',mat_fname{useN(i)})
    end
end
mat_fname = goodfile;

nfiles = length(mat_fname);
display(sprintf('%d good files found',nfiles))

rLabels = {'OGL','Plex','IGL','Med'};

for f = 1:nfiles
    
    %%% load data
    mat_fname{f}
    clear xb yb
    load(mat_fname{f},'xpts','ypts','rfx','rfy','tuning','zscore','xb','yb','meanGreenImg')
    
    %%% threshold for good RF
    zthresh = 5.0;
    
    %%% select RFs that have zscore(ON, OFF) greater than zthresh
    use = find(zscore(:,1)>zthresh | zscore(:,2)<-zthresh);
    useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);
    useOnOff = intersect(useOn,useOff);
    notOn = find(zscore(:,1)<zthresh); notOff = find(zscore(:,2)>-zthresh);
    
    fractionResponsive(f)=length(use)/length(zscore);
    
    %%% calculate amplitude of response based on size response tuning(cells,on/off,size, time)
    %%% average over 3 spot sizes and response time window
    amp = nanmean(nanmean(tuning(:,:,1:end-1,8:15),4),3);
    
    %%% positive rectify amp, to calculate preference index for ON/OFF
    ampPos = amp; ampPos(ampPos<0)=0;
    onOff = (ampPos(:,1)-ampPos(:,2))./(ampPos(:,1)+ampPos(:,2));
    onOff(notOn)=-1; onOff(notOff)=1;
    
    %%% histogram of On/Off selectivity
    onOffHist = hist(onOff(use),[-1:0.1:1]);
    figure
    bar([-1:0.1:1],onOffHist); xlabel('on off pref')
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% calculate size tuning curve, by averaging over peak response window
    sz_tune = nanmean(tuning(:,:,:,8:15),4);  %%% sz_tune(cell,on/off,size)
    
    %%% calculate preferred size as weighted average
    if nsz==3
        szPref = squeeze(sz_tune(:,:,1)+ sz_tune(:,:,2)*2 + sz_tune(:,:,3)*3)./sum(sz_tune(:,:,1:3),3);
    else
        szPref = squeeze(sz_tune(:,:,1)+ sz_tune(:,:,2)*2 + sz_tune(:,:,3)*3  + sz_tune(:,:,4)*4)./sum(sz_tune(:,:,1:4),3);
    end
    
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
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% plot mean size tuning for on and off
    figure
    subplot(2,2,1)
    plot(squeeze(mean(tuning(useOn,1,:,:),1))');
    colororder(jet(nsz+1)*0.75)
    title('ON')
    
    subplot(2,2,2)
    plot(squeeze(mean(tuning(useOff,2,:,:),1))');
    colororder(jet(nsz+1)*0.75)
    title(mat_fname{f})
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% store tuning for all files
    szTuning(1,:,:,f) = nanmean(tuning(useOn,1,:,:),1);
    szTuning(2,:,:,f) = nanmean(tuning(useOff,2,:,:),1);
    
    %%% retinotopy
    if xyswap ==1
        xptsnew = ypts;
        yptsnew = xpts;
    else
         xptsnew = xpts;
        yptsnew = ypts;
    end
        %%% center RF positions
    x0 = nanmedian(rfx(useOn,1));
    y0 = nanmedian(rfy(useOn,1));
    
    figure
    plot(rfx(useOff,2),xptsnew(useOff),'.'); xlabel('RFx location'); ylabel('cell x location')
    title('off')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    plot(rfx(useOff,2),yptsnew(useOff),'.'); xlabel('RF x location'); ylabel('cell y location')
    title('off')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
        figure
    plot(rfx(useOn,2),xptsnew(useOn),'.'); xlabel('RFx location'); ylabel('cell x location')
    title('on')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    plot(rfx(useOn,2),yptsnew(useOn),'.'); xlabel('RF x location'); ylabel('cell y location')
    title('on')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    
    %%% mean rf centers
    mx = mean(rfx(useOn,1),1);
    my = mean(rfy(useOn,1),1);
    
    %%% calculate correlation coeffs for RF location and cell location
    cc = corrcoef(rfx(useOn,1)-mx,xptsnew(useOn));
    topoCC(1,1,f) = cc(2,1);
    cc = corrcoef(rfy(useOn,1)-my,yptsnew(useOn));
    topoCC(2,1,f) = -cc(2,1);
    cc = corrcoef(rfx(useOff,2)-mx,xptsnew(useOff));
    topoCC(1,2,f) = cc(2,1);
    cc = corrcoef(rfy(useOff,2)-my,yptsnew(useOff));
    topoCC(2,2,f) = -cc(2,1);
    
    %%% create values for shuffle
    n= length(rfx);
    xshuff = xptsnew(ceil(n*rand(n,1)));
    yshuff = yptsnew(ceil(n*rand(n,1)));
    
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
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
        
        %%% center RF positions
    x0 = nanmedian(rfx(useOn,1));
    y0 = nanmedian(rfy(useOn,1));

    figure
subplot(1,2,1)
plot(xpts(useOn),rfx(useOn,1)-x0,'r.'); hold on;
plot(xpts(useOff),rfx(useOff,2)-x0,'b.'); %ylim([-30 30]); axis square
title('X topography'); legend('ON','OFF')
xlabel('x location'); ylabel('x RF');

subplot(1,2,2)
plot(ypts(useOn),rfy(useOn,1)-y0,'r.');hold on;
%ylim([-30 30]); axis square
plot(ypts(useOff),rfy(useOff,2)-y0,'b.');
title('Y topography'); legend('ON','OFF')
xlabel('y location'); ylabel('y RF');
    

    
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
            if ax ==1 & rep==1
                title(sprintf('x0 = %0.1f y0=%0.1f',x0,y0))
            else
                title(sprintf('%s %s',axLabel{ax},onoffLabel{rep}))
            end
        
        end
    end
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
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
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        
        %%% compile data
        for r = 1:4
            if r<=length(xb) & sum(inpolygon(xpts,ypts,xb{r},yb{r}))>0
                inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
                fracUsed(r,f) = length(intersect(use, find(inRegion)))/sum(inRegion);
                onSizeDist(r,1:5,f) = hist(szPref(intersect(useOn, find(inRegion)),1),1:0.5:3)/length(intersect(useOn, find(inRegion)));
                offSizeDist(r,1:5,f) = hist(szPref(intersect(useOff, find(inRegion)),2),1:5)/length(intersect(useOff, find(inRegion)));
                onOffHistAll(r,:,f) = hist(onOff(intersect(use,find(inRegion))),[-1:0.1:1])/ length(intersect(use,find(inRegion)));
                regionTuning(r,1,:,:,f) = nanmean(tuning(intersect(useOn, find(inRegion)),1,:,:),1);
                regionTuning(r,2,:,:,f) = nanmean(tuning(intersect(useOff, find(inRegion)),2,:,:),1);
            else
                fracUsed(r,f) = NaN;
                onSizeDist(r,1:5,f) = NaN;
                offSizeDist(r,1:5,f) = NaN;
                onOffHistAll(r,:,f) =NaN;
                regionTuning(r,1,:,:,f) = NaN;
                regionTuning(r,2,:,:,f) = NaN;
                
            end
        end
        
        %%% fraction used figure
        figure
        bar(fracUsed(:,f)); ylabel('fraction'); title('fraction used'); xlabel('region'); ylim([0 1])
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% on/off preference figure
        figure
        for r = 1:4
            subplot(2,2,r)
            bar(-1:0.1:1,onOffHistAll(r,:,f)); ylim([0 1]); xlabel('on off index'); title(rLabels{r});
        end
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% ON size preference
        figure
        for r = 1:4
            subplot(2,2,r)
            bar(1:5,onSizeDist(r,:,f)); ylim([0 1]); xlabel('size'); title([rLabels{r} ' ON']);
        end
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% OFF size preference
        figure
        for r = 1:4
            subplot(2,2,r)
            bar(1:5,offSizeDist(r,:,f)); ylim([0 1]); xlabel('size'); title([rLabels{r} ' OFF']);
        end
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% ON size tuning
        figure
        for r = 1:4
            subplot(2,2,r);
            plot(squeeze(regionTuning(r,1,:,:,f))'); title([rLabels{r} ' ON']); ylim([-0.1 0.2])
        end
        colororder(jet(nsz+1)*0.75)
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% Off size tuning
        figure
        for r = 1:4
            subplot(2,2,r);
            plot(squeeze(regionTuning(r,2,:,:,f))'); title([rLabels{r} ' OFF']); ylim([-0.1 0.2])
        end
        colororder(jet(nsz+1)*0.75)
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        
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
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

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
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% plot response timecourses
t = 0.1*((1:21)-3);  %%% time in seconds
labels = {'ON','OFF'};

col = 'bcgyr'
for rep = 1:2  %%% on vs off
    figure
    hold on
    for sz = 1:nsz+1;
        errorbar(t, squeeze(mean(szTuning(rep,sz,:,:),4))',squeeze(std(szTuning(rep,sz,:,:),[],4))'/sqrt(nfiles) );
        xlabel('sec');
        ylabel('dF/F');
    end
    colororder(jet(nsz+1)*0.75)
    xlim([-0.2 2]); ylim([-0.03 0.125])
    title(labels{rep})
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
end


%%% make a legend (since shaded errorbars mess up legend
figure
for i = 1:nsz+1
    hold on
    plot(1,1,col(i));
end
legend({'3deg','6deg','12deg','full-field'});
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% calculate mean values for topography
clear data
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
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% trying for tuning across recordings
% 
% fracUsed(r,f) 
% onSizeDist(r,1:5,f)
% offSizeDist(r,1:5,f) 
% onOffHistAll(r,:,f)
% regionTuning(r,1,:,:,f) 
% regionTuning(r,2,:,:,f) 

%%% fraction responsive
figure
bar(nanmean(fracUsed,2)); %%% add error bars
title('fraction used'); set(gca,'Xtick',1:4); set(gca,'Xticklabels',rLabels); ylim([0 1])

%%% on size distribution
figure
for r = 1:4
    subplot(2,2,r);
    bar(1:0.5:3,squeeze(nanmean(onSizeDist(r,:,:),3)));
    xlabel('size'); title([rLabels{r} ' ON']);
end

%% off size distribution
figure
for r = 1:4
    subplot(2,2,r);
    bar(1:0.5:3,squeeze(nanmean(offSizeDist(r,:,:),3)));
    xlabel('size'); title([rLabels{r} ' OFF']);
end

%%% on/off bias
figure
for r = 1:4
    subplot(2,2,r)
    bar(-1:0.1:1,nanmean(onOffHistAll(r,:,:),3)); ylim([0 1]); title(rLabels{r})
end


%%% region tuning
figure
for r = 1:4
    subplot(2,2,r);
    plot(1:21,squeeze(nanmean(regionTuning(r,1,:,:,:),5)));
    title([rLabels{r} ' ON']); ylim([-0.1 0.2])
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% Off size tuning
figure
for r = 1:4
    subplot(2,2,r);
    plot(1:21,squeeze(nanmean(regionTuning(r,2,:,:,:),5)));
    title([rLabels{r} ' Off']); ylim([-0.1 0.2])
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

figure
plot(f);
xlabel('session #')
ylabel('fraction of cells responsive'); ylim([0 1]);
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