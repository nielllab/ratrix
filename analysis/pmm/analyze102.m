
subject = {'102'};
%junk = allToSmall(subject,[now - 9999 now],1,0);
d = getSmalls(subject{1})

% d = recoverStepTransition(d)

ssOnly2Contrast = max(find(d.targetContrast==0.75));
ssOnly1Orientation = max(find(d.targetOrientation==pi/2));
only2Contrast = ([1:length(d.date)] > ssOnly2Contrast) & ([1:length(d.date)] < ssOnly1Orientation);
only1Orientation = ([1:length(d.date)] > ssOnly1Orientation);

figure;
hold on
plot([1:length(d.date)],d.targetContrast,'b.')
plot([1:length(d.date)],d.deviation,'r.')
plot([1:length(d.date)],d.targetOrientation,'g.')

% figure; doPlot('percentCorrect', d )

%%
conditionType='fourFlankers';
plotType='performancePerContrastPerCondition'; %performancePerContrastPerCondition, performancePerDeviationPerCondition
performanceMeasure = 'pctCor';
stepUsed = [];
verbose = 0;
figure; flankerAnalysis(removeSomeSmalls(d,d.step~=12),  conditionType, plotType,performanceMeasure, stepUsed, verbose)
title('all 12')

figure; flankerAnalysis(removeSomeSmalls(d,~only2Contrast),  conditionType, plotType,performanceMeasure, stepUsed, verbose)
title('only2Contrast')

conditionType='twoFlankers';
figure; flankerAnalysis(removeSomeSmalls(d,~only1Orientation), conditionType, plotType,performanceMeasure, stepUsed, verbose)
title('only1Orientation')


%temproal ROC
subplotParams.index=1; subplotParams.x=1; subplotParams.y=1;
gcf=figure;
handles=gcf+[1:18];
whichPlots=zeros(1,18); whichPlots([11 15])=1;
inspectRatResponses(char(subject),'noPathUsed',whichPlots,handles,subplotParams,removeSomeSmalls(d,d.step~=12));
cleanUpFigure(handles([11 15]))

%%

%if using only2Contrast, beware the inhomgenaity
figure; doPlot('plotBias', removeSomeSmalls(d,~only2Contrast))
figure; doPlot('plotBias', removeSomeSmalls(d,d.step~=12))
%% 
conditionType='twoFlankers';
plotType='performancePerDeviationPerCondition'; %performancePerContrastPerCondition, performancePerDeviationPerCondition
performanceMeasures={'correctRejections','hitRate','pctCor'}
for i=1:length(performanceMeasures)
   f=figure; flankerAnalysis(removeSomeSmalls(d,d.step~=12),  conditionType, plotType,performanceMeasures{i}, stepUsed, verbose)
   axis([.15 0.35 0.45 0.7 ])
   xlabel('distance from target to flanker')
   set(gca,'XTickLabel',[2.5,3,3.5,5])
   set(gca,'XTick',[2.5,3,3.5,5]/16)
   set(gca,'YTickLabel',[.5:.05:.75])
   set(gca,'YTick',[.5:.05:.7])
   title('')
   legend('')
   cleanUpFigure(f)
end

performanceMeasure = 'pctRightward';
f=figure; flankerAnalysis(removeSomeSmalls(d,d.step~=12),  conditionType, plotType,performanceMeasure,  stepUsed, verbose)
   xlabel('distance from target to flanker')
   axis([.15 0.35 0.35 0.6 ])
   set(gca,'XTickLabel',[2.5,3,3.5,5])
   set(gca,'XTick',[2.5,3,3.5,5]/16)
   set(gca,'YTickLabel',[.35:.05:.6])
   set(gca,'YTick',[.35:.05:.6])
   title('bias')
   legend('')
   cleanUpFigure(f)
   
%% analysis conditioned upon after only correct trials

d = getSmalls('102');
% d = removeSomeSmalls(d, d.trialNumber < 276000);
d = removeSomeSmalls(d, d.trialNumber < 278000);

