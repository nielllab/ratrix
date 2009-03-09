


%%

humans={'cmg','dan','pkc','lct'};
humanDateRange=[datenum('04-Jan-2009 19:34:59') now];
humanGoodType='humanPsych';

rats={'228', '227','230','233','234','139','138'};   
ratDateRange=[0 datenum('04-Feb-2009')];
ratGoodType='withoutAfterError';

condType='8flanks+&nfMix'%'colin+3'%&nfMix', '8flanks+'
filter=[];
filter{1}.type='11';
filter{2}.type='manualVersion';
filter{2}.includedVersions=[2,3,5:10]; %remove first version learning, and 4th version wrong contrast
filter{3}.type='performanceRange';
filter{3}.parameters.performanceMethod='pCorrect';               
filter{3}.parameters.performanceParameters={[.60 1],'symetricBoxcar',100}; 
filter{3}.parameters.goodType=humanGoodType;
filter{3}.parameters.whichCondition={'hasFlank',[1]};
filter{2}=[];
% filter{3}=[];
%,'dprimeMCMC','criterionMCMC'
[statsH CIH namesH paramsH]=getFlankerStats(humans,condType,{'pctCorrect','yes','hits','CRs','dpr','crit'},filter,humanDateRange,humanGoodType);

filter{1}.type='9.4';
filter{3}=[]; % rat's inlcude low performance data, b/c can't obviously , little impact on results, biggest consequences 228 would get many trial removed (30% for <55%, xx% for <60%)
[statsR CIR namesR paramsR]=getFlankerStats(rats,condType,{'pctCorrect','yes','hits','CRs','dpr','crit'},filter,ratDateRange,ratGoodType);
[statsRnf CIRnf namesRnf paramsRnf]=getFlankerStats(rats,'8flanks+&nfMix',{'pctCorrect','yes','hits','CRs','dpr','crit'},'9.4range',ratDateRange,ratGoodType);
[statsRnfb CIRnfb namesRnfb paramsRnfb]=getFlankerStats(setdiff(rats,{'227','228','229','230','234'}),'noFlank',{'pctCorrect','yes','hits','CRs','dpr','crit'},'preFlankerStep',[1 now],ratGoodType);
%switch color of Para
paraInd=find(strcmp('para',namesH.conditions));
paramsH.colors(paraInd,:)=[.7 .7 .7];
paramsR.colors(paraInd,:)=[.7 .7 .7];

mainArrow={'changeFlank','colin'};
otherArrow={'other','colin'};
add1line={'changeFlank','colin',[1];'changeFlank','para',[3]};
add2lines={'changeFlank','colin',[1];'changeFlank','changeTarget',[3];'changeFlank','para',[3]};
add3lines={'other','colin',[1];'other','changeTarget',[3];'other','para',[3]; 'other','changeFlank',[3]};
%% no dots
% figure;
% doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'changeFlank','colin'},0,0,0,0,0,3,mainArrow)
% doHitFAScatter(statsR,CIR,namesR,paramsR,[],{'changeFlank','colin'},0,0,0,0,0,3,mainArrow)

%%  one human, one rat, and stats
close all
figure; 
doDiagram=zeros(length(namesR.subjects),length(namesR.conditions)); doDiagram( find(ismember(namesR.subjects,{'233'})), find(ismember(namesR.conditions,{'changeFlank','colin'})))=1;
doHitFAScatter(statsH,CIH,namesH,paramsH,{'cmg'},{'changeFlank','changeTarget','colin','para'},0,0,0,0,0,3,add3lines)
cleanUpFigure(gcf)
doHitFAScatter(statsR,CIR,namesR,paramsR,{'233'},{'changeFlank','colin'},0,doDiagram,doDiagram,doDiagram,0,3,add3lines)

%% fake data
figure
stats=[];
stats(1,1,1)=.55; % colin hit
stats(1,2,1)=.7; % colin cr
stats(1,1,2)=.8; % pop hit
stats(1,2,2)=.75; % pop cr 

er=.06;
CI(1,1,1,:)=stats(1,1,1)+er*[-1 1]; % colin hit
CI(1,2,1,:)=stats(1,2,1)+er*[-1 1]; % pop hit
CI(1,1,2,:)=stats(1,2,2)+er*[-1 1]; % colin cr
CI(1,2,2,:)=stats(1,2,2)+er*[-1 1]; % pop cr 

