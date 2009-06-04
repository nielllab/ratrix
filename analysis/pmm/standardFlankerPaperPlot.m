function standardFlankerPaperPlot(figID)


if ~exist('figID','var') || isempty(figID)
    figID=[2 3 4 7]; % 6
    %figID=[4 7];  % test one of them
end

if ~exist('dateRange','var')
    dateRange=[0 pmmEvent('endToggle')];
end

if ~exist('statTypes','var')
    statTypes={'pctCorrect','CRs','hits','dpr','yes'};
end

if ~exist('subjects','var')
    %subjects={'138','228'}; % quick for testing
    subjects={'228','227','230','233','234','138','139'}; %sorted for amount
end

if ~exist('savePath','var')
    savePath='C:\Documents and Settings\rlab\Desktop\graphs';
end



if any(ismember(figID,7))
    addFig7=true;
    figID(figID==7)=[]; %remove it from the standard list
else
    addFig7=false;
end

includeModel=0;
addBarIms=0;  % when false uses fll ims as a fig
addSingleRatPerformance=1;
addFig5=0; %still outside


for f=1:length(figID)
    or=(pi/12);
    singleRat='138';     % use for single rat plot
    
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
            sweptImageValues={or,or,or,1,[0 1]};
            borderColor=[.2 .5 .2; 1 0 0];
            montageSize=[1 2];
            montageReorder=[2 1];
            barImageOrder=[2 1 1];
                        
                
            filter{1}.type='9.4.1+nf';              % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            conditionType='8flanks+&nfMix&nfBlock'  % use the + which groups the base 8 types and gives them a condition name.
            useConds={'other','noFm','noFb'};       % display these conditions
            condRename={'flank','noFmix','noFblk'};     % rename them this way
            colors=[1 0 0; .2 .5 .2; .2 .2 .5];     % assign these colors
            %cMatrix={[13],[14]};                   % emphasize this comparison, calculate it from first arrow
            arrows={'noFb','other',2}; %...           % arrows from A-->B
                %'noFm','noFb'};                   % extra line
             ROCuseConds={'noFb','other'};
            ylab=[50 75 100];
            diffEdges=linspace(-25,25,10);
        case 3
            %images
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
            or=[-1 1]*(or);
            sweptImageValues={or,or(1),or(1),1,1};
            borderColor=[1 0 0; 0 1 1];
            montageSize=[1 2];
            montageReorder=[1 2];
            barImageOrder=montageReorder;
            
            filter{1}.type='9.4';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            conditionType='8flanks+';               % lump popout and non-popout groups
            useConds={'colin','changeFlank'};       % display these conditions
            condRename={'col','pop1'};              % rename them this way
            colors=[1 0 0; 0 1 1];                  % assign these colors
            %cMatrix={[9],[10]};                     % emphasize this comparison, calculate it from first arrow
            arrows={'changeFlank','colin'};          % arrows from A-->B
            ROCuseConds=arrows;
            ylab=[50 60 70 80];
            diffEdges=linspace(-5,5,10);
                        
            %INCLUDES PARA AND POP2:
            
            %sweptImageValues={or,or,or(1),1,1};
            %...etc for image params
            %conditionType='popVsNot'                % lump popout and non-popout groups
            %useConds={'not','pop'};                 % display these conditions
            %condRename={'sameOr','popOut'};              % rename them this way
            %colors=[1 0 0; 0 1 1];                  % assign these colors
            %cMatrix={[1],[2]};                      % emphasize this comparison, calculate it from first arrow
            %arrows={'not','pop'};                    % arrows from A-->B
            %ylab=[50 60 70 80];
        case 4
            %images
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
            or=[-1 1]*(or);
            sweptImageValues={or,or,or(1),1,1};
            borderColor=[1 0 0; 0 1 1; 0 1 1; .1 .1 .1];
            montageSize=[1 4];
            montageReorder=[1 4 2 3];
            barImageOrder=montageReorder;
            
            filter{1}.type='9.4';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            conditionType='8flanks+';               % lump popout and non-popout groups
            useConds={'colin','para','changeFlank','changeTarget'};  % display these conditions
            condRename={'col','para','pop1','pop2'};% rename them this way
            colors=[1 0 0; 0 0 0; 0 1 1; 0 1 1];                     % assign these colors
            %cMatrix={[1],[2]};                      % emphasize this comparison, calculate it from first arrow
            arrows={'para','colin'};          % arrows from A-->B
            ROCuseConds=arrows;
            ylab=[50 60 70 80];
            diffEdges=linspace(-5,5,10);
        case 6
            %phase
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast','flankerPhase'}; % why does contrast have to be last?

            sweptImageValues={or,or,or,1,1,[0 pi]};
            borderColor=[1 0 0; 0 0 1];
            montageSize=[1 2];
            montageReorder=[1 2];
            barImageOrder=montageReorder;
            
            filter{1}.type='9.4';                      % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            conditionType='colin-other';               % lump popout and non-popout groups
            useConds={'colinear', 'phaseRev'};         % display these conditions
            condRename={'phaseReverse','phaseAllign'}; % rename them this way
            colors=borderColor;                        % assign these colors
            %cMatrix={[1],[2]};                        % emphasize this comparison, calculate it from first arrow
            arrows=useConds;                           % arrows from A-->B
            ROCuseConds={'phaseRev','colinear',};
            ylab=[50 60 70 80];
            diffEdges=linspace(-5,5,10);
            
        case -4 % not useful; just reduces power by restricting phase
            %images
            sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
            or=[-1 1]*(or);
            sweptImageValues={or,or,or(1),1,1};
            borderColor=[1 0 0; 0 1 1; 0 1 1; 0 0 0];
            montageSize=[2 2];
            montageReorder=[1 2 4 3];
            
            filter{1}.type='9.4';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
            conditionType='colin+3';                % lump popout and non-popout groups
            useConds={'---','lll','l-l','-l-'};     % display these conditions
            condRename={'col','para','pop1','pop2'};% rename them this way
            colors=[1 0 0; 0 0 0; 0 1 1; 0 1 1];    % assign these colors
            %cMatrix={[1],[2]};                     % emphasize this comparison, calculate it from first arrow
            arrows={'lll','---'};                   % arrows from A-->B
            ylab=[50 60 70 80];
            
        case -99 % lard
            %colors=[1 0 0; .8 1 1; .8 1 1; .6 .6 .6; .2,.2,.2; 0 1 .5; 0 1 .8];
        otherwise
            figID
            error('bad figID')
    end
    
    % OPTIONS: add filters to end of main filter
    
    % GET IMAGES
    [images]=getStimSweep(sweptImageParameters,sweptImageValues,borderColor);
    
    
    % GET STATS
    [stats CI names params]=getFlankerStats(subjects,conditionType,statTypes,filter,dateRange);
    
    % assign names and colors for calls below
    labeledNames=assignLabeledNames(subjects);
    
    cMatrix{1}=find(strcmp(names.conditions,arrows{1,1}));
    cMatrix{2}=find(strcmp(names.conditions,arrows{1,2}));
    
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
        set(gca,'Visible','on','box','on')
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
        doBarPlotWithStims(p,ci,barIms,colors,[50 max(ylab)],'stats&CI',false)
        title(sprintf('single rat performance (%s)',labeledNames{find(strcmp(singleRat,subjects))}));
        set(gca,'xTick',[1:length(usedConditionIDs)]); set(gca,'xTickLabel',condRename)
        ylabel('pctCorrect'); set(gca,'yTick',ylab); set(gca,'yTickLabel',ylab)
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
    ylabel('pctCorrect'); set(gca,'yTick',ylab); set(gca,'yTickLabel',ylab)
    set(gca,'yLim',[50 max(ylab)]); axis square;
    
    %SUBPLOT: emphasize comparison
    si=si+1; subplot(sx,sy,si);
    alpha=0.05;
    doFigAndSub=false;
    addTrialNums=false;
    addNames=labeledNames;
    multiComparePerPlot=false;
    objectColors.histSig=colors(find(strcmp(useConds,names.conditions(cMatrix{2}))),:); % use the color of the first comparison
    objectColors.histInsig=[0 0 0];
    objectColors.subjectSig=objectColors.histSig;
    objectColors.subjectInsig=[0 0 0];
    viewFlankerComparison(names,params,cMatrix,{'pctCorrect'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors)
    title('difference in pctCorrect');
    xlabel(sprintf('pct(%s) - pct(%s)', cMatrixNames{1},cMatrixNames{2}))
    ylabel('         count     rat ID');
    axis square;
    
    
    set(figID(f),'Position',[0 40 800 640])
    settings.fontSize=7;
    cleanUpFigure(figID(f),settings)
    filename=sprintf('paperFig_%d',figID(f));
    saveas(gcf,fullfile(savePath,filename),'bmp')
    
    
    if addFig5
        
        
    end
    
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
        subplot(3,2,(2*ff)+1); doHitFAScatter(stats,CI,names,params,subjects,ROCuseConds,doLegend,doCurve,doYesLine,doCorrectLine,sideText,doErrorBars,arrows)
           
        
        objectColors.histSig=[1 0 0];
        objectColors.subjectSig=objectColors.histSig;
        subplot(6,4,(ff*8)+3); viewFlankerComparison(names,params,cMatrix,{'hits'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); axis square;
        subplot(6,4,(ff*8)+4); viewFlankerComparison(names,params,cMatrix,{'CRs'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); axis square;
        subplot(6,4,(ff*8)+7); viewFlankerComparison(names,params,cMatrix,{'yes'},subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); axis square;
        subplot(6,4,(ff*8)+8); viewFlankerComparison(names,params,cMatrix,{'dpr'},subjects,[],alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot,objectColors,displaySignificance); axis square;
        
        set(gcf,'Position',[0 40 700 1040])
        filename=sprintf('paperFig_%d',7);
        saveas(gcf,fullfile(savePath,filename),'bmp')
    end
    
end


end