figure;
doPlot('percentCorrect', d);

conditionType='twoFlankers';
plotType='performancePerDeviationPerCondition'; %performancePerDeviationPerCondition, performancePerContrastPerCondition, phaseEffect
performanceMeasure = 'pctRightward'; %pctCor, pctRightward, hitRate, correctRejections
stepUsed = [];
verbose = 0;

[context sideName correctName] =getSideCorrectContext(d)
numSides = length(sideName);
numCorrect = length(correctName);
figure;
for i = 1:numSides
    for j = 1:numCorrect
        index=(i-1)*numCorrect + j;
        subplot(numSides, numCorrect,index )
        flankerAnalysis(removeSomeSmalls(d, ~context(index,:)),  conditionType, plotType,performanceMeasure, stepUsed, verbose)
%         doPlot('plotBias', removeSomeSmalls(d, ~context(index,:)), 2, numSides, numCorrect, index);
        if j == 1
            ylabel(sideName{i})
        end
        if i == 1
            title(correctName{j})
        end
    end
end
afterCorrects=context(2,:) | context(4,:);
figure;         flankerAnalysis(d,  conditionType, plotType,performanceMeasure, stepUsed, verbose)
figure;         flankerAnalysis(removeSomeSmalls(d,~afterCorrects),  conditionType, plotType,performanceMeasure, stepUsed, verbose)


subplotParams.index=1; subplotParams.x=1; subplotParams.y=1;
gcf=figure;
handles=gcf+[1:18];
whichPlots=zeros(1,18); whichPlots([11 15])=1;
inspectRatResponses(char(d.info.subject),'noPathUsed',whichPlots,handles,subplotParams,d);

cleanUpFigure(handles([11 15]))
%%  check probe trials and best performing context


d = getSmalls('102');
d = removeSomeSmalls(d, d.trialNumber < 260000 | d.trialNumber > 283864);


absInd=d.trialNumber(min(find(d.date>datenum('Apr.9,2008'))));% when the lights changed
localInd=min(find(d.date>datenum('Apr.9,2008')));

        smoothingWidth=300;
        threshold=0.85;
        axMin=0.3;
        axMax=1;
        dayTransitionsOn=1;
        addSteps=1;
        plotCorrectionTrialsToo=1;
        markTrialsToThreshold=0;
        noFlankInds=getFlankerConditionInds(d,getGoods(d),'noFlank');  %'noFlank'
        TFconditionInds=getFlankerConditionInds(d,getGoods(d),'fourFlankers'); 
        devInds=getFlankerConditionInds(d,getGoods(d),'allDevs'); 

plotCorrectionTrialsToo=1
subplot(141); ;title('correction Trails');
doPlotPercentCorrect(d,getGoods(d),smoothingWidth,threshold,axMin,axMax,dayTransitionsOn,addSteps,plotCorrectionTrialsToo,markTrialsToThreshold);
plot(localInd,0.4,'g^','markerSize',10)

plotCorrectionTrialsToo=0;
subplot(142); ;title('no Flank probe');
doPlotPercentCorrect(d,getGoods(d),smoothingWidth,threshold,axMin,axMax,dayTransitionsOn,addSteps,plotCorrectionTrialsToo,markTrialsToThreshold,{noFlankInds,[0 1 0]})
plot(localInd,0.4,'g^','markerSize',10)


subplot(143); title('all flankers ');
doPlotPercentCorrect(d,getGoods(d),smoothingWidth,threshold,axMin,axMax,dayTransitionsOn,addSteps,plotCorrectionTrialsToo,markTrialsToThreshold,{devInds,[0 0 1; 0 0 1; 0 0 1; 0 1 0;0 0 1]})
plot(localInd,0.4,'g^','markerSize',10)


subplot(144);title('farthest flanker');
condition=devInds(end,:) ;%& TFconditionInds(1,:);
doPlotPercentCorrect(d,getGoods(d),smoothingWidth,threshold,axMin,axMax,dayTransitionsOn,addSteps,plotCorrectionTrialsToo,markTrialsToThreshold,{condition,[0 1 0]})
plot(localInd,0.4,'g^','markerSize',10)