names.stats={'hits','CRs'}
names.conditions={'colin','changeFlank'};
names.subjects={'one test'}
params.colors=[1 0 0; 0 1 1]
doDiagram=1;
mainArrow={'changeFlank','colin'};
noDiagram=0;
doHitFAScatter(stats,CI,names,params,[],[],0,noDiagram,noDiagram,noDiagram,0,3,mainArrow)
%[j1 j2
%diff]=viewFlankerComparison(names,params,{1,2},[],[],[],[],false,false,false,false, []); % needs raw
%set(gca,'xtickLabel',[0 .5 1],'xtick',[0 .5 1])
cleanUpFigure

startVals=[38, 19; 40 24]
for i=1:2
dpr=(norminv(stats(1,i,1))-norminv(1-stats(1,i,2)))
cr=-(norminv(stats(1,i,1))+norminv(1-stats(1,i,2)))/2;
            [dprCurve crCurve ] = getDprCurve(51, dpr, cr, 0);
            plot(dprCurve(1,1:startVals(i,1)), dprCurve(2,1:startVals(i,1)), 'color', params.colors(i,:));
            plot(crCurve(1,[startVals(i,2):end]),   crCurve(2,[startVals(i,2):end]), 'color', params.colors(i,:));
end

a=fill(1-[stats(1,1,2) stats(1,1,2) stats(1,2,2) stats(1,2,2)],[.01,.04,.04,0.01],'b'); set(a,'edgeAlpha',0,'FaceColor',[.8 .8 .8])
a=fill([.01,.04,.04,0.01],[stats(1,1,1) stats(1,1,1) stats(1,2,1) stats(1,2,1)],'b'); set(a,'edgeAlpha',0,'FaceColor',[.8 .8 .8])
a=fill([.01,.04,.04,0.01],[stats(1,1,1) stats(1,1,1) stats(1,2,1) stats(1,2,1)],'b'); set(a,'edgeAlpha',0,'FaceColor',[.8 .8 .8])

%%  only circle on one end
% 
% figure;
% doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'para','changeFlank'},0,0,0,0,0,2); % dots
% doHitFAScatter(statsR,CIR,namesR,paramsR,[],{'para','changeFlank'},0,0,0,0,0,2)
% doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'colin'},0,0,0,0,0,3,add3lines)
% doHitFAScatter(statsR,CIR,namesR,paramsR,[],{'colin'},0,0,0,0,0,3,add3lines)

%%
% 
% figure;
% doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'para','changeFlank','colin'},0,0,0,0,0,2); % dots
% doHitFAScatter(statsR,CIR,namesR,paramsR,[],{'para','changeFlank','colin'},0,0,0,0,0,2)
% doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'colin','changeFlank'},0,0,0,0,0,3,mainArrow)
% doHitFAScatter(statsR,CIR,namesR,paramsR,[],{'colin','changeFlank'},0,0,0,0,0,3,mainArrow)

%%

%% all rats and humans, basic simple, with dots

% close all
figure;
doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'para'},0,0,0,0,0,2) % dots
doHitFAScatter(statsR,CIR,namesR,paramsR,[],{'para'},0,0,0,0,0,2)
doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'colin','changeFlank'},0,0,0,0,0,3,mainArrow)
doHitFAScatter(statsR,CIR,namesR,paramsR,[],{'colin','changeFlank'},0,0,0,0,0,3,mainArrow)

cleanUpFigure(gcf)

%% all rats and humans, includes arows from noFlank, mixed
%need to be more careful with the the selection of 9.4range... multiple
%contrasts...?
% also many rats are cut out, bc step 8 is prior to fpa tilts!

% close all
figure;
doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'para','noFm'},0,0,0,0,0,2); % dots
doHitFAScatter(statsRnf,CIRnf,namesRnf,paramsRnf,[],{'para'},0,0,0,0,0,2)
doHitFAScatter(statsRnf,CIRnf,namesRnf,paramsRnf,[],{'noFm'},0,0,0,0,0,2,{'noFm','changeFlank',[3]})
doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'noFm'},0,0,0,0,0,2,{'noFm','changeFlank',[3]})
paramsRnfb.colors=[1 0 1];
doHitFAScatter(statsRnfb,CIRnfb,namesRnfb,paramsRnfb,[],{'noF'},0,0,0,0,0,2)

doHitFAScatter(statsH,CIH,namesH,paramsH,[],{'colin','changeFlank'},0,0,0,0,0,3,mainArrow)
doHitFAScatter(statsRnf,CIRnf,namesRnf,paramsRnf,[],{'colin','changeFlank','para','noFm'},0,0,0,0,0,3,mainArrow)

