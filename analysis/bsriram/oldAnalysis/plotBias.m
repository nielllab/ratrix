serverDataPath = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\bsriram\data\ratNumber\';
fhan = figure();
load([serverDataPath '\allRats.mat']);
[l b] = getArrangement(length(allRats));
for no = 1:length(allRats)
    rat = allRats(no);
    load([serverDataPath int2str(rat) '\compressedData.mat']);

    compressedData = getGoods(compressedData,'RemMK');

    biasL = getSmooth(getResponses(compressedData,'l'),101,ones(1,length(compressedData)));
    biasR = getSmooth(getResponses(compressedData,'r'),101,ones(1,length(compressedData)));
    
    trialNumbers = getTrials(compressedData);
    
    subplot(l,b,no);
    hold on;
    plot(trialNumbers,biasL,'b');
    plot(trialNumbers,biasR,'r');
    xlabel('trial numbers');
    ylabel('bias');
    title(['rat number ' int2str(rat)]);
    axis([trialNumbers(1) trialNumbers(end) 0 1]);
    hold off;
end