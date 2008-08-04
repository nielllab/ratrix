function  doPlotPercentCorrect(d,which,smoothingWidth,threshold,axMin,axMax,dayTransitionsOn,addSteps,plotCorrectionTrialsToo,plotAfterErrorsToo, markTrialsToThreshold,addManualChangeMarker,conditionInds)
%d is the smallData
%which is a logical of whats plotted, typically filtered for "good trials"
%smoothing width is length of a boxcar filter
%axMin and axMax are the positions of the axis
%the rest are logicals
% add steps adds on color colded bars for step number
%correction trials are always excluded from main performance (optionally plotted seperately)
%   -->  why removed? b/c otherwise might make animals look better than they are
%after error trials are always included from main performance (& optionally plotted seperately)
%   -->   why NOT removed? b/c can only make animals look worse, and definitly belong if no CTs

%conditionInds- an optional matrix that is numContext X numConditions logicals
%  (can be used as a reference like correction trials, but context is provided by user)
% or a cell with logicals in the first and the seconds  specifies the color of the inds
%
%example: doPlotPercentCorrect(d)
% doPlotPercentCorrect(d,[],[],[],[],[],[],[],[],[],[],[],{conditionInds,conditionColors})

if ~exist('addManualChangeMarker','var') | isempty(addManualChangeMarker)
    addManualChangeMarker=1;
end

if ~exist('which','var') | isempty(which)
    which=getGoods(d);
end

if ~exist('smoothingWidth','var') | isempty(smoothingWidth)
    smoothingWidth=100;
end

if ~exist('threshold','var') | isempty(threshold)
    threshold=.85;
end

if ~exist('axMin','var') | isempty(axMin)
    axMin=0.3;
end

if ~exist('axMax','var') | isempty(axMax)
    axMax=1;
end

if ~exist('dayTransitionsOn','var') | isempty(dayTransitionsOn)
    dayTransitionsOn=1;
end

if ~exist('addSteps','var') | isempty(addSteps)
    addSteps=1;
end

if ~exist('plotCorrectionTrialsToo','var') | isempty(plotCorrectionTrialsToo)
    plotCorrectionTrialsToo=1;
end

if ~exist('plotAfterErrorsToo','var') | isempty(plotAfterErrorsToo)
    plotAfterErrorsToo=0;
end

if ~exist('markTrialsToThreshold','var') | isempty(markTrialsToThreshold)
    markTrialsToThreshold=0;
end

if ~exist('addManualChangeMarker','var') | isempty(addManualChangeMarker)
    addManualChangeMarker=0;
end

if ~exist('conditionInds','var') | isempty(conditionInds)
    plotByCondition=0;

else
    plotByCondition=1;
    if isa(conditionInds,'cell')
        conditionColors=conditionInds{2};
        conditionInds=conditionInds{1};
    elseif isa(conditionInds,'logical')
        %conditionInds=conditionInds % continue
        conditionColors=cool(size(conditionInds,1)); %default colors
    else
        error('bad')
    end
end

totalTrials=size(d.date,2);
hold on;

if addSteps
    numColors=12; %a good number of visible distinguishable colors
    %to test: %figure; colorbar; colormap(jet(numColors));
    stepColors=jet(numColors);
    stepColor=stepColors;
    stepHeight=0.05;
    stepFractionalY=0.05;
    stepYCenter=axMin+stepFractionalY*(axMax-axMin); %maybe at chance? =0.5
    stepYTop=stepYCenter+stepHeight/2;
    stepYBottom=stepYCenter-stepHeight/2;

    steps=unique(d.step);
    if any(isnan(steps))
        steps=steps(1:min(find(isnan(steps)))) %only allow one nan
    end
    for i=1:length(steps)
        whichColor=mod(steps(i)-1,numColors)+1; %this confirms that there are no 0's as the index, and makes it loop
        if isnan(steps(i))
            stepColor=[1 1 1]; %draw white boxes if you don't have the step
            stepTitle ='';
            whichTrialsThisStep=find(isnan(d.step));
        else
            stepColor=stepColors(whichColor,:);
            stepTitle=num2str(steps(i));
            whichTrialsThisStep=find(d.step==steps(i));
        end
        stepStart=min(whichTrialsThisStep);
        stepEnd=max(whichTrialsThisStep);
        stepWidth=stepEnd-stepStart;
        hr=rectangle('Position',[stepStart, stepYBottom, stepWidth+eps, stepHeight],'FaceColor',[stepColor],'EdgeColor',[1 1 1]);
        h=text(stepStart, stepYCenter, stepTitle);
    end

    %only some have this
    if any(strcmp(fields(d),'currentShapedValue')) && ~all(isnan(d.currentShapedValue))
        %add on parameter using currentShapedValue
        blockHeight=stepHeight;
        blockYCenter=stepYCenter+stepHeight;
        blockYBottom=stepYBottom+stepHeight;

        sVals=d.currentShapedValue;
        %this determines all the starting and ending points for continuous parameter values ignoring nans in the begining middle or end
        sValStart=find([0 (diff(sVals)~=0)] & ~isnan(sVals));
        sValEnd=find([(diff(sVals)~=0) 0] & ~isnan(sVals));
        if ~isnan(sVals(1))
            sValStart=[1 sValStart];
        end
        if ~isnan(sVals(end))
            sValEnd=[sValEnd length(sVals)];
        end

        %shapedParameterIndicator
        colors=[.8 .8 .8; .9 .9 .9];
        numColors=size(colors,1);
        for i=1:length(sValStart)
            whichColor=mod(i-1,numColors)+1; %this confirms that there are no 0's as the index, and makes it loop
            blockColor=colors(whichColor,:);
            sValTitle=num2str(sVals(sValStart(i)));
            blockStart=sValStart(i);
            blockEnd=sValEnd(i);
            blockWidth=blockEnd-blockStart;
            hr=rectangle('Position', [blockStart, blockYBottom, blockWidth+eps, blockHeight],'FaceColor',[blockColor],'EdgeColor',[1 1 1]);
            h=text(blockStart, blockYCenter, sValTitle);
        end
    end
