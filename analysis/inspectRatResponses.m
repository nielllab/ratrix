function completed=inspectRatResponses(subject,loadPath,whichPlots,handles,subplotParams,d, useBodyWeightCache)
%inspectRatResponses('rat_113') %gets the last smallData file for the rat
%inspectRatResponses('rat_113',[1 1 1 0 0 1 1 0 0 0 0],[1:9],subplotParams) %gets the last smallData file for the rat
%inspectRatResponses=('rat_107',particularSmallDataFile)
%d=load(smallData_rat102)  source of saved file: getRatrixDataFromStation
%subject='rat_107'



%by default, plot performance.
if ~exist('whichPlots','var')
    whichPlots=[1 1 1 0 0 0 0 0 0 0 0 0 0 0 0];
end

plotTrialsPerDay=whichPlots(1);
plotMoreDetails=whichPlots(2); %this is the handle for the performance figure.
plotDPrime=whichPlots(3);
plotLickAndRT=whichPlots(4);
plotEvenMoreLickAndRT=whichPlots(5);
%makeADailyRaster=whichPlots(6);
plotResponseDensity=whichPlots(6);
plotResponseRaster=whichPlots(7);
plotRewardTime=whichPlots(8);
plotMotorResponsePattern=whichPlots(9);
plotFlankerAnalysis=whichPlots(10);
plotTemporalROC=whichPlots(11);
plotLocallyNormalizedEffect=whichPlots(12);
plotContrastCurve=whichPlots(13);
plotTheBodyWeights=whichPlots(14);
plotBias=whichPlots(15);
plotBiasScatter=whichPlots(16);
plotRatePerDay=whichPlots(17);
plotPerformancePerDaysTrial=whichPlots(18);




%define default handles.
if ~exist('handles','var')
    handles=[1:size(whichPlots,2)];
else
    if size(whichPlots,2)~= size(handles,2)
        error('Handles must be defined for every Plot. EVEN unplotted ones.');
    end
end


%define location in subplot
if ~exist('subplotParams','var'); subplotParams=[]; end
if isempty(subplotParams)
    subplotParams.x=1;
    subplotParams.y=1;
    subplotParams.index=1;
end

%optionally choose to override and provide smallData from outside source.
if ~exist('d','var')
    d='loadMe - im not a struct nor am i empty';
end
if strcmp(class(d),'char')
    d=getSmalls(subject)
end


if ~exist('useBodyWeightCache','var'); useBodyWeightCache = []; end
if isempty(useBodyWeightCache)
    useBodyWeightCache = 0;
end

savePath='out';

hasData=0;
if strcmp(class(d),'struct')
    if any(strcmp(fields(d),'date'))
        totalTrials=size(d.date,2)
        hasData=1;
    end
end

if ~hasData
    disp(['no data for ' subject '!'])
    eachPlot=find(whichPlots);
    for i=1:size(eachPlot,2)
        figure(handles(eachPlot(i))); subplot(subplotParams.y, subplotParams.x, subplotParams.index);
        title(subject);
        text(0.5,0.5,'no data')
        set(gca,'YTickLabel','')
        set(gca,'XTickLabel','')
    end
    return  %ends the inspect for this rat
end

goods=getGoods(d,'withoutAfterError');
%goods=getGoods(d);

if plotBias || plotBiasScatter
    goodForBias=getGoods(d,'forBias');
end

%pretty important hard coded parameter -  consider what uses it before
%changing it
smoothingWidth=100;


if sum([plotDPrime plotLickAndRT])>0
    if (subplotParams.x==1) && (subplotParams.y==1)
        plotCombinedDetails=1;
    else
        warning('cant plot combined details for more than one subject.')
        plotCombinedDetails=0;
    end
else
    plotCombinedDetails=0;
end


%define Titles
contextInfo=[subject '; ' datestr(min(d.date),22) ' to ' datestr(max(d.date),22)];

%per day analysis
[trialsPerDay correctPerDay]=makeDailyRaster(d.correct,d.date,d.date>0,smoothingWidth,60*12,subject,0,handles,subplotParams,0,0);  %in terms of ALL trials correction and kills, RETURN trialsPerDay
[goodTrialsPerDay correctPerDay]=makeDailyRaster(d.correct,d.date,goods,smoothingWidth,60*12,subject,0,handles,subplotParams,0,0);

if plotTrialsPerDay
    doPlot('plotTrialsPerDay',d,handles(1),subplotParams.y, subplotParams.x, subplotParams.index)
    %     figure(handles(1)); subplot(subplotParams.y, subplotParams.x, subplotParams.index);
    %     bar(goodTrialsPerDay); %will only good trials will be counted? yes
    %     %title(['Trials Per Day- ' contextInfo])
    %     title([subject '; ' datestr(min(d.date),6) '-' datestr(max(d.date),6)])
    %     axis([0.5 size(trialsPerDay,2)+0.5 0 1000])
end

if plotResponseDensity || plotResponseRaster
    junk=makeDailyRaster(d.correct(goods),d.date(goods),smoothingWidth,5,subject,1,handles,subplotParams,plotResponseDensity,plotResponseRaster); %in terms of good trials, PLOT NOT SAVED
end

[d.correctInRow runEnds d.numSwitchesThisRun]=calcAmountCorrectInRow(d.correct,d.response);
if plotRewardTime==1 & ismember('actualRewardDuration',fields(d))
    figure(handles(8)); subplot(subplotParams.y, subplotParams.x, subplotParams.index);
    %     edges=[0:0.02:2];
    %     count=histc(d.actualRewardDuration,edges);
    %     bar(edges,count,'histc')
    %     axis([0 2 0 1000])
    maxN=5;
    [junk secondsRewardTime labelStruc]=calcDailyRewards(d,trialsPerDay,maxN);
    bar(secondsRewardTime,'stacked'), colormap(cool)
    axis([0 length(secondsRewardTime) 0 200])
    text(0.5, 150, [sprintf('x%s \n%3.0f total',char(labelStruc(3)), sum(secondsRewardTime(:)))])
    %legend (labelStruc,'Location','NorthOutside','Orientation','horizontal')
    %     ylabel('H2O sec')
    set(gca,'YTickLabel','')
    set(gca,'XTickLabel','')
    title(subject);
    %     xlabel('day')
