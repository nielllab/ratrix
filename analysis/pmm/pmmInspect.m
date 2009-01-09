function pmmInspect
%what philip wants to look at
% with the intention of being really quick daily analysis that matters


%%

%%
numFig=18; %number of possible figures
j=0;
subjects={'117','130','144'}
who='tiltDiscrim';
subplotParams.x=2; subplotParams.y=2;
j=j+1; handles=j.*numFig+[1:numFig];
dateRange=[now-90 now];
numRats=size(subjects,2)*size(subjects,1);
whichPlots=zeros(1,numFig);
whichPlots([17 18])=1;
for i=1:numRats
    subplotParams.index=i;
    d=getSmalls(subjects{i},dateRange);
    inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
savePlotsToPNG(whichPlots,handles,who,where);


%%
numFig=18; %number of possible figures
j=0;
subjects={'138','139','227','228','231','232','229','230','233','234','237'}; %older
%subjects={'271','272','273','274','275','276','277','278'};  %newer
%subjects={'138','139','227','228','231','232','229','230','233','234','237','274','278'}; %joined
%subjects={'273','274','276','278'};  %newer

%facts=getBasicFacts(r); who=facts(find(cellfun( @(x) ~isempty(x),strfind(lower(facts(:,8)),'left'))))
subjects={'138','139','229','230','233','234','237','278'} % right
subjects={'227','228','231','232','274'} % left, bigger tilt too
subjects={'227','229','230','237'}
who='flankers';
subplotParams.x=2; subplotParams.y=2;
j=j+1; handles=j.*numFig+[1:numFig];
dateRange=[now-90 now];
numRats=size(subjects,2)*size(subjects,1);
whichPlots=zeros(1,numFig);
%whichPlots([10 12])=1; %+18,17
for i=1:numRats
    subplotParams.index=i;
    d=getSmalls(subjects{i},dateRange);
    %d=removeSomeSmalls(d,~getGoods(d,'withoutAfterError'));
    if any(d.flankerPosAngle==0)
        allBeforeTilt=d.trialNumber<=(d.trialNumber(max(find(d.flankerPosAngle==0))));
        d=removeSomeSmalls(d,allBeforeTilt); %datestr(d.date(min(find(d.flankerPosAngle==pi/12))),22)
    end
    flankersTooFaint=(d.flankerContrast<0.3);
    %d=removeSomeSmalls(d,flankersTooFaint);
    inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
savePlotsToPNG(whichPlots,handles,who,where);

%% overlap hack  --turn off doInset in inspect rat response to get it to work

subjects={'138','139','227','228','231','232','229','230','233','234','237','238'};
who='15ers';
subplotParams.x=4; subplotParams.y=3;
subplotParams.x=2; subplotParams.y=1;  %subjects={'138','228'};
j=j+1; handles=j.*numFig+[1:numFig];
dateRange=[now-30 now];
numRats=size(subjects,2)*size(subjects,1);
whichPlots=zeros(1,numFig);
whichPlots(10)=1; %+18,17
figure; hold on
for i=1:numRats
    subplotParams.index=1; % set to 1
    d=getSmalls(subjects{i},dateRange);
    %allBeforeTilt=d.trialNumber<=(d.trialNumber(max(find(d.flankerPosAngle==0))));
    if ismember('currentShapedValue',fields(d))
        allBut3to4and8=~ismember(d.currentShapedValue,[0.3,0.4,0.8])
        d=removeSomeSmalls(d,allBut3to4and8); %datestr(d.date(min(find(d.flankerPosAngle==pi/12))),22)
        if length(d.date)>100
            inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
        end
    end
end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
savePlotsToPNG(whichPlots,handles,who,where);

%%
subjects= {'136','137','131','135'};
who='goToSide';
subplotParams.x=2; subplotParams.y=2;
j=j+1; handles=j.*numFig+[1:numFig];
dateRange=[now-10 now];
numRats=size(subjects,2)*size(subjects,1);
whichPlots=zeros(1,numFig);
%whichPlots(10)=1;
for i=1:numRats
    subplotParams.index=i;
    d=getSmalls(subjects{i},dateRange);
    inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