%%  same as above
conditionType='twoFlankers';
plotType='performancePerDeviationPerCondition'; %performancePerContrastPerCondition, performancePerDeviationPerCondition
performanceMeasures={'correctRejections','hitRate','pctCor'}
for i=1:length(performanceMeasures)
   f=figure; flankerAnalysis(removeSomeSmalls(d,d.step~=12),  conditionType, plotType,performanceMeasures{i}, stepUsed, verbose)
    axis([.15 0.35 0.3 1 ])
   xlabel('distance from target to flanker')
   set(gca,'XTickLabel',[2.5,3,3.5,5])
   set(gca,'XTick',[2.5,3,3.5,5]/16)
   set(gca,'YTickLabel',[.3:.1:1])
   set(gca,'YTick',[.3:.1:1])
   title('')
%    legend('')
   cleanUpFigure(f)
end

performanceMeasure = 'pctRightward';
f=figure; flankerAnalysis(removeSomeSmalls(d,d.step~=12),  conditionType, plotType,performanceMeasure,  stepUsed, verbose)
   xlabel('distance from target to flanker')
   axis([.15 0.35 0.2 0.7 ])
   set(gca,'XTickLabel',[2.5,3,3.5,5])
   set(gca,'XTick',[2.5,3,3.5,5]/16)
   set(gca,'YTickLabel',[.2:.1:.7])
   set(gca,'YTick',[.2: .1:.7])
   title('bias')
%    legend('')
   cleanUpFigure(f)
   
   
   performanceMeasure = 'dpr';
f=figure; flankerAnalysis(removeSomeSmalls(d,d.step~=12),  conditionType, plotType,performanceMeasure,  stepUsed, verbose)
   xlabel('distance from target to flanker')
   axis([.15 0.35 0.2 0.7 ])
   set(gca,'XTickLabel',[2.5,3,3.5,5])
   set(gca,'XTick',[2.5,3,3.5,5]/16)
   set(gca,'YTickLabel',[.2:.1:.7])
   set(gca,'YTick',[.2: .1:.7])
   title('bias')
%    legend('')
   cleanUpFigure(f)
   
   
%%


conditionType='fourFlankers';
plotType='performancePerDeviationPerCondition'; %performancePerContrastPerCondition
performanceMeasure = 'pctCor'; %pctCor pctRightward
stepUsed = [];
verbose = 0;

subjects = {'rat_132','rat_133','rat_134','rat_135'};
f=figure; 
for i=1:length(subjects)
%junk = allToSmall({subjects{i}},[now - 9999 now],1,0);
d = getSmalls(subjects{i});
%figure; doPlot('percentCorrect', d )
%plot(min(find(floor(d.date)==datenum('Dec.12,2007'))),.5,'rx')

step10start=d.date(min(find(d.step==10)));
step12start=d.date(min(find(d.step==12)));
if isempty(step12start)
    step12start=9999999999999999;
end
%endDate=min(datenum('Dec.12,2007'),step12start);
%which=[endDate-10<d.date & endDate>d.date];
which=[step10start<d.date & min(datenum('Dec.12,2007'),step12start)>d.date];


subplot(2,2,i)
flankerAnalysis(removeSomeSmalls(d,~which),  conditionType, plotType,performanceMeasure, stepUsed, verbose)
axis([.18 .2 .5 1])
   set(gca,'XTickLabel',[])
   set(gca,'XTick',[])
      legend('')
       xlabel('condition')
title(subjects{i}(5:7))
%figure; flankerAnalysis(removeSomeSmalls(d,d.step~=10),  conditionType, plotType,performanceMeasure, stepUsed, verbose)
end
cleanUpFigure(f)



%%
subjects = {'136','138','228','230'};
for i=1:length(subjects)
    d=getSmalls(subjects{i},[now-8 now])
    subplot(2,2,i)
    doPlot('percentCorrect',d); title(subjects{i})
end

