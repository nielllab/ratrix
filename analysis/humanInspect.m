
close all

sx=3;
sy=2;
subjects={'cmg'} %bas, cmg
dateRange=[datenum('04-Jan-2009 19:34:59') now];
goodType='humanPsych';

figure
[stats CI names params]=getFlankerStats({'cmg'},'colin+3',{'pctCorrect','yes','hits','CRs'},'11',dateRange,goodType);
[stats2 CI2 names2 params2]=getFlankerStats({'cmg'},'colin+3&contrasts',{'pctCorrect','yes','hits','CRs'},'12',dateRange,goodType);
[delta ]=viewFlankerComparison(names,params);
figure
%%

for i=1:length(subjects)
    d=getSmalls(subjects{i},dateRange)
    goods=getGoods(d,goodType);
    [condInd name has colors]=getFlankerConditionInds(d,goods,'colin+3');
    
    subplot(sx,sy,1)
    doPlotPercentCorrect(d,goods,[],[],[],[],[],[],[],[],[],[],{condInd,colors})
    
    doPlot('plotRatePerDay',d,gcf,sx,sy,2,'humanPsych',false)
    axis([get(gca,'Xlim') -20 50 ])
    
    subplot(sx,sy,3)
    [s plotParams]=flankerAnalysis(d,'colin+3','performancePerContrastPerCondition', 'pctCor','11',goodType);
    
    subplot(sx,sy,4)
    [s plotParams]=flankerAnalysis(d,'colin+3','performancePerContrastPerCondition', 'hits','12',goodType);

    subplot(sx,sy,5)
    doHitFAScatter(stats,CI,names,params,[],[],0,0,0,0,1,3,{'l-l','---'})
    
    subplot(sx,sy,6)
    [s plotParams]=flankerAnalysis(d,'colin+3','performancePerContrastPerCondition', 'CRs','12',goodType);
    %perc ondition "miss rate" is poorly defined for muliple contrasts
    %doHitFAScatter(stats2,CI2,names2,params2,[],[],0,0,0,0,1,3)%,{'l-l','---'}) 
end
%%

