function [delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix,statTypes,subjects,diffEdges,alpha,doFigAndSub,addTrialNums,addNames,multiComparePerPlot)
% params- from getFlankerStats
% names-  from getFlankerStats
% cMatrix- cell array 2xN numberComparison  example with N=1 comparison:
%   {[1],[2 3 4]} compares the 1st to the 2nd to 4th conditions lumped together
%   note: if using any MCMC stats, only one condition can be compared to
%   another (no group comparisons allowed-- have to define group and rerun ch)
%   defaults to one that makes sense for params.settings.conditionType == 8flanks or colin+3
% statTypes - defaults to the ones in names.stats without dprime
% statTypes - defaults to all ones in names.subjects, (if passed in, subjects must be in this list)
%
% delta - the differences between conditions for all rats combined
% CI    - the confidence interval between conditions for all rats combined
% deltas- the differences for each rat
% CIs   - confidence intervals for each rat
%
%example: [delta CI]=viewFlankerComparison(params,names)



if ~exist('params','var') || isempty(params)
    %usually this is passed in
    %get some default stats to run this code
    [junk1 junk2 names params]=getFlankerStats({'230','233'});
end


if ~exist('subjects','var') || isempty(subjects)
    subjects=names.subjects;
end

if ~exist('statTypes','var') || isempty(statTypes)
    statTypes=names.stats;
    %statTypes=statTypes(~strcmp(statTypes,'dpr')); %remove dprime
end
numStats=size(statTypes,2);


if ~exist('diffEdges','var') || isempty(diffEdges)
    createDefaultDiffEdges=true;
    nBins=10;
    diffEdges=nan(length(statTypes),nBins+1);
    %     minX=-6;
    %     maxX=6;
    %     diffEdges=linspace(minX,maxX,13);
    % else
    %     minX=min(diffEdges);
    %     maxX=max(diffEdges);
else
    createDefaultDiffEdges=false;
    minX=min(diffEdges);
    maxX=max(diffEdges);
    if size(diffEdges,1)==1
        diffEdges=repmat(diffEdges,numStats,1)
    end
end

if ~exist('alpha','var') || isempty(alpha)
    alpha=0.05;
end

if ~exist('doFigAndSub','var') || isempty(doFigAndSub)
    doFigAndSub=true;
end

if ~exist('addTrialNums','var') || isempty(addTrialNums)
    addTrialNums=true;
end

if ~exist('addNames','var') || isempty(addNames)
    addNames=false;
else
    if islogical(addNames)
        labeledNames=subjects; %will only be used if addNames = true.
    elseif strcmp(class(addNames),'cell') && length(addNames)==length(subjects)
        labeledNames=addNames; % cell array of strings
        addNames=true;
    else
        error('addNames must be true or false or cell array of strings, length subjects')
    end
end


if ~exist('multiComparePerPlot','var') || isempty(multiComparePerPlot)
    multiComparePerPlot=false;
end

conditionType=params.settings.conditionType;

if ~exist('cMatrix','var') || isempty(cMatrix)
    switch conditionType
        case 'colin+3'
            cMatrix={[1],[2];
                [1],[3];
                [1],[4];
                [1],[2,3,4];
                [2],[3];};
        case '8flanks'
            cMatrix={[1 8],[2 7];
                [1 8],[3 6];
                [1 8],[4 5];
                [1 8],[2:6];};
        case '8flanks+'
            cMatrix={[9],[10];
                [9],[12]};
        case {'8flanks+&nfBlock','8flanks+&nfMix'}
            cMatrix={[9],[10];
                [9],[14];
                [10],[14]};
        case {'noFlank&nfBlock'}
            cMatrix={[1],[2]};
        case {'colin+1&devs'}
            dimming=flipLR([1:4]/5)';
            cMatrix={[1],[2];
                [3],[4];
                [5],[6];
                [7],[8]};
            comparisonColor=dimming*[1 0 0];
%             cMatrix={[1],[8];
%                 [3],[8];
%                 [5],[8];
%                 [7],[8];
%                 [2],[8];
%                 [4],[8];
%                 [6],[8];
%                 [8],[8]};
%             comparisonColor=[dimming*[1 0 0]; dimming*[0 1 1]];
        otherwise
            conditionType
            error('this condition type has no default comparisons -- the must be specified in 3rd arg in ')
    end
