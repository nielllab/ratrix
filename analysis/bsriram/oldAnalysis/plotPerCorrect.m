clear; clc;
serverDataPath = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\bsriram\data\ratNumber\';
fhan = figure();
load([serverDataPath '\allRats.mat']);
allRats = 267;
[l b] = getArrangement(length(allRats));
for no = 1:length(allRats)
    rat = allRats(no);
    display(int2str(rat)); pause(0);
    
    load([serverDataPath int2str(rat) '\compressedData.mat']);
    
    compressedData = getGoods(compressedData,'RemAll');

    flag = ones(1,length(compressedData));
    perCorrect = getSmooth(getCorrects(compressedData),101,flag);
    
    perCorrectCorrection = getSmooth(getCorrects(compressedData),101,getCorrections(compressedData));
    perCorrectnonCorrection = getSmooth(getCorrects(compressedData),101,~getCorrections(compressedData));
    
    trialNumbers = getTrials(compressedData);
    
    subplot(l,b,no);
    hold on;
    plot(trialNumbers,perCorrect,'b');
    plot(trialNumbers,perCorrectCorrection,'Color',[0.9 0.9 0.9]);
    plot(trialNumbers,perCorrectnonCorrection,'r','LineWidth',2);
    
    xlabel('trial numbers');
    ylabel('% correct');
    title(['rat number ' int2str(rat)]);
    axis([trialNumbers(1) trialNumbers(end) 0.5 1]);
    axis tight;
end

