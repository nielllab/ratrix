

%% 
close all

%%  example code
d=getSmalls('327',[],5);
sum(d.correctionTrial)
mean(d.correctionTrial)


d.responseTime
filter=d.responseTime>.7;
x=removeSomeSmalls(d,filter);
figure; doPlotPercentCorrect(x);
title('327 faster than 700msec')

%% other things to call sometimes

edit quickInspect

goods=getGoods(d);  % safe to analyze
doPlot('plotRatePerDay',d) % 'plotRatePerDay' 'plotBiasScatter' 'makeDailyRaster', 'percentCorrect', 'plotLickAndRT'

smoothingWidth=30;
which=getGoods(d,'withoutAfterError');  % a logical
plotCorrectionTrialsToo=true;
doPlotPercentCorrect(d,which,smoothingWidth,[],[],[],true,true,plotCorrectionTrialsToo)%,axMin,axMax,dayTransitionsOn,addSteps,plotCorrectionTrialsToo,plotAfterErrorsToo, markTrialsToThreshold,addManualChangeMarker,conditionInds)