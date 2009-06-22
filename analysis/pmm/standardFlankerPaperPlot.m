function done=standardFlankerPaperPlot(figID)


done=0; 

if ~exist('figID','var') || isempty(figID)
    figID=[2 3 4 5 7]; % 6
    %figID=[2 7];  % test one of them
end

if ~exist('dateRange','var')
    dateRange=[0 pmmEvent('endToggle')];
end

if ~exist('statTypes','var') 
    statTypes={'pctCorrect','CRs','hits','dpr','yes','crit','dprimeMCMC','criterionMCMC'}; % full, requires WINBUGs to be installed... try without MCMC if you need to 
    statTypes={'pctCorrect','CRs','hits','dpr','yes','crit'}; % faster, but no error bars on dprim stats
end

if ~exist('subjects','var')
    subjects={'228','227','230','233','234','138','139'}; %sorted for amount
    %subjects={'138','228','230','233'}; % quick for testing, passes lillie-test
    %subjects={'138','228'}; % quick for testing
end

if ~exist('savePath','var')
    savePath='C:\Documents and Settings\rlab\Desktop\graphs';
end



if any(ismember(figID,1))
    doFig1=true;
    figID(figID==1)=[]; %remove it from the standard list
else
    doFig1=false;
end

if any(ismember(figID,7))
    addFig7=true;
    figID(figID==7)=[]; %remove it from the standard list
else
    addFig7=false;
end

if any(ismember(figID,7))
    addFig8=true;
    figID(figID==8)=[]; %remove it from the standard list
else
    addFig8=false;
end




includeModel=1;
addBarIms=1;  % when false uses fll ims as a fig
addSingleRatPerformance=1;