end


if plotCorrectionTrialsToo
    %plot correction trial correct
    goodCTs=getGoods(d,'justCorrectionTrials');
    [performance colors]=calculateSmoothedPerformances(d.correct(goodCTs)',smoothingWidth,'boxcar','powerlawBW');
    plot(find(goodCTs),performance,'color',[1,0.8,0.9]) %pink
end

if plotAfterErrorsToo
    %plot after errors
    goodAEs=getGoods(d,'justAfterError');
    [performance colors]=calculateSmoothedPerformances(d.correct(goodAEs)',smoothingWidth,'boxcar','powerlawBW');
    plot(find(goodAEs),performance,'color',[0.8,1,.9]) %light green
end


%plot MAIN good performance
[performanceOnGood colors]=calculateSmoothedPerformances(d.correct(which)',smoothingWidth,'boxcar','powerlawBW');
plot(find(which),performanceOnGood,'color',[0,0,0], 'linewidth', 2)

%add on day transitions
if dayTransitionsOn
    [trialsPerDay]=makeDailyRaster(d.correct,d.date);  %in terms of ALL trials correction and kills, RETURN trialsPerDay
    trialsCompletedBy=cumsum(trialsPerDay);
    for i=1:length(trialsPerDay)
        plot([trialsCompletedBy(i),trialsCompletedBy(i)], [stepYTop,axMax],'color',[.9,.9,.9])
    end
end

% add on threshold
plot([0,totalTrials], [threshold,threshold],'color',[.8,.8,.8])


if plotByCondition
    %one more plot for each provided context
    numConditions=size(conditionInds,1);
    for i=1:numConditions
        [performance colors]=calculateSmoothedPerformances(d.correct(conditionInds(i,:))',smoothingWidth,'boxcar','powerlawBW');
        plot(find(conditionInds(i,:)),performance,'color',conditionColors(i,:))
    end
end

if markTrialsToThreshold
    indexInPerformance=min(find(performanceOnGood>threshold) );

    if size(indexInPerformance,1)>0  % if any there (avoids "empty Matrix" & "[]"  failing)
        indexInPerformance=min(find(performanceOnGood>threshold & (d.step(which)> 4)') ); % find the first trial after first 3 steps -- should really act on it being nACF
    end

    if size(indexInPerformance,1)>0
        trialsToThreshold=min(find(indexInPerformance==cumsum(which)  ));
        daysToThreshold=min(find(trialsCompletedBy>trialsToThreshold));
        h=plot(trialsToThreshold,performanceOnGood(indexInPerformance), 'o');
        set(h, 'markerSize',10,'LineWidth', 3,'Color', [0 0.6 0]);
        comment=sprintf('%s trials\n%s days',  num2str(trialsToThreshold),  num2str(daysToThreshold));
        %h=text(trialsToThreshold, 0.4, comment);
        h=text(trialsToThreshold, threshold+0.7*(1-threshold), comment);
        set(h, 'Color', [0 0.6 0]);
    else
        %the animal has no section above threshold
    end
end

%add on manual change
if addManualChangeMarker

    %default location
    markerHeight=axMin+0.05;

    if exist('stepYTop','var')
        %if steps exist move it above that
        markerHeight=stepYCenter+stepHeight;
    end

    if exist('blockHeight','var')
        %if currentshaped value indicator exists, move it up
        markerHeight=markerHeight+blockHeight;
    end

    if ismember('manualVersion',fields(d))
        manualVersion=d.manualVersion;
        manualVersion(isnan(manualVersion))=-1;
        beforeChange=find(diff(manualVersion));
        afterChange=beforeChange+1;
        numChanges=length(beforeChange);
        h=plot(afterChange,repmat(markerHeight,1,numChanges), 'x','Color', [0 0 .8]);
        set(h, 'markerSize',6,'LineWidth', 2);
    end

    %Could trace out the manualVersioni number, but adds too much clutter,
    %with little valuable info
    includeManaulVersionNumber=0;
    if includeManaulVersionNumber
        for i=1:numChanges
            h=text(afterChange(i), markerHeight-0.01, sprintf('%d',manualVersion(afterChange(i))));
            set(h,'FontSize',8)
        end
    end
end


axis([0,max(1,totalTrials),axMin,axMax])