savePlotsToPNG(whichPlots,handles,who,where);

%% trends in effect

subjects={'231'};
who='231';
subplotParams.x=1; subplotParams.y=2;
j=j+1; handles=j.*numFig+[1:numFig];
handles=1:numFig;

%subjects={'138','139','227','228','231','232','229','230','233','234','237','238'};
%who='15ers';
% subplotParams.x=4; subplotParams.y=3;

dateRange=[now-120 now];
dateRange= [datenum('22-Sep-2008')-100 datenum('22-Sep-2008')]
whichPlots=zeros(1,numFig);
whichPlots([3])=1;

numFigs=4;
for i=1:numFigs
    figure; hold on
end

numRats=size(subjects,2)*size(subjects,1);
for i=1:numRats;
    subplotParams.index=i;
    d=getSmalls(subjects{i},dateRange);
    if length(d.date)>200
        totalTrials=length(d.date);
        goods=getGoods(d,'withoutAfterError');
        [conditionInds names haveData colors]=getFlankerConditionInds(d,goods,'colin+3');
        shuffleData=d;

        %effect per chunk
        chunkSize=6000;
        trialsPerChunk=repmat(chunkSize,1,floor(totalTrials/chunkSize)) ; %ignore the last partial-chunk if less than chunk size
        trialsCompletedBy=cumsum(trialsPerChunk);
        trialsCompletedBefore=[0 trialsCompletedBy(1:end-1)];
        for i=1:length(trialsPerChunk)
            shuffledInds=trialsCompletedBefore(i)+randperm(trialsPerChunk(i)); %shuffled within day
            shuffleData.response(trialsCompletedBefore(i)+1:trialsCompletedBy(i))=d.response(shuffledInds);
        end


        [dpr]  =dprimePerConditonPerDay(trialsCompletedBy,conditionInds,goods,d);
        [shuffleDpr]=dprimePerConditonPerDay(trialsCompletedBy,conditionInds,goods,shuffleData);

        %all days
        [dprAll]       =dprimePerConditonPerDay(totalTrials,conditionInds,goods,d);
        [shuffleDprAll]=dprimePerConditonPerDay(totalTrials,conditionInds,goods,shuffleData);

        [pct more]  =performancePerConditionPerDay(trialsCompletedBy,conditionInds,goods,d);
        [shufflePct shuffleMore]=performancePerConditionPerDay(trialsCompletedBy,conditionInds,goods,shuffleData);
        [delta CI]=collinearVsOtherCI(more,names);
        [shuffleDelta shuffleCI]=collinearVsOtherCI(shuffleMore,names);

        %all days
        [pctAll pctAllMore]              =performancePerConditionPerDay(totalTrials,conditionInds,goods,d);
        [shufflePctAll shufflePctAllMore]=performancePerConditionPerDay(totalTrials,conditionInds,goods,shuffleData);
        [deltaAll CIAll]=collinearVsOtherCI(pctAllMore,names);
        [shuffleDeltaAll shuffleCIAll]=collinearVsOtherCI(shufflePctAllMore,names);

        %%% percent correct
        figure(gcf-numFigs+1) % reset to first



        plot(ones(size(pctAll)),shufflePctAll','o', 'MarkerSize',10,'color',[.6,.7,.8])
        plot(ones(size(pctAll)),pctAll'       ,'ko','MarkerSize',10)
        plot(repmat(trialsCompletedBy, size(pct,1),1)',shufflePct','.','color',[.6,.7,.8])
        plot(repmat(trialsCompletedBy, size(pct,1),1)',pct','k.')

        for i=haveData
            plot(1,pctAll(  i,:)','o','MarkerSize',10,'color',colors(i,:))
            plot(trialsCompletedBy',pct( i,:)','.','color',colors(i,:))
        end
        %axis( [1 max([totalTrials 2]) -.5 max([max(dpr(~isinf(dpr(:)))) 1])   ])
        axis([get(gca,'XLim') 0 1])
        ylabel('pct Correct')

        %%%
        figure(gcf+1)
        plot(ones(size(dprAll)),shuffleDprAll','o', 'MarkerSize',10,'color',[.6,.7,.8])
        plot(ones(size(dprAll)),dprAll'       ,'ko','MarkerSize',10)
        plot(repmat(trialsCompletedBy, size(dpr,1),1)',shuffleDpr','.','color',[.6,.7,.8])
        plot(repmat(trialsCompletedBy, size(dpr,1),1)',dpr','k.')

        for i=haveData
            plot(1,dprAll(  i,:)','o','MarkerSize',10,'color',colors(i,:))
            plot(trialsCompletedBy',dpr( i,:)','.','color',colors(i,:))
        end
        %axis( [1 max([totalTrials 2]) -.5 max([max(dpr(~isinf(dpr(:)))) 1])   ])
        axis([get(gca,'XLim') -2 2])
        ylabel('dprime')


        figure(gcf+1) %dpr
        subplot(122); hold on
        title(who)
        effect=dpr(1,:)-mean(dpr);
        outliers=abs(effect)>20;
        plot(effect,'r.','MarkerSize',10)
        plot(get(gca,'XLim'),[0 0],'k')
        plot(get(gca,'XLim'),[mean(effect(~outliers)) mean(effect(~outliers))],'--','color',[1,0,0])
        axis([get(gca,'XLim') -0.5 0.5])

        subplot(121); hold on
        title('shuffle control')
        effect=shuffleDpr(1,:)-mean(shuffleDpr);
        outliers=abs(effect)>20;
        plot(effect,'.','MarkerSize',10,'color',[.6,.7,.8])
        plot(get(gca,'XLim'),[0 0],'k')
        plot(get(gca,'XLim'),[mean(effect(~outliers)) mean(effect(~outliers))],'--','color',[.6,.7,.8])
        axis([get(gca,'XLim') -0.5 0.5])
        ylabel('difference in dprime (colinear-avg other conditions)')
        xlabel('chunk of trials')

        figure(gcf+1)  %pct corrrect diff across conditions
        subplot(122); hold on
        title(who)
        effect=pct(1,:)-mean(pct(2:4,:));
        %outliers=abs(effect)>20;
        outliers=zeros(size(effect))
        %errorbar(1:length(delta),delta,delta-CI(1,:),CI(2,:)-delta)
        plot([repmat(1:length(delta),2,1)],[delta; CI(2,:)],'color',[1 0 0])
        plot([1:length(delta)],[delta],'ro')
        plot(0,deltaAll,'o','MarkerSize',10,'color',[1 0 0]) %all of them combined
        plot([repmat(0,2,1)],[deltaAll; CIAll(2,:)],'color',[1 0 0],'LineWidth',5)
        plot(effect,'r.','MarkerSize',10)
        plot(get(gca,'XLim'),[0 0],'k')
        plot(get(gca,'XLim'),[deltaAll deltaAll],'--','color',[1,0,0])
        axis([get(gca,'XLim') -0.1 0.1])

        subplot(121); hold on
        title('shuffle control')
        effect=shufflePct(1,:)-mean(shufflePct(2:4,:));
        %outliers=abs(effect)>20;
        outliers=zeros(size(effect))
        plot([repmat(1:length(shuffleDelta),2,1)],[shuffleDelta; shuffleCI(2,:)],'color',[.6,.7,.8])
        plot([1:length(shuffleDelta)],[shuffleDelta],'o','color',[.6,.7,.8])
        plot(0,shuffleDeltaAll,'o','MarkerSize',10,'color',[.6,.7,.8]) %all of them combined
        plot([repmat(0,2,1)],[shuffleDeltaAll; shuffleCIAll(2,:)],'color',[1 0 0],'LineWidth',5)
        plot(effect,'.','MarkerSize',10,'color',[.6,.7,.8])
        plot(get(gca,'XLim'),[0 0],'k')
        plot(get(gca,'XLim'),[shuffleDeltaAll shuffleDeltaAll],'--','color',[.6,.7,.8])
        axis([get(gca,'XLim') -0.1 0.1])
        ylabel('difference in pctCorrect (colinear-avg other conditions)')
        xlabel('chunk of trials')

        %Confidence Interval of the Difference of Two Independent Binomial Proportions

        %why is there a different value in delta, than in the performance
        %of pct correct? double check the way delta is claulated, and how
        %it gets past through...

    end

end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
%savePlotsToPNG(whichPlots,handles,who,where);

%%

d=getSmalls('231');%,[now-1 now]); % 233 231

filter{1}.type='12';
filter{2}.type='performancePercentile';
filter{2}.parameters.whichCondition={'FullTargetContrastSomeFlankerAndMatchedNoSig',[1]};
filter{2}.parameters.goodType='withoutAfterError';
filter{2}.parameters.performanceMethod='pCorrect';
filter{2}.parameters.performanceParameters={[.5 1],'symetricBoxcar',200}; %symetricBoxcar
filter{2}=[]; %turn off filter 2

measures={'pctCor','pctYes','correctRejections','hitRate'};

for i=1:length(measures)
    figure(i)
    [stats plotParams]=flankerAnalysis(d,'colin+3','performancePerContrastPerCondition', measures{i}, filter,true)
end
%% contrast sweep hitFA scatter
% close all; figure(1)
 [stats CI names params]=getFlankerStats({'233'},'colin+3&contrasts',{'hits','CRs','yes','pctCorrect'},'12',[1 now]);
% stats(1,5:end,2)=repmat(stats(1,1:4,2),1,4); %fill in CRs to pair all contrasts
% stats(1,1:4,1)=1-stats(1,1:4,2); %set zero contrast to 0 sensitivity for now
% doHitFAScatter(stats,CI,names,params,[],1,1,0);

%% bar plot contrast
 [stats CI names params]=getFlankerStats({'233','231'},'colin+3&contrasts',{'hits','CRs','yes','pctCorrect'},'12',[1 now]);
%% correct

a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));
y=(params.raw.numYes(:,:));
figure;doBarPlotWithStims(sum(a),sum(c),[],params.colors,[0 100]); %all subjects
title('all'); ylabel('pctCorrect')

figure; doBarPlotWithStims(a(1,:),c(1,:),[],params.colors,[0 100]); %one subject
figure; doBarPlotWithStims(a(2,:),c(2,:),[],params.colors,[0 100] ); %other subject

%% yes

a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));
y=(params.raw.numYes(:,:));
figure;doBarPlotWithStims(sum(a),sum(y),[],params.colors,[0 100]); %all subjects
title('all'); ylabel('pctCorrect')

figure; doBarPlotWithStims(a(1,:),y(1,:),[],params.colors,[0 100]); %one subject
figure; doBarPlotWithStims(a(2,:),y(2,:),[],params.colors,[0 100] ); %other subject

%%

values = cellfun(@(x) str2num(x(5:end)), names.conditions); 
small=0.01; values=values+repmat([-2:1]*small,1,5);  %offset for viewing
    
for i=1:length(names.subjects)
   figure; hold on
   statInd=find(strcmp('yes',names.stats));
%    plot([-10 100],[.5 .5],'k--');
%    plot(values,stats(i,:,statInd),'k');
   for j=1:length(values)
       eb=plot([values(j) values(j)],[CI(i,j,statInd,1) CI(i,j,statInd,2)],'color',params.colors(j,:),'LineWidth',2);
   end
   axis([-.2 1.2 0 1]);
   set(gca,'xTick',[0 .5 1])
   set(gca,'xTickLabel',[0 .5 1])
   set(gca,'yTick',[.5 .6 .7])
   set(gca,'yTickLabel',[.5 .6 .7])
   xlabel('target contrast')
   ylabel('p(yes)')
   axis square
end
%% see easy performance during the contrats sweep
figure;
d=removeSomeSmalls(d,d.step<12);
[conditionInds names haveData conditionColors]=getFlankerConditionInds(d,[],'allTargetContrasts');
contrastPairs=matchwithNoSig(conditionInds(2:end,:),conditionInds(1,:));
doPlotPercentCorrect(d,[],[],[],[],[],[],[],[],[],[],[],{contrastPairs(end,:),[0 0 1]})% high contrast
figure
contrastPairs=matchwithNoSig(conditionInds(2:end,:),conditionInds(1,:)); doPlotPercentCorrect(d,[],[],[],[],[],[],[],[],[],[],[],contrastPairs)
contrastPairs=matchwithNoSig(conditionInds(2:end,:),conditionInds(1,:)); doPlotPercentCorrect(d,[],[],[],[],[],[],[],[],[],[],[],contrastPairs)
contrastPairs=matchwithNoSig(conditionInds(2:end,:),conditionInds(1,:)); doPlotPercentCorrect(d,[],[],[],[],[],[],[],[],[],[],[],contrastPairs)

%% see orientation sweep

subjects={'231','234'};%,[now-1 now]); % 231','234','274 % orientationSweep;  '274' removed b/c bad performance
filter{1}.type='14';
measures={'pctCor','pctYes','correctRejections','hitRate'};
for i=1:length(subjects)
    d=getSmalls(subjects{i});
    for j=1:length(measures)
        %figure
        subplot(length(subjects),length(measures),(i-1)*length(measures)+j)
        [stats plotParams]=flankerAnalysis(d,'allRelativeTFOrientationMag','performancePerContrastPerCondition', measures{j}, filter,'withoutAfterError',true)
        xlabel(subjects{i})
    end