if doFig1
%% timeline
    subject='234'
    LearningDateRange=[datenum('21-Jun-2008') datenum('19-Oct-2008')]
    figure(1)
    subplot(2,1,1)
    d=getSmalls(subject)
    d=removeSomeSmalls(d,~ismember(d.step,[5 6 7 8 9]))
    %d=removeSomeSmalls(d,d.currentShapedValue >0.32)
    d=removeSomeSmalls(d,d.trialNumber >30000) % don't show all the collection data.. takes up to much space
    d.step(d.currentShapedValue==0.4)=10;  % plot 9.4 as step 10, cuz thats what we call the data collection regime
    %min(d.trialNumber(d.currentShapedValue>0.29 & d.currentShapedValue<0.31) %19963
    d=removeSomeSmalls(d,d.currentShapedValue<0.29 & d.trialNumber>20000);  %this presrves the first 0.2's which go to 19962,  remove reset hiccup data.  i think this is fair 
    dayBoundary=false;
    doPlotPercentCorrect(d,[],200,0.75,[],[],dayBoundary,true,0,0,0,0)
    set(gca,'YTick',[0.34,0.5 0.75 1])
    set(gca,'YTickLabel',{'step:','50%','75%','100%'})
    steps=unique(d.step);
    nearestTrialNumberForGraduationMark=100; %100 or 1000 or 5000
    for i=1:length(steps)
        firstTrialPerStep(i)=min(find(d.step==steps(i)))
        roundedTrialNumber(i)=round(firstTrialPerStep(i)/nearestTrialNumberForGraduationMark)*nearestTrialNumberForGraduationMark;
        dayPerStep(i)=floor(d.date(firstTrialPerStep(i))-d.date(1));
    end
    plot(get(gca,'XLim'),[.5 .5],'k--') % chance line
    totalTrialNumber=floor(length(d.date)/nearestTrialNumberForGraduationMark)*nearestTrialNumberForGraduationMark;
    xTick=[roundedTrialNumber([1 2]) totalTrialNumber]
    set(gca,'XTick',xTick)
    set(gca,'XTickLabel',xTick)
    ylabel('% correct')
    totalDays=floor(d.date(end)-d.date(1));
    xlabel(sprintf('trial # (over %d days)',totalDays))
    title('training performance')
    
    subplot(2,1,2)
    sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast','mean','stdGaussMask','flankerOffset','pixPerCycs'}; % why does contrast have to be last?
    or=(pi/12);
    sweptImageValues={or,or,or,1,0,0.2,1/5,0,64;...
        or,or,or,0.6,0,0.5,1/5 ,0,64;...  0.6 target contrast is used to render close perception of linearized contrast
        or,or,or,0.6,0,0.5,1/5 ,0,32;...
        or,or,or,0.6,0,0.5,1/16,0,32;...
        or,or,or,0.6,0.6*0.1,0.5,1/16,3,32;...
        or,or,or,0.6,0.6*0.4,0.5,1/16,3,32}
    steps=[5:10];
    borderColors=jet(12);
    images=zeros(600,600,3,length(steps),'uint8');  % 'fullZoom600'
    for i=1:length(steps)
     [images(:,:,:,i)]=getStimSweep(sweptImageParameters,{sweptImageValues{i,:}},borderColors(steps(i),:),[],'fullZoom600');
    end
    montageSize=[1 length(steps)];
    montageReorder=[1 :length(steps)];
    montage(images(:,:,:,montageReorder),'DisplayRange',[0,255],'Size', montageSize);
    title('stimulus conditions')
    set(gcf,'Position',[10 410 1500 600])
    %xlim=get(gca,'xLim'); imCenters=linspace(xlim(1),xlim(2),length(steps)+2)
    %set(gca,'xTick',imCenters,'XTickLabel',{'a','b'})  %MONTAGE KILLS THE XTICK LABEL?
    %get(gca,'XTickLabel')
cleanUpFigure
  %%
      %%
    sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
    sweptImageValues={or,or,or,1,[1 0]}
    borderColors=jet(2);
     [images]=getStimSweep(sweptParameters,sweptImageValues,borderColors,[],'column');
    montageSize=[1 2];
    montageReorder=[1 2];
    montage(images(:,:,:,montageReorder),'DisplayRange',[0,255],'Size', montageSize);
    title('stimulus conditions')
            
end


for f=1:length(figID)
    or=(pi/12);
    singleRat='138';     % use for single rat plot
    subject='234';  %check this one out
    switch figID(f)
        case 1      
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
            sweptImageValues={or,or,or,1,0};
            borderColor=[0 0 0];
            montageSize=[1 1];
            montageReorder=[1];

            
            
            filter{1}.type='preFlankerStep';
            conditionType='noFlank'  % use the + which groups the base 8 types and gives them a condition name.
            useConds={'noFlank'};            % display these conditions
            condRename={'target only'};     % rename them this way
            colors=[.5 .5 .5];              % assign these colors
            cMatrix={[1],[1]};              % emphasize this comparison, calculate it from first arrow
            arrows=[];                      % arrows from A-->B      
            error('untested')
        case 2
            %images
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
            sweptImageValues={or,or,or,1,[1 0 0]};
            borderColor=[ .9 0 0; .2 .5 .2; .4 .9 .4];
            montageSize=[1 3];
            montageReorder=[1 2 3];
            barImageOrder=[1 2 3];
                        
            

            
%             conditionType='8flanks+&nfMix&nfBlock'  % use the + which groups the base 8 types and gives them a condition name.
%             useConds={'other','noFm','noFb'};       % display these conditions
%             arrows={'noFm','other',2}; %...           % arrows from A-->B
%             %'noFm','noFb'};                   % extra line
%             ROCuseConds={'noFm','other'};
            
            
            conditionType='hasFlank&nfMix&nfBlock';
            useConds={'hasF','noFm','noFb'};       % display these conditions
            arrows={'noFm','hasF',2}; %...           % arrows from A-->B
            %'noFm','noFb'};                         % extra line
            ROCuseConds={'noFm','hasF'};
            
            filter{1}.type='9.4.1+nf';              % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            condRename={'F+','F-','F-'}; % rename them this way
            barGroups={'mix',[1 2],[77]; 'block',[3],[79]}; % add grouped labels
            
            colors=[.9 0 0; .2 .5 .2; .4 .9 .4];     % assign these colors
            %cMatrix={[13],[14]};                   % emphasize this comparison, calculate it from first arrow
             
            ylab=[50 75 100];
            diffEdges=linspace(-20,20,11);
        case 3
            %images
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
            or=[-1 1]*(or);
            sweptImageValues={or,or(1),or(1),1,1};
            borderColor=[.9 0 0; 0 .8 .8 ];
            montageSize=[1 2];
            montageReorder=[1 2];
            barImageOrder=montageReorder;
            barGroups={}; % add grouped labels
            
            filter{1}.type='9.4';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
        
            fig3version=2;
            switch fig3version
                case 1
                    conditionType='8flanks+';               % lump popout and non-popout groups21
                    useConds={'colin','changeFlank'};       % display these conditions
                    condRename={'col','pop1'};              % rename them this way
                    colors=[.9 0 0; 0 .8 .8 ];                  % assign these colors
                    %cMatrix={[9],[10]};                     % emphasize this comparison, calculate it from first arrow
                    arrows={'changeFlank','colin'};          % arrows from A-->B
 
                case 2%INCLUDES PARA AND POP2:
                    %sweptImageValues={or,or,or(1),1,1};
                    %...etc for image params
                    conditionType='popVsNot'                % lump popout and non-popout groups
                    useConds={'not','pop'};                 % display these conditions
                    condRename={'iso-orient','pop-out'};              % rename them this way
                    colors=[.9 0 0; 0 .8 .8 ];                  % assign these colors
                    %cMatrix={[1],[2]};                      % emphasize this comparison, calculate it from first arrow
                    arrows={'pop','not'};                    % arrows from A-->B
            end
            
            ROCuseConds=arrows;
            ylab=[50 60 70 80];
            diffEdges=linspace(-5,5,11);
                    
        case 4
            %images
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
            or=[-1 1]*(or);
            sweptImageValues={or,or,or(1),1,1};
            borderColor=[.9 0 0; 0 .8 .8 ; 0 .8 .8 ; .1 .1 .1];
            montageSize=[1 4];
            montageReorder=[1 4 2 3];
            barImageOrder=montageReorder;
            barGroups={}; % add grouped labels
            
            filter{1}.type='9.4';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            conditionType='8flanks+';               % lump popout and non-popout groups
            useConds={'colin','para','changeFlank','changeTarget'};  % display these conditions
            condRename={'col','para','pop1','pop2'};% rename them this way
            colors=[.9 0 0; 0 0 0; 0 .8 .8 ; 0 .8 .8 ];                     % assign these colors
            %cMatrix={[1],[2]};                      % emphasize this comparison, calculate it from first arrow
            arrows={'para','colin'};          % arrows from A-->B
            ROCuseConds=arrows;
            ylab=[50 60 70 80];
            diffEdges=linspace(-5,5,11);
        case 5
            %phase
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast','flankerPhase'}; % why does contrast have to be last?

            sweptImageValues={or,or,or,1,1,[0 pi]};
            borderColor=[.9 0 0; 0 0 1];
            montageSize=[1 2];
            montageReorder=[1 2];
            barImageOrder=montageReorder;
            barGroups={}; % add grouped labels
            
            filter{1}.type='9.4';                      % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            conditionType='colin-other';               % lump popout and non-popout groups
            useConds={'colinear','phaseRev'};         % display these conditions
            condRename={'same','reverse'}; % rename them this way
            colors=borderColor;                        % assign these colors
            %cMatrix={[1],[2]};                        % emphasize this comparison, calculate it from first arrow
            arrows=useConds;                           % arrows from A-->B
            ROCuseConds={'phaseRev','colinear',};
            ylab=[50 60 70 80];
            diffEdges=linspace(-5,5,11);
            
        case -4 % not useful; just reduces power by restricting phase
            %images
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
            or=[-1 1]*(or);
            sweptImageValues={or,or,or(1),1,1};
            borderColor=[.9 0 0; 0 .8 .8 ; 0 .8 .8 ; 0 0 0];
            montageSize=[2 2];
            montageReorder=[1 2 4 3];
            barGroups={}; % add grouped labels
            
            filter{1}.type='9.4';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            conditionType='colin+3';                % lump popout and non-popout groups
            useConds={'---','lll','l-l','-l-'};     % display these conditions
            condRename={'col','para','pop1','pop2'};% rename them this way
            colors=[.9 0 0; 0 0 0; 0 .8 .8 ; 0 .8 .8 ];    % assign these colors
            %cMatrix={[1],[2]};                     % emphasize this comparison, calculate it from first arrow
            arrows={'lll','---'};                   % arrows from A-->B
            ylab=[50 60 70 80];
            
        case -99 % lard
            %colors=[.9 0 0; .8 1 1; .8 1 1; .6 .6 .6; .2,.2,.2; 0 1 .5; 0 1 .8];
        otherwise
            figID
            error('bad figID')
    end
    
    % OPTIONS: add filters to end of main filter
    
    % GET IMAGES
     antiAliasing=false;
     useSymbolicFlanker=false;
    [images]=getStimSweep(sweptImageParameters,sweptImageValues,borderColor,[],'column',false,antiAliasing,useSymbolicFlanker);
    
    
    % GET STATS
    [stats CI names params]=getFlankerStats(subjects,conditionType,statTypes,filter,dateRange);
    
    % assign names and colors for calls below
    labeledNames=assignLabeledNames(subjects);
    
    cMatrix{1}=find(strcmp(names.conditions,arrows{1,2}));
    cMatrix{2}=find(strcmp(names.conditions,arrows{1,1}));
    
    cMatrixNames{1}=condRename{find(strcmp(useConds,arrows{1,1}))};
    cMatrixNames{2}=condRename{find(strcmp(useConds,arrows{1,2}))};
    
    % overwrite default colors with chosen colors... could turn this off...
    usedConditionIDs=[];
    for c=1:length(useConds)
        usedConditionIDs(c)=find(strcmp(useConds(c),names.conditions));
    end
    params.colors(usedConditionIDs,:)=colors; % this can now be used in doHitFAScatter
    
    
    
    % SET UP PLOTS
    figure(figID(f));
    sx=2;sy=2;si=0;
    
    if includeModel
        %SUBPLOT: model
        si=si+1; subplot(sx,sy,si);
        %modelName=sprintf('Model %s',63+figID(f));
        %text(.5,.5,modelName)
        axis square;
        set(gca,'Visible','off','box','on')
        set(gca,'xTick',[]); set(gca,'xTickLabel',[]);
        set(gca,'yTick',[]); set(gca,'yTickLabel',[]);
    end
    
    %SUBPLOT: stims
    if addBarIms
        for i=1:length(barImageOrder)
            barIms{i}=images(:,:,:,barImageOrder(i))
        end
    else
        si=si+1; subplot(sx,sy,si);
        montage(images(:,:,:,montageReorder),'DisplayRange',[0,255],'Size', montageSize);
        title('stimulus conditions')
        %axis square;
        barIms=[];
    end
    
    if addSingleRatPerformance
        %SUBPLOT: single rat performance
        si=si+1; subplot(sx,sy,si);
        p=100*stats(strcmp(singleRat,names.subjects),usedConditionIDs,find(strcmp('pctCorrect',names.stats)));
        ci= 100*CI(strcmp(singleRat,names.subjects),usedConditionIDs,find(strcmp('pctCorrect',names.stats)),[1:2]);
        ci=reshape(ci(:),length(usedConditionIDs),2);
        doBarPlotWithStims(p,ci,barIms,colors,[50 max(ylab)],'stats&CI',false,barGroups)
        title(sprintf('single rat performance (%s)',labeledNames{find(strcmp(singleRat,subjects))}));
        set(gca,'xTick',[1:length(usedConditionIDs)]); set(gca,'xTickLabel',condRename)
        ylabel('percent correct  (P)'); set(gca,'yTick',ylab); set(gca,'yTickLabel',ylab)
        set(gca,'yLim',[50 max(ylab)]); axis square;
    end
    
    %SUBPLOT: group performance
    si=si+1; subplot(sx,sy,si);
    p=100*stats(:,usedConditionIDs,find(strcmp('pctCorrect',names.stats)));
    stat=mean(p);
    ci=[stat; stat]+[-1; 1]*std(p);
    nc=length(usedConditionIDs);
    %doBarPlotWithStims(stat,ci',[],colors,[50 75],'stats&CI',false) % with std error bar
    %doBarPlotWithStims(stat,[stat; stat]',[],colors,[55 70],'stats&CI',false) % no error bar
    hold on;
    axis([0 nc+1 50 100])
    if 1 % add connector per subject
        offset=0.0;
        if 0 % add connector for some subjects
            
            %worst
            y2=100*stats(find(y==min(y)),usedConditionIDs,find(strcmp('pctCorrect',names.stats)));
            plot([1:nc]+offset,y2,'k--')
            %best
            y2=100*stats(find(y==max(y)),usedConditionIDs,find(strcmp('pctCorrect',names.stats)));
            plot([1:nc]+offset,y2,'k--')
            %fig a
            y2=100*stats(strcmp(singleRat,names.subjects),usedConditionIDs,find(strcmp('pctCorrect',names.stats)));
            plot([1:nc]+offset,y2,'k--')
        elseif 1 % add connector for all subjects
            for j=1:size(stats,1) % subjects
                subId=find(strcmp(subjects(j),names.subjects));
                y2=100*stats(subId,usedConditionIDs,find(strcmp('pctCorrect',names.stats)));
                plot([1:nc]+offset,y2,'k--')
                switch labeledNames{j}
                    case {'r3','r1','r7','r5','r2'}
                        text(nc+0.3, y2(end),labeledNames(j)) %label subjects
                    case {'r1'}
                        text(0.2, y2(1)-0.7,labeledNames(j)) %label subjects
                    otherwise
                        text(0.2, y2(1),labeledNames(j)) %label subjects
                end
            end
        end
    end
    
    %add scatter for subjects
    for j=1:size(stats,1) % subjects
        for i=1:length(usedConditionIDs)
            x=repmat(i+offset,1,length(names.subjects));
            y=100*stats(:,usedConditionIDs(i),find(strcmp('pctCorrect',names.stats)));
            d=plot(x(j),y(j),'.','MarkerSize',20,'color',colors(i,:));
            %set(d,'MarkerEdgeColor','b','MarkerFaceColor','r')
        end
    end
    
    title(sprintf('all rats performance (N=%d)',length(subjects)));
    set(gca,'xTick',[1:length(usedConditionIDs)]); set(gca,'xTickLabel',condRename)
    ylabel('percent correct  (P)'); set(gca,'yTick',ylab); set(gca,'yTickLabel',ylab)
    set(gca,'yLim',[50 max(ylab)]); axis square;
    
    %SUBPLOT: emphasize comparison
    si=si+1; subplot(sx,sy,si);
    alpha=0.05;
    doFigAndSub=false;
    addTrialNums=true; % false!
    addNames=[]; labeledNames;
    multiComparePerPlot=false;
    objectColors.histSig=[.2 .2 1]; % use dark blue always
    %objectColors.histSig=colors(find(strcmp(useConds,names.conditions(cMatrix{2}))),:); % use the color of the first comparison
    objectColors.histInsig=[.8 .8 .8];
    objectColors.subjectSig=objectColors.histSig;
    objectColors.subjectInsig=objectColors.histInsig;
    displaySignificance=true;
    labelAxis=false;
    encodeSideRule=false;
    viewPopulationMeanAndCI=false;
    viewFlankerComparison(names,params,cMatrix,{'pctCorrect'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors, displaySignificance,labelAxis,encodeSideRule,viewPopulationMeanAndCI)
    title('difference in percent correct');
    xlabel(sprintf('P(%s) - P(%s)', cMatrixNames{1},cMatrixNames{2}))
    ylabel('         count     rat ID');
    axis square;

    
    
    set(figID(f),'Position',[0 40 800 640])
    settings.fontSize=13;
    settings.textObjectFontSize=7;
    cleanUpFigure(figID(f),settings)
    filename=sprintf('paperFig_%d',figID(f));
    saveas(gcf,fullfile(savePath,filename),'bmp')
 
    if addFig7
        figure(7)
        ff=figID(f)-2;
        doLegend=false;
        doCurve=false;
        doYesLine=false;
        doCorrectLine=false;
        sideText=false; %?
        doErrorBars=3; %ellipse
        displaySignificance=false;
        
        subplot(4,2,(2*ff)+1); doHitFAScatter(stats,CI,names,params,subjects,ROCuseConds,doLegend,doCurve,doYesLine,doCorrectLine,sideText,doErrorBars,arrows)
        title(sprintf('%s -> %s', cMatrixNames{1},cMatrixNames{2}))
        

%         subplot(8,4,(ff*8)+3); viewFlankerComparison(names,params,cMatrix,{'hits'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); axis square;
%         subplot(8,4,(ff*8)+4); viewFlankerComparison(names,params,cMatrix,{'CRs'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); axis square;
%         subplot(8,4,(ff*8)+7); viewFlankerComparison(names,params,cMatrix,{'yes'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); axis square;
%         subplot(8,4,(ff*8)+8); viewFlankerComparison(names,params,cMatrix,{'dpr'},subjects,[],alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); axis square;
       
        
        subplot(8,6,(ff*12)+4); viewFlankerComparison(names,params,cMatrix,{'pctCorrect'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); cleanMiniStat('correct')
        subplot(8,6,(ff*12)+5); viewFlankerComparison(names,params,cMatrix,{'yes'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); cleanMiniStat('yes')
        subplot(8,6,(ff*12)+6); viewFlankerComparison(names,params,cMatrix,{'hits'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); cleanMiniStat('hit')
        if any(ismember(names.stats,'dprimeMCMC')) && any(ismember(names.stats,'criterionMCMC')) 
            subplot(8,6,(ff*12)+10); viewFlankerComparison(names,params,cMatrix,{'dprimeMCMC'},subjects,[],alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); cleanMiniStat('d''')
            subplot(8,6,(ff*12)+11); viewFlankerComparison(names,params,cMatrix,{'criterionMCMC'},subjects,[],alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); cleanMiniStat('criterion')
        else
            subplot(8,6,(ff*12)+10); viewFlankerComparison(names,params,cMatrix,{'dpr'},subjects,[],alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); cleanMiniStat('d''')
            subplot(8,6,(ff*12)+11); viewFlankerComparison(names,params,cMatrix,{'crit'},subjects,[],alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); cleanMiniStat('criterion')
        end
        subplot(8,6,(ff*12)+12); viewFlankerComparison(names,params,cMatrix,{'CRs'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); cleanMiniStat('CR')
       
        
        set(gcf,'Position',[0 40 700 1040])
        filename=sprintf('paperFig_%d',7);
        saveas(gcf,fullfile(savePath,filename),'bmp')
    end


end

if addFig8
    %%
    figure(8)
    sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast','stdGaussMask','flankerOffset','pixPerCycs'}; % why does contrast have to be last?
    or=(pi/12);
    sweptImageValues={...or,or,or,0,0,0.5,1/16,0,32;...  
        or,or,or,0.6,0,1/16,0,32;... 0.6 target contrast is used to render close perception of linearized contrast
        -or,or,or,0.6,0.6,1/16,3,32;...
        or,-or,or,0.6,0.6,1/16,3,32;...
        -or,-or,or,0.6,0.6,1/16,3,32;...
        or,or,or,0.6,0.6,1/16,3,32}
    
    borderColors=[ 0 0 1; 0 .8 .8 ; 0 .8 .8 ; 0 0 0; .9 0 0];
    n=size(borderColors,1);
    images=zeros(500,300,3,n,'uint8');  % 'column'
    antiAliasing=false;
    useSymbolicFlanker=true;
    for i=1:n
     [images(:,:,:,i)]=getStimSweep(sweptImageParameters,{sweptImageValues{i,:}},borderColors(i,:),[],'column',false,antiAliasing,useSymbolicFlanker);
    end
    montageSize=[1 n];
    montageReorder=[1 :n];
    montage(images(:,:,:,montageReorder),'DisplayRange',[0,255],'Size', montageSize);
    set(gcf,'Position',[10 410 1500 600])
    %%
end

done=1;

function cleanMiniStat(statType)
title(['\Delta ' statType])
xlabel([])
ylabel([])
axis square;
        