serverDataPath = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\bsriram\data\ratNumber\';
fhan = figure();
load([serverDataPath '\allRats.mat']);
[l b] = getArrangement(length(allRats));
for no = 1:length(allRats)
    rat = allRats(no);
    load([serverDataPath int2str(rat) '\compressedData.mat']);
    compressedData = changeDateFormat(compressedData);
    trials = getNotrials(getDates(compressedData));
    
    subplot(l,b,no);
    bar(1:length(trials),trials);
    xlabel('days since start');
    ylabel('number of trials');
    title(['rat number ' int2str(rat)]);
    axis tight;
end

