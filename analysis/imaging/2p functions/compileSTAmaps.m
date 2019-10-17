%%% compiles data from sparse noise analysis
%%% cmn 2019

close all
clear all

files = dir('*.mat');

for f = 1:length(files)
    files(f).name
    load(files(f).name,'xpts','ypts','rfx','rfy','tuning','zscore')
    
    zthresh = 5;
    
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
    
    n=0;
    for i = 1:length(use)-1;
        for j=i+1:length(use)
            n=n+1;
            dist(n) = sqrt((xpts(use(i))-xpts(use(j))).^2 + (ypts(use(i))-ypts(use(j))).^2 );
            onOffpairs(n,1) = onOff(use(i));
            onOffpairs(n,2) = onOff(use(j));
        end
    end
%     
%     figure
%     plot(dist,abs(onOffpairs(:,1)-onOffpairs(:,2)),'.');
    
    onoffSim = 1 - 0.5*abs(onOffpairs(:,1)-onOffpairs(:,2));
    bins = 0:25:300;
    for i = 1:length(bins)-1;
        inrange = dist>bins(i) & dist<bins(i+1);
        simHist(i,f) = mean(onoffSim(inrange));
        cc = corrcoef(onOffpairs(inrange,1),onOffpairs(inrange,2));
        simCorr(i,f) = cc(2,1);
    end
    
    distShuff = dist(ceil(n*rand(n,1)));
    for i = 1:length(bins)-1;
        inrange = distShuff>bins(i) & distShuff<bins(i+1);
        simHistShuff(i,f) = mean(onoffSim(inrange));
        cc = corrcoef(onOffpairs(inrange,1),onOffpairs(inrange,2));
        simCorrShuff(i,f) = cc(2,1);
    end
    
%     figure
%     plot(simHist(:,f)); hold on; plot(simHistShuff(:,f));
%     
%     figure
%     plot(bins(2:end)*2,simCorr(:,f)); hold on; plot(bins(2:end)*2,simCorrShuff(:,f),'r:');
%     ylabel('On / Off correlation');
%     xlabel('distance (um)');
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
    
end

centers = 0.5*(bins(1:end-1) + bins(2:end))
figure
errorbar(centers*2,mean(simCorr,2),std(simCorr,[],2)/sqrt(length(files)));
hold on
errorbar(centers*2,mean(simCorrShuff,2),std(simCorrShuff,[],2)/sqrt(length(files)),'r:');
ylabel('On / Off correlation');
xlabel('distance (um)');
legend('data','shuffle');
xlim([0 600]); ylim([-0.5 0.75])

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

