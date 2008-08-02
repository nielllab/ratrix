clear; clc;
serverDataPath = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\bsriram\data\ratNumber\';
fhan = figure();load([serverDataPath '\allRats.mat']);
[l b] = getArrangement(length(allRats));
for no = 1:length(allRats)
    rat = allRats(no);
    display(int2str(rat)); pause(0);
    
    load([serverDataPath int2str(rat) '\compressedData.mat']);
    
    compressedData = changeDateFormat(compressedData);

    flag = ones(1,length(compressedData));
    ITIs = getSmooth(getITI(compressedData),101,flag);
    
    % change days into seconds
    ITIs = ITIs*86400;
    ITIs(ITIs>3600) = 0;
    
    trialNumbers = getTrials(compressedData);
    
    subplot(2,2,rat-266);
    plot(trialNumbers,ITIs);
    xlabel('trial numbers');
    ylabel('ITI(s)');
    title(['rat number ' int2str(rat)]);
    axis([trialNumbers(1) trialNumbers(end) 0 50]);
end