end

%PLOT
%myTitle=['Performance for ' contextInfo];
myTitle=[subject '; ' datestr(min(d.date),6) '-' datestr(max(d.date),6)];

figure(handles(2)); subplot(subplotParams.y, subplotParams.x, subplotParams.index); hold on;
performanceFig=gcf;
numSubplot=subplotParams.x*subplotParams.y;
%this is the total number of subplot that will appear in this figure
%use to restrict the amount of information if many subplots

if numSubplot==1
    myTitle=['Performance for ' contextInfo];
    xlabel(sprintf('Trial Number (%d good of %d total)', sum(goods), length(goods)))
    ylabel('Percent Correct')
    set(gca,'YTickLabel','chance|thresh|perfect')
elseif numSubplot>1 && numSubplot<=9
    myTitle=[subject '; ' datestr(min(d.date),6) '-' datestr(max(d.date),6)];
    xlabel(sprintf('Trial Number (%d good of %d total)', sum(goods), length(goods)))
    ylabel('Percent Correct')
    set(gca,'YTickLabel','chance|thresh|perfect')
else %if numSubplot>9
    myTitle=[subject]; %maybe do something for dateRanges of all animals...
    %ideally indicate on graph if dateRange is unexpected...
    set(gca,'YTickLabel','50%|85%|100%')
end

if plotCombinedDetails
    subplot(311);
end

if plotMoreDetails
    plotCorrectionTrialsToo=1; %etc
end

if plotCombinedDetails
    %plot performance for a contrast type
    contrastConditionInds(1,:)=(goods & d.targetContrast==0.5)
    contrastConditionInds(2,:)=(goods & d.targetContrast==0.75)
    contrastConditionInds(3,:)=(goods & d.targetContrast==1)
else
    contrastConditionInds=[];
end

%smoothingWidth=100; %set above
threshold=0.85;
axMin=0.3;
axMax=1;
dayTransitionsOn=1;
addSteps=1;
plotCorrectionTrialsToo=1;
plotAfterErrorsToo=1;
markTrialsToThreshold=1;
addManualChangeMarker=1;
doPlotPercentCorrect(d,goods,smoothingWidth,threshold,axMin,axMax,dayTransitionsOn,addSteps,plotCorrectionTrialsToo,plotAfterErrorsToo,markTrialsToThreshold,addManualChangeMarker,contrastConditionInds)

title(myTitle)
set(gca,'YTick',[.5 threshold 1])
set(gca,'XTick',[0 max(totalTrials,1)])
set(gca,'XTickLabel',[num2str(0) '|' num2str(totalTrials)])


% %color coded step numbers
% numColors=12; %a good number of visible distinguishable colors\
% %to test:
% %figure; colorbar; colormap(jet(numColors));
% stepColors=jet(numColors);
% stepColor=stepColors;
% stepHeight=0.05;
% stepFractionalY=0.05;
% stepYCenter=axMin+stepFractionalY*(axMax-axMin); %maybe at chance? =0.5
% stepYTop=stepYCenter+stepHeight/2;
% stepYBottom=stepYCenter-stepHeight/2;
%
% steps=unique(d.step);
% if any(isnan(steps))
%     steps=steps(1:min(find(isnan(steps)))) %only allow one nan
% end
% for i=1:length(steps)
%     whichColor=mod(steps(i)-1,numColors)+1; %this confirms that there are no 0's as the index, and makes it loop
%     if isnan(steps(i))
%         stepColor=[1 1 1]; %draw white boxes if you don't have the step
%         stepTitle ='';
%         whichTrialsThisStep=find(isnan(d.step));
%     else
%         stepColor=stepColors(whichColor,:);
%         stepTitle=num2str(steps(i));
%         whichTrialsThisStep=find(d.step==steps(i));
%     end
%     stepStart=min(whichTrialsThisStep);
%     stepEnd=max(whichTrialsThisStep);
%     stepWidth=stepEnd-stepStart;
%     hr=rectangle('Position',[stepStart, stepYBottom, stepWidth+eps, stepHeight],'FaceColor',[stepColor],'EdgeColor',[1 1 1]);
%     h=text(stepStart, stepYCenter, stepTitle);
% end
%
% if any(strcmp(fields(d),'currentShapedValue')) && ~all(isnan(d.currentShapedValue))
%     %add on parameter using currentShapedValue
%     blockHeight=stepHeight;
%     blockYCenter=stepYCenter+stepHeight;
%     blockYBottom=stepYBottom+stepHeight;
%
%     sVals=d.currentShapedValue;
%     %this determines all the starting and ending points for continuous parameter values ignoring nans in the begining middle or end
%     sValStart=find([0 (diff(sVals)~=0)] & ~isnan(sVals));
%     sValEnd=find([(diff(sVals)~=0) 0] & ~isnan(sVals));
%     if ~isnan(sVals(1))
%         sValStart=[1 sValStart];
%     end
%     if ~isnan(sVals(end))
%         sValEnd=[sValEnd length(sVals)];
%     end
%
%     %shapedParameterIndicator
%     colors=[.8 .8 .8; .9 .9 .9];
%     numColors=size(colors,1);
%     for i=1:length(sValStart)
%         whichColor=mod(i-1,numColors)+1; %this confirms that there are no 0's as the index, and makes it loop
%         blockColor=colors(whichColor,:);
%         sValTitle=num2str(sVals(sValStart(i)));
%         blockStart=sValStart(i);
%         blockEnd=sValEnd(i);
%         blockWidth=blockEnd-blockStart;
%         hr=rectangle('Position', [blockStart, blockYBottom, blockWidth+eps, blockHeight],'FaceColor',[blockColor],'EdgeColor',[1 1 1]);
%         h=text(blockStart, blockYCenter, sValTitle);
%     end
%
% end
%
% %add on day transitions
% trialsCompletedBy=cumsum(trialsPerDay);
% for i=1:length(trialsPerDay)
%     plot([trialsCompletedBy(i),trialsCompletedBy(i)], [stepYTop,axMax],'color',[.9,.9,.9])
% end



