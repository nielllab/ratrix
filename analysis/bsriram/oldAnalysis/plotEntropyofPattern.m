clc; clear;
serverDataPath = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\bsriram\data\ratNumber\';
fhan = figure();
load([serverDataPath '\allRats.mat']);
[l b] = getArrangement(length(allRats));
for no = 1:length(allRats)
    rat = allRats(no);
    display(int2str(rat)); pause(0);
    load([serverDataPath int2str(rat) '\compressedData.mat']);
    display('done loading');
    respLTotal = getResponses(getGoods(compressedData,'RemAll'),'l');
    targetLTotal = getTargets(getGoods(compressedData,'RemAll'),'l');
    respLNC = getResponses(getGoods(getGoods(compressedData,'RemAll'),'RemCorr'),'l');
    targetLNC = getTargets(getGoods(getGoods(compressedData,'RemAll'),'RemCorr'),'l');

    p00 = [0 0]; p01 = [0 1]; p10 = [1 0];  p11 = [1 1];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % for total data
    d = respLTotal;
    d1 = targetLTotal;
    o = zeros(4,length(d));
    I = o;
    w = 101;
    range = (w-1)/2;
    startInd = range+1;
    stopInd = length(d)-range;

    for i = startInd:stopInd
        o(1,i) = length(strfind(int2str(d(i-range:i+range)),int2str(p00)));
        o(2,i) = length(strfind(int2str(d(i-range:i+range)),int2str(p01)));
        o(3,i) = length(strfind(int2str(d(i-range:i+range)),int2str(p10)));
        o(4,i) = length(strfind(int2str(d(i-range:i+range)),int2str(p11)));
        I(1,i) = length(strfind(int2str(d1(i-range:i+range)),int2str(p00)));
        I(2,i) = length(strfind(int2str(d1(i-range:i+range)),int2str(p01)));
        I(3,i) = length(strfind(int2str(d1(i-range:i+range)),int2str(p10)));
        I(4,i) = length(strfind(int2str(d1(i-range:i+range)),int2str(p11)));
    end
    
    so = sum(o);
    o = o./[so;so;so;so];
    
    sI = sum(I);
    I = I./[sI;sI;sI;sI];
    
    eTotal = -sum(o.*log2(o));
    eTTotal = -sum(I.*log2(I));
    trialNumTotal = getTrials(getGoods(compressedData,'RemAll'));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % for NC data
    d = respLNC;
    d1 = targetLNC;
    o = zeros(4,length(d));
    I = o;
    w = 101;
    range = (w-1)/2;
    startInd = range+1;
    stopInd = length(d)-range;

    for i = startInd:stopInd
        o(1,i) = length(strfind(int2str(d(i-range:i+range)),int2str(p00)));
        o(2,i) = length(strfind(int2str(d(i-range:i+range)),int2str(p01)));
        o(3,i) = length(strfind(int2str(d(i-range:i+range)),int2str(p10)));
        o(4,i) = length(strfind(int2str(d(i-range:i+range)),int2str(p11)));
        I(1,i) = length(strfind(int2str(d1(i-range:i+range)),int2str(p00)));
        I(2,i) = length(strfind(int2str(d1(i-range:i+range)),int2str(p01)));
        I(3,i) = length(strfind(int2str(d1(i-range:i+range)),int2str(p10)));
        I(4,i) = length(strfind(int2str(d1(i-range:i+range)),int2str(p11)));
    end
    
    so = sum(o);
    o = o./[so;so;so;so];
    
    sI = sum(I);
    I = I./[sI;sI;sI;sI];
    
    eNC = -sum(o.*log2(o));
    eTNC = -sum(I.*log2(I));    
    trialNumNC = getTrials(getGoods(getGoods(compressedData,'RemAll'),'RemCorr'));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(2*l,b,2*no-1);
    hold on;
    plot(trialNumTotal,eTotal,'b');
    plot(trialNumTotal,eTTotal,'k');
    xlabel('trial numbers');
    ylabel('total entropy(bits)');
    title(['rat number ' int2str(rat)]);
    axis([trialNumTotal(1) trialNumTotal(end) 0 2]);
    %axis tight;
    hold off;
    
    subplot(2*l,b,2*no);
    hold on;
    plot(trialNumNC,eNC,'b');
    plot(trialNumNC,eTNC,'k');
    xlabel('trial numbers');
    ylabel('nonCorrection entropy(bits)');
    title(['rat number ' int2str(rat)]);
    axis([trialNumNC(1) trialNumNC(end) 0 2]);
    %axis tight;
    hold off;
end