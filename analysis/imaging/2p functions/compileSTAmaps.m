%%% compiles data from sparse noise analysis
%%% cmn 2019

close all
clear all

files = dir('*.mat');

for f = 1:length(files)
    files(f).name
    load(files(f).name,'xpts','ypts','rfx','rfy','tuning','zscore')
    
    zthresh = 5.5;
    
    use = find(zscore(:,1)>zthresh | zscore(:,2)<-zthresh);
    useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);
    useOnOff = intersect(useOn,useOff);
    
    notOn = find(zscore(:,1)<zthresh); notOff = find(zscore(:,2)>-zthresh);
    
    amp = nanmean(nanmean(tuning(:,:,1:3,8:15),4),3);
    
    ampPos = amp; ampPos(ampPos<0)=0;
    onOff = (ampPos(:,1)-ampPos(:,2))./(ampPos(:,1)+ampPos(:,2));
    onOff(notOn)=-1; onOff(notOff)=1;
    
    onOffHist = hist(onOff(use),[-1:0.1:1]);
    figure
    bar(onOffHist);
    
sz_tune = nanmean(tuning(:,:,:,8:15),4);
szPref = squeeze(sz_tune(:,:,1)+ sz_tune(:,:,2)*2 + sz_tune(:,:,3)*3)./sum(sz_tune(:,:,1:3),3);

    
    clear szPairs onOffPairs dist
    n=0;
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
    
    onoffSim = 1 - 0.5*abs(onOffpairs(:,1)-onOffpairs(:,2));
    bins = 0:25:200;
    for i = 1:length(bins)-1;
        inrange = dist>bins(i) & dist<bins(i+1);
        simHist(i,f) = mean(onoffSim(inrange));
        cc = corrcoef(onOffpairs(inrange,1),onOffpairs(inrange,2));
        simCorr(i,f) = cc(2,1);
        cc = corrcoef(szPairs(inrange,1),szPairs(inrange,2));
        szCorr(i,f) =cc(2,1);
        
    end
    
    distShuff = dist(ceil(n*rand(n,1)));
    for i = 1:length(bins)-1;
        inrange = distShuff>bins(i) & distShuff<bins(i+1);
        simHistShuff(i,f) = mean(onoffSim(inrange));
        cc = corrcoef(onOffpairs(inrange,1),onOffpairs(inrange,2));
        simCorrShuff(i,f) = cc(2,1);
              cc = corrcoef(szPairs(inrange,1),szPairs(inrange,2));
        szCorrShuff(i,f) =cc(2,1);
    end
    
    %     figure
    %     plot(simHist(:,f)); hold on; plot(simHistShuff(:,f));
    %
    figure
    plot(bins(2:end)*2,simCorr(:,f)); hold on; plot(bins(2:end)*2,simCorrShuff(:,f),'r:');
    ylabel('On / Off correlation');
    xlabel('distance (um)');
    title(files(f).name)
    %
    figure
    subplot(2,2,1)
    plot(squeeze(mean(tuning(useOn,1,:,:),1))');
    title('ON')
    
    subplot(2,2,2)
    plot(squeeze(mean(tuning(useOff,2,:,:),1))');
    title(files(f).name)
    
    szTuning(1,:,:,f) = nanmean(tuning(useOn,1,:,:),1);
    szTuning(2,:,:,f) = nanmean(tuning(useOff,2,:,:),1);
    
    n= length(rfx);
    xshuff = xpts(ceil(n*rand(n,1)));
    yshuff = ypts(ceil(n*rand(n,1)));
    
    
    mx = mean(rfx(useOn,1),1);
    my = mean(rfy(useOn,1),1);
    
    figure
    plot(rfx(useOff,2),xpts(useOff),'.');
    
    
    cc = corrcoef(rfx(useOn,1)-mx,xpts(useOn));
    topoCC(1,1,f) = cc(2,1);
    cc = corrcoef(rfy(useOn,1)-my,ypts(useOn));
    topoCC(2,1,f) = -cc(2,1);
    cc = corrcoef(rfx(useOff,2)-mx,xpts(useOff));
    topoCC(1,2,f) = cc(2,1);
    cc = corrcoef(rfy(useOff,2)-my,ypts(useOff));
    topoCC(2,2,f) = -cc(2,1);
    
    cc = corrcoef(rfx(useOn,1)-mx,xshuff(useOn));
    topoCCshuff(1,1,f) = cc(2,1);
    cc = corrcoef(rfy(useOn,1)-my,yshuff(useOn));
    topoCCshuff(2,1,f) = -cc(2,1);
    cc = corrcoef(rfx(useOff,2)-mx,xshuff(useOff));
    topoCCshuff(1,2,f) = cc(2,1);
    cc = corrcoef(rfy(useOff,2)-my,yshuff(useOff));
    topoCCshuff(2,2,f) = -cc(2,1);
    
    
    figure
    plot(topoCC(:,:,f)); hold on; plot(topoCCshuff(:,:,f));
    title(files(f).name)
    
    


    
    
end

centers = 0.5*(bins(1:end-1) + bins(2:end))
figure
errorbar(centers*2,nanmean(simCorr,2),nanstd(simCorr,[],2)/sqrt(length(files)));
hold on
errorbar(centers*2,nanmean(simCorrShuff,2),nanstd(simCorrShuff,[],2)/sqrt(length(files)),'r:');
ylabel('On / Off correlation');
xlabel('distance (um)');
legend('data','shuffle');
xlim([0 400]); ylim([-0.1 0.6])

centers = 0.5*(bins(1:end-1) + bins(2:end))
figure
errorbar(centers*2,nanmean(szCorr,2),nanstd(szCorr,[],2)/sqrt(length(files)));
hold on
errorbar(centers*2,nanmean(szCorrShuff,2),nanstd(szCorrShuff,[],2)/sqrt(length(files)),'r:');
ylabel('size pref correlation');
xlabel('distance (um)');
legend('data','shuffle');
xlim([0 400]); ylim([-0.1 0.6])


t = 0.1*((1:21)-3);
labels = {'ON','OFF'};

col = 'bgrk'
for rep = 1:2
    figure
    hold on
    for sz = 1:4;
        shadedErrorBar(t, squeeze(mean(szTuning(rep,sz,:,:),4))',squeeze(std(szTuning(rep,sz,:,:),[],4))'/sqrt(length(files)),col(sz) );
        xlabel('sec');
        ylabel('dF/F');
    end
    
    xlim([-0.2 2]); ylim([-0.03 0.125])
end

figure
for i = 1:4
    hold on
    plot(1,1,col(i));
end
legend({'3deg','6deg','12deg','full-field'});

figure
data(:,1) = mean(topoCC(:,1,:),3);
err(:,1) = std(topoCC(:,1,:),[],3) / sqrt(f);

data(:,2) = mean(topoCCshuff(:,1,:),3);
err(:,2) = std(topoCCshuff(:,1,:),[],3) / sqrt(f);

figure
barweb(data,err)
set(gca,'Xticklabel',{'azimuth','elevation'});
ylabel('correlation coeff');
legend({'data','shuffle'})
title('topography correlation')
