%% check phase
subjects={'136','137'};%136 & 137 effect of phase on goToSide
% d=getSmalls('137')
% datestr(d.date(min(find(abs(d.targetContrast-0.6)<10^-9))),22)
% datestr(d.date(max(find(abs(d.targetContrast-0.6)<10^-9))),22)
% dateRange=[datenum('Aug.06,2008') datenum('Nov.06,2008')];%when 137 was on 0.6 target contrast
% dateRange=[datenum('Aug.01,2008') datenum('Nov.30,2008')];%when 137 was on 0.6 target contrast
dateRange=[datenum('Aug.07,2008') datenum('Nov.05,2008')];% acceptable for 136/ 137
% d=getSmalls('136',dateRange); unique(d.targetContrast)
% d=getSmalls('137',dateRange); unique(d.targetContrast)
[stats CIs names params]=getFlankerStats(subjects, 'allPhases',{'dpr','pctCorrect','yes','hits','CRs'},'X.4',dateRange);

%%
%population first
f=figure;
a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));
doBarPlotWithStims(sum(a),sum(c),[],params.colors,[]); %all subjects
title('all'); ylabel('pctCorrect')

figure; doBarPlotWithStims(a(1,:),c(1,:),[],params.colors,[50 70]); %one subject
figure; doBarPlotWithStims(a(2,:),c(2,:),[],params.colors,[50 70] ); %other subject
figure; surf(reshape(c(2,:)./a(2,:),4,4))

%% consider relative phases on go to side rats
[stats CIs names params]=getFlankerStats(subjects, '3phases',{'pctCorrect'},'X.4',dateRange); %no stats have effect: 'dpr','yes','hits','CRs'

%%
cMatrix={[1],[2];[1],[3];[2],[3] }; %same vs. reverse phase
viewFlankerComparison(names,params, cMatrix,[],[],[-3:3])

a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));
figure;doBarPlotWithStims(sum(a),sum(c),[],params.colors,[]); %all subjects
figure; doBarPlotWithStims(a(1,:),c(1,:),[],params.colors,[50 70]); %one subject
figure; doBarPlotWithStims(a(2,:),c(2,:),[],params.colors,[50 70] ); %other subject

%%
clear all; close all

subjects={'228','227','230','233','234','139','138'}; %puts high-lighted rat (end) on the top
dateRange=[0 pmmEvent('endToggle')]
[stats CIs names params]=getFlankerStats(subjects, 'colin-other',{'pctCorrect'},'9.4',dateRange); %no stats have effect: 'dpr','yes','hits','CRs'
a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));

%
colors=[0.8,0,0; 0.3 0,0];
sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast','flankerPhase'}; % why does contrast have to be last?      
or=pi/12;
antiAliasing=false;
useSymbolicFlanker=true;
sweptImageValues={-or,-or,-or,1,1,[0 pi]};
borderColor=[];
[images]=getStimSweep(sweptImageParameters,sweptImageValues,borderColor,[],'column',false,antiAliasing,useSymbolicFlanker);
%
barImageOrder=[1 2]
for i=1:length(barImageOrder)
    barIms{i}=images(:,:,:,barImageOrder(i))
end

%
    addTrialNums=false; % false!
    multiComparePerPlot=false;
    objectColors.histSig=[.2 .2 1]; % use dark blue always
    %objectColors.histSig=colors(find(strcmp(useConds,names.conditions(cMatrix{2}))),:); % use the color of the first comparison
    objectColors.histInsig=[.6 .6 .6];
    objectColors.subjectSig=objectColors.histSig;
    objectColors.subjectInsig=objectColors.histInsig;
    displaySignificance=false;
    labelAxis=false;
    encodeSideRule=false;
    viewPopulationMeanAndCI=false;
    yScaling=[60 10 30 0]

    padFraction=0;
    