end

%% see position sweep
figure
subjects={'138','139','228','232','233'}%,[now-1 now]); % '138','139','228','232','233' vary position
filter{1}.type='13';
measures={'pctCor','pctYes','correctRejections','hitRate'};
for i=1:length(subjects)
    d=getSmalls(subjects{i});
    for j=1:length(measures)
        subplot(length(subjects),length(measures),(i-1)*length(measures)+j)
        [stats plotParams]=flankerAnalysis(d,'colin+1&nfBlock','performancePerDeviationPerCondition', measures{j}, filter,'withoutAfterError',false)
    end
    xlabel(subjects{i})
end

%% see standard
figure
%previously viewed these rats: {'228', '227','230','233','234','139','138'}
subjects={'227','229','230','237'}%,[now-1 now]); % '227','229','230','237' %standard .4 .75
filter{1}.type='11';
% filter{2}.type='performancePercentile';
% filter{2}.parameters.whichCondition={'FullTargetContrastSomeFlankerAndMatchedNoSig',[1]};
% filter{2}.parameters.goodType='withoutAfterError';
% filter{2}.parameters.performanceMethod='pCorrect';
% filter{2}.parameters.performanceParameters={[.5 1],'symetricBoxcar',200}; %symetricBoxcar
% filter{2}=[]; %turn off filter 2

filter{2}.type='responseSpeedPercentile';
filter{2}.parameters.range=[0 .8];%whats justified?

[stats CI names params]=getFlankerStats(subjects,'8flanks+&nfMix',{'pctCorrect','yes'},filter,[1 now]);

viewFlankerComparison(names,params)

%% check stats for abstract
subjects={'228', '227','230','233','234','139','138'}
[stats CI names params]=getFlankerStats(subjects,'colin+3',{'pctCorrect','yes','CRs','hits','dprimeMCMC','criterionMCMC'},'9.4',[1 now]);
cMatrix={[1],[2]; [1],[3]; [1],[4]}
viewFlankerComparison(names,params,cMatrix)
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


% for i=1:length(subjects)
%     d=getSmalls(subjects{i});
%     for j=1:length(measures)
%         subplot(length(subjects),length(measures),(i-1)*length(measures)+j)
%         [stats plotParams]=flankerAnalysis(d,'colin+3','performancePerDeviationPerCondition', measures{j}, filter,true)
%     end
%     xlabel(subjects{i})
% end