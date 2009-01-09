% function makeFlankerNeuralPrediction


%simulation parameters
numTrials=2000;
numMsec=100;
peak=60;
baseLine=20;
amplitude=peak-baseLine;
bpm=10; %binsPerMsec
delay=20; %stimulus to LGN
fbDelay=15;
smoothingKernalWidthMs=3; %
std=smoothingKernalWidthMs*bpm;
g=fspecial('gauss',[1 std*4], std);
rasterYRange=[5 15];

%define conditions and values
conditionNames={'noFlank', 'colinear', 'popOut', 'parallel'};
colors=[0 0  0 ; 1 0 0 ; 0 1 1; .6 .6 .6];
ffSurroundSuppression=[.1 .2 .2 .2];
fbSuppression=[.4 .8 .6 .6];
% peaks=[peak repmat(peak*)]
for i=1:length(conditionNames)
    pSpike=zeros(numTrials, numMsec*bpm);
    pSpike(:,1:(delay*bpm))=(baseLine)/(1000*bpm); %before the stimulus
    pSpike(:,(delay*bpm)+1:(delay+fbDelay)*bpm)=(baseLine+amplitude*(1-ffSurroundSuppression(i)))/(1000*bpm); %after the stimulus
    pSpike(:,(delay+fbDelay)*bpm:end)=(baseLine+amplitude*(1-ffSurroundSuppression(i))*(1-fbSuppression(i)))/(1000*bpm); %with feedback
    spike{i}=rand(numTrials,numMsec*bpm)<pSpike;
    x=conv(sum(spike{i}),g);
    width=length(g);
    psth{i}=x(width+1:end-width)*1000*bpm/(numTrials);
    size(psth{i})
end

%%
figure;
hold on;
for i=1:length(conditionNames)
    plot(1:size(psth{i},2),psth{i}, 'color', colors(i,:))
end


%raster
for i=1 %only the first condition
   [trial time]=ind2sub(size(spike{i}), find(spike{i}))
   plot(time-width/2, rasterYRange(1)+((trial/numTrials)*diff(rasterYRange)), '.', 'color', colors(i, :), 'MarkerSize', 1);
end
% yLabel('rate')
% xLabel('time (mSec)')
xTimeLabel=[0 delay fbDelay+delay numMsec];
yRateLabel=[0:20:60]
set(gca, 'XTickLabel', xTimeLabel)
set(gca, 'XTick', (xTimeLabel*bpm)-width)
set(gca, 'YTickLabel', yRateLabel)
set(gca, 'YTick', yRateLabel)
axis([0 numMsec*bpm 0 max(yRateLabel)]);

cleanUpFigure(gcf)