end

numSubjects=length(subjects);
numComparison=size(cMatrix,1);

if ~exist('comparisonColor','var') || isempty(comparisonColor)
    comparisonColor=jet(numComparison);
end

if doFigAndSub
    figure
end

if numStats==1 || (multiComparePerPlot)
    squareStats=true
    %fill up a square of subplots
    disp('since only one stat or multiComparePerPlot, making a square marix of plots')
    disp('rather than ploting numComparisions x numStats')
else
    squareStats=false
    %force each stat to be colum, with rows being the same comparisoon and
    %different stats
end

CIs=zeros(numComparison,numStats,numSubjects,2);
deltas=zeros(numComparison,numStats,numSubjects);
numSamples=zeros(numComparison,numStats,numSubjects);

for k=1:numSubjects

    subjectInd=find(strcmp(subjects{k},names.subjects))';
    more.hits=params.raw.numHits(subjectInd,:)';
    more.misses=params.raw.numMisses(subjectInd,:)';
    more.CRs=params.raw.numCRs(subjectInd,:)';
    more.FAs=params.raw.numFAs(subjectInd,:)';
    more.numAttempted=params.raw.numAttempt(subjectInd,:)';
    more.numCorrect=params.raw.numCorrect(subjectInd,:)';

    for i=1:size(cMatrix,1)
        for j=1:size(statTypes,2)
            statInd=find(strcmp(statTypes{j},names.stats));
            switch statTypes{j}
                case {'pctCorrect', 'yes', 'hits', 'CRs'}
                    [deltas(i,j,k) CIs(i,j,k,1:2) numSamples(i,j,k)] = compareAtoBbinofit(more,cMatrix{i,1},cMatrix{i,2},statTypes{j},alpha);
                    deltas(i,j,k)=deltas(i,j,k)*100;
                    CIs(i,j,k,1:2)=CIs(i,j,k,1:2)*100;
                    xlabelStrings{j}=sprintf('change in %s',statTypes{j});
                case {'dpr','RT'}

                    deltas(i,j,k)=...
                        mean(params.stats(k,cMatrix{i,1},statInd))-... %difference
                        mean(params.stats(k,cMatrix{i,2},statInd));%works on the average of the statistics, not a weighed average

                    %                      deltas(i,j,k)=log(...     %beware: if negative dprime, log ratio gets imaginary numbers
                    %                         mean(params.stats(k,cMatrix{i,1},statInd))./...%log ratio
                    %                         mean(params.stats(k,cMatrix{i,2},statInd)));%works on the average of the statistics, not a weighed average

                    CIs(i,j,k,1:2)=nan;
                    numSamples(i,j,k)=sum(more.numAttempted([cMatrix{i,1} cMatrix{i,2}])); %unknown
                    xlabelStrings{j}=sprintf('change in %s',statTypes{j});
                case {'dprimeMCMC'}

                    if size(cMatrix{i,1},2)>1 || size(cMatrix{i,2},2)>1
                        a=cMatrix{i,1}
                        b=cMatrix{i,2}
                        conditionType
                        names.conditions
                        error('dprime can only compare single conditions, not groups-- you may need a new grouped condition')
                    end


                    theDiff=params.mcmc.samples{k,cMatrix{i,1},statInd}-params.mcmc.samples{k,cMatrix{i,2},statInd};
                    deltas(i,j,k)=median(theDiff);
                    sorted=sort(theDiff);
                    ciInds=round(size(sorted,2).*[alpha 1-alpha]);
                    CIs(i,j,k,1:2)=sorted(ciInds);
                    numSamples(i,j,k)=sum(more.numAttempted([cMatrix{i,1} cMatrix{i,2}]));
                    xlabelStrings{j}=sprintf('difference of %s',statTypes{j});

                    %                     sampleRatio=params.mcmc.samples{k,cMatrix{i,1},statInd}./params.mcmc.samples{k,cMatrix{i,2},statInd};
                    %                     if any(sampleRatio<0)
                    %                         find(sampleRatio<0)
                    %                         sum(sampleRatio<0)
                    %                         error('log of negatives will cause complex numbers')
                    %                     end
                    %                     logSampleRatio=log(sampleRatio);
                    %                     deltas(i,j,k)=median(logSampleRatio);
                    %                     sorted=sort(logSampleRatio);
                    %                     ciInds=round(size(sorted,2).*[alpha 1-alpha]);
                    %                     CIs(i,j,k,1:2)=sorted(ciInds);
                    %                     numSamples(i,j,k)=sum(more.numAttempted([cMatrix{i,1} cMatrix{i,2}]));
                    %                     xlabelStrings{j}=sprintf('log ratio of %s',statTypes{j});
                case {'biasMCMC', 'criterionMCMC'}

                    %param2==B minus param1==A just like in
                    %diffOfBino...WRONG! --> compareAtoBbinofit flips it back to the sensible A-B
                    sampleDiff=params.mcmc.samples{k,cMatrix{i,1},statInd}-params.mcmc.samples{k,cMatrix{i,2},statInd};
                    deltas(i,j,k)=median(sampleDiff);
                    sorted=sort(sampleDiff);
                    ciInds=round(size(sorted,2).*[alpha 1-alpha]);
                    CIs(i,j,k,1:2)=sorted(ciInds);
                    numSamples(i,j,k)=sum(more.numAttempted([cMatrix{i,1} cMatrix{i,2}]));
                    xlabelStrings{j}=sprintf('change in %s',statTypes{j});
                otherwise
                    statType
                    error('bad type');
            end
        end

        %generate name
        Aname=[cell2mat([names.conditions(cMatrix{i,1})]') repmat('&',length(cMatrix{i,1}),1)]';
        Aname=Aname(1:end-1);
        Bname=[cell2mat([names.conditions(cMatrix{i,2})]') repmat('&',length(cMatrix{i,2}),1)]';
        Bname=Bname(1:end-1);
        comparisonNames{i,1}=sprintf('(%s) - (%s)',Aname,Bname);

    end
end

%combined analysis
combined.hits=sum(params.raw.numHits,1)';
combined.misses=sum(params.raw.numMisses,1)';
combined.CRs=sum(params.raw.numCRs,1)';
combined.FAs=sum(params.raw.numFAs,1)';
combined.numAttempted=sum(params.raw.numAttempt,1)';
combined.numCorrect=sum(params.raw.numCorrect,1)';
for i=1:numComparison
    for j=1:numStats
        statInd=find(strcmp(statTypes{j},names.stats));
        if size(cMatrix{i,1},2)==1 && size(cMatrix{i,2},2)==1
            popStats=...
                (params.stats(:,cMatrix{i,1},statInd)'-...%difference
                params.stats(:,cMatrix{i,2},statInd)');   %works on the average of the statistics, not a weighed average
        else
            popStats=...
                mean(params.stats(:,cMatrix{i,1},statInd)')-...%difference
                mean(params.stats(:,cMatrix{i,2},statInd)');   %works on the average of the statistics, not a weighed average
        end
                
        switch statTypes{j}
            case {'pctCorrect', 'yes', 'hits', 'CRs'}
                [delta(i,j) CI(i,j,1:2)]=compareAtoBbinofit(combined,cMatrix{i,1},cMatrix{i,2},statTypes{j},alpha);
                delta(i,j)=delta(i,j)*100;
                CI(i,j,1:2)=CI(i,j,1:2)*100;
                statInd=find(strcmp(statTypes{j},names.stats));
                popStats=100*popStats;
                CI2(i,j,1:2)=mean(popStats) + [-1 1]*std(popStats); % delta+/- stdPop
                %disp(sprintf('uber: %2.2g %2.2g stds: %2.2g %2.2g',CI(i,j,1),CI(i,j,2),CI2(i,j,1),CI2(i,j,2)))
            case {'biasMCMC', 'criterionMCMC','dprimeMCMC','dpr','RT'}
                delta(i,j)=mean(popStats);
                stdPop=std(popStats);
                CI(i,j,1:2)=delta(i,j) + [-stdPop stdPop]; % delta+/- stdPop
            otherwise
                statTypes{j}
                error('bad type');
        end
    end
end


% %test
% combined.hits=(params.raw.numHits)';
% combined.misses=(params.raw.numMisses)';
% combined.CRs=(params.raw.numCRs)';
% combined.FAs=(params.raw.numFAs)';
% combined.numAttempted=(params.raw.numAttempt)';
% combined.numCorrect=(params.raw.numCorrect)';
% for i=1:numComparison
%     for j=1:numStats
%         [d c]=compareAtoBbinofit(combined,cMatrix{i,1},cMatrix{i,2},statTypes{j},alpha);
%     end
% end


%%
whichComparison=[1:numComparison];
numComparison=length(whichComparison);




% pass this control from outside...
for j=1:numStats
    maxBinCount=0;
    if createDefaultDiffEdges
        theseValues=CIs(:,j,:,:);
        thoseValues=deltas(:,j,:);
        edgeValue=max(abs([theseValues(:); thoseValues(:) ]))*1.1;
        minX=-edgeValue;
        maxX=edgeValue;
        diffEdges(j,:)=linspace(minX,maxX,nBins+1);
    end
    %small loop to find maxBinCount per statistic
    for i=whichComparison
        try
            count=histc(permute(deltas(i,j,:),[3 2 1]), diffEdges(j,:)); % make a matrix...
        catch
            keyboard
        end

        doSubPlot(doFigAndSub,squareStats,multiComparePerPlot,numStats, numComparison,i,j);

        if ~multiComparePerPlot
            bar(diffEdges(j,:),count,'histc');
        else
            plot(minmax(diffEdges(j,:)), [0 0] ,'k');
        end
        hold on
        maxBinCount=max(maxBinCount, max(count));
    end

    if multiComparePerPlot
        interComparisonSpace=4;
        statSpace=5;
        inds=([1:numComparison]-1)*(numSubjects+interComparisonSpace)+(numSubjects/2);
        comparisonYVals=maxBinCount*(1.1+((statSpace*inds)/((numSubjects+interComparisonSpace)*numComparison)));
    else
        statSpace=2;
    end

    %main loop
    for i=whichComparison
        doSubPlot(doFigAndSub,squareStats,multiComparePerPlot,numStats, numComparison,i,j);
        for k=1:numSubjects

            %assign color
            if multiComparePerPlot
                color=comparisonColor(i,:);
            else
                if sign(CIs(i,j,k,2))==sign(CIs(i,j,k,1))
                    color=[1 0 0];
                else
                    color=[0 0 0];
                end
            end

            %             dateRange=[datenum('21-Jun-2008') datenum('19-Oct-2008')];  %dangerous.  have to validate. try []
            if ifYesIsLeftRat(subjects{k})%,dateRange)
                mark= 'o';
            else
                mark= '^';
            end

            if multiComparePerPlot
                ind=(i-1)*(numSubjects+interComparisonSpace)+k;
                yVal=maxBinCount*(1.1+((statSpace*ind)/((numSubjects+interComparisonSpace)*numComparison)));
                %plot([CIs(i,j,k,1) CIs(i,j,k,2)], [yVal yVal], 'color', color);
                %plot(deltas(i,j,k), yVal,mark, 'markerSize', 7, 'color', color);  % supress per subject
            else
                yVal=maxBinCount*(1.1+((statSpace*k)/numSubjects));
                plot([CIs(i,j,k,1) CIs(i,j,k,2)], [yVal yVal], 'color', color);
                plot(deltas(i,j,k), yVal,mark, 'markerSize', 7, 'color', color);
            end

           
            plot([0 0], [0 (1.2+statSpace)*maxBinCount],'k');
            if addTrialNums
                t=text(maxX, yVal, num2str(numSamples(i,j,k)));
                set(t, 'HorizontalAlignment', 'right');
            end
            if addNames
                t=text(maxX*0.9, yVal, labeledNames(k));
                set(t, 'HorizontalAlignment', 'right');
            end
            set(gca, 'TickLength', [0 0]);
            set(gca, 'XTickLabel', []);
        end

        %population effect
        if i<=size(CI,1) %only for some comparisons

            %assign color
            if multiComparePerPlot
                color=comparisonColor(i,:);
            else
                if abs(delta(i,j))>(CI(i,j,2)-CI(i,j,1))*(2/2)
                    %more lenient thresh: sign(CI(i,j,1))==sign(CI(i,j,2))
                    color=[1 0 0];
                else
                    color=[0 0 0];
                end
            end

            populationYVal=-maxBinCount/2;
            if multiComparePerPlot
                plot([ CI(i,j,1)  CI(i,j,2)], repmat(comparisonYVals(i),1,2), 'color', color,'lineWidth',4); % uber-rat errorbar
                plot([CI2(i,j,1) CI2(i,j,2)], repmat(comparisonYVals(i),1,2), 'color', [0 0 0],'lineWidth',2); %   population std
                plot(delta(i,j), comparisonYVals(i), 'o', 'markerSize', 7, 'color', color);
            else
                plot([CI(i,j,1) CI(i,j,2)], repmat(populationYVal,1,2), 'color', color,'lineWidth',4); %   population errorbar
                plot(delta(i,j), populationYVal, 'o', 'markerSize', 7, 'color', color);
                %CI2(i,j,1:2)
            end
            
        end

        axis([minX maxX (maxBinCount+eps)*[-1 1.2+statSpace]]) %eps fixes error if maxBinCount=0
        if ~multiComparePerPlot
        set(gca, 'YTickLabel', maxBinCount);
        set(gca, 'YTick', maxBinCount);
        else 
            set(gca, 'YTickLabel', comparisonNames);
            set(gca, 'YTick', comparisonYVals);
        end
    end
end

for j=1:numStats
    doSubPlot(doFigAndSub,squareStats,multiComparePerPlot,numStats, numComparison,numComparison,j);
    labeledEdges=[min(diffEdges(j,:)) 0 max(diffEdges(j,:))];
    set(gca, 'XTick', labeledEdges);
    labeledEdgeStrings={num2str(labeledEdges(1),'%2.2g'),num2str(labeledEdges(2),'%2.2g'),num2str(labeledEdges(3),'%2.2g'); };
    set(gca, 'XTickLabel', labeledEdgeStrings);

    xlabel(xlabelStrings{j});
end

for i=1:numComparison
    if ~multiComparePerPlot
    doSubPlot(doFigAndSub,squareStats,multiComparePerPlot,numStats, numComparison,i,1);
    ylabel(comparisonNames{i}); %this is not really the ylabel
%     else
%         ylabel()
    end
    %maybe use figure text
end


%subplot(numComparison,numStats,1);
%ylabel('# rats');

%savePlotsToPNG(true,gcf,figName,'C:\Documents and Settings\rlab\Desktop\graphs\');


%peek at some rats
% deltas*100
% i=6; j=1; k=find(strcmp(subjects,'229')); phaseEffect229 = [deltas(i,j,k) (CIs(i,j,k,1)-CIs(i,j,k,2))/2]
% i=4; j=1; k=find(strcmp(subjects,'231')); popoutEffect231= [deltas(i,j,k) (CIs(i,j,k,1)-CIs(i,j,k,2))/2]
% i=1; j=1; collinEffectAll= [delta(i,j) (CI(i,j,2)-CI(i,j,1))/2]
%% summary - combine all rats data




% subplot(1,numStats,j)
% er=(CI(:,j,2)-CI(:,j,1))
% %b=barh(delta(:,j))
% %colormap(gray)
% bar(delta(:,j))
% colormap([.8,.8,.8])
% hold on
% errorbar(delta(:,j),er,'k')
% axis([0 6 -4 4])
% title(statTypes{j})
% set(gca, 'XTickLabel', comparisonNames);
% end
%


function doSubPlot(doFigAndSub,squareStats,multiComparePerPlot,numStats, numComparison,i,j)

if doFigAndSub
    if squareStats
        if multiComparePerPlot
            II=ceil(sqrt(numStats));
            JJ=II-(1)*(II^2-II>=numStats);
            subplot(II, JJ,j);
        else
            II=ceil(sqrt(numComparison));
            JJ=II-(1)*(II^2-II>=numComparison);
            subplot(II, JJ,i);
        end

    else
        if multiComparePerPlot
            subplot(1, numStats,j); %this is probably never used
        else
            subplot(numComparison, numStats,(i-1)*numStats+j);
        end

    end
end











