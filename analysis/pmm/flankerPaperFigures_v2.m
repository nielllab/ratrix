%e



%% stats
x=100*diff(stats(:,find(ismember(names.conditions,{'colin','changeFlank'})),find(strcmp('pctCorrect',names.stats)))');
[h p] = ttest(x,0,.05,'right');
disp(sprintf('pop-colin pctCorrect: p= %5.5f 1-tail t-test',p))
[p] = signrank(x,0);
disp(sprintf('pop-colin pctCorrect: p= %5.5f  sign rank test',p))


[stats CI names params]=getFlankerStats(subjects,'8flanks+',{'dpr'},'9.4')
x=100*diff(stats(:,find(ismember(names.conditions,{'colin','changeFlank'})),find(strcmp('dpr',names.stats)))');
[h p] = ttest(x,0,.05,'right');
disp(sprintf('pop-colin log ratio dprime: p= %5.5f 1-tail t-test',p))
[p] = signrank(x,0);
disp(sprintf('pop-colin log ratio dprime: p= %5.5f  sign rank test',p))


%% figure 1: main effect

subjects={'228', '227','138','139','230','233','234'}; %left and right, removed 229 274 231 232 too little data for 9.4., 237 maybe enough data, almost 5kTrials, outlier
subjects={'228', '227','230','233','234','139','138'};%sorted for amount of data
labeledNames={'r7','r6','r5','r4','r3','r2','r1'};
filter{1}.type='9.4';
[stats CI names params]=getFlankerStats(subjects,'8flanks+',{'pctCorrect','CRs','hits','dprimeMCMC','yes'},filter)

%%

useConds={'colin','changeFlank','changeTarget','para'};
singleRat='230'; % 234
p=100*stats(strcmp(singleRat,names.subjects),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
ci= 100*CI(strcmp(singleRat,names.subjects),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)),[1:2])
ci=reshape(ci(:),4,2);
f=figure;
subplot(2,2,1)
colors=[1 0 0; .8 1 1; .8 1 1; .6 .6 .6];
doBarPlotWithStims(p,ci,[],colors,[50 75],'stats&CI',false)
title(sprintf('single rat performance (%s)',labeledNames{find(strcmp(singleRat,subjects))})); ylabel('pctCorrect')
set(gca,'xTick',[1 2 3 4])
set(gca,'xTickLabel',{'col','po1','po2','par'})

subplot(2,2,2)
if 0 %uber rat
    a=(params.raw.numAttempt(:,[9 10 11 12]));
    c=(params.raw.numCorrect(:,[9 10 11 12]));
    doBarPlotWithStims(sum(a),sum(c),[],colors,[50 75],'binodata',false);
elseif 1 %show many subjects
    p=100*stats(:,find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
    stat=mean(p)
    ci=[stat; stat]+[-1; 1]*std(p)
    %doBarPlotWithStims(stat,ci',[],colors,[50 75],'stats&CI',false) % with std error bar
    %doBarPlotWithStims(stat,[stat; stat]',[],colors,[55 70],'stats&CI',false) % no error bar
    hold on; axis([0 5 55 70])
    if 1 % add connector per subject
        offset=0.0;
        if 0 % add connector for some subjects
            
            %worst
            y2=100*stats(find(y==min(y)),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
            plot([1:4]+offset,y2,'k--')
            %best
            y2=100*stats(find(y==max(y)),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
            plot([1:4]+offset,y2,'k--')
            %fig a
            y2=100*stats(strcmp(singleRat,names.subjects),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
            plot([1:4]+offset,y2,'k--')
        elseif 1 % add connector for all subjects
            for j=1:size(stats,1) % subjects
                subId=find(strcmp(subjects(j),names.subjects))
                y2=100*stats(subId,find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
                plot([1:4]+offset,y2,'k--')
                switch labeledNames{subId}
                    case {'r3','r6'}
                        text(4.3, y2(end),labeledNames(subId)) %label subjects
                    case {'r1'}
                        text(0.2, y2(1)-0.7,labeledNames(subId)) %label subjects
                    otherwise
                        text(0.2, y2(1),labeledNames(subId)) %label subjects
                end
            end
        end
    end
    
    %add scatter for subjects
    for j=1:size(stats,1) % subjects
        for i=1:length(useConds)
            x=repmat(i+offset,1,length(names.subjects));
            y=100*stats(:,find(ismember(names.conditions,useConds(i))),find(strcmp('pctCorrect',names.stats)));
            d=plot(x(j),y(j),'.','MarkerSize',20,'color',colors(i,:));
            %set(d,'MarkerEdgeColor','b','MarkerFaceColor','r')
        end
    end
    
    
end
title('all rats performance'); ylabel('pctCorrect')
set(gca,'xTick',[1 2 3 4])
set(gca,'xTickLabel',{'col','po1','po2','par'})


nBins=7;  %try 7, 18, 10, 20
subplot(2,2,3)
cMatrix={[find(ismember(names.conditions,{'colin'}))], [find(ismember(names.conditions,{'changeFlank'}))]}
viewFlankerComparison(names,params, cMatrix,{'pctCorrect'},[],[-5:10/nBins:5],[],false,false,labeledNames)
title('colinear vs popout1')
ylabel('count')

subplot(2,2,4)
cMatrix={[find(ismember(names.conditions,{'colin'}))], [find(ismember(names.conditions,{'para'}))]}
viewFlankerComparison(names,params, cMatrix,{'pctCorrect'},[],[-5:10/nBins:5],[],false,false,labeledNames)
title('colinear vs parallel')
ylabel('count')

%% figure 2  hit v fa scatter and stats

figure
subplot(2,1,1)
none=zeros(size(stats,1),size(stats,2));
doCurve=zeros(size(stats,1),size(stats,2));  doCurve([find(ismember(names.subjects,{'230'}))],[find(ismember(names.conditions,{'colin','changeFlank'}))])=1;
%doHitFAScatter(stats,CI,names,params,{'228','230','138'},{'colin','changeFlank'},false,doCurve,doCurve,doCurve,false);
%doHitFAScatter(stats,CI,names,params,{'230'},{'colin','changeFlank'},false,doCurve,doCurve,doCurve,false,3,{'changeFlank','colin'}); axis([.46 .55 .7 .79])
doHitFAScatter(stats,CI,names,params,[],{'colin','changeFlank'},false,none)
%,none,doCurve,false,3,{'changeFlank','colin'});
title('ROC space, influence of collinear')


%%
nBins=11;%11/16 is closest near match to 10/7%

% stats
subplot(4,2,5)
cMatrix={[find(ismember(names.conditions,{'colin'}))], [find(ismember(names.conditions,{'changeFlank'}))]}
viewFlankerComparison(names,params, cMatrix,{'dprimeMCMC'},[],[-0.3:.6/nBins:0.3],[],false,false,labeledNames)
ylabel('count')
xlabel('difference in dprime')

subplot(4,2,6)
cMatrix={[find(ismember(names.conditions,{'colin'}))], [find(ismember(names.conditions,{'changeFlank'}))]}
viewFlankerComparison(names,params, cMatrix,{'yes'},[],[-8:16/nBins:8],[],false,false,labeledNames)
ylabel('count')

subplot(4,2,7)
cMatrix={[find(ismember(names.conditions,{'colin'}))], [find(ismember(names.conditions,{'changeFlank'}))]}
viewFlankerComparison(names,params, cMatrix,{'hits'},[],[-8:16/nBins:8],[],false,false,labeledNames)
ylabel('count')

subplot(4,2,8)
cMatrix={[find(ismember(names.conditions,{'colin'}))], [find(ismember(names.conditions,{'changeFlank'}))]}
viewFlankerComparison(names,params, cMatrix,{'CRs'},[],[-8:16/nBins:8],[],false,false,labeledNames)
ylabel('count')


%% figure 3: orientation sweep


subjects={'231','234'};%,[now-1 now]); % 231','234','274 % orientationSweep;  '274' removed b/c bad performance
filter{1}.type='14';
dateRange=[1 pmmEvent('endToggle')];
%dateRange=[pmmEvent('endToggle') now];
[stats CI names params]=getFlankerStats(subjects,'allRelativeTFOrientationMag',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
%[stats CI names params]=getFlankerStats(subjects,'allRelativeTFOrientationMag',{'hits','CRs','yes','pctCorrect','criterionMCMC','biasMCMC','dprimeMCMC'},filter,dateRange);
params.colors=[1 0 0; .9 .2 .8; .7 .4 .9; 0 1 1; 0 .2 .8];
values = cellfun(@(x) str2num(x), names.conditions);

%%
figure(2)
w=3; w=2;
for i=1:length(subjects)
       subplot(length(subjects),w,(i-1)*w+2); hold on
       statInd=find(strcmp('pctCorrect',names.stats));
       plot([-10 100],[.5 .5],'k--');
       plot(values,stats(i,:,statInd),'k');
       for j=1:length(values)
           eb=plot([values(j) values(j)],[CI(i,j,statInd,1) CI(i,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
       end
       axis([-5 95 .45 .7]);
       set(gca,'xTick',[0 30 90])
       set(gca,'xTickLabel',[0 30 90])
       set(gca,'yTick',[.5 .6 .7])
       set(gca,'yTickLabel',[.5 .6 .7])
       xlabel('flanker orientation')
       ylabel('p(correct)')
       axis square
    
    subplot(length(subjects),w,(i-1)*w+1);  hold on
    statInd=find(strcmp('yes',names.stats));
    plot(values,stats(i,:,statInd),'k');
    for j=1:length(values)
        eb=plot([values(j) values(j)],[CI(i,j,statInd,1) CI(i,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    axis([-5 95 .2 .7]);
    set(gca,'xTick',[0 30 90])
    set(gca,'xTickLabel',[0 30 90])
    set(gca,'yTick',[.3 .5 .7])
    set(gca,'yTickLabel',[.3 .5 .7])
    xlabel('flanker orientation')
    ylabel('p(yes)')
    axis square
    
    %    subplot(length(subjects),w,(i-1)*w+3);
    %    doHitFAScatter(stats,CI,names,params,subjects(i),[],false,0,0,0,1,3);
    %    %doHitFAScatter(stats,CI,names,params,[],{'colin','changeFlank'},false,doCurve,doCurve,doCurve,false,3,{'changeFlank','colin'});
    %
    %      subplot(length(subjects),w,(i-1)*w+4);  hold on
    %    statInd=find(strcmp('dprimeMCMC',names.stats));
    %    plot(values,stats(i,:,statInd),'k');
    %    for j=1:length(values)
    %        eb=plot([values(j) values(j)],[CI(i,j,statInd,1) CI(i,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    %    end
    %    axis([-5 95 0 1]);
    %    set(gca,'xTick',[0 30 90])
    %    set(gca,'xTickLabel',[0 30 90])
    %    set(gca,'yTick',[0 .5 1])
    %    set(gca,'yTickLabel',[0 .5 1])
    %    xlabel('flanker orientation')
    %    ylabel('d-prime')
    %    axis square
    %
    
%     subplot(length(subjects),w,(i-1)*w+2);  hold on
%     statInd=find(strcmp('criterionMCMC',names.stats));
%     plot(values,-stats(i,:,statInd),'k');
%     for j=1:length(values)
%         eb=plot([values(j) values(j)],-[CI(i,j,statInd,1) CI(i,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
%     end
%     axis([-5 95 -1.5 .5]); %axis([-5 95 -.5 1.5]);
%     set(gca,'xTick',[0 30 90])
%     set(gca,'xTickLabel',[0 30 90])
%     set(gca,'yTick',[-1 -.5 0])
%     set(gca,'yTickLabel',[-1 .5 0])
%     xlabel('flanker orientation')
%     ylabel('-criterion')
%     axis square
end
settings.turnOffLines=1;
cleanUpFigure(gcf,settings)


%% flanker distance
%setup basic- no flanker conditions, just distance
subjects={'233','138','232'};%     '228','139'
%subjects={'228','139'};%
subjects={'232','138'};%
subjects={'232','233','138','228','139'};%



filter{1}.type='13';
[stats CI names params]=getFlankerStats(subjects,'allDevs',{'hits','CRs','yes','pctCorrect'},filter,[1 now]);
values = cellfun(@(x) str2num(x(5:end)), names.conditions);
arrows=[];
curveAndBias=1;

%% alternate setup
% compare colinear to popout
subjects={'232','138'};%
subjects={'232','233','228','139','138'};% 
%subjects={'232','233','139'}; % 138,228 not very good..
subjects={'232'};
last139problemDate=datenum('Nov.15,2008');
dateRange=[pmmEvent('endToggle') now];
%subjects={'232'};%
filter{1}.type='13';
[stats CI names params]=getFlankerStats(subjects,'colin+1&devs',{'hits','CRs','yes','pctCorrect'},filter,dateRange);
values = cellfun(@(x) str2num(x(5:end)), names.conditions);
small=0.1; values=values+repmat([-1 1]*small,1,4);  %offset for viewing
%values([1 2 5 6 9 10 13 14])=-1; %hack to only plot the first half, by
%moving the other half off the visible plot
%values([3 4 7 8 11 12 15 16])=-1; %hack to cut off some kinds
arrows={'l-l 2.50','--- 2.50',1; 'l-l 3.00','--- 3.00',3;'l-l 3.50','--- 3.50',3;'l-l 5.00','--- 5.00',3};
curveAndBias=0
[delta CId deltas CIs]=viewFlankerComparison(names,params,[],{'pctCorrect'},[],[-10 10],[],[],false,false,true)
figure; doHitFAScatter(stats,CI,names,params,subjects,[],0,curveAndBias,curveAndBias,0,0,3,arrows);
%%
figure(4)
w=3; %w=5;
for i=1:length(subjects)
    subInd=find(strcmp(subjects{i},names.subjects));
    
    subplot(length(subjects),w,(i-1)*w+1); hold on
    statInd=find(strcmp('pctCorrect',names.stats));
    plot([-10 100],[.5 .5],'k--');
    text(.1,.8,subjects{i})
    %plot(values,stats(i,:,statInd),'k');
    for j=1:length(values)
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    axis([0 6 .45 .8]);
    set(gca,'xTick',[3 5])
    set(gca,'xTickLabel',[ 3 5])
    set(gca,'yTick',[.5 .6 .7])
    set(gca,'yTickLabel',[.5 .6 .7])
    xlabel('flanker distance')
    ylabel('p(correct)')
    axis square
    
    subplot(length(subjects),w,(i-1)*w+2);  hold on
    statInd=find(strcmp('yes',names.stats));
    %plot(values,stats(subInd,:,statInd),'k');
    for j=1:length(values)
        eb=plot([values(j) values(j)],[CI(subInd,j,statInd,1) CI(subInd,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
    end
    axis([0 6 .2 .7]);
    set(gca,'xTick',[3 5])
    set(gca,'xTickLabel',[3 5])
    set(gca,'yTick',[.3 .5 .7])
    set(gca,'yTickLabel',[.3 .5 .7])
    xlabel('flanker distance')
    ylabel('p(yes)')
    axis square
    
    subplot(length(subjects),w,(i-1)*w+3);
    doHitFAScatter(stats,CI,names,params,subjects(i),[],0,curveAndBias,curveAndBias,0,0,3,arrows);
end
settings.turnOffLines=1;
cleanUpFigure(gcf,settings)

%%



%% check stats for abstract
subjects={'228','227','230','233','234','139','138'}
[stats CI names params]=getFlankerStats(subjects,'colin+3',{'pctCorrect','yes','CRs','hits','dprimeMCMC','criterionMCMC'},'9.4',[1 now]);
cMatrix={[1],[2]; [1],[3]; [1],[4]}
viewFlankerComparison(names,params,cMatrix)
%%
stat=mean(stats(:,:,find(strcmp('criterionMCMC',names.stats))))
ci(1:4,1)=mean(CI(:,:,find(strcmp('criterionMCMC',names.stats)),1));
ci(1:4,2)=mean(CI(:,:,find(strcmp('criterionMCMC',names.stats)),2));
figure; doBarPlotWithStims(stat,ci,[],params.colors,[0 .5],'stats&CI',0);


stat=mean(stats(:,:,find(strcmp('dprimeMCMC',names.stats))))
ci(1:4,1)=mean(CI(:,:,find(strcmp('dprimeMCMC',names.stats)),1));
ci(1:4,2)=mean(CI(:,:,find(strcmp('dprimeMCMC',names.stats)),2));
figure; doBarPlotWithStims(stat,ci,[],params.colors,[.5 .9],'stats&CI',0);

stat=mean(stats(:,:,find(strcmp('yes',names.stats))))
ci(1:4,1)=mean(CI(:,:,find(strcmp('yes',names.stats)),1));
ci(1:4,2)=mean(CI(:,:,find(strcmp('yes',names.stats)),2));
figure; doBarPlotWithStims(stat,ci,[],params.colors,[.4 .6],'stats&CI',0);


stat=mean(stats(:,:,find(strcmp('CRs',names.stats))))
ci(1:4,1)=mean(CI(:,:,find(strcmp('CRs',names.stats)),1));
ci(1:4,2)=mean(CI(:,:,find(strcmp('CRs',names.stats)),2));
figure; doBarPlotWithStims(stat,ci,[],params.colors,[.6 .7],'stats&CI',0);

stat=mean(stats(:,:,find(strcmp('pctCorrect',names.stats))))
ci(1:4,1)=mean(CI(:,:,find(strcmp('pctCorrect',names.stats)),1));
ci(1:4,2)=mean(CI(:,:,find(strcmp('pctCorrect',names.stats)),2));
figure; doBarPlotWithStims(stat,ci,[],params.colors,[.5 1],'stats&CI',0);

figure; doHitFAScatter(stats,CI,names,params,{'228','230','138'},false, repmat([0 1 0 0],3,1));

doCurve=zeros(7,4); doCurve([1 4],[1 2])=1; doYesLine=doCurve;
figure; doHitFAScatter(stats,CI,names,params,[],false, doCurve,doYesLine,false,false);

doCurve=zeros(3,4); doYesLine=doCurve; doCurve([1],[1 2])=1; doYesLine(:,[1 2])=1;
figure; doHitFAScatter(stats,CI,names,params,{'228','230','138'},false, doCurve,doYesLine,false,false);
title('3 typical best rats')

doCurve=zeros(3,4);  doCurve([2],[1 2])=1;
figure; doHitFAScatter(stats,CI,names,params,{'228','230','138'},false, doCurve,doCurve,doCurve,false);
title('3 typical best rats- explain one of them')


doCurve=zeros(4,4); doYesLine=doCurve; doCurve([1],[1 2])=1; doYesLine(:,[1 2])=1;
figure; doHitFAScatter(stats,CI,names,params,{'227','233','234','139'},false, doCurve,doYesLine,false,false);
title('the other four rats')

% for i=1:length(subjects)
%     d=getSmalls(subjects{i});
%     for j=1:length(measures)
%         subplot(length(subjects),length(measures),(i-1)*length(measures)+j)
%         [stats plotParams]=flankerAnalysis(d,'colin+3','performancePerDeviationPerCondition', measures{j}, filter,true)
%     end
%     xlabel(subjects{i})
% end

%% noFlank condition make some plots on population performance

subjects={'228','227','230','233','234','138','139'};%sorted for amount of removed b/c  nfBlock problems= {'138','139',}
%subjects= {'138'}%,'139'}
labeledNames={'r7','r6','r5','r4','r3','r2','r1'};
filter{1}.type='9.4.1+nf'; % use range to include noFm
%last139problemDate=datenum('Nov.15,2008');
dateRange=[0 pmmEvent('endToggle')];
[stats CI names params]=getFlankerStats(subjects,'8flanks+&nfMix&nfBlock',{'pctCorrect','CRs','hits','dpr','yes'},filter,dateRange)

%%
useConds={'other','noFm','noFb'};
%useConds={'colin','changeFlank','changeTarget','para','other','noFm','noFb'};
singleRat='230'; % 234
p=100*stats(strcmp(singleRat,names.subjects),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
ci= 100*CI(strcmp(singleRat,names.subjects),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)),[1:2]);
ci=reshape(ci(:),length(useConds),2);
f=figure;
subplot(1,2,1)
colors=[ 1 0 0; .2 .5 .2; .2 .2 .5];
%colors=[1 0 0; .8 1 1; .8 1 1; .6 .6 .6; .2,.2,.2; 0 1 .5; 0 1 .8];
doBarPlotWithStims(p,ci,[],colors,[50 100],'stats&CI',false)
title(sprintf('single rat performance (%s)',labeledNames{find(strcmp(singleRat,subjects))})); ylabel('pctCorrect')
set(gca,'xTick',[1:length(useConds)])
set(gca,'xTickLabel',{'flank','noFm','noFb'})
ylab=[50 75 100];
set(gca,'yTick',ylab)
set(gca,'yTickLabel',ylab)
%set(gca,'xTickLabel',{'col','po1','po2','par','flank','noF_m','noF_b'})

subplot(1,2,2)
if 0 %uber rat
    a=(params.raw.numAttempt(:,find(ismember(names.conditions,useConds))));
    c=(params.raw.numCorrect(:,find(ismember(names.conditions,useConds))));
    doBarPlotWithStims(sum(a),sum(c),[],colors,[50 85],'binodata',false);
elseif 1 %show many subjects
    p=100*stats(:,find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
    stat=mean(p)
    ci=[stat; stat]+[-1; 1]*std(p)
    nc=length(useConds);
    %doBarPlotWithStims(stat,ci',[],colors,[50 75],'stats&CI',false) % with std error bar
    %doBarPlotWithStims(stat,[stat; stat]',[],colors,[55 70],'stats&CI',false) % no error bar
    hold on;
    axis([0 nc+1 50 100])
    if 1 % add connector per subject
        offset=0.0;
        if 0 % add connector for some subjects
            
            %worst
            y2=100*stats(find(y==min(y)),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
            plot([1:nc]+offset,y2,'k--')
            %best
            y2=100*stats(find(y==max(y)),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
            plot([1:nc]+offset,y2,'k--')
            %fig a
            y2=100*stats(strcmp(singleRat,names.subjects),find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
            plot([1:nc]+offset,y2,'k--')
        elseif 1 % add connector for all subjects
            for j=1:size(stats,1) % subjects
                subId=find(strcmp(subjects(j),names.subjects));
                y2=100*stats(subId,find(ismember(names.conditions,useConds)),find(strcmp('pctCorrect',names.stats)));
                plot([1:nc]+offset,y2,'k--')
                switch labeledNames{subId}
                    case {'r3','r1','r7','r5','r2'}
                        text(nc+0.3, y2(end),labeledNames(subId)) %label subjects
                    case {'r1'}
                        text(0.2, y2(1)-0.7,labeledNames(subId)) %label subjects
                    otherwise
                        text(0.2, y2(1),labeledNames(subId)) %label subjects
                end
            end
        end
    end
    
    %add scatter for subjects
    for j=1:size(stats,1) % subjects
        for i=1:length(useConds)
            x=repmat(i+offset,1,length(names.subjects));
            y=100*stats(:,find(ismember(names.conditions,useConds(i))),find(strcmp('pctCorrect',names.stats)));
            d=plot(x(j),y(j),'.','MarkerSize',20,'color',colors(i,:));
            %set(d,'MarkerEdgeColor','b','MarkerFaceColor','r')
        end
    end
    
    title(sprintf('all rats performance (%s)','r1-7')); ylabel('pctCorrect')
    set(gca,'xTick',[1:length(useConds)])
    set(gca,'xTickLabel',{'flank','noFm','noFb'})
    set(gca,'yTick',ylab)
    set(gca,'yTickLabel',ylab)
end

%% check hitVs FA

doCurve=false;  %doCurve([2],[1 2])=1;
%[stats CI names params]=getFlankerStats({'231'},'allRelativeTFOrientationMag',{'hits','CRs'},'14',[1 now]);
figure; doHitFAScatter(stats,CI,names,params,subjects);



%% dimmer
subjects={'228', '227','230','233','234','139','138'};% sorted for amount of data

filter{1}.type='9.4';
% filter{2}.type='responseSpeedPercentile';
% filter{2}.parameters.range=[0 .7];%whats justified?
dateRange=[0 pmmEvent('endToggle')];
[stats CI names params]=getFlankerStats(subjects,'8flanks+',{'pctCorrect','CRs','hits','yes'},filter,dateRange)

subjects={'237','229','227','230'}; % constant test
filter{1}.type='11';
% filter{2}.type='performancePercentile';
% filter{2}.parameters.goodType='withoutAfterError';
% filter{2}.parameters.whichCondition={'noFlank',1}
% filter{2}.parameters.performanceMethod='pCorrect';
% filter{2}.parameters.performanceParameters={[.25 1],'boxcar',100}

              
[stats2 CI2 names2 params2]=getFlankerStats(subjects,'8flanks+',{'pctCorrect','CRs','hits','yes'},filter,dateRange)
%%
arrows={'changeFlank','colin',1};
figure; doHitFAScatter(stats2,CI2,names2,params2,[],{'changeFlank','colin'},0,0,0,0,0,3,arrows);
figure; doHitFAScatter(stats,CI,names,params,[],{'changeFlank','colin'},0,0,0,0,0,3,arrows);
%%
close all
nBins=7;  %try 7, 18, 10, 20
subplot(2,1,1)
cMatrix={[find(ismember(names.conditions,{'colin'}))], [find(ismember(names.conditions,{'changeFlank'}))]}
viewFlankerComparison(names,params, cMatrix,{'pctCorrect'},[],[-5:10/nBins:5],[],false,false,[])
title('colinear - popout1')
ylabel('count')

subplot(2,1,2)
viewFlankerComparison(names2,params2, cMatrix,{'pctCorrect'},[],[-5:10/nBins:5],[],false,false,[])

%%




