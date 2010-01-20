function viewBlockedData()%(d,subjects)

if ~exist('d','var') || isempty(d)
    group=1;
    switch group
        case 0
            subjects={'277'} % test any one
        case 1
            subjects={'231','234'} % all colin, many target contrasts on 12, or many flanker onctrasts on 15, or joint contrast on colinear on 16
        case 2
            subjects={'227', '229', '230', '237', '232', '233'}; %many flank types, 5 contrasts
        case 3
            subjects={'138','139', '228','277'}; %many flanks, one contrast  -- can these be directly compared to interleaved trials?
    end
end

%quick set params
if all(ismember(subjects,{'231','234'}))
    dateRange= [pmmEvent('firstBlocking')+2 pmmEvent('231&234-jointSweep')]; filter{1}.type='12'; 
    dateRange= [pmmEvent('231&234-jointSweep')+1 pmmEvent('231-test200msecDelay')]; filter{1}.type='16';
    dateRange= [pmmEvent('231&234-SOA')+1 now]; filter{1}.type='18'; % 12 15 16 18
   dateRange= [pmmEvent('231&234-differentSOAtimes') now]
elseif  all(ismember(subjects,{'227', '229', '230', '237', '232', '233'}))
    dateRange= [pmmEvent('startBlocking10rats')+2 now];
    %dateRange= [pmmEvent('231&234-jointSweep')+1 now];
    filter{1}.type='12';
    %filter{2}.type='trialThisBlockRange';  % could clean up some, but
    %reduces power if you rmeove to many... maybe 10 trials?
    %filter{2}.parameters.range=[10 150];
elseif  all(ismember(subjects,{'138','139', '228','277'}))
    dateRange= [pmmEvent('startBlocking10rats')+2 pmmEvent('patternRatsDelay')];
    filter{1}.type='11';
else
    subjects
    error('don''t have an auto date range for that rat, or rats span group types')
end

switch filter{1}.type
    case {'11','12'}
        conditionType='allBlockIDs';
        %conditionType='4flanksBlocked';  % not yet
        factor='targetContrast';
    case {'15'}
        conditionType='allBlockIDs';
        factor='flankerContrast';
    case {'16'}
        conditionType='allBlockIDs';
        factor='targetContrast';  % at actually both, but we will show target Contrast
    case {'18'}
        conditionType='allSOAs';
        factor='SOA';  %will analyze most frequent SOA, but label is 1st rounded SOA
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
        set(gca,'xTickLabel',unique(seg_params.factors.(factor))); % this only works b/c we used acsending target contrasts
        xlabel(sprintf('blocks, guessing they are %s',factor))
        title(subjects{s})
        
        
                %%

                %%
                %close all
                if 0 % reaction time per block
%                     subjects={'231','234'} % all colin, many target contrasts on 12, or many flanker onctrasts on 15, or joint contrast on colinear on 16
%                     conditionType='allBlockIDs'
%                     conditionType='fiveFlankerContrastsFullRange'
%                     conditionType='allPhantomTargetContrastsCombined'; %'allTargetContrasts'
%                     filter{1}.type='16';
%                     dateRange= [pmmEvent('231&234-jointSweep')+1 datenum('28-Oct-2009')]; % end on first analysis date
%                     [stats CI names params]=getFlankerStats(subjects(s),conditionType,{'RT'},filter,dateRange);
%                     
                    



                    %[stats CI names params]=getFlankerStats(subjects(s),conditionType,{'RT'},filter,dateRange);
                    

                    f1=figure;
                    f2=figure;
                    w=3; h=3;
                    for i=1:length(names.rtCategories)
                        mn=params.RT.mean(:,:,i);
                        std=params.RT.std(:,:,i);
                        fast=params.RT.fast(:,:,i);
                        ci=[mn-std;  mn+std ]';  % big;  could use SEM
                        ci=[mn;  mn]'; % doing nothing
                        figure(f1); subplot(h,w,i);   doBarPlotWithStims(mn,ci,[],params.colors,[1 2.2],'stats&CI',false);
                        
                        %ci=[fast;  fast]';
                        %figure(f2); subplot(w,h,i);   doBarPlotWithStims(fast,ci,[],params.colors,[0.7 1.1],'stats&CI',false);
                        title(names.rtCategories{i})
                    end
                    
                    
                    As=[4 6 9]
                    Bs=[5 8 7]
                    w=length(As); h=1;
                    for i=1:length(As)
                        aID=As(i); 
                        bID=Bs(i); 
                        A=params.RT.mean(:,:,aID);
                        B=params.RT.mean(:,:,bID);
                        metric=(A-B)./((A+B)/2)
                        ci=[metric;  metric]';
                        
                        er=sqrt(...
                            (params.RT.std(:,:,aID).^2/params.raw.numMisses) + ... %params.raw.numMisses is only a rough guess ... atcual values should use the appropriate observations for that type, but this breaks the for loop, or requires a "switch" on type
                            (params.RT.std(:,:,bID).^2/params.raw.numMisses))
                        ci=[metric-er/2;  metric+er/2]';
                        figure(f2); subplot(h,w,i);   doBarPlotWithStims(metric,ci,[],params.colors,[-0.5 0.5],'stats&CI',false);
                        title(sprintf('%s-%s',names.rtCategories{aID},names.rtCategories{bID}))
                    end
                    subplot(h,w,1); xlabel('say yes faster')
                    subplot(h,w,2); xlabel('...not b/c of hits')
                    subplot(h,w,3); xlabel('...but b/c of fast FA')
                    
                    subplot(h,w,2); xlabel('...b/c of fast hits')
                    subplot(h,w,3); xlabel('...despite slow FA')
                end 
 
        

        %%
        if 0
            %future: performance "trialPerBlock"
            figure;
            transitionFilters=[1 2 3 4 5 6 7 Inf]; %1 for up by 1 or inf for ALL ups
            %transitionFilters=[ Inf]; %1 for up by 1 or inf for ALL ups
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