%
subplot(2,2,1)
doBarPlotWithStims(a(end,[1 2]),c(end,[1 2]),barIms,colors,[50 80],[],false,[],0.8); %one subject
set(gca,'xtick',[],'ytick',[50 60 70 80])
text(1,48,'same','HorizontalAlignment','center')
text(2,48,'\pi','HorizontalAlignment','center')
text(1.5,45,'relative phase','HorizontalAlignment','center')
ylabel('% correct (P)')
subplot(2,2,3)
cMatrix={[1],[2]}; %same vs. other phase?
addNames=assignLabeledNames(subjects)
viewFlankerComparison(names,params, cMatrix,[],[],[-5:5],[],false,addTrialNums,addNames,multiComparePerPlot,objectColors, displaySignificance,labelAxis,encodeSideRule,viewPopulationMeanAndCI,yScaling,padFraction)
text(0,-2,'P(same)- P(\pi)','HorizontalAlignment','center')
xlabel('');  ylabel('count     rat ID    ');
% stat
%pf=friedman(c(:,[1 2])./a(:,[1 2]),1,'off')
%x=c(:,[1 2])./a(:,[1 2]); [h p]=ttest(x(:,1)-x(:,2))

%
dateRange=[datenum('Aug.07,2008') datenum('Nov.05,2008')];% acceptable for 136/ 137
[stats CIs names params]=getFlankerStats({'136','137'}, '3phases',{'pctCorrect'},'X.4',dateRange); %no stats have effect: 'dpr','yes','hits','CRs'
a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));
%
colors=[0.8,0,0; 0.5,0,0; 0.3 0,0];
sweptImageValues={-or,-or,-or,1,1,[0 pi/2 pi]};
borderColor=[];
[images]=getStimSweep(sweptImageParameters,sweptImageValues,borderColor,[],'column',false,antiAliasing,useSymbolicFlanker);
%
barImageOrder=[1 2 3]
for i=1:length(barImageOrder)
    barIms{i}=images(:,:,:,barImageOrder(i))
end

subplot(2,2,2)
doBarPlotWithStims(a(1,[1 3 2]),c(1,[1 3 2]),barIms,colors,[50 80],[],false,[],0.8); %one subject

set(gca,'xtick',[],'ytick',[50 60 70 80])
text(1,48,'same','HorizontalAlignment','center')
text(2,48,'|\pi/2|','HorizontalAlignment','center')
text(3,48,'\pi','HorizontalAlignment','center')
text(2,45,'relative phase','HorizontalAlignment','center')
subplot(2,2,4)
cMatrix={[1],[3]}; %same vs. half pi shift phase
%
addNames= {'r9','r8'};
yScaling=[40 30 30 0] % better for 2 subjects   
viewFlankerComparison(names,params, cMatrix,[],[],[-5:5],[],false,addTrialNums,addNames,multiComparePerPlot,objectColors, displaySignificance,labelAxis,encodeSideRule,viewPopulationMeanAndCI,yScaling,padFraction)
text(0,-2,'P(same)- P(|\pi/2|)','HorizontalAlignment','center')
xlabel(''); ylabel('')

% stat
%pf=friedman(c(:,[1 3])./a(:,[1 3]),1,'off')
%x=c(:,[1 3])./a(:,[1 3]); [h p]=ttest(x(:,1)-x(:,2))

%

    set(gcf,'Position',[0 40 600 640])
    settings.PaperPosition=[.5 .5 3.5 3.5];
    settings.LineWidth=1.5;
    settings.HgGroupLineWidth=0.5;
    settings.fontSize=10; %12 is 12 on a 3.5 inch wide column.  10 looks better
    settings.MarkerSize=5;%8; 8 is good for dots, x is good for symbols
    settings.textObjectFontSize=7;
    settings.turnOffTics=true;
    settings.box='off';
cleanUpFigure(gcf,settings)

cleanUpFigure(gcf,settings)
subplot(2,2,1); settings.alphaLabel='a'; cleanUpFigure(gca,settings)
subplot(2,2,2); settings.alphaLabel='b'; cleanUpFigure(gca,settings)
subplot(2,2,3); settings.alphaLabel='c'; cleanUpFigure(gca,settings)
subplot(2,2,4); settings.alphaLabel='d'; cleanUpFigure(gca,settings)
             
%clearvars % save memory for rendering / printing high resolution
saveFigs('C:\Documents and Settings\rlab\Desktop\graphs',{'-dtiffn','png'},gcf,1200,{'-opengl'});


