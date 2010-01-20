
%make 4 plots:
%sf (1 of 2 rats)
% target contrast (2 rats)
% flanker contrast (as many as have enough data, blocked)
% flanker distance (randomized)


clear all; close all;
%%

minCandela=4;
maxCandela=84;  % not currently used for plot

basicErrorBarColor=[.8 .8 .8]
highlightColor=[.2 .8 .2];
chanceLineColor=[.5 .5 .5];


%% target contrast

subjects={'233','231' }%  '231'  is 231 used elsewhere in the study?
filter{1}.type='12';
dateRange=[0 pmmEvent('endToggle')];
[stats CI names params]=getFlankerStats(subjects,'allPhantomTargetContrastsCombined',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
[nfstats nfCI nfnames nfparams]=getFlankerStats(subjects,'noFlank',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
params.colors(:,:)=.8;  % overwrite color with gray
values = getMichealsonContrast(params.factors.phantomTargetContrastCombined(1,:),minCandela,maxCandela);
values = log2(getMichealsonContrast(params.factors.phantomTargetContrastCombined(1,:),minCandela,maxCandela))
values =params.factors.phantomTargetContrastCombined(1,:);
%doHitFAScatter(stats,CI,names,params,subjects,[],0,0,0,0,0,3,[]);  %
whichHighlighted=abs(values-1)<0.01;
params.colors(whichHighlighted,:)=repmat(highlightColor,sum(whichHighlighted),1); %

%%
figure(17); hold on
subplot(1,4,2); hold on
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    plot(values,stats(subInd,:,statInd),'k')
end
%ci's afterwards
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    for j=1:length(values)
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    %text(0,stats(subInd,end,statInd),subjects{i})
    %text(1.2,stats(subInd,end,statInd),assignLabeledNames(subjects(i)))
end

plot([-7 7],[.5 .5],'color',chanceLineColor);
%plot([2 2],[0 1],'color',chanceLineColor););

axis([0 1.1 .4 1]);
set(gca,'xTick',[0 .5 1])
set(gca,'xTickLabel',{'0','0.5','1'})
set(gca,'yTick',[.5 .75 1])
set(gca,'yTickLabel',[.5 .75 1])
xlabel('target contrast')
ylabel('p(correct)')
axis square
    
%%  flanker contrast
subjects={'233'}; % 231
subjects={'233','139','138','228','232'}%,'231'};% '138, 228 '232' have extra contrasts.  228 [.1 .2 .3 .4]
%subjects={'231'}; % why is 228 missing step 8 data?
conditionType='fiveFlankerContrasts';
removeNonTilted=false; % this influences: 138, 228 232
filter{1}.type='9'; % 9.x.1?
dateRange=[0 pmmEvent('endToggle')];
[stats CI names params]=getFlankerStats(subjects,conditionType,{'hits','CRs','yes','pctCorrect'},filter,dateRange,[],[],removeNonTilted);

