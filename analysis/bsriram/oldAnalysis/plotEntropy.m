serverDataPath = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\bsriram\data\ratNumber\';
fhan = figure();
load([serverDataPath '\allRats.mat']);
[l b] = getArrangement(length(allRats));
for no = 1:length(allRats)
    rat = allRats(no);
    display(int2str(rat)); pause(0);
    load([serverDataPath int2str(rat) '\compressedData.mat']);
    
    cDTotal = getGoods(compressedData,'RemAll');
    cDNC = getGoods(cDTotal,'RemCorr');

    
    pLTotal = getSmooth(getResponses(cDTotal,'l'),101,ones(1,length(cDTotal)));
    pLTargetTotal = getSmooth(getTargets(cDTotal,'l'),101,ones(1,length(cDTotal)));
    trialNumTotal = getTrials(cDTotal);
    
    pLnonCorrection = getSmooth(getResponses(cDNC,'l'),101,ones(1,length(cDNC)));
    pLTargetnonCorrection = getSmooth(getTargets(cDNC,'l'),101,ones(1,length(cDNC)));
    trialNumnonCorrection = getTrials(cDNC);
    
    ERTotal = -(pLTotal.*log(pLTotal)+(1-pLTotal).*log(1-pLTotal));
    ERnonCorrection = -(pLnonCorrection.*log(pLnonCorrection)+(1-pLnonCorrection).*log(1-pLnonCorrection));
    
    ETTotal = -(pLTargetTotal.*log(pLTargetTotal)+(1-pLTargetTotal).*log(1-pLTargetTotal));
    ETnonCorrection = -(pLTargetnonCorrection.*log(pLTargetnonCorrection)+(1-pLTargetnonCorrection).*log(1-pLTargetnonCorrection));
    
    subplot(2*l,b,2*no-1);
    hold on;
    plot(trialNumTotal,ERTotal,'b');
    plot(trialNumTotal,ETTotal,'k');
    xlabel('trial numbers');
    ylabel('total entropy(bits)');
    title(['rat number ' int2str(rat)]);
    %axis([trialNumTotal(1) trialNumTotal(end) 0.2 1]);
    axis tight;
    hold off;
    
    subplot(2*l,b,2*no);
    hold on;
    plot(trialNumnonCorrection,ERnonCorrection,'b');
    plot(trialNumnonCorrection,ETnonCorrection,'k');
    xlabel('trial numbers');
    ylabel('nonCorrection entropy(bits)');
    title(['rat number ' int2str(rat)]);
    %axis([trialNumnonCorrection(1) trialNumnonCorrection(end) 0.2 1]);
    axis tight;
    hold off;
end
