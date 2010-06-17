%contrastContrastWork
clear all
%%

subjects={'234'}%,'231'} % all colin, many target contrasts on 12, or many flanker onctrasts on 15, or joint contrast on colinear on 16
dateRange= [pmmEvent('firstBlocking')+2 pmmEvent('231&234-jointSweep')]; filter{1}.type='12';
dateRange= [pmmEvent('231&234-jointSweep')+1 pmmEvent('231-test200msecDelay')]; filter{1}.type='16';
%dateRange= [pmmEvent('231&234-SOA')+1 now]; filter{1}.type='18'; % 12 15 16 18
%dateRange= [pmmEvent('231&234-differentSOAtimes') now]
conditionType='allBlockIDs';
factor='targetContrast';
%%
figure
%filter{2}.type='nCorrectInARowCandidate'
%filter{2}.parameters.range=[5]; 

for s=1:length(subjects)
    
    d=getSmalls(subjects{s},dateRange)

    d=addYesResponse(d);
    d=removeSomeSmalls(d,isnan(d.blockID));
    %[stats CI names params]=getFlankerStats(subjects(s),conditionType,{'pctCorrect'},filter,dateRange);
    %doBarPlotWithStims(100*stats,100*reshape(CI,[],2),[],params.colors,[40 100],'stats&CI');
    
    [stats CI names params]=getFlankerStats(subjects(s),conditionType,{'hits','CRs','yes','pctCorrect'},filter,dateRange);
    
    
    %change from grades of red to jet
    params.colors=repmat(jet(5),4,1); %use color code from above
    
    % connect constant flankers with arrows
    conditions=[]; % all
    c=names.conditions;
    k=2;
    arrows={c{1},c{6},k; c{6},c{11},k; c{11},c{16},k;...
        c{2},c{7},k; c{7},c{12},k; c{12},c{17},k;...
        c{3},c{8},k; c{8},c{13},k; c{13},c{18},k;...
        c{4},c{9},k; c{9},c{14},k; c{14},c{19},k;...
        c{5},c{10},k; c{10},c{15},k; c{15},c{20},k}
    
    doHitFAScatter(stats,CI,names,params,subjects(s),conditions,0,0,0,0,0,1,arrows);  % note bias - say yes more when close
    title(subjects{s})
end

cleanUpFigure
set(gcf,'Position',[50 50 800 400])

%% th idea beind the model

%g=binomial
%ih=1-g*b % irrelevant hit
%ih=1-g*b % irrelevant hit 


%% 
 