% use blocked, not interleaved values from prestep
%filter{1}.type='preFlankerStep'; % may include learning
%filter{1}.type='preFlankerStep.matchTrials.1'; % no bias of mean, but higher variance
filter{1}.type='preFlankerStep.last400'; % may reduce variance, but mean is suspect... 228 lacks enough trilas
[nfstats nfCI nfnames nfparams]=getFlankerStats(subjects,'noFlank',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
params.colors(:,:)=.8;  % overwrite color with gray
values = params.factors.flankerContrast(1,:);
whichHighlighted=abs(values-0.4)<0.01;
params.colors(whichHighlighted,:)=repmat(highlightColor,sum(whichHighlighted),1); %

%%
%figure
subplot(1,4,3);
hold on
    
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    plot(values(2:end),stats(subInd,2:end,statInd),'k')
    
    %no flank added on
    %eb=plot([0 0],[nfCI(subInd,1,statInd,1) nfCI(subInd,1,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    eb=plot(0 ,nfstats(subInd,1,statInd),'.k');
    %connector to fartherest
    eb=plot([0.05 0] ,[mean([nfstats(subInd,1,statInd) stats(subInd,2,statInd)])  nfstats(subInd,1,statInd)]   ,'k');
end

%ci's afterwards
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    for j=2:length(values)
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    %text(.5,stats(subInd,end,statInd),assignLabeledNames(subjects(i)))  
end
plot([-.25 1],[.5 .5],'color',chanceLineColor);
plot([0 0],[0 .5],'color',chanceLineColor);
axis([0 .45 .4 1]);
set(gca,'xTick',[0 .2 .4])
set(gca,'xTickLabel',{'0','.2','.4'})
set(gca,'yTick',[.5 .75 1])
set(gca,'yTickLabel',[.5 .75 1])
xlabel('flanker contrast')
ylabel('p(correct)')
axis square
%%  flanker distance

subjects={'232','233','138','228','139'};%
filter{1}.type='13';
dateRange=[pmmEvent('last139problem') pmmEvent('endToggle')];
[stats CI names params]=getFlankerStats(subjects,'allDevs',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
[nfstats nfCI nfnames nfparams]=getFlankerStats(subjects,'noFlank',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
params.colors(:,:)=.8;  % overwrite color with gray
values = cellfun(@(x) str2num(x(5:end)), names.conditions);
%doHitFAScatter(stats,CI,names,params,subjects,[],0,0,0,0,0,3,[]);  % note bias - say yes more when close
whichHighlighted=abs(values-3)<0.01;
params.colors(whichHighlighted,:)=repmat(highlightColor,sum(whichHighlighted),1); %

%%
%figure
subplot(1,4,4);
hold on
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    plot(values,stats(subInd,:,statInd),'k')
    
    %no flank added on
    eb=plot([6 6],[nfCI(subInd,1,statInd,1) nfCI(subInd,1,statInd,2)],'color',params.colors(length(values),:),'LineWidth',2);
    eb=plot(6 ,nfstats(subInd,1,statInd),'.k');
    
    %connector to fartherest
    eb=plot([5.5 6] ,[mean([nfstats(subInd,1,statInd) stats(subInd,end,statInd)])  nfstats(subInd,1,statInd)]   ,'k');
end

% ci afterwards
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    for j=1:length(values)
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    %text(6.5,nfstats(subInd,end,statInd),assignLabeledNames(subjects(i)))
end

plot([0 7],[.5 .5],'color',chanceLineColor);
plot([2 2],[0 1],'color',chanceLineColor);
axis([0 6 .4 1]);
set(gca,'xTick',[0 2 3 5 6])
set(gca,'xTickLabel',{'0','2','3','5','inf'})
set(gca,'yTick',[.5 .75 1])
set(gca,'yTickLabel',[.5 .75 1])
xlabel('flanker distance (\lambda)')
ylabel('p(correct)')
axis square


% if 0
%     %% 232's flanker effect per distance
%     
%     subjects={'232'}%,'233','138','228','139'};%
%     filter{1}.type='13';
%     dateRange=[pmmEvent('last139problem') pmmEvent('endToggle')];
%     [stats CI names params]=getFlankerStats(subjects,'colin+1&devs',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
%     [nfstats nfCI nfnames nfparams]=getFlankerStats(subjects,'noFlank',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
%     params.colors(:,:)=.8;  % overwrite color with gray
%     values = cellfun(@(x) str2num(x(5:end)), names.conditions);
%     figure
%     doHitFAScatter(stats,CI,names,params,subjects,[],0,0,0,0,0,3,[]);  % note bias - say yes more when close
%     
%     %%
% end
% if 0
%     figure; hold on
%     for i=1:length(subjects)
%         subInd=find(strcmp(subjects{i},names.subjects));
%         statInd=find(strcmp('pctCorrect',names.stats));
%         
%         
%         plot([0 7],[.5 .5],'color',chanceLineColor);
%         plot([2 2],[0 1],'color',chanceLineColor);
%         
%         %plot(values,stats(i,:,statInd),'k');
%         for j=1:length(values)
%             
%             eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
%         end
%         
%         %no flank added on
%         
%         col=[1 3 5 7];
%         not=[2 4 6 8];
%         
%         plot(values(col),stats(subInd,col,statInd),'r')
%         plot(values(not),stats(subInd,not,statInd),'c')
%         %text(6.5,nfstats(subInd,end,statInd),subjects{i})
%         axis([0 7 .4 1]);
%         set(gca,'xTick',[3 5 6])
%         set(gca,'xTickLabel',{'3','5','inf'})
%         set(gca,'yTick',[.5 .75 1])
%         set(gca,'yTickLabel',[.5 .75 1])
%         xlabel('flanker distance')
%         ylabel('p(correct)')
%         axis square
%     end
%     
%     
%     %%
%     
%     cMatrix=[];
%     addTrialNums=1;
%     doFigAndSub=0;
%     multiComparePerPlot=0;
%     [delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix,{'pctCorrect'},subjects,[],[],doFigAndSub,addTrialNums,true,multiComparePerPlot, []);
%     close(gcf);
%     figure; hold on
%     
%     plot([0 7],[0 0],'k--');
%     for j=1:length(values(col))
%         eb=plot([values(col(j)) values(col(j))],-[CI(j,subInd,1) CI(j,subInd,2)],'color',params.colors(j,:),'LineWidth',2);
%     end
%     plot(values(col),-delta,'.k')
%     
%     
%     axis([0 7 -8 8]);
%     set(gca,'xTick',[3 5 6])
%     set(gca,'xTickLabel',{'3','5','inf'})
%     set(gca,'yTick',[-8 -4 0 4 8])
%     set(gca,'yTickLabel',[-8 -4 0 4 8])
%     xlabel('flanker distance')
%     ylabel('change in pctCorrect (pop1-colin)')
%     axis square
% end
%% new figure for target alone

subplot(1,4,1);
%figure
hold on
subjects={'138','139'} % too much clutter
subjects={'138'}
startSweepDate=datenum('Feb.21,2008')
endSweepDate=datenum('Mar.18,2008')
dateRange=[startSweepDate endSweepDate]
filter{1}.type='2';
removeNonTilted=false;
[stats CI names params]=getFlankerStats(subjects,'allPixPerCycs&PhantomContrast',{'pctCorrect'},filter,dateRange,[],[],removeNonTilted)
params.colors(:,:)=.8;  % overwrite color with gray




c=params.factors.phantomTargetContrastCombined(1,:);
%c = log2(getMichealsonContrast(params.factors.phantomTargetContrastCombined(1,:),minCandela,maxCandela))
ppc=params.factors.pixPerCycs(1,:); % only need it for one subjetc
contrasts=params.factors.phantomTargetContrastCombined(1,:);
cpd=getCycPerDeg(ppc,17.8,[1024 768],14) % box - to screen center
whichHighlighted=abs(cpd-0.22)<0.01;
params.colors(whichHighlighted,:)=repmat(highlightColor,sum(whichHighlighted),1); %

%%
hold on
includePPC=unique(ppc);
contrastUsed=1;

for i=1:length(subjects)
    for j=1:length(includePPC)
        subInd=find(strcmp(subjects{i},names.subjects));
        statInd=find(strcmp('pctCorrect',names.stats));
        condInds=find(ismember(ppc,includePPC) &  contrasts==contrastUsed);
        condInds(c(condInds)==0)=[]; % don't inlcude the 0 contrast condition
        plot([0 2],[.5 .5],'color',chanceLineColor);
        plot(cpd(condInds),stats(i,condInds,statInd),'k');
    end
end

%plot error bard on top, afterwards
for i=1:length(subjects)
    for j=1:length(includePPC)
        subInd=find(strcmp(subjects{i},names.subjects));
        statInd=find(strcmp('pctCorrect',names.stats));
        condInds=find(ismember(ppc,includePPC) &  contrasts==contrastUsed);
        condInds(c(condInds)==0)=[]; % don't inlcude the 0 contrast condition
        for j=1:length(condInds)
            eb=plot([cpd(condInds(j)) cpd(condInds(j))],[CI(subInd,condInds(j),statInd,1) CI(subInd,condInds(j),statInd,2)],'color',params.colors(j,:),'LineWidth',2);
        end
    end
end

%text(1.2,stats(subInd,condInds(end),statInd),assignLabeledNames(subjects(i)))
axis([0 2 .4 1]);
set(gca,'xTick',[0 .22 1 2])
set(gca,'xTickLabel',{'0','0.22','1','2'})
set(gca,'yTick',[.5 .75 1])
set(gca,'yTickLabel',[.5 .75 1])
xlabel('spatial freqency (cyc/deg)')
ylabel('p(correct)')
axis square

%% old figure with contrast sweep
if 0
    includePPC=[16 32 ]%64];
    highlightedPPC=[32];
    for i=1:length(subjects)
        for j=1:length(includePPC)
            
            subInd=find(strcmp(subjects{i},names.subjects));
            statInd=find(strcmp('pctCorrect',names.stats));
            condInds=find(ppc==includePPC(j))
            condInds(c(condInds)==0)=[];
            plot([0 1],[.5 .5],'k--');
            
            if includePPC(j)>30
                color=[.2 .8 .2];
            else
                color=[.2 .2 .2];
            end
            plot(c(condInds),stats(i,condInds,statInd),'color',color);  % don't inlcude the 0 contrast condition\
            color=brighten(color,0.7);
            for j=1:length(condInds)
                c(condInds(j))
                %params.colors(condInds(j),:); unused grey
                
                eb=plot([c(condInds(j)) c(condInds(j))],[CI(subInd,condInds(j),statInd,1) CI(subInd,condInds(j),statInd,2)],'color',color,'LineWidth',2);
            end
            
            %text(1.2,stats(subInd,condInds(end),statInd),assignLabeledNames(subjects(i)))
            %axis([0 1.5 .4 1]);
            set(gca,'xTick',[0 .5 1])
            set(gca,'xTickLabel',{'0','0.5','1'})
            set(gca,'yTick',[.5 .75 1])
            set(gca,'yTickLabel',[.5 .75 1])
            xlabel('target contrast')
            ylabel('p(correct)')
            axis square
        end
    end
end
%%


settings.fontSize=10;
settings.PaperPosition=[.5 .5 7.5  2.25];
cleanUpFigure(gcf,settings)
subplot(1,4,1); settings.alphaLabel='a'; cleanUpFigure(gca,settings)
subplot(1,4,2); settings.alphaLabel='b'; cleanUpFigure(gca,settings)
subplot(1,4,3); settings.alphaLabel='c'; cleanUpFigure(gca,settings)
subplot(1,4,4); settings.alphaLabel='d'; cleanUpFigure(gca,settings)
%clearvars -except savePath figureType allFigID resolution renderer  % save memory for rendering / printing high resolution
savePath='C:\Documents and Settings\rlab\Desktop\graphs';
figureType={'-dtiffn','png'};  renderer= {'-opengl'}; resolution=1200; % paper print quality
saveFigs(savePath,figureType,gcf,resolution,renderer);
