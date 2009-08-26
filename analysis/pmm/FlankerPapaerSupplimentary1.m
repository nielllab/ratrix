
%make three plots:
% target contrast (2 rats)
% flanker contrast (as many as have enough data, blocked)
% flanker distance (randomized)

minCandela=4;
maxCandela=84;

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

%%
figure; hold on
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    
    subplot(1,4,2); hold on
    
    plot([-7 7],[.5 .5],'k--');
    %plot([2 2],[0 1],'k--');
    
    %plot(values,stats(i,:,statInd),'k');
    for j=1:length(values)
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    
    if 0 %no flank added on
        eb=plot([1.25 1.25],[nfCI(subInd,1,statInd,1) nfCI(subInd,1,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
        eb=plot(6 ,nfstats(subInd,1,statInd),'.k');
        %connector to fartherest
        eb=plot([1.125 1.25] ,[mean([nfstats(subInd,1,statInd) stats(subInd,end,statInd)])  nfstats(subInd,1,statInd)]   ,'k');
    end
    plot(values,stats(subInd,:,statInd),'k')
    
    %text(0,stats(subInd,end,statInd),subjects{i})
    %axis([-2 0.5 .45 1]);
    
    text(1.2,stats(subInd,end,statInd),assignLabeledNames(subjects(i)))
    axis([0 1.5 .45 1]);
    set(gca,'xTick',[0 .5 1])
    set(gca,'xTickLabel',{'0','0.5','1'})
    set(gca,'yTick',[.5 .75 1])
    set(gca,'yTickLabel',[.5 .75 1])
    xlabel('target Contrast')
    ylabel('p(correct)')
    axis square
end

%%  flanker contrast
subjects={'233'}; % 231
subjects={'233','139','138','228','232','231'};% '138, 228 '232' have extra contrasts.  228 [.1 .2 .3 .4]
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

%%
%figure
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    
    subplot(1,4,3);
    hold on
    
    plot([-.25 1],[.5 .5],'k--');
    plot([0 0],[0 .5],'k--');
    
    %plot(values,stats(i,:,statInd),'k');
    for j=2:length(values)
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    
    %no flank added on
    %eb=plot([0 0],[nfCI(subInd,1,statInd,1) nfCI(subInd,1,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    eb=plot(0 ,nfstats(subInd,1,statInd),'.k');
    %connector to fartherest
    eb=plot([0.05 0] ,[mean([nfstats(subInd,1,statInd) stats(subInd,2,statInd)])  nfstats(subInd,1,statInd)]   ,'k');
    
    plot(values(2:end),stats(subInd,2:end,statInd),'k')
    
    text(.5,stats(subInd,end,statInd),assignLabeledNames(subjects(i)))
    axis([-.25 1 .45 1]);
    set(gca,'xTick',[0 .2 .4])
    set(gca,'xTickLabel',{'0','.2','.4'})
    set(gca,'yTick',[.5 .75 1])
    set(gca,'yTickLabel',[.5 .75 1])
    xlabel('flanker contrast')
    ylabel('p(correct)')
    axis square
end

%%  flanker distance

subjects={'232','233','138','228','139'};%
filter{1}.type='13';
dateRange=[pmmEvent('last139problem') pmmEvent('endToggle')];
[stats CI names params]=getFlankerStats(subjects,'allDevs',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
[nfstats nfCI nfnames nfparams]=getFlankerStats(subjects,'noFlank',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
params.colors(:,:)=.8;  % overwrite color with gray
values = cellfun(@(x) str2num(x(5:end)), names.conditions);
%doHitFAScatter(stats,CI,names,params,subjects,[],0,0,0,0,0,3,[]);  % note bias - say yes more when close


%%
%figure
subplot(1,4,4); hold on
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    
    
    
    plot([0 7],[.5 .5],'k--');
    plot([2 2],[0 1],'k--');
    
    %plot(values,stats(i,:,statInd),'k');
    for j=1:length(values)
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    
    %no flank added on
    eb=plot([6 6],[nfCI(subInd,1,statInd,1) nfCI(subInd,1,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    eb=plot(6 ,nfstats(subInd,1,statInd),'.k');
    %connector to fartherest
    eb=plot([5.5 6] ,[mean([nfstats(subInd,1,statInd) stats(subInd,end,statInd)])  nfstats(subInd,1,statInd)]   ,'k');
    
    plot(values,stats(subInd,:,statInd),'k')
    
    text(6.5,nfstats(subInd,end,statInd),assignLabeledNames(subjects(i)))
    axis([0 7 .45 1]);
    set(gca,'xTick',[3 5 6])
    set(gca,'xTickLabel',{'3','5','inf'})
    set(gca,'yTick',[.5 .75 1])
    set(gca,'yTickLabel',[.5 .75 1])
    xlabel('flanker distance')
    ylabel('p(correct)')
    axis square
end




%% 232's flanker effect per distance



subjects={'232'}%,'233','138','228','139'};%
filter{1}.type='13';
dateRange=[pmmEvent('last139problem') pmmEvent('endToggle')];
[stats CI names params]=getFlankerStats(subjects,'colin+1&devs',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
[nfstats nfCI nfnames nfparams]=getFlankerStats(subjects,'noFlank',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
params.colors(:,:)=.8;  % overwrite color with gray
values = cellfun(@(x) str2num(x(5:end)), names.conditions);
figure
doHitFAScatter(stats,CI,names,params,subjects,[],0,0,0,0,0,3,[]);  % note bias - say yes more when close

%%

if 0
figure; hold on
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    
    
    plot([0 7],[.5 .5],'k--');
    plot([2 2],[0 1],'k--');
    
    %plot(values,stats(i,:,statInd),'k');
    for j=1:length(values)
        
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    
    %no flank added on
    
    col=[1 3 5 7];
    not=[2 4 6 8];
    
    plot(values(col),stats(subInd,col,statInd),'r')
    plot(values(not),stats(subInd,not,statInd),'c')
    text(6.5,nfstats(subInd,end,statInd),subjects{i})
    axis([0 7 .45 1]);
    set(gca,'xTick',[3 5 6])
    set(gca,'xTickLabel',{'3','5','inf'})
    set(gca,'yTick',[.5 .75 1])
    set(gca,'yTickLabel',[.5 .75 1])
    xlabel('flanker distance')
    ylabel('p(correct)')
    axis square
end


%%

cMatrix=[];
addTrialNums=1;
doFigAndSub=0;
multiComparePerPlot=0;
[delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix,{'pctCorrect'},subjects,[],[],doFigAndSub,addTrialNums,true,multiComparePerPlot, []);
close(gcf);
figure; hold on

plot([0 7],[0 0],'k--');
for j=1:length(values(col))
    eb=plot([values(col(j)) values(col(j))],-[CI(j,subInd,1) CI(j,subInd,2)],'color',params.colors(j,:),'LineWidth',2);
end
plot(values(col),-delta,'.k')


    axis([0 7 -8 8]);
    set(gca,'xTick',[3 5 6])
    set(gca,'xTickLabel',{'3','5','inf'})
    set(gca,'yTick',[-8 -4 0 4 8])
    set(gca,'yTickLabel',[-8 -4 0 4 8])
    xlabel('flanker distance')
    ylabel('change in pctCorrect (pop1-colin)')
    axis square
end
%% new figure for target alone

subplot(1,4,1); hold on
subjects={'138','139'}
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
%%
includePPC=[16 32];
for i=1:length(subjects)
  
    for j=1:length(includePPC)

    subInd=find(strcmp(subjects{i},names.subjects));
    statInd=find(strcmp('pctCorrect',names.stats));
    condInds=find(ppc==includePPC(j))
    condInds(c(condInds)==0)=[];
    plot([0 1],[.5 .5],'k--');
    
    if includePPC(j)>30
    plot(c(condInds),stats(i,condInds,statInd),'k');  % don't inlcude the 0 contrast condition
    else
     plot(c(condInds),stats(i,condInds,statInd),'k-.');  % don't inlcude the 0 contrast condition\
    end
    for j=1:length(condInds)    
        c(condInds(j))
        eb=plot([c(condInds(j)) c(condInds(j))],[CI(subInd,condInds(j),statInd,1) CI(subInd,condInds(j),statInd,2)],'color',params.colors(condInds(j),:),'LineWidth',2);
    end
   
 text(1.2,stats(subInd,condInds(end),statInd),assignLabeledNames(subjects(i)))
    axis([0 1.5 .45 1]);
    set(gca,'xTick',[0 .5 1])
    set(gca,'xTickLabel',{'0','0.5','1'})
    set(gca,'yTick',[.5 .75 1])
    set(gca,'yTickLabel',[.5 .75 1])
    xlabel('target Contrast')
    ylabel('p(correct)')
    axis square
    end
end



cleanUpFigure(gcf)