% % add on threshold
% if plotMoreDetails
%     %add on fraction rewarded assuming all correct are rewarded
%     trialsCompletedBefore=[0 trialsCompletedBy(1:end-1)];
%     midPointPerDay=trialsCompletedBefore+(trialsPerDay/2);
%     for i=1:length(trialsPerDay)
%         if i<= length(correctPerDay)
%         ss=midPointPerDay(i)-correctPerDay(i)/2;
%         ee=midPointPerDay(i)+correctPerDay(i)/2;
%         else
%             ss=midPointPerDay(i);
%             ee=midPointPerDay(i);
%         end
%                 plot([ss,ee], [threshold,threshold],'color',[.8,.8,1])
%     end
% else
%     %a normal threshold
%     plot([0,totalTrials], [threshold,threshold],'color',[.8,.8,.8])
% end

% if plotMoreDetails
%     %plot correction trial correct
%     which=getGoods(d,'justCorrectionTrials');
%     [performance colors]=calculateSmoothedPerformances(d.correct(which)',smoothingWidth,'boxcar','powerlawBW');
%     plot(find(which),performance,'color',[1,0.8,0.9]) %pink
%     hold on
%
%     %plot after correction trial performance
%     %[performance colors]=calculateSmoothedPerformances(d.correct(afterCTs & ~manualKill)',smoothingWidth,'boxcar','powerlawBW');
%     %plot(find(afterCTs & ~manualKill),performance,'color',[1.0,0.9,0.8])
%     %%orange
% end

% %calculate MAIN good performance
% [performanceOnGood colors]=calculateSmoothedPerformances(d.correct(goods)',smoothingWidth,'boxcar','powerlawBW');
%
% %include binofit
% % [P, PCI] = binofit(performanceOnGood*smoothingWidth,smoothingWidth*ones(size(performanceOnGood)));
% % fillHandle=fill([find(goods) flipLR(find(goods))], [PCI(:,1)' flipLR(PCI(:,2)')], [.8 .8 .8])
% % set(fillHandle, 'EdgeColor', 'none')
%
% %plot MAIN good performance
% plot(find(goods),performanceOnGood,'color',[0,0,0], 'linewidth', 2)
% axis( [1 max([totalTrials 2]) axMin axMax])
%
% markTrialsToThreshold=1;
% if markTrialsToThreshold
%
%
%
%
%     indexInPerformance=min(find(performanceOnGood>threshold) );
%
%     indexInPerformance
%     size(performanceOnGood>threshold)
%     size(d.step(goods)> 4)
%
%     if size(indexInPerformance,1)>0  % if any there (avoids "empty Matrix" & "[]"  failing)
%         indexInPerformance=min(find(performanceOnGood>threshold & (d.step(goods)> 4)') ); % find the first
%     end
%
%     if size(indexInPerformance,1)>0
%         trialsToThreshold=min(find(indexInPerformance==cumsum(goods)  ));
%         daysToThreshold=min(find(trialsCompletedBy>trialsToThreshold));
%         h=plot(trialsToThreshold,performanceOnGood(indexInPerformance), 'o');
%         set(h, 'markerSize',10,'LineWidth', 3,'Color', [0 0.6 0]);
%         comment=sprintf('%s trials\n%s days',  num2str(trialsToThreshold),  num2str(daysToThreshold));
%         %h=text(trialsToThreshold, 0.4, comment);
%         h=text(trialsToThreshold, threshold+0.7*(1-threshold), comment);
%         set(h, 'Color', [0 0.6 0]);
%     else
%         %the animal has no section above threshold
%     end
% end



if plotDPrime || plotCombinedDetails
    if plotCombinedDetails
        subplot(312); hold on
    else
        figure (handles(3)); subplot(subplotParams.y, subplotParams.x, subplotParams.index); hold on;
    end


    conditionInds=getFlankerConditionInds(d,goods);

    %make fake data of the same size (eventually rand shuffle or monte carlo)
    fakeData.correctResponseIsLeft=int8(rand(1,totalTrials)>0.5);
    fakeData.correctResponseIsLeft(find(fakeData.correctResponseIsLeft==0))=-1;
    fakeData.response=uint8(rand(1,totalTrials)>0.5);
    fakeData.response(find(fakeData.response==1))=3; %set lefts
    fakeData.response(find(fakeData.response==0))=1; %set rights
    %shuffleData.correctResponseIsLeft=
    %randperm(totalTrials) OR randperm(sum(goods))

    %d-prime calcs per day
    [fakeDpr]=dprimePerConditonPerDay(trialsCompletedBy,conditionInds,goods,fakeData);
    [dpr more]=dprimePerConditonPerDay(trialsCompletedBy,conditionInds,goods,d);
    %all days
    [dprAll]=    dprimePerConditonPerDay(totalTrials,conditionInds,goods,d);
    [fakeDprAll]=dprimePerConditonPerDay(totalTrials,conditionInds,goods,fakeData);

    plot(ones(size(fakeDprAll(1:5,:))),fakeDprAll(1:5,:)','co','MarkerSize',10)
    plot(ones(size(    dprAll(1:5,:))),    dprAll(1:5,:)','ko','MarkerSize',10)
    plot(1                     ,    dprAll(  2,:)','ro','MarkerSize',10)
    plot(1                     ,    dprAll(  6,:)','go','MarkerSize',10)
    plot(1                     ,    dprAll(  7,:)','bo','MarkerSize',10)

    plot(repmat(trialsCompletedBy,7,1)',fakeDpr(1:7,:)','c.')
    plot(repmat(trialsCompletedBy,7,1)',dpr(1:7,:)','k.')
    plot(repmat(trialsCompletedBy,1,1)',dpr(  2,:)','r.')
    plot(repmat(trialsCompletedBy,1,1)',dpr(  6,:)','g.')
    plot(repmat(trialsCompletedBy,1,1)',dpr(  7,:)','b.')
    axis( [1 max([totalTrials 2]) -.5 max([max(dpr(~isinf(dpr(:)))) 1])   ])
    ylabel('dprime')
end


if plotLickAndRT || plotCombinedDetails
    if plotCombinedDetails
        subplot(313); hold on
    else
        figure (handles(4)); subplot(subplotParams.y, subplotParams.x, subplotParams.index); hold on;
    end


    %reaction time and licks
    threshold=10;
    threshedResponseTime=d.responseTime;
    threshedResponseTime(d.responseTime>threshold)=threshold;
    threshedResponseTime(d.responseTime<0)=mean(threshedResponseTime);
    plot(threshedResponseTime,'.','MarkerSize',1,'color',[.6,.8,.6]); hold on
    plot(conv2(single(threshedResponseTime), ones(1,100)/100,'same'),'color',[.4,.6,.4]);
    plot(conv2(single(d.numRequestLicks), ones(1,100)/100,'same'),'.','MarkerSize',1,'color',[.6,.4,.4]); hold off
    axis( [1 max([totalTrials 2]) 0 10])
    ylabel('rt (sec) ')
    xlabel(sprintf('Trial Number (%d good of %d total)', sum(goods), length(goods)))
end


if plotEvenMoreLickAndRT
    %reaction time sorted by contrast
    figure
    r1=histc(threshedResponseTime(goods & d.targetContrast==0    & d.date>now-10),[0:threshold/50:threshold]);
    r2=histc(threshedResponseTime(goods & d.targetContrast==0.5  & d.date>now-10),[0:threshold/50:threshold]);
    r3=histc(threshedResponseTime(goods & d.targetContrast==0.75 & d.date>now-10),[0:threshold/50:threshold]);
    r4=histc(threshedResponseTime(goods & d.targetContrast==1    & d.date>now-10),[0:threshold/50:threshold]);
    bar([r1/sum(r1); r2/sum(r2); r3/sum(r3); r4/sum(r4) ]')

    %num licks sorted by contrast

    L1=histc(single(d.numRequestLicks(goods & d.targetContrast==0    & d.date>now-10)),[0:12]);
    L2=histc(single(d.numRequestLicks(goods & d.targetContrast==0.5    & d.date>now-10)),[0:12]);
    L3=histc(single(d.numRequestLicks(goods & d.targetContrast==1    & d.date>now-10)),[0:12]);
    bar([L1/sum(L1); L2/sum(L2); L3/sum(L3)]')

    %this explains the jaggies: takes longer BECAUSE doing hastily doing more center licks
    figure
    these=goods & d.targetContrast==0   & d.date>now-10;
    plot(single(d.numRequestLicks(these))-0.2,threshedResponseTime(these),'.', 'MarkerSize',5,'color',[.2,.8,.2]); hold on
    these=goods & d.targetContrast==0.5 & d.date>now-10;
    plot(single(d.numRequestLicks(these)),    threshedResponseTime(these),'.', 'MarkerSize',5,'color',[.8,.2,.2])
    these=goods & d.targetContrast==1   & d.date>now-10;
    plot(single(d.numRequestLicks(these))+0.2,threshedResponseTime(these),'.', 'MarkerSize',5,'color',[.2,.2,.8]); hold off
    axis( [1 12 0 10])
end



%saveas(performanceFig,[savePath '/graphs/' subject '-Performance-' datestr(max(d.date),29) '.png'],'png');


if plotMotorResponsePattern
    %PLOT REPONSE PATTERN
    figure(handles(9)); subplot(subplotParams.y, subplotParams.x, subplotParams.index); hold on
    lengthHistory=3;
    [count patternType uniques]=findResponsePatterns(d.response(getGoods(d,'forBias')),lengthHistory,2,0);
    patternIDs=unique(patternType);
    color=[0.9,0,0.0;  %lefts are red
        1,0.8,0.8;
        1,0.8,0.8; %alternating strategy
        1,0.8,0.8;
        0.8,1,0.8
        0.8,1,0.8; %alternating strategy
        0.8,1,0.8;
        0.0,0.9,0.0]; %rights are green
    for i=1:2^lengthHistory
        event=(patternType==patternIDs(i));
        [frequency(i,:)]=calculateSmoothedPerformances(event,smoothingWidth*5,'boxcar','powerlawBW');
        %find(~manualKill & ~dualResponse),
        disp(['Doing motor response pattern number' num2str(i)])
        plot(frequency(i,:),'color',color(i,:))  % not perfectly aligned with trials
        title(sprintf('Response Pattern Frequency, past %d trials, %s',smoothingWidth*5,contextInfo))
        ylabel('Frequency'); xlabel('Trial');
    end
    axis( [1 max([totalTrials 2]) 0 0.25])
    hold on
end


if plotFlankerAnalysis
    figure(handles(10));  subplot(subplotParams.y, subplotParams.x, subplotParams.index); hold on
    title(d.info.subject{1})
    if ismember('flankerContrast',fields(d))

        filter='colin+3';%'colin-other';
        haveFlanks=d.flankerContrast>0;
        [condition names ind colors]=getFlankerConditionInds(d,goods & haveFlanks,filter);
        %this works if you don't want to be contrast sensitive; otherwise use flankerAnalysis  (commented out below)
        
        %deal with the fact that come rats choose right for "yes" and some choose left for "yes"
        presentVal=unique(d.response(d.correct==1 & d.targetContrast>0));
        absentVal=unique(d.response(d.correct==1 & d.targetContrast==0));
        if length(absentVal)>1 | length(presentVal)>1
            error('this rat learned more than one detection rule; if feature go right VS go left')
        end
        
        if length(ind)>0
        for i=ind
            some=removeSomeSmalls(d,~condition(i,:));
            correctAnswerID=(some.correctResponseIsLeft);
            correctAnswerID(correctAnswerID==-1)=3;
            if ~all((some.correctResponseIsLeft==1)==(some.correct==1 & some.response==1) | (some.correct==0 & some.response~=1))
                x=((some.correctResponseIsLeft==1)==(some.correct==1 & some.response==1) | (some.correct==0 & some.response~=1))
                violations=find(~x)
                error('violates correct response is left; should never happen, regardless of trial manager rules')
            end
            [allDpr b]=dprime(some.response(getGoods(some)),correctAnswerID(getGoods(some)),'presentVal',presentVal,'absentVal',absentVal);
            s.hits(i)=b.hits;
            s.correctRejects(i)=b.correctRejects;
            s.misses(i)=b.misses;
            s.falseAlarms(i)=b.falseAlarms;
        end

        % conditionType='allPixPerCycs'; %all SF?
        % plotType='performancePerContrastPerCondition';
        % performanceMeasure = 'pctCor'; %pctCor, pctRightward, hitRate, correctRejections
        % stepUsed = [];
        % verbose = 0;
        %
        % context=getGoods(d);
        % index=1;
        % [s plotParams]=flankerAnalysis(removeSomeSmalls(d, ~context(index,:)),  conditionType, plotType,performanceMeasure, stepUsed, verbose)
        %
        % %all of tempStats are size(numContrast x numConditions)
        % contrasts=unique(d.targetContrast(~isnan(d.targetContrast)));
        % contrasts(contrasts==0)=[]; %remove 0 contrasts because ill defined for detection (this was handled by flankerAnalysis)
        % [context names]=getFlankerConditionInds(d,getGoods(d),conditionType);
        %
        % reduce=1;
        % if reduce
        %     ppcInd=find(ismember(names,'32'))
        %     s.hits=s.hits(:,ppcInd);
        %     s.misses=s.misses(:,ppcInd);
        %     s.correctRejects=s.correctRejects(:,ppcInd);
        %     s.falseAlarms=s.falseAlarms(:,ppcInd);
        % end
        %
        % %the trick to understanding the non-reduced plot is to color it appropriately
        % colors=jet(size(s.hits(:),1));
        
        doInset=0;
        if doInset
            doPlotPercentCorrect(d,[],[],[],[],[],[],[],[],[],[],[],{condition,colors})
            pctCorrectYfraction=0.25;
        else
            plot([0 1], [0 1],'k');
            pctCorrectYfraction=1;
        end

        %params
        %fs=15;
        ciwidth=4;
        alpha=0.05;
        
        yLim=[0 1/pctCorrectYfraction];
        xLim=get(gca,'XLim');

        
        
        % Get Confidence Interval
        [hitRate, hitPci] = binofit(s.hits(:),s.misses(:)+s.hits(:),alpha);
        [faRate, faPci] = binofit(s.falseAlarms(:),s.falseAlarms(:)+s.correctRejects(:),alpha);

        % the ROC crosses
        axis([xLim yLim ]);
        plot([0 xLim(2)], [0 yLim(2)],'k')
        %ind=find(ismember(names,{'VH 3.5', 'VV 3.5'}));

        for  i=1:length(ind)
            dpr = sqrt(2) * (erfinv((2*hitRate(ind(i)) - 1)) + erfinv((1-2*faRate(ind(i))))); %check assumptions....
            % dpr = sqrt(2) * (erfinv((hits - misses)/numSigs) + erfinv((CR - FA)/numNoSigs)); %what I use (from code)
            [dprMesh h f]=getDprMesh;
            [cs,hh] = contour(f*xLim(2),h*yLim(2),dprMesh,[dpr dpr]);
            set(hh, 'LineColor', colors(ind(i),:));
        end

        %scale to match duplexed axis
        hitRate=hitRate*diff(yLim);
        hitPci=hitPci*diff(yLim);
        faRate=faRate*diff(xLim);
        faPci=faPci*diff(xLim);

        
        %set(gca, 'FontSize', [fs])
        set(gca,'YTickLabel',[0 .5 1])
        set(gca,'YTick',[0  yLim(2)/2 yLim(2)])
        ylabel('Hit Rate'); xlabel('False Alarm Rate');
        
        %indicate if "yes" response is left or right side
        switch presentVal
            case 3
               text(.7*diff(xLim),.6*diff(yLim),'Y=R')
            case 1
               text(.7*diff(xLim),.6*diff(yLim),'Y=L')
        end

        for i=1:length(ind)
            hci=plot([faPci(ind(i),1) faPci(ind(i),2)],[hitRate(ind(i)) hitRate(ind(i))],'color',colors(ind(i),:)); %horizontal error bar
            vci=plot([faRate(ind(i)) faRate(ind(i))],[hitPci(ind(i),1) hitPci(ind(i),2)],'color',colors(ind(i),:)); %vert error bar
            plot(faRate(ind(i)), hitRate(ind(i)),'.','MarkerSize',20,'color',colors(ind(i),:)) %vh 3.5

            set(hci, 'LineWidth',ciwidth)
            set(vci, 'LineWidth',ciwidth)
        end

        %     if (subplotParams.x==1) && (subplotParams.y==1)
        %         %if only one subject plot all 4 graphs.
        %         subplot(2,2,1); plot(([1:size(performanceOnGood,1)]),performanceOnGood,'k')
        %         title('Performance on all trial types'); ylabel('% correct')
        %         axis([1,size(performanceOnGood,1),axMin,1])
        %
        %         for i=1:size(flankerPerformances,2)/2
        %             subplot(2,2,i+1); title(flankerTitles{i}); hold on
        %             %note: ploting out of order of performance vector, so that solid red is ontop
        %             a=(i-1)*2+2; plot(whenFlankerCondition{a}',flankerPerformances{a}(:,1),':c')
        %             a=(i-1)*2+1; plot(whenFlankerCondition{a}',flankerPerformances{a}(:,1),'r')
        %             axis([1,size(performanceOnGood,1),axMin,1])
        %         end
        %
        %     else
        %         i=2;%vertical horizontal target comparison.
        %         %i=3;%vertical horizontal flanker comparison.
        %         subplot(subplotParams.y, subplotParams.x, subplotParams.index)
        %         title(flankerTitles{i}); hold on
        %         %note: ploting out of order of performance vector, so that solid red is ontop
        %         a=(i-1)*2+2; plot(whenFlankerCondition{a}',flankerPerformances{a}(:,1),':c')
        %         a=(i-1)*2+1; plot(whenFlankerCondition{a}',flankerPerformances{a}(:,1),'r')
        %         axis([1,size(performanceOnGood,1),axMin,1])
        %     end

        %saveas(gcf,[savePath '/graphs/' subject '-FlankerAnalyis-' datestr(max(d.date),29) '.png'],'png');
        else
            set(gca,'YTickLabel',[])
            set(gca,'XTickLabel',[])
            text(0.5, 0.5, 'not yet');
        end
    else
        %wrong stimulus type
            set(gca,'YTickLabel',[])
            set(gca,'XTickLabel',[])
    end
    axis square;
end



if plotTemporalROC

    if 1 %analyze per condition
        smoothingWidth=400; %800-1000 with four conditions should be about 100 per condition (hits+misses)
        segments=[smoothingWidth:smoothingWidth:(floor(totalTrials/smoothingWidth))*smoothingWidth];
        numColors=min([size(segments,2) 100]);
        blockEnds=[segments totalTrials];
        [conditionInds names hasData]=getFlankerConditionInds(d,goods,'allDevs');%,'allDevs','twoFlankers');
        conditionInds=conditionInds(hasData,:);
        names=names(hasData);

        startColor=repmat([0.9,0.9,0.9],length(hasData),1)
        endColor=startColor;
        inds=find(strcmp('VV',names)); endColor(inds,:)=repmat([0.9,0.1,0.1],length(inds),1);  %vv is red
        inds=find(strcmp('VH',names)); endColor(inds,:)=repmat([0.5,0.9,0.9],length(inds),1);  %vh is cyan
        inds=find(strcmp('HV',names)); endColor(inds,:)=repmat([0.5,0.9,0.9],length(inds),1);  %hv is cyan
        inds=find(strcmp('HH',names)); endColor(inds,:)=repmat([0.5,0.9,0.9],length(inds),1);  %hh is cyan

        inds=find(strcmp('dev-2.5',names)); endColor(inds,:)=repmat([0.9,0.1,0.1],length(inds),1);  %red
        inds=find(strcmp('dev-3.0',names)); endColor(inds,:)=repmat([0.1,0.9,0.1],length(inds),1);  %green
        inds=find(strcmp('dev-3.5',names)); endColor(inds,:)=repmat([0.1,0.1,0.9],length(inds),1);  %blue
        inds=find(strcmp('dev-5.0',names)); endColor(inds,:)=repmat([0.9,0.1,0.9],length(inds),1);  %magenta

        startColor=endColor;
    else %all of them
        smoothingWidth=250; %with four conditions should be at least 100 per condition estimate
        segments=[smoothingWidth:smoothingWidth:(floor(totalTrials/smoothingWidth))*smoothingWidth];
        numColors=min([size(segments,2) 100]);
        blockEnds=[segments totalTrials];
        conditionInds=ones(1,totalTrials);%maybe reflect flanker conditions one day
        startColor=[0.9,0.9,0.9];
        endColor=[0.9,0.1,0.1];
    end
    [dpr dprStats]=dprimePerConditonPerDay(blockEnds,conditionInds,goods,d);

    %haveData=find(sum(conditionInds')>0);
    haveData=find(sum((dpr==-99)')==0);
    haveData=haveData(haveData<=5)
    startColor=startColor(haveData,:);  %remove conditions that don't have data
    endColor=endColor(haveData,:);

    %     endColor(1,:)=[1 1 1];
    %     startColor=endColor;

    temp=cell2mat(dprStats(haveData,:));
    hits=reshape([temp.hits], size(temp,1),size(temp,2));
    CR=reshape([temp.correctRejects], size(temp,1),size(temp,2));
    misses=reshape([temp.misses], size(temp,1),size(temp,2));
    FA=reshape([temp.falseAlarms], size(temp,1),size(temp,2));

    hitRate=[hits./(hits+misses)];
    FARate=[FA./(FA+CR)];

    figure(handles(11)); subplot(subplotParams.y, subplotParams.x, subplotParams.index)
    for i=1:size(startColor,1)
        colorplot(FARate(i,:),hitRate(i,:), numColors,startColor(i,:),endColor(i,:));
    end
    title(sprintf ('ROC Curve %s ', subject));
    plot([0 1], [0 1],'k')
    ylabel('Hit Rate'); xlabel('False Alarm Rate');
    axis([0 1 0 1])
end


if plotLocallyNormalizedEffect
    [conditionInds names hasData]=getFlankerConditionInds(d,goods);
    conditionInds=conditionInds(hasData,:);
    names=names(hasData);
    effectType='usePctCorrect';
    switch effectType
        case 'useDpr'
            smoothingWidth=500;


            %Some coding work needs to be done here!!!**!!!*
            segments=[smoothingWidth:smoothingWidth:(floor(totalTrials/smoothingWidth))*smoothingWidth];
            blockEnds=[segments totalTrials];
            [dpr dprStats]=dprimePerConditonPerDay(blockEnds,conditionInds,goods,d);


            normDpr=log(dpr(2:end,:)./repmat(dpr(1,:),6,1)); %d prime log ratio\
            normEffect=normDpr;
            edges=[-1:0.1:1]; %need to choose a better range for log ratio in subsequent histogram
        case 'usePctCorrect'
            smoothingWindow=100;
            lastGoodTrial= cumsum(conditionInds,2);
            ignoreBefore=max(sum(lastGoodTrial'==0))+1;
            lastGoodTrial(lastGoodTrial==0)=1;
            lastPerformance=zeros(size(conditionInds));
            for i=1:size(conditionInds,1)
                [performance ]=calculateSmoothedPerformances(d.correct(goods & conditionInds(i,:))',smoothingWindow,'boxcar','powerlawBW');
                lastPerformance(i,:)=performance(lastGoodTrial(i,:));

            end
            %this evaluates the extent to which a particular condition is
            %larger than all combined conditions.  Each value (particular and combined)
            %is based on N values, where N is the size of the smoothing
            %window
            betterThanOthers=lastPerformance(2:end,ignoreBefore:end)-repmat(lastPerformance(1,ignoreBefore:end),size(conditionInds,1)-1,1);
            normEffect=betterThanOthers;
            edges=[-0.3:0.01:0.3];%+/-30 percentCorrect
        otherwise
            error('unknown feature for normalized effect')
    end


    if (subplotParams.x==1) && (subplotParams.y==1)
        figure(handles(12));

        title(sprintf ('Normalized Effect %s ', subject));
        ylabel('A'); xlabel('B');
        n=size(normEffect,1);
        for i=1:n
            count=histc(normEffect(i,:),edges);
            subplot(n,1,i)
            bar(edges,count,'histc')
        end
        %why is there a dip in the histograms?
        %consider adding a vertical slash for the mean of the distribution
        %consider color coding better
        %don't forget to add a noise distribution for statistical significance

        %axis([0 1 0 1])
    else
        figure(handles(12)); subplot(subplotParams.y, subplotParams.x, subplotParams.index)

    end
end


if plotContrastCurve

    if (subplotParams.x==1) && (subplotParams.y==1)
        figure(handles(13));
        subplot(211);

        conditionType='fourFlankers';
        plotType='performancePerContrastPerCondition'; %performancePerContrastPerCondition, performancePerDeviationPerCondition
        performanceMeasure = 'pctCor';
        stepUsed = [];
        error('if multiple contrast mergeWithSameTypeZeroContrast = 1 for detection and = 0 for discrimination... how do you know what to use?')
        flankerAnalysis(d, conditionType, plotType,performanceMeasure, stepUsed)
        title(sprintf('Performance per Contrast, %s',contextInfo))

        subplot(211);

    else
        figure(handles(13)); subplot(subplotParams.y, subplotParams.x, subplotParams.index)

    end
end

if plotTheBodyWeights
    lastNdays = 30;
    plotBodyWeights({subject},lastNdays,subplotParams,handles(14), useBodyWeightCache);
end


if plotBiasScatter || plotBias
    side=double(d.response(goodForBias)==3); %right=1 left=0
    check=size(side,2)==sum(d.response(goodForBias)==1)+sum(d.response(goodForBias)==3);
    if ~check
        numLeft=sum(d.response(goodForBias)==1)
        numRight=sum(d.response(goodForBias)==3)
        theSum=numLeft+numRight
        numTotal=size(d.response(goodForBias),2)
        responseTypes=unique(d.response(goodForBias))
        error ('it seems like there are responses beside left and right');
    end
    [bias colors]=calculateSmoothedPerformances(side',50,'boxcar','powerlawBW');
end

if plotBias
    figure(handles(15)); subplot(subplotParams.y, subplotParams.x, subplotParams.index);
    plot(find(goodForBias),bias,'color',[0,0,0], 'linewidth', 2);
    axis([0 max(totalTrials,1) 0 1]);
    title(subject)
end

if plotBiasScatter
    biasSegmentWidth=100;
    segments=[biasSegmentWidth:biasSegmentWidth:(floor(totalTrials/biasSegmentWidth))*biasSegmentWidth];
    %numColors=min([size(segments,2) 100]);
    blockEnds=[segments totalTrials];
    alternatingSide=diff([nan side])~=0;
    [alternatingBias colors]=calculateSmoothedPerformances(alternatingSide',50,'boxcar','powerlawBW');
    figure(handles(16)); subplot(subplotParams.y, subplotParams.x, subplotParams.index);
    rectangle('Position',[0.25 0.25 0.5 0.5], 'LineStyle', '--')

    hold on;
    h=plot(bias,alternatingBias,'co');  %main

    ss=ceil(sum(goodForBias)*0.9); %last 10% of data a different color
    ee=sum(goodForBias);
    h=plot(bias(ss:ee),alternatingBias(ss:ee),'ro');

    h=plot(mean(side),mean(alternatingSide), 'Marker', '*', 'MarkerSize', 10, 'LineWidth', 4);

    set(h, 'MarkerFaceColor', [0 0 0]);
    axis([0 1 0 1]);
    set(gca,'XTickLabel','')
    set(gca,'YTickLabel','')
    title(subject)

    text(0.125, 0.5, 'L');
    text(0.875, 0.5, 'R');
    text(0.5, 0.875, 'Alt');
    text(0.5, 0.125, 'Same');
end



if plotRatePerDay
    numDays=length(trialsPerDay);
    trailsByDay=cumsum(trialsPerDay);
    ss=[1 trailsByDay(1:end-1)+1];
    ee=(trailsByDay);

    secondsPerDay=60*60*24;
    seccondsPerSession=2*60*60;
    stdInSecs=60; %in seconds
    g= fspecial('gaussian',[1 6*stdInSecs],stdInSecs);


    figure(handles(17)); subplot(subplotParams.y, subplotParams.x, subplotParams.index); hold on
    timeVec=zeros(numDays,seccondsPerSession);
    for i=1:numDays
        if (trialsPerDay(i))>0
            when=floor((d.date(ss(i):ee(i))-d.date(ss(i)))*secondsPerDay)+1;
            when=when(when<seccondsPerSession);  % don't look at trials after 1st session this day...
            timeVec(i,when)=1;  % mark each second a trial occured
            ht=-i*(10/numDays);
            plot(when,ht(ones(size(when))),'.','MarkerSize',1); %raster on the bottom
        end
    end
    rate=conv2(timeVec,g,'same')*60;
    hasTrials=trialsPerDay>0;
    mn=mean(rate(hasTrials,:));
    stdRate=std(rate(hasTrials,:));

    lastOne=max(find(hasTrials));
    plot(rate','color',[0.9,0.9,0.9])
    plot(rate(lastOne,:),'r')
    if sum(hasTrials)>10
        plot(mn-stdRate,'g')
        plot(mn+stdRate,'g')
        plot(mn,'k')
    end
    calculatePause=0;
    if calculatePause
        %the goal is to find a time when the rat no longer tries with gusto
        %this point must be a time where the trial rate is low (one trial per minute)
        %and the time must have no more rates above 63% of the peak rate
        samplePeakTime=60*10; %in seconds, like timeVec
        peakRate=nan(1, length(numDays));
        pauseInd=nan(1, length(numDays));
        peakEnd=nan(1, length(numDays));
        avgPeakRate=nan(1, length(numDays));
        peakInd=nan(1, length(numDays));
        for i=1:numDays
            if (trialsPerDay(i))>0
                peakRate(i)=max(rate(i,:));
                peakInd(i)=min(find(rate(i,:)==peakRate(i)));
                peakEnd(i)=min([size(timeVec,2) peakInd(i)+samplePeakTime]);
                avgPeakRate(i) = mean(rate(i,peakInd(i):peakEnd(i)));
                k=1; %63% of the peak rate
                threshRate=(1-(exp(-1/k))) * peakRate(i);
                lastTimeRateAboveThresh=max(find(rate(i,:)>threshRate));
                minThreshRate=1; %minimum thresh rate is 1 trial per minute
                timesNoTrials=find(rate(i,:)<minThreshRate); %note: this is dependent on filterWidth stdInSecs
                if any(timesNoTrials>lastTimeRateAboveThresh)
                    pauseInd(i)=min(timesNoTrials(timesNoTrials>lastTimeRateAboveThresh));
                else
                    pauseInd(i)=seccondsPerSession;
                end
                trialsBeforePause=sum(timeVec(i,1:pauseInd(i)));
                rewardBefore=calculateRewardPerOpenTime(d.actualRewardDuration(ss(i):ss(i)+trialsBeforePause-1));
                rewardAfter=calculateRewardPerOpenTime(d.actualRewardDuration(ss(i)+trialsBeforePause:ee(i)));
            end
        end

        %park peak and pause time
        plot(pauseInd,zeros(size(pauseInd)),'d','color',[.5,.5,.5])
        plot(peakInd,peakRate,'o','color',[.5,.5,.5])

        %last one red
        plot(pauseInd(lastOne),0,'rd')
        plot(peakInd(lastOne),peakRate(lastOne),'ro')
        %plot(peakEnd,avgPeakRate,'v')
    end
    axis([0,seccondsPerSession,-10,20]);
    yTics=[0,5,10,15];
    hrTics=1:ceil(seccondsPerSession/(60*60));
    set(gca,'YTickLabel',yTics)
    set(gca,'XTickLabel',hrTics)
    set(gca,'YTick',yTics)
    set(gca,'XTick',hrTics)
    %imagesc(rate)
end


if plotPerformancePerDaysTrial

    hoursBetweenChunks=3;
    hoursPerSession=2;
    [junk1 junk2 ss ee]=getSessionStartAndEnd(d,hoursBetweenChunks,hoursPerSession)
    numDays=length(ee);  %this really means numSession so the code could rename numDays with numSessions
    trialsPerSession=diff([0 ee]);

    %     numDays=length(trialsPerDay);
    %     trailsByDay=cumsum(trialsPerDay);
    %     ss=[1 trailsByDay(1:end-1)+1];
    %     ee=(trailsByDay);

    %figure(handles(18))
    %close (handles(18))
    figure(handles(18)); subplot(subplotParams.y, subplotParams.x, subplotParams.index);
    hold on

    smoothingWidth=50;
    perfPerDay=nan(length(ee),max(trialsPerSession));
    goodsPerDay=zeros(1,length(trialsPerSession));
    for i=1:numDays
        if (trialsPerSession(i))>0
            if sum(goods(ss(i):ee(i)))>1

                which=goods==9;  %alwyas false logical of the right size
                which(ss(i):ee(i))=goods(ss(i):ee(i));

                [performanceOnGood colors]=calculateSmoothedPerformances(d.correct(which)',smoothingWidth,'boxcar','powerlawBW');
                perfPerDay(i,1:sum(which))=performanceOnGood;
                goodsPerDay=sum(which);
                %plot(find(which)-min(find(which))+1,performanceOnGood,'color',[0,0,0], 'linewidth', 2)

            end
        end
    end

    plot(perfPerDay','color',[0.9,0.9,0.9])
    hasTrials=trialsPerSession>0;
    null=logical(zeros(size(perfPerDay)));
    hasNums=~isnan(perfPerDay);
    ind=1;
    for i=1:size(perfPerDay,2)
        thisTrial=null;
        thisTrial(:,i)=1;

        mn(ind)=max ([ 0 mean(perfPerDay(hasNums & thisTrial))]);
        stdPerf(ind)=std(perfPerDay(hasNums & thisTrial));
        ind=ind+1;
        %     mn(i)=mean(perfPerDay(find(hasTrials), find(~isnan(perfPerDay(:,1))))); %the average of all days that have trials, and all trials that are not nans
        %     stdPerf(i)=std(perfPerDay((hasTrials & ~isnan(perfPerDay(:,1))),:)); %the average of all days that have trials, and all trials that are not nans
    end
    mn(mn==0)=nan;
    stdPerf(stdPerf==0)=nan;
    %     stdPerf=std(perfPerDay(hasTrials,:));
    plot(perfPerDay(max(find(hasTrials)),:),'r')
    if sum(hasTrials)>10
        %plot(mn-stdPerf,'g')
        %plot(mn+stdPerf,'g')
        plot(mn,'k')
    end
    maxTrials=max([size(perfPerDay,2) 2])
    axis( [1 maxTrials axMin axMax])

    set(gca,'YTickLabel','50%|85%|100%')
    set(gca,'YTick',[.5, .85, 1]')
    set(gca,'XTickLabel',sprintf('%d',maxTrials))
    set(gca,'XTick',maxTrials)
    %imagesc(perfPerDay)

end

%determine all saved graphs here.
%if exist('savePath','var')
%imwrite(uint8(count),['out/' subject '/responseDensity.jpg'],'Quality',100);
%imwrite(rgbIm,['out/' subject '/rightWrongDensity.jpg'],'Quality',100);
%imwrite(uint8(255*pctCorrectDensity),['out/' subject '/pctCorrectDensity.jpg'],'Quality',100);
%saveas(responseRasterFig,[savePath '/graphs/' subject '-ResponseRaster-' datestr(max(date),29) '.png'],'png');
%saveas(rgbImFig,[savePath '/graphs/' subject '-ResponseDensity-' datestr(max(date),29) '.png'],'png');
%end



% temp=diff(find(d.correctionTrial==0))-1;
% runLenghthCT=temp(find(temp~=0));
% histCorectionTrialRunLength=histc(runLenghthCT,[1:10]);