cleanUpFigure(gcf)
%%  cleaner for 3 rats
figure;
whichRats={'138','139','233'} % only 3 available for nfb {'138','139','233'}
%doHitFAScatter(statsR,CIR,namesR,paramsR,whichRats,{'para'},0,0,0,0,0,2)
doHitFAScatter(statsRnf,CIRnf,namesRnf,paramsRnf,whichRats,{'noFm'},0,0,0,0,0,2,{'noFm','changeFlank',[3]})
paramsRnfb.colors=[1 0 1];
doHitFAScatter(statsRnfb,CIRnfb,namesRnfb,paramsRnfb,whichRats,{'noF'},0,0,0,0,0,2)
doHitFAScatter(statsRnfb,CIRnfb,namesRnfb,paramsRnfb,whichRats,{'noF'},0,0,0,0,0,3)
doHitFAScatter(statsRnf,CIRnf,namesRnf,paramsRnf,whichRats,{'colin','changeFlank','noFm','para',},0,0,0,0,0,3,mainArrow)

%%

figure; [j1 j2 thediff]=viewFlankerComparison(namesRnf,paramsRnf,{9,14},{'pctCorrect'},[],[],[],false,false,false,false, []); 
figure; [j1 j2 thediff]=viewFlankerComparison(namesH,paramsH,{9,14},{'pctCorrect'},[],[],[],false,false,false,false, []); 

%%

if ismember('90',namesH.conditions) % orientation sweep
    cMatrix={1,2;2,3;3,4;4,5}
        %cMatrix={1,5}
else
    Aind=find(ismember(namesH.conditions,'changeFlank'));
    Bind=find(ismember(namesH.conditions,'colin'));
    cMatrix={[Bind],[Aind]};
end


objectColors.histInsig=[0 0 0]; objectColors.subjectInsig=objectColors.histInsig;

figure;
fontSize=20;

