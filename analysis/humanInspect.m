
close all

sx=3;
sy=2;
subjects={'lct'} %bas, cmg, jsl, dan, pkc,lct
%subjects={'cmg','dan','pkc','lct'} %enough trials and correct
dateRange=[datenum('04-Jan-2009 19:34:59') now];
goodType='humanPsych';

figure
condType='8flanks+'%'colin+3'%&nfMix', '8flanks+'
filter=[];
filter{1}.type='11';
filter{2}.type='manualVersion';
filter{2}.includedVersions=[2,3,5:10]; %remove first version learning, and 4th version wrong contrast
filter{3}.type='performanceRange';
filter{3}.parameters.performanceMethod='pCorrect';               
filter{3}.parameters.performanceParameters={[.6 1],'symetricBoxcar',100}; 
filter{3}.parameters.goodType=goodType;
filter{3}.parameters.whichCondition={'hasFlank',[1]};
filter{2}=[];
filter{3}=[];
[stats CI names params]=getFlankerStats(subjects,condType,{'pctCorrect','yes','hits','CRs'},filter,dateRange,goodType);
%[stats2 CI2 names2 params2]=getFlankerStats({'cmg'},'colin+3&contrasts',{'pctCorrect','yes','hits','CRs'},'12',dateRange,goodType);
[delta ]=viewFlankerComparison(names,params);
figure

% dateRange=[now-(40./(60*24)) now];
for i=1:length(subjects)
    d=getSmalls(subjects{i},dateRange)
    minUsed= 60*24*(d.date(end)-d.date(1));
    minLeft=90-minUsed;
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
            %[s plotParams]=flankerAnalysis(d,'colin+1','performancePerDeviationPerCondition', 'pctCor','13',goodType);
            
            filter{1}.type='14'; % keep filter{2} from above
            [stats CI names params]=getFlankerStats(subjects,'allRelativeTFOrientationMag',{'pctCorrect','yes','hits','CRs'},filter,dateRange,goodType);
            doHitFAScatter(stats,CI,names,params,[],[],0,0,0,0,1,3,[])
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

