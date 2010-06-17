
%qWhatAreTheStats
alpha=0.01;  % confirm all use this alpha (including t-test)
dateRange=[0 733876];
subjects={'228','227','230','233','234','139','138'}; %puts high-lighted rat (end) on the top
statTypes={'pctCorrect'};
statNames={'anova','friedman','ttest','anovaHSD','friedmanHSD'};
statNames={'anovaHSD'};
%%

[junk1 junk2 names3 params3]=getFlankerStats(subjects,'8flanks+',statTypes,'9.4',dateRange,[]);
[junk1 junk2 names2 params2]=getFlankerStats(subjects,'hasFlank&nfMix&nfBlock',statTypes,'9.4.1+nf',dateRange,[]);
[junk1 junk2 namesPhase paramsPhase]=getFlankerStats(subjects,'colin-other',statTypes,'9.4',dateRange,[]);
%%
%[junk1 junk2 namesS4_1 paramsS4_1]=getFlankerStats(subjects,'colin-other',statTypes,'9.4',dateRange,[]);
%%

disp('*********** FIGURE 3 ************')
displayStatSig(names3,params3,statNames,alpha,[],{[9 10],[9 11],[9 12],[10 11],[10 12],[11 12]});
disp('*********** FIGURE 2 ************')
[j p]=displayStatSig(names2,params2,statNames,alpha,[],{[1 2]});

%%
disp('*********** PHASE (SUPP 3) ************')
alpha=0.05; 
[j p]=displayStatSig(namesPhase,paramsPhase,statNames,alpha,[],{[1 2]});
%%
close all
clc
disp('*********** DPRIME (SUPP 4) ************')
statNames={'anovaDpr','anova'};
statNames={'aDprimHSD','anovaHSD'};
statNames={'friedmanHSD1','fDprimHSD1','anovaHSD','aDprimHSD'};

alpha=0.05; 
disp('*********** 1 ************')
[j p]=displayStatSig(names2,params2,statNames,alpha,[],{[1 2]});
disp('*********** 2 ************')
[j p]=displayStatSig(names3,params3,statNames,alpha,[],{[9 10],[9 11],[9 12],[10 11],[10 12],[11 12]});
disp('*********** 3 ************')
alpha=0.05; 
[j p]=displayStatSig(namesPhase,paramsPhase,statNames,alpha,[],{[1 2]});

%% spliting data into chonological tenths
[junk1 junk2 names3Ten params3Ten]=getFlankerStats(subjects,'8flanks+&tenths',statTypes,'9.4',dateRange,[]);
statNames={'anovaHSDb','friedmanHSDb'};
[j p]=displayStatSig(names3Ten,params3Ten,statNames,alpha,[],{[9 10],[9 11],[9 12],[10 11],[10 12],[11 12]});


%% make some figs

cSet={[9 10],[9 11],[9 12],[10 11],[10 12],[11 12]};
allConds=names3.conditions(unique([cSet{:}]));
blockLength=200;
featureNames={'condition','subject'}
D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names3,params3,allConds,[featureNames 'correct'],blockLength);
predictors={}; %{D.condition D.subject}
for f=1:length(featureNames)
    predictors=[predictors D.(featureNames{f})];
end

 [pAnova t anovaHSDstats terms] = anovan(D.correct,predictors,'model',2,'sstype',3,'varnames',featureNames,'display','off');
p=pAnova(1);  %assumes you want to know the first one which is usually condition!
figure; [anovaHSDc mn h]=multcompare(anovaHSDstats,'ctype','hsd','alpha',alpha,'display','on');

%% mult compare figure
% get values by breaking into the end of multcompare in the 'dodisp'
%[j p]=displayStatSig(names3,params3,{'anovaHSD'},0.05,[],{[9 10],[9 11],[9 12],[10 11],[10 12],[11 12]});
close(18); 
figure(18); subplot(2,1,1); hold on
mns=[0.6204 0.6438 0.6379 0.6448];
halfwidth =[0.0039 0.0039 0.0039 0.0039]; % alpha =0.05
%halfwidth =[0.0047 0.0048 0.0047 0.0047]; %alpha =0.01
colors=[.9 0 0; 0 .8 .8 ; 0 .8 .8 ; .2 .2 .2];
n=length(allConds);
shortNames={'para','pop_2','pop_1','colin'}'
for i=1:n
    plot(mns(i)+halfwidth(i)*[-1 1],-[i i],'color',colors(i,:));
    plot(mns(i),-i,'o','color',colors(i,:))
    text(.609,-i,shortNames{n-i+1},'HorizontalAlignment','right')
end
set(gca,'ytick',-[4 3 2 1],'yTickLabel',[],'ylim',-[4.5 0.5],'xlim',[0.61 0.66],'xtick',[0.62 0.64 0.66],'xTickLabel',[62 64 66])
xlabel('ANOVA''s % correct (population mean)')

% get values by breaking into the end of multcompare in the 'dodisp'
%[j p]=displayStatSig(names3,params3,{'friedmanHSD1'},0.01,[],{[9 10],[9 11],[9 12],[10 11],[10 12],[11 12]});
mns=[1.0000 3.2857 2.0000 3.7143];
halfwidth =[0.8864 0.8864 0.8864 0.8864]; % alpha =0.05
%halfwidth =[1.0742 1.0742 1.0742 1.0742]; % alpha =0.01
subplot(2,1,2); hold on
for i=1:n
    plot(mns(i)+halfwidth(i)*[-1 1],-[i i],'color',colors(i,:));
    plot(mns(i),-i,'o','color',colors(i,:))
    text(-0.1,-i,shortNames{n-i+1},'HorizontalAlignment','right')
end
set(gca,'ytick',-[4 3 2 1],'yTickLabel',[],'ylim',-[4.5 0.5],'xlim',[0 5],'xtick',[1:4],'xTickLabel',[1:4])
xlabel('Friedman''s rank (population mean)')


set(gcf,'Position',[100 100 400 500])
settings.PaperPosition=[.5 .5 3.5 3.5];
settings.fontSize=12;
settings.textObjectFontSize=12;
settings.alphaLabel=[];
cleanUpFigure(gcf,settings)
subplot(2,1,1); settings.alphaLabel='a'; cleanUpFigure(gca,settings)
subplot(2,1,2); settings.alphaLabel='b'; cleanUpFigure(gca,settings)
%%
saveFigs('C:\Documents and Settings\rlab\Desktop\graphs',{'-dtiffn','png'},gcf,600,{'-opengl'})
