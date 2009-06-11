


standardFlankerPaperPlot([2:4]);

%%


% GET STATS
dateRange=[0 pmmEvent('endToggle')];
statTypes={'pctCorrect','CRs','hits','dpr','yes'};
%subjects={'138','228'}; % quick for testing
subjects={'228','227','230','233','234','138','139'}; %sorted for amount

filter{1}.type='9.4';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
conditionType='8flanks+';              % lump popout and non-popout groups
useConds={'colin','para'};  % display these conditions
%useConds={'colin','para','changeFlank','changeTarget'};  % display these conditions
%condRename={'col','para','pop1','pop2'};% rename them this way
cMatrix={[9],[12]};                      % emphasize this comparison, calculate it from first arrow


[stats CI names params]=getFlankerStats(subjects,conditionType,statTypes,filter,dateRange);


%% ROC space
%     si=si+1; subplot(sx,sy,si); text(.5,.5,'stims')
subplot(1,2,1)
doLegend=false;
doCurve=false;
doYesLine=false;
doCorrectLine=false;
sideText=false; %?
doErrorBars=3; %ellipse
arrows={names.conditions{cMatrix{1,2}},names.conditions{cMatrix{1,1}}};
doHitFAScatter(stats,CI,names,params,subjects,useConds,doLegend,doCurve,doYesLine,doCorrectLine,sideText,doErrorBars,arrows)

% SUBPLOT: emphasize comparison
cMatrixNames=useConds;
diffEdges=[]
alpha=0.05;
doFigAndSub=false;
addTrialNums=false;
addNames=assignLabeledNames(subjects);
multiComparePerPlot=false;
objectColors.histSig=params.colors(cMatrix{1},:); % use the color of the first comparison
objectColors.histInsig=[0 0 0];
objectColors.subjectSig=objectColors.histSig;
objectColors.subjectInsig=[0 0 0];

subplot(2,4,3); viewFlankerComparison(names,params,cMatrix,{'hits'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors); axis square;
subplot(2,4,4); viewFlankerComparison(names,params,cMatrix,{'CRs'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors); axis square;
subplot(2,4,7); viewFlankerComparison(names,params,cMatrix,{'yes'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors); axis square;
subplot(2,4,8); viewFlankerComparison(names,params,cMatrix,{'dpr'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors); axis square;


 set(gcf,'Position',[0 0 1200 500])
    settings.fontSize=7;
    cleanUpFigure(gcf,settings)


%title('difference in pctCorrect');
%xlabel(sprintf('pct(%s) - pct(%s)', cMatrixNames{1},cMatrixNames{2}))
%ylabel('         count     rat ID');

%% correct rejects on axis
% okay the better way to do this is make a group called on axis, and one
% called off axis, and look for effects

conditionType='16flanks';              % lump popout and non-popout groups
[stats CI names params]=getFlankerStats(subjects,conditionType,statTypes,filter,dateRange);

figure
subplot(2,4,3); viewFlankerComparison(names,params,cMatrix,{'hits'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors); axis square;
onAxisFlanks=find(ismember(names.conditions,{'nRR','nLL'}));
skewFlanks=find(ismember(names.conditions,{'nLR','nRL'}));
usedConditionIDs=[onAxisFlanks skewFlanks];

singleRat={'233'}
barIms=[];   % eventually add em
colors=params.colors(8+usedConditionIDs,:);


 p=100*stats(strcmp(singleRat,names.subjects),usedConditionIDs,find(strcmp('pctCorrect',names.stats)));
 ci= 100*CI(strcmp(singleRat,names.subjects),usedConditionIDs,find(strcmp('pctCorrect',names.stats)),[1:2]);
 ci=reshape(ci(:),length(usedConditionIDs),2);
 doBarPlotWithStims(p,ci,barIms,colors,[50 100],'stats&CI',false)
 set(gca,'xTick',[1:length(usedConditionIDs)]); set(gca,'xTickLabel',names.conditions(usedConditionIDs))
    
 figure
    c=[ params.raw.numCorrect(strcmp(singleRat,names.subjects),onAxisFlanks);...
        params.raw.numCorrect(strcmp(singleRat,names.subjects),skewFlanks)];
    a=[ params.raw.numAttempt(strcmp(singleRat,names.subjects),onAxisFlanks);...
        params.raw.numAttempt(strcmp(singleRat,names.subjects),skewFlanks)];

  doBarPlotWithStims(sum(a,2)',sum(c,2)',barIms,[],[50 100], 'binodata',false)
 
%% confirm fraction of probe trials is 5%

dateRange=[0 pmmEvent('endToggle')];
statTypes={'pctCorrect'};
subjects={'228','227','230','233','234','138','139'}; %sorted for amount
filter{1}.type='9';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
conditionType='flankOrNot';              % lump popout and non-popout groups
[stats CI names params]=getFlankerStats(subjects,conditionType,statTypes,filter,dateRange);


a=params.raw.numAttempt;
empiricalProbeFraction=a(:,2)./sum(a,2)
%         0.0493166346203814
%         0.0511124121779859
%         0.0496052091878589
%         0.0488610102344008
%          0.050045199783041
%          0.049918143435678
%         0.0488343908177087
%%  check for stability of performance in the testing period

numSubjects=length(subjects);
figure
filter{1}.type='9.4';    
for i=1:numSubjects

    d=getSmalls(subjects{i},dateRange);
    d=filterFlankerData(d,filter);
    subplot(numSubjects,1,i);
    doPlotPercentCorrect(d);
    daysOn(i)=diff(minmax(d.date))
end

%%  check on short stims


subjects={'230','227','233','232'} %good performers on all trials ... note: I pulled these out as the ones I cared about before looking at the other 3 rats, which turn out to be low performers... does that justify their exclusion?  how does it effect stat testing?
subjects={'229','237','138','230', '227','233','232'};% include low or chance performers to see what they are like

filter{1}.type='11';
% filter{2}.type='responseSpeedPercentile';
% filter{2}.parameters.range=[0 .7];%whats justified?
dateRange=[pmmEvent('endToggle') now];
% filter{2}.type='performancePercentile';
% filter{2}.parameters.goodType='withoutAfterError';
% filter{2}.parameters.whichCondition={'noFlank',1}
% filter{2}.parameters.performanceMethod='pCorrect';
% filter{2}.parameters.performanceParameters={[.25 1],'boxcar',100}
filter{2}.type='targetDurationRangeMs';
filter{2}.parameters.range=[199 201];


[stats CI names params]=getFlankerStats(subjects,'8flanks+',{'pctCorrect','CRs','hits','yes'},filter,dateRange)
%%
figure
nBins=7;  %try 7, 18, 10, 20
subplot(2,1,1)
cMatrix={[find(ismember(names.conditions,{'colin'}))], [find(ismember(names.conditions,{'changeFlank'}))]}
labeledNames=assignLabeledNames(subjects);
viewFlankerComparison(names,params,cMatrix,{'pctCorrect'},subjects,[-5:10/nBins:5],[],false,true,labeledNames)
title('colinear - popout1')
ylabel('count')
axis square

subplot(2,1,2)
arrows={'changeFlank','colin',1};
doHitFAScatter(stats,CI,names,params,subjects,{'changeFlank','colin'},0,0,0,0,0,3,arrows);


