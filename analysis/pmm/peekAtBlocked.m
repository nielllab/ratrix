


subjects={'227'};
subjects={'227', '229', '230', '237', '232', '233'}

numSubjects=length(subjects);
w=ceil(sqrt(numSubjects));
h=floor(sqrt(numSubjects));
%%
for i=1:numSubjects
    d=getSmalls(subjects{i})
    
    dateRange= [pmmEvent('startBlocking10rats')+2 now];
    %conditionType='allBlockIDs';
    conditionType= 'colin+1';
    filter{1}.type='12'; % 12 15 16
    plotType='performancePerContrastPerCondition';
    performanceMeasure='pctCor'; % 'pctYes'
    verbose=false;
    subplot(h,w,i)
    [stats plotParams]=flankerAnalysis(d, conditionType, plotType, performanceMeasure, filter, 'withoutAfterError',verbose)

    axis([0 1.1 .5 1])
end

%%



[stats CI names params]=getFlankerStats(subjects,'colin+3&blockedContrasts',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
%params.colors(:,:)=.8;  % overwrite color with gray
values = cellfun(@(x) str2num(x(5:end)), names.conditions);
figure

%%
%(stats,CI,names,params,subjects,conditions=[],doLegend=0,doCurve=0,doYesLine=0,doCorrectLine,sideText,doErrorBars,arrowFromAtoB)
%arrows={'','',1}
conditions=names.conditions([1 4 5 8 9 12 13 16]) % vs. para
%conditions=names.conditions([1 2 5 6 9 10 13 14]) % vs. pop1
for i=1:length(subjects)
        subplot(h,w,i)
        arrows=[];
doHitFAScatter(stats,CI,names,params,subjects(i),conditions,0,0,0,0,0,1,arrows);  % note bias - say yes more when close
title(subjects{i})
end


%%
[delta CI]=viewFlankerComparison(names,params,[],{'pctCorrect'}); %subjects([1 2 3 4 6])); % remove 237 the low performer
%%

cMatrix={[1],[4];
    [5],[8];
    [9],[12];
    [13],[16];};
[delta CI]=viewFlankerComparison(names,params,cMatrix); %subjects([1 2 3 4 6])); % remove 237 the low performer
%%
doFigAndSub=true
multiComparePerPlot=false;
[delta CI]=viewFlankerComparison(names,params,[],{'pctCorrect'},[],[],doFigAndSub,false,true,multiComparePerPlot);



%%

subjects={'231','234'}
subjects={'234'}
numSubjects=length(subjects);
w=numSubjects;h=1;
%% 


for i=1:numSubjects
    d=getSmalls(subjects{i})
    
    %dateRange= [pmmEvent('startBlocking10rats')+2 now];
    dateRange=[pmmEvent('231&234-jointSweep')  pmmEvent('231-test200msecDelay')];
    %conditionType='allBlockIDs';
    conditionType= 'fiveFlankerContrastsFullRange';
    filter{1}.type='16'; % 12 15 16
    plotType='performancePerContrastPerConditionWithAllFlankContastAndDev';
    performanceMeasure='pctCor'%'dpr'; % 'pctYes' 'pctCor'
    verbose=false;
    subplot(h,w,i)
    [stats plotParams]=flankerAnalysis(d, conditionType, plotType, performanceMeasure, filter, 'withoutAfterError',verbose)

    axis([0 1.1 .5 1])
    xlabel('target contrast')
    title(subjects{i})
end
 cleanUpFigure

%%

[stats CI names params]=getFlankerStats(subjects,'allBlockIDs',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
%params.colors(:,:)=.8;  % overwrite color with gray
params.factors.targetContrast
params.factors.flankerContrast
names.conditions
params.colors=repmat(plotParams.colors,4,1); %use color code from above
%%
%(stats,CI,names,params,subjects,conditions=[],doLegend=0,doCurve=0,doYesLine=0,doCorrectLine,sideText,doErrorBars,arrowFromAtoB)
%arrows={'','',1}
figure
conditions=names.conditions([1 4 5 8 9 12 13 16]) % vs. para
%conditions=names.conditions([1 2 5 6 9 10 13 14]) % vs. pop1
conditions=[]
c=names.conditions



% connect constant flanker
k=2;
arrows={c{1},c{6},k; c{6},c{11},k; c{11},c{16},k;...
    c{2},c{7},k; c{7},c{12},k; c{12},c{17},k;...
    c{3},c{8},k; c{8},c{13},k; c{13},c{18},k;...
    c{4},c{9},k; c{9},c{14},k; c{14},c{19},k;...
    c{5},c{10},k; c{10},c{15},k; c{15},c{20},k}

% % connect constant target
% k=2
% arrows={c{1},c{2},k; c{2},c{3},k; c{3},c{4},k; c{4},c{5},k;...
%     c{6},c{7},k; c{7},c{8},k; c{8},c{9},k; c{9},c{10},k;...
%     c{11},c{12},k; c{12},c{13},k; c{13},c{14},k; c{14},c{15},k;...
%     c{16},c{17},k; c{17},c{18},k; c{18},c{19},k; c{19},c{20},k};


for i=1:length(subjects)

        subplot(h,w,i)
        
doHitFAScatter(stats,CI,names,params,subjects(i),conditions,0,0,0,0,0,1,arrows);  % note bias - say yes more when close
title(subjects{i})
end

cleanUpFigure
set(gcf,'Position',[50 50 800 400])

%%

[stats CI names params]=getFlankerStats(subjects,'allBlockIDs',{'dprimeMCMC'},filter,dateRange);

%% 
figure; 
params.colors=repmat(plotParams.colors,4,1); %use color code from above
for subj=1:length(subjects)
    subplot(h,w,subj); hold on
    for i=1:size(stats,2)
        plot(params.factors.targetContrast(subj,i),stats(subj,i),'.','MarkerSize',20,'color',params.colors(i,:))
    end
    xlabel('target contrast')
    ylabel('d''')
    %legend(unique(params.factors.targetContrast(:)))
    legend({'0','0.25','0.5','0.75','1.0'})
    for i=1:size(stats,2)
        smallDisplacement=params.factors.flankerContrast(subj,i)/100;
        plot(params.factors.targetContrast(subj,i)+smallDisplacement*[1 1],[CI(subj,i,1,1) CI(subj,i,1,2)],'color',params.colors(i,:))
    end
    axis([0 1.1 0 2.5])
    title(subjects{subj})
end
cleanUpFigure