objectColors.histSig=[0 0 .8]; objectColors.subjectSig=objectColors.histSig;
subplot(2,4,3); [j1 j2 crtDiffH]=viewFlankerComparison(namesH,paramsH,cMatrix,{'pctCorrect'},[],[],[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
subplot(2,4,4); [j1 j2 yesDiffH]=viewFlankerComparison(namesH,paramsH,cMatrix,{'yes'},[],[],[],false,false,false,false, objectColors); ylabel(''); xlabel('% yes', 'FontSize', fontSize);
objectColors.histSig=[0 .5 0]; objectColors.subjectSig=objectColors.histSig;
subplot(2,4,7); [j1 j2 crtDiffR]=viewFlankerComparison(namesR,paramsR,cMatrix,{'pctCorrect'},[],[],[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
subplot(2,4,8); [j1 j2 yesDiffR]=viewFlankerComparison(namesR,paramsR,cMatrix,{'yes'},[],[],[],false,false,false,false, objectColors); ylabel(''); xlabel('% yes', 'FontSize', fontSize);
subplot(1,2,1);  hold on %axis equal;

y=reshape(crtDiffH,1,[]);
x=reshape(yesDiffH,1,[]);
arrow('Start',zeros(2,size(x,2)),'Stop',[x; y]','Length',5,'Width',0.3, 'EdgeColor','b','FaceColor','b')
y=reshape(crtDiffR,1,[]);
x=reshape(yesDiffR,1,[]);
arrow('Start',zeros(2,size(x,2)),'Stop',[x; y]','Length',5,'Width',0.3,'EdgeColor',[0 .5 0],'FaceColor',[0 .5 0]) 

xlabel('bias (% yes)', 'FontSize', fontSize) %_{delta}
ylabel('performance (% correct)', 'FontSize', fontSize)

xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
plot( [0, 0],ylim, '--k')
plot(xlim, [0, 0], '--k')
axis([xlim ylim])

if ismember('90',namesH.conditions) % orientation sweep
   %set(gca, 'XTickLabel', [-5 0 30], 'XTick', [-5 0 30], 'YTickLabel', [-5 0 10], 'YTick', [-5 0 10]);
   %axis([-10, 30, -5, 10]); %axis equal; 
else
   set(gca, 'XTickLabel', [-5 0 30], 'XTick', [-5 0 30], 'YTickLabel', [-5 0 10], 'YTick', [-5 0 10]);
   axis([-5, 30, -5, 10]); %axis equal; 
end



settings.fontSize=fontSize;
cleanUpFigure(gcf,settings);

%% now STD measures
figure;
objectColors.histSig=[0 0 .8]; objectColors.subjectSig=objectColors.histSig;
subplot(2,4,3); [j1 j2 dprDiffH]=viewFlankerComparison(namesH,paramsH,cMatrix,{'dpr'},[],linspace(-1,1,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('d-prime', 'FontSize', fontSize);
subplot(2,4,4); [j1 j2 critDiffH]=viewFlankerComparison(namesH,paramsH,fliplr(cMatrix),{'crit'},[],linspace(-1,1,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('criterion', 'FontSize', fontSize);
objectColors.histSig=[0 .5 0]; objectColors.subjectSig=objectColors.histSig;
subplot(2,4,7); [j1 j2 dprDiffR]=viewFlankerComparison(namesR,paramsR,cMatrix,{'dpr'},[],linspace(-.2,.2,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('d-prime', 'FontSize', fontSize);
subplot(2,4,8); [j1 j2 critDiffR]=viewFlankerComparison(namesR,paramsR,fliplr(cMatrix),{'crit'},[],linspace(-.05,.05,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('criterion', 'FontSize', fontSize);
subplot(1,2,1); axis square;

%dprimeMCMC, criterionMCMC

plot([0, 0], [-.3, .7], '--k')
hold on
plot([-.7, .7], [0, 0], '--k')


%add an arbitrary scale, consistent across all plots...
crScale=1;
dprScale=1;
x=reshape(critDiffR,1,[])*crScale;
y=reshape(dprDiffR,1,[])*dprScale;
%rotate axis 45deg
%x=-(dpr+crit);
%y=dpr-crit;
a=arrow('Start',zeros(2,size(x,2)),'Stop',[x; y],'Length',5,'Width',0.3, 'TipAngle', 12, 'EdgeColor',[0 .5 0],'FaceColor', [0 .5 0])
% set
x=reshape(critDiffH,1,[])*crScale;
y=reshape(dprDiffH,1,[])*dprScale;
arrow('Start',zeros(2,size(x,2)),'Stop',[x; y],'Length',5,'Width',0.3, 'EdgeColor','b','FaceColor','b') %again for humans 

xlabel('bias (criterion)', 'FontSize', fontSize) %_{delta}
ylabel('performance (d-prime)', 'FontSize', fontSize)


if ismember('90',namesH.conditions) % orientation sweep
set(gca, 'XTickLabel', [-.1 0 .7], 'XTick', [-.1 0 .7], 'YTickLabel', [-.3 0  .7], 'YTick', [-.3 0 .7]);
    axis([-.7 .1 -.3 .7])
else
    set(gca, 'XTickLabel', [-.1 0 .7], 'XTick', [-.1 0 .7], 'YTickLabel', [-.3 0  .7], 'YTick', [-.3 0 .7]);
    axis([-.1 .7 -.3 .7])
end

%         viewFlankerComparison(namesH,paramsH,cMatrix,{'pctCorrect'},[],[-10:10],[],false,false,false,false)
%         xlabel(''); ylabel(''); set(gca,'xTickLabel',''); set(gca,'yTickLabel','');
%         set(gca,'CameraUpVector', [1 -1 0]);  axis equal
%         set(gca,'Visible','off');

settings.fontSize=20;
cleanUpFigure(gcf,settings);



%% TESTING CRITERIA
subplot(2,4,8); [j1 j2 x1]=viewFlankerComparison(namesR,paramsR,(cMatrix),{'criterionMCMC'},[],linspace(-.2,.2,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('criterion', 'FontSize', fontSize);
subplot(2,4,8); [j1 j2 x2]=viewFlankerComparison(namesR,paramsR,(cMatrix),{'crit'},[],linspace(-.2,.2,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('criterion', 'FontSize', fontSize);
x1=reshape(x1,1,[])
x2=reshape(x2,1,[])
[sort(x1); sort(abs(x2))]
disp(sprintf('%3.2g \t',[sort(abs(x1))]))
disp(sprintf('%3.2g \t',[sort(abs(x2))]))
disp(' ')
disp(sprintf('%3.2g \t',[x1]))
disp(sprintf('%3.2g \t',[x2]))
% Why are they different?

%% compare the distance of para from colin and popout
    Aind=find(ismember(namesH.conditions,'changeFlank'));
    Bind=find(ismember(namesH.conditions,'colin'));
    Cind=find(ismember(namesH.conditions,'para'));
    Dind=find(ismember(namesH.conditions,'changeTarget')); % not used in final, just to peek
    cMatrix1={[Cind],[Aind]}; % distance from changeFlank
    cMatrix2={[Cind],[Bind]}; % distance from colinear
    
    
%% subplots
close all
figure
fontSize=20

    cMatrix1={[Aind],[Cind]}; % distance from changeFlank
    cMatrix2={[Bind],[Cind]}; % distance from colinear
sens={'pctCorrect'}; %pctCorrect dpr;
bias={'yes'}; % yes crit
objectColors.histInsig= [ 0 0 0]; objectColors.subjectInsig=objectColors.histInsig;
objectColors.histSig=[0 0  .8]; objectColors.subjectSig=objectColors.histSig;
subplot(4,2,1); [j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesH,paramsH,cMatrix2,sens,[],linspace(-15,15,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
subplot(4,2,2); [j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesH,paramsH,cMatrix2,bias,[],linspace(-30,30,9),[],false,false,false,false, objectColors); ylabel(''); xlabel(bias, 'FontSize', fontSize);
subplot(4,2,5); [j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesH,paramsH,cMatrix1,sens,[],linspace(-15,15,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
subplot(4,2,6); [j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesH,paramsH,cMatrix1,bias,[],linspace(-30,30,9),[],false,false,false,false, objectColors); ylabel(''); xlabel(bias, 'FontSize', fontSize);

objectColors.histSig=[0 .8 0]; objectColors.subjectSig=objectColors.histSig;
subplot(4,2,3); [j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesR,paramsR,cMatrix2,sens,[],linspace(-4,4,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
subplot(4,2,4); [j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesR,paramsR,cMatrix2,bias,[],linspace(-4,4,9),[],false,false,false,false, objectColors); ylabel(''); xlabel(bias, 'FontSize', fontSize);
subplot(4,2,7); [j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesR,paramsR,cMatrix1,sens,[],linspace(-4,4,9),[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
subplot(4,2,8); [j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesR,paramsR,cMatrix1,bias,[],linspace(-4,4,9),[],false,false,false,false, objectColors); ylabel(''); xlabel(bias, 'FontSize', fontSize);

   


%% 
    cMatrix1={[Cind],[Aind]}; % distance from changeFlank
    cMatrix2={[Cind],[Bind]}; % distance from colinear
statTypes={'distanceROC'} % pctCorrect
diffEdges=[-30:3:30];
    
figure
fontSize=20
objectColors.histInsig= [0 .6 .6]; objectColors.subjectInsig=objectColors.histInsig;
objectColors.histSig=[0 .8 .8]; objectColors.subjectSig=objectColors.histSig;
[j1 j2 roc1H roc1Hci]=viewFlankerComparison(namesH,paramsH,cMatrix1,statTypes,[],diffEdges,[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
[j1 j2 roc1R roc1Rci]=viewFlankerComparison(namesR,paramsR,cMatrix1,statTypes,[],diffEdges,[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
objectColors.histInsig= [.6 0 0]; objectColors.subjectInsig=objectColors.histInsig;
objectColors.histSig=[.8 0 0]; objectColors.subjectSig=objectColors.histSig;
[j1 j2 roc2R roc2Rci]=viewFlankerComparison(namesR,paramsR,cMatrix2,statTypes,[],diffEdges,[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);
[j1 j2 roc2H roc2Hci]=viewFlankerComparison(namesH,paramsH,cMatrix2,statTypes,[],diffEdges,[],false,false,false,false, objectColors); ylabel(''); xlabel('% correct', 'FontSize', fontSize);

%% plot above
figure
area([.1 .1 3 3],[.1 30-.1 30-.1 .1],'EdgeColor', 'none', 'FaceColor' ,[.8,1,1])
hold on
area([.1 .1 30-.1 30-.1],[.1 3 3 .1],'EdgeColor', 'none', 'FaceColor' ,[1,.8,.8])
area([.1 .1 3 3],[.1 3 3 .1],'EdgeColor', 'none', 'FaceColor' ,[.8,.8,1])

% draw lines to the wall if a sample is not sig different from it
ns=find(roc1Rci(1,1,:,1)<0); % not sig
plot([zeros(1,length(ns)); reshape(roc1R(ns),1,[])],repmat(reshape(roc2R(ns),1,[]),2,1),'b')
ns=find(roc1Hci(1,1,:,1)<0); % not sig
plot([zeros(1,length(ns)); reshape(roc1H(ns),1,[])],repmat(reshape(roc2H(ns),1,[]),2,1),'b')

ns=find(roc2Rci(1,1,:,1)<0); % not sig
plot(repmat(reshape(roc1R(ns),1,[]),2,1),[zeros(1,length(ns)); reshape(roc2R(ns),1,[])],'r')
ns=find(roc2Hci(1,1,:,1)<0); % not sig
plot(repmat(reshape(roc1H(ns),1,[]),2,1),[zeros(1,length(ns)); reshape(roc2H(ns),1,[])],'r')


plot([0 30],[0 30],'k')

plot(roc1H(:),roc2H(:),'.','markerSize',20,'color',[0 0 .8])
plot(roc1R(:),roc2R(:),'.','markerSize',20,'color',[0 .5 0])
axis([0 30 0 30]);

axis square
xlabel('distance from pop-out_1','fontSize',fontSize)
ylabel('distance from collinear','fontSize',fontSize)

set(gca, 'XTickLabel', [0 .1 .2 .3], 'XTick', [0 10 20 30], 'YTickLabel', [0 .1 .2 .3], 'YTick', [0 10 20 30]);
cleanUpFigure(gcf)
%% distance is cluttered

subjects={'232','138'};%     
subjects={'232','233','138','228','139'};%    
dateRange=[datenum('Nov.15,2008') now];  
filter{1}.type='13';
filter{2}.type='responseSpeedPercentile';
filter{2}.parameters.range=[.05 .95];%whats justified?
%filter{2}=[]; %remove it
[stats CI names params]=getFlankerStats(subjects,'2flanks&devs',{'hits','CRs','yes','pctCorrect','dpr','crit'},filter,dateRange);
values = cellfun(@(x) str2num(x(end-4:end)), names.conditions);
small=0.1; values=values+repmat([-1 1]*small,1,4);  %offset for viewing

%%
%point to colin at every distance (very cluttered)
figure; 
doHitFAScatter(stats,CI,names,params,{'232'},[],0,0,0,0,0,3,arrows);
arrows={'changeFlank 2.50','colin 2.50',[3],[1];'changeFlank 3.50','colin 3.50',[3],[1];'changeFlank 5.00','colin 5.00',[3],[1]; 'changeFlank 3.00','colin 3.00',[1],[1]};
doHitFAScatter(stats,CI,names,params,subjects,{'colin 3.00'},0,0,0,0,0,3,arrows);
 cleanUpFigure(gcf)
 %%
%show distant scatter, emphasize coherence of nearby
arrows={'changeFlank 2.50','colin 2.50',[1]; 'changeFlank 3.00','colin 3.00',[1];'changeFlank 3.50','colin 3.50',[3];'changeFlank 5.00','colin 5.00',[3]};

%show two closest, connect them
arrows={'changeFlank 2.50','colin 2.50',[2],[1]; 'changeFlank 3.00','colin 3.00',[1],[0];'changeFlank 2.50','changeFlank 3.00',[3],[0]};

%show all and connect (only reasonable for one rat)
arrows={'changeFlank 2.50','colin 2.50',[2],[1]; 'changeFlank 3.00','colin 3.00',[1],[0];'changeFlank 2.50','changeFlank 3.00',[3],[0]};

figure; doHitFAScatter(stats,CI,names,params,subjects,{'colin 3.00','changeFlank 3.00'},0,0,0,0,0,3,arrows);
  
%%

%[mDelta mCI]=viewFlankerComparison(namesR,paramsR,{[9],[10]},{'pctCorrect'},[],[-7 7],[],[],false,false,true);

[delta CI deltas CIs]=viewFlankerComparison(names,params,[],{'pctCorrect'},[],[-7 7],[],[],false,false,true)
%%
figure
vals=[2.5,3,3.5,5]';
mCI=[1.9 2.8]; % ci FROM MAIN EXPT
fHandle=fill([0 0 10 10],[mCI fliplr(mCI)],'c');
set(fHandle,'FaceColor',[.9 .9 .9],'EdgeAlpha',0)
hold on;
plot([0  10]',[2.37]*[1 1],'--','color',[.6 .6 .6]); % horizontal dashed line at previous value ni main expt


plot(vals,-delta(:),'ro');
plot([vals  vals]',-reshape(CI(:),4,2)','r-');
axis([2 6 0 5])
yTicks=[0 2 4 6];
set(gca,'xTickLabel',vals,'xTick',vals,'yTickLabel',yTicks,'yTick',yTicks)
ylabel(sprintf('collinear suppression \n(change in %% correct)'))
xlabel('distance from target')
cleanUpFigure
%% crappy mix
% figure
% doHitFAScatter(statsR,CIR,namesR,paramsR,[],{'colin','changeFlank'},0,0,0,0,0,3,mainArrow)
% doHitFAScatter(stats,CI,names,params,[],{'colin 3.00','changeFlank 3.00'},0,0,0,0,0,3,arrows);

%%
close all
figure
filter{1}.type='14';
dateRange=[datenum('Nov.15,2008') now];  
filter{2}=[];
[statsR CIR namesR paramsR]=getFlankerStats({'231','234'},'allRelativeTFOrientationMag',{'hits','CRs','yes','pctCorrect','dpr','crit'},filter,dateRange);
paramsR.colors=[1 0 0; .9 .2 .8; .7 .4 .9; 0 1 1; 0 .2 .8];
doHitFAScatter(statsR,CIR,namesR,paramsR,[],[],0,0,0,0,0,3,{'30','0',[1],[0]; '90','30',[3],[0]})

filter{2}.type='manualVersion'
filter{2}.includedVersions=[2,3,5:10]; %remove first version learning, and 4th version wrong contrast
[statsH CIH namesH paramsH]=getFlankerStats({'lct'},'allRelativeTFOrientationMag',{'hits','CRs','yes','pctCorrect','dpr','crit'},filter,humanDateRange,humanGoodType);
paramsH.colors=[1 0 0; .9 .2 .8; .7 .4 .9; 0 1 1; 0 .2 .8];
doHitFAScatter(statsH,CIH,namesH,paramsH,[],[],0,0,0,0,0,3,{'30','0',[1];'90','30',[3]})
nudge=[.01,.01; .02,.0; .005,-.01; .01,-.02; .0,-.02;];
for i=1:length(namesH.conditions)
    text(1-statsH(1,i,2)+nudge(i,1),statsH(1,i,1)+nudge(i,2),namesH.conditions(i))
end

set(gca, 'XTick', [0 .5 1], 'XTickLabel', [0 .5 1]);
cleanUpfigure(gcf)

%%
stats=statsR; CI=CIR; names=namesR; params=paramsR
subjects={'231','234'}
params.colors=[1 0 0; .9 .2 .8; .7 .4 .9; 0 1 1; 0 .2 .8];
values = cellfun(@(x) str2num(x), names.conditions);

figure(1) 
hold on
w=3; w=2;

for i=1:length(subjects)
%    %subplot(3,w,(i-1)*w+1); hold on
%    statInd=find(strcmp('pctCorrect',names.stats));
%    plot([-10 100],[.5 .5],'k--');
%    plot(values,stats(i,:,statInd),'k');
%    for j=1:length(values)
%        eb=plot([values(j) values(j)],[CI(i,j,statInd,1) CI(i,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
%    end
%    axis([-5 95 .45 .85]);
%    set(gca,'xTick',[0 30 90])
%    set(gca,'xTickLabel',[0 30 90])
%    set(gca,'yTick',[.5 .6 .8])
%    set(gca,'yTickLabel',[.5 .6 .8])
%    xlabel('flanker orientation')
%    ylabel('p(correct)')
%    axis square
    
   %subplot(3,w,(i-1)*w+2);  hold on
   statInd=find(strcmp('yes',names.stats));
   plot(values,stats(i,:,statInd),'color',[0 0.5 0]);
   for j=1:length(values)
       eb=plot([values(j) values(j)],[CI(i,j,statInd,1) CI(i,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
   end
   axis([-5 95 0 .6]);
   set(gca,'xTick',[0 30 90])
   set(gca,'xTickLabel',[0 30 90])
   set(gca,'yTick',[0 .3 .6])
   set(gca,'yTickLabel',[0 .3 .6])
   xlabel('flanker orientation')
   ylabel('p(yes)')
   axis square
   

end
settings.turnOffLines=1;

%   subplot(3,w,5); hold on
%    statInd=find(strcmp('pctCorrect',names.stats));
%    plot([-10 100],[.5 .5],'k--');
%    plot(values,statsH(1,:,statInd),'k');
%    for j=1:length(values)
%        eb=plot([values(j) values(j)],[CIH(1,j,statInd,1) CIH(1,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
%    end
%    
%    axis([-5 95 .45 .85]);
%    set(gca,'xTick',[0 30 90])
%    set(gca,'xTickLabel',[0 30 90])
%    set(gca,'yTick',[.5 .6 .8])
%    set(gca,'yTickLabel',[.5 .6 .8])
%    xlabel('flanker orientation')
%    ylabel('p(correct)')
%    axis square

  % subplot(3,w,6);  hold on
   statInd=find(strcmp('yes',namesH.stats));
   offset=-1;
   plot(values+offset,statsH(1,:,statInd),'b');

   for j=1:length(values)
       eb=plot([values(j) values(j)]+offset,[CIH(1,j,statInd,1) CIH(1,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
   end
   axis([-5 95 0 .75]);
   set(gca,'xTick',[0 30 90])
   set(gca,'xTickLabel',[0 30 90])
   set(gca,'yTick',[0 .5 .75])
   set(gca,'yTickLabel',[0 .5 .75])
   xlabel('flanker orientation')
   ylabel('p(yes)')
   axis square

cleanUpFigure(gcf,settings)
%% images
clear all
sc=4; 

sx=384*sc;
sy=512*sc;
[param]=getDefaultParameters(ifFeatureGoRightWithTwoFlank,'goToRightDetection','2_4','Oct.09,2007')
param.maxWidth    =sx;
param.maxHeight   =sy;
param.pixPerCycs  =16*sc;
param.flankerContrast  =1;
param.flankerOffset=3;
param.stdGaussMask=1/16;
param.mean= 0.5;
param.phase= 0;
[step]=setFlankerStimRewardAndTrialManager(param, 'test')
sm=getStimManager(step);

desiredX=250*sc;
desiredY=425*sc;
padX=(sx-desiredX)/2; padY=(sy-desiredY)/2;
borderWidth=10;

or=pi/12;
torients=[-or];
forients=[-or];
tcontrasts=[1];
fpas=[or];
sizes=[length(torients) length(forients) length(tcontrasts) length(fpas)];
images=nan(desiredY,desiredX,3,max(cumprod(sizes)));%*length(forients)*length(tcontrasts)*length(fpas));
colors=[.5 .5 .5; .6 1 1; .6 1 1; .3 .3 .3];
order=[1:8 fliplr(9:12) fliplr(13:16)];
for i=1:length(torients)
    forceStimDetails.targetOrientation=torients(i);
    for j=1:length(forients)
        forceStimDetails.flankerOrientation=forients(j);
        for k=1:length(tcontrasts)
            forceStimDetails.targetContrast=tcontrasts(k);
            for l=1:length(fpas)
                forceStimDetails.flankerPosAngle=fpas(l);

                %border color
                colorInd=1;
                if torients(i)==forients(j)
                    if torients(i)==fpas(l)
                        colorInd=1;% colin
                    else
                        colorInd=4;% para
                    end
                end

                [im0 details]= sampleStimFrame(sm,'nAFC',forceStimDetails,[3],sy,sx);
                %grab the thing in the center
                im1=uint8(255*repmat(reshape(colors(colorInd,:),[1 1 3]),[desiredY desiredX 1]));
                center=repmat(im0(1+padY+borderWidth:sy-padY-borderWidth,1+padX+borderWidth:sx-padX-borderWidth),[1 1 3]);
                im1(borderWidth+1:end-borderWidth,borderWidth+1:end-borderWidth,:)=center;

                %[i j k l]=ind2sub(sizes,ind);
                ind=sub2ind(sizes,i, j, k, l)
                ind=order(ind);
                images(:,:,:,ind)=im1;
                %                 imtool(im1)
                %                 pause
            end
        end
    end
end

figure; imagesc(images(:,:,:,[1])/255); axis equal
figure; montage(images/255, [0 255],'Size',[1 1]);

%%
images=uint8(images);
figure
montage(images,'DisplayRange',[0 255],'Size',[2 8]); % or [2 2] if
title('sample stimuli')

%%
figure
subplot(1,2,1)
montage(images(:,:,:,[5 1]),'DisplayRange',[0 255],'Size',[1 2]);
title('colinear example')
xlabel('left = no                   right = yes')

subplot(1,2,2)

montage(images(:,:,:,[1 3 2 4 9 11 10 12 ]),'DisplayRange',[0 255],'Size',[2 4]);
title('stimulus grouping')
set(gca,'xTick',diff(get(gca,'Xlim'))*[1:4]/5)
set(gca,'xTickLabel',diff(get(gca,'Xlim'))*[1:4]/5)
xlabel('col              po1                po2              par')
%set(gca,'xTickLabel',{'col','po1','po2','par'})\


%% num days performed estimate
d=(filterFlankerData(getSmalls('228',[0 datenum('04-Feb-2009')]),'9.4')); (length(unique(floor(d.date))))
d=(filterFlankerData(getSmalls('234',[datenum('Nov.15,2008') datenum('04-Feb-2009')]),'14')); (length(unique(floor(d.date))))

