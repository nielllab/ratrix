
close all

sx=3;
sy=2;
subjects={'pkc'} %bas, cmg, jsl, dan
%subjects={'cmg','dan','pkc'} %enough trials and correct
dateRange=[datenum('04-Jan-2009 19:34:59') now];
goodType='humanPsych';

figure
condType='8flanks+'%'colin+3'%&nfMix', '8flanks+'
filter=[];
filter{1}.type='11';
filter{2}.type='manualVersion';
filter{2}.includedVersions=[3:10];
%filter{2}=[]
[stats CI names params]=getFlankerStats(subjects,condType,{'pctCorrect','yes','hits','CRs'},filter,dateRange,goodType);
%[stats2 CI2 names2 params2]=getFlankerStats({'cmg'},'colin+3&contrasts',{'pctCorrect','yes','hits','CRs'},'12',dateRange,goodType);
[delta ]=viewFlankerComparison(names,params);
figure

%%

dateRange(2)=now;
% dateRange=[now-(40./(60*24)) now];
for i=1:length(subjects)
    d=getSmalls(subjects{i},dateRange)
    minUsed= 60*24*(d.date(end)-d.date(1));
    minLeft=90-minUsed;
    d=removeSomeSmalls(d,d.manualVersion==1)
    goods=getGoods(d,goodType);
    [condInd name has colors]=getFlankerConditionInds(d,goods,condType);
    
    subplot(sx,sy,1)
    doPlotPercentCorrect(d,goods,[],[],[],[],[],[],[],[],[],[],{condInd,colors})
    
    doPlot('plotRatePerDay',d,gcf,sx,sy,2,'humanPsych',false)
    axis([get(gca,'Xlim') -20 50 ])
    
    subplot(sx,sy,3)
    [s plotParams]=flankerAnalysis(d,condType,'performancePerContrastPerCondition', 'pctCor','11',goodType);
    
    subplot(sx,sy,5)
    %doHitFAScatter(stats,CI,names,params,[],[],0,0,0,0,1,3,{'l-l','---'})
    % doHitFAScatter(stats,CI,names,params,[],[],0,0,0,0,1,3,{'changeFlank'
    % ,'colin'})
    doHitFAScatter(stats,CI,names,params,[],{'changeFlank','colin'},0,0,0,0,1,3,{'changeFlank','colin'})
    
    switch max(d.step)
        case 14
            
            subplot(sx,sy,4)
            [s plotParams]=flankerAnalysis(d,'allRelativeTFOrientationMag','performancePerContrastPerCondition', 'hits','14',goodType);
            legend(plotParams.conditionNames)
            
            subplot(sx,sy,6)
            [s plotParams]=flankerAnalysis(d,'colin+1','performancePerDeviationPerCondition', 'pctCor','13',goodType);
        case 12
            subplot(sx,sy,4)
            [s plotParams]=flankerAnalysis(d,condType,'performancePerContrastPerCondition', 'hits','12',goodType);
            
            subplot(sx,sy,6)
            [s plotParams]=flankerAnalysis(d,condType,'performancePerContrastPerCondition', 'CRs','12',goodType);
            %perc ondition "miss rate" is poorly defined for muliple
            %contrasts
            %doHitFAScatter(stats2,CI2,names2,params2,[],[],0,0,0,0,1,3)%,{'l-l','---'})
        case 11
            doPlot('plotBiasScatter',d,gcf,sx,sy,4,'humanPsych',false); hold off
            %subplot(sx,sy,6); plot(d.responseTime)
            doPlot('plotITI',d,gcf,sx,sy,6,'humanPsych',false); hold off
    end
end
disp(sprintf('min Used: %2.2g min Left: %2.2g',minUsed,minLeft))
%%

