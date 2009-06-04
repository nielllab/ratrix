function viewBlockedData(subjects)

if ~exist('d','var') || isempty(d)
    subjects={'231','234'}
end

%quick set params
dateRange= [pmmEvent('firstBlocking') now]


for s=1:length(subjects)
    
    figure;     
    d=getSmalls(subjects{s},[dateRange]);
    d=removeSomeSmalls(d,isnan(d.blockID));
    subplot(1,2,1);
    doPlotPercentCorrect(d)
    d=addYesResponse(d);
    
    subplot(1,2,2);
    %bar for that blockID
    
    filter{1}.type='12';
    %filter{2}.type='trialThisBlockRange';
    %filter{2}.parameters.range=[50 Inf];
    [stats CI names params]=getFlankerStats(subjects(s),'allBlockIDs',{'pctCorrect'},filter,dateRange);
    doBarPlotWithStims(100*stats,100*reshape(CI,[],2),[],params.colors,[50 100],'stats&CI');
    
    %dot for each
    [seg_stats seg_CI seg_names seg_params]=getFlankerStats(subjects(s),'allBlockSegments',{'pctCorrect'},filter,dateRange);

    offset=0.25;% for viewing
    plot(seg_params.factors.blockID+offset,100*seg_stats,'k.')
    set(gca,'xtick',unique(seg_params.factors.blockID));
    set(gca,'xTickLabel',unique(seg_params.factors.targetContrast)); % this only works b/c we used acsending target contrasts
    xlabel('blocks, guessing they are target contrast')
    title(subjects{s})
    
%%    
    %future: performance "trialPerBlock"
    figure;
    transitionFilter=-Inf; %1 for up by 1 or inf for ALL ups
    trialsBeforeAfter=[50 150];
    trialsPerBin=25;
    [trialIDs details]=getBlockTransitionTrialNums(d,transitionFilter,trialsBeforeAfter,trialsPerBin);
    for i=1:size(trialIDs,1)
        inds=trialIDs(i,:,:);
        inds=inds(:); %unwrap
        inds(isnan(inds))=[]; %remove bad
        correct=d.correct(inds);
        yes=d.yes(inds);
        cUp(i)=binofit(sum(correct),length(correct));
        yUp(i)=binofit(sum(correct),length(correct));
    end
    
    transitionFilter=-transitionFilter;
    [trialIDs details]=getBlockTransitionTrialNums(d,transitionFilter,trialsBeforeAfter,trialsPerBin);
    for i=1:size(trialIDs,1)
        inds=trialIDs(i,:,:);
        inds=inds(:); %unwrap
        inds(isnan(inds))=[]; %remove bad
        correct=d.correct(inds);
        yes=d.yes(inds);
        cDown(i)=binofit(sum(correct),length(correct));
        yDown(i)=binofit(sum(yes),length(yes));
    end
   
    subplot(1,2,1)
    plot(details.binStartStop(1,:),cUp,'r'); hold on
    plot(details.binStartStop(1,:),cDown,'b');
    plot([0 0],get(gca,'Ylim'),'k')
    ylabel('correct')
    title(subjects{s})
    
    subplot(1,2,2)
    plot(details.binStartStop(1,:),yUp,'r'); hold on
    plot(details.binStartStop(1,:),yDown,'b');
    plot([0 0],get(gca,'Ylim'),'k')
    ylabel('yes')
%%    
    %maybe I should return logicals into d for the 30 bin windows... then
    %use standard analaysis tools
            
    %conditioned on from contrast--> to contrast
    
    addPhase=0;  %doesn't really belong here
    if addPhase
        
        [stats CI names params]=getFlankerStats(subjects(s),'allBlockIDs&2Phases',{'pctCorrect','hits','CRs'},'12',dateRange); % ''pctCorrect', maybe denoise with 'hits'
        
        %plot(1:sum(params.factors.alignedPhase),stats( params.factors.alignedPhase),'r.'); hold on
        %plot(1:sum(params.factors.alignedPhase),stats(~params.factors.alignedPhase),'b.'); hold on
        diffEdges=[];
        multiComparePerPlot=false;
        [delta CI]=viewFlankerComparison(names,params,[],[],[],diffEdges,[],true,true,[],multiComparePerPlot, [], true);
        
        [stats CI names params]=getFlankerStats({'231','234'},'colin-other',{'CRs'},'12',dateRange); % ''pctCorrect', maybe denoise with 'hits'
        [delta CI]=viewFlankerComparison(names,params,{1,2},[],[],diffEdges,[],true,true,[],multiComparePerPlot, [], true);
    end
end


%d=getSmalls(subjects{s});
%d=removeSomeSmalls(d,isnan(d.blockID));
%[c names haveData colors]=getFlankerConditionInds(d,getGoods(d,'withoutAfterError'),'allBlockSegments');
