function viewBlockedData(subjects)

if ~exist('d','var') || isempty(d)
    group=0;
    switch group
        case 0
            subjects={'227'} % test any one
        case 1
            subjects={'231','234'} % all colin, many target contrasts
        case 2
            subjects={'227', '229', '230', '237', '232', '233'}; %many flank types, 5 contrasts
        case 3
            subjects={'138','139', '228','277'}; %many flanks, one contrast
    end
end

%quick set params
if all(ismember(subjects,{'231','234'}))
    dateRange= [pmmEvent('firstBlocking')+2 now]
    conditionType='allBlockIDs';
    filter{1}.type='12';
elseif  all(ismember(subjects,{'227', '229', '230', '237', '232', '233'}))
    dateRange= [pmmEvent('startBlocking10rats')+2 now]
    conditionType='allBlockIDs';
    filter{1}.type='12';
elseif  all(ismember(subjects,{'138','139', '228','277'}))
    dateRange= [pmmEvent('startBlocking10rats')+2 now]
    conditionType='allBlockIDs';
    conditionType='4flanksBlocked';
    filter{1}.type='11';
else
    subjects
    error('don''t have an auto date range for that rat, or rats span group types')
end

try
    for s=1:length(subjects)
        
        figure;
        d=getSmalls(subjects{s},[dateRange]);
        d=removeSomeSmalls(d,isnan(d.blockID));
        subplot(1,2,1);
        doPlotPercentCorrect(d)
        d=addYesResponse(d);
        
        subplot(1,2,2);
        %bar for that blockID
        
        
        %filter{2}.type='trialThisBlockRange';
        %filter{2}.parameters.range=[50 Inf];
        [stats CI names params]=getFlankerStats(subjects(s),conditionType,{'pctCorrect'},filter,dateRange);
        doBarPlotWithStims(100*stats,100*reshape(CI,[],2),[],params.colors,[40 100],'stats&CI');
        
        %dot for each
        [seg_stats seg_CI seg_names seg_params]=getFlankerStats(subjects(s),'allBlockSegments',{'pctCorrect'},filter,dateRange);
        
        %quick fix for nan block on end
        blockID=seg_params.factors.blockID;
        if length(seg_stats)~=length(blockID)
            if length(blockID)< length(seg_stats)
                blockID(end+1:length(seg_stats))=nan;  % fill in with nans for plotting to still work
            else
                sblockID
                length(seg_stats)
                length(blockID)
                error('never seen that before!')
            end
        end
        
        offset=0.25;% for viewing
        plot(blockID+offset,100*seg_stats,'k.')
        set(gca,'xtick',unique(blockID));
        set(gca,'xTickLabel',unique(seg_params.factors.targetContrast)); % this only works b/c we used acsending target contrasts
        xlabel('blocks, guessing they are target contrast')
        title(subjects{s})
        
        %%
        if 0
            %future: performance "trialPerBlock"
            figure;
            transitionFilters=[1 2 3 4 5 6 7 Inf]; %1 for up by 1 or inf for ALL ups
            transitionFilters=[ Inf]; %1 for up by 1 or inf for ALL ups
            n=length(transitionFilters);
            for t=1:n
                transitionFilter=transitionFilters(t);
                trialsBeforeAfter=[50 150];
                trialsPerBin=5;
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
                
                subplot(n,2,2*(t-1)+1)
                plot(details.binStartStop(1,:),cUp,'r'); hold on
                plot(details.binStartStop(1,:),cDown,'b');
                plot([0 0],get(gca,'Ylim'),'k')
                ylabel('correct')
                title(subjects{s})
                
                subplot(n,2,2*(t-1)+2)
                plot(details.binStartStop(1,:),yUp,'r'); hold on
                plot(details.binStartStop(1,:),yDown,'b');
                plot([0 0],get(gca,'Ylim'),'k')
                ylabel('yes')
            end
            set(gcf,'Position',[10 40 550 1000])
        end
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
    
catch ex
    getReport(ex)
    'oops!'
    keyboard
end

%d=getSmalls(subjects{s});
%d=removeSomeSmalls(d,isnan(d.blockID));
%[c names haveData colors]=getFlankerConditionInds(d,getGoods(d,'withoutAfterError'),'allBlockSegments');
