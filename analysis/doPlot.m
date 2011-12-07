function doPlot(plotType,d,figureHandle,subplotX,subplotY,subplotInd,goodType,removeHuman)
% doPlot(plotType,d,figureHandle,subplotX,subplotY,subplotInd)
% plots ratrix data intelligently
%
% INPUTS
% plotType = one of several predefined views
% 		'allTypes'
%  		'plotTrialsPerDay'
%  		'plotRewardTime'
%  		'percentCorrect'
% 		'plotLickAndRT'
% 		'flankerDpr'
% 		'plotTemporalROC'
% 		'plotTheBodyWeights'
% 		'plotBiasScatter'
%  		'plotBias'
%  		'plotRatePerDay'
%       'makeDailyRaster'
% d		ratrix data structure (returned by getSmalls)
% figureHandle
% subplotx
% subploty
% subplotind
%
% OUTPUTS: nothing returned
%
% EXAMPLE:
% d=getSmalls('195');
% figure; doPlot('percentCorrect',d)
% figure; doPlot('plotBias',d)

%confirm has data
hasData=0;
if strcmp(class(d),'struct')
    if any(strcmp(fields(d),'date'))
        totalTrials=size(d.date,2)
        hasData=1;
    end
end

%reject if has no data
if ~hasData
    disp(['no data!'])
    text(0.5,0.5,'no data')
    set(gca,'YTickLabel','')
    set(gca,'XTickLabel','')
    return  %ends the doPlot
end

%add defaults for missing fields
if ~strcmp('correctionTrial',fields(d))
    d.correctionTrial=zeros(size(d.correct)); %freeDrinks never defined this
end

%checkData
confirmDataMembers(d,'allTypes');
confirmDataMembers(d,plotType);

%get subject
subject=d.info.subject{1};

%determine good trials
if ~exist('goodType','var')
    goodType=[];
end
if ~exist('removeHuman','var')
    removeHuman=true;
end
goods=getGoods(d,goodType,removeHuman);

%redefine goods for bias -- no center allowed!
if any(strcmp(plotType,{'plotBias','plotBiasScatter'}))
    
    %goods=getGoods(d,'forBias',removeHuman);
    includeCenterResponses=false;
    goods=getGoods(d,'basic',removeHuman,includeCenterResponses);
    
    side=double(d.response(goods)==3); %right=1 left=0
    check=size(side,2)==sum(d.response(goods)==1)+sum(d.response(goods)==3);
    if ~check
        numLeft=sum(d.response(goods)==1)
        numRight=sum(d.response(goods)==3)
        theSum=numLeft+numRight
        numTotal=size(d.response(goods),2)
        responseTypes=unique(d.response(goods))
        error ('it seems like there are responses beside left and right');
    end
    biasSmoothingWidth=50;
    [bias colors]=calculateSmoothedPerformances(side',biasSmoothingWidth,'boxcar','powerlawBW');
end


%plot where it belongs
if exist('figureHandle','var') && ~isempty(figureHandle)
    figure(figureHandle);
    if exist('subplotX','var') && exist('subplotY','var') && exist('subplotInd','var')
        empties=cellfun(@isempty,{subplotX subplotY subplotInd});
        if any(empties)
            if ~all(empties)
                error('can''t have some empty subplot inds and some not empty')
            end
        else
            subplot(subplotX, subplotY, subplotInd);
        end
    end
else
    figureHandle=[];
end

%for multiple plots
hold on

switch plotType
    case 'plotTrialsPerDay'
        
        
        totalTrialsPerDay=makeDailyRaster(d.correct,d.date);  %in terms of ALL trials correction and kills, RETURN trialsPerDay
        goodTrialsPerDay=makeDailyRaster(d.correct,d.date,goods);
        legendStrs = {};
        if ismember('didHumanResponse',fields(d)) & ismember('containedForcedRewards',fields(d)) & ismember('didStochasticResponse',fields(d))
            %define types
            humanModified=d.containedForcedRewards==1 | d.didHumanResponse==1;
            computermodified= d.didStochasticResponse==1 & ~humanModified;
            CTs=d.correctionTrial==1 & ~ (humanModified | computermodified);
            
            %get counts
            humanTrialsPerDay=makeDailyRaster(d.correct,d.date,humanModified);
            computerTrialsPerDay=makeDailyRaster(d.correct,d.date,computermodified);
            CTsPerDay=makeDailyRaster(d.correct,d.date,CTs);
            
            %combine
            allTypes=[goodTrialsPerDay; CTsPerDay; computerTrialsPerDay ];
            legendStrs = {'good trials','correction trials','stochastic reward'};
            
            if removeHuman
                allTypes=[allTypes; humanTrialsPerDay];
                legendStrs{end+1} = 'keyboard response';
            end
            
        else
            %define types
            CTs=d.correctionTrial==1;
            %get counts
            CTsPerDay=makeDailyRaster(d.correct,d.date,CTs);
            %combine
            allTypes=[goodTrialsPerDay; CTsPerDay];
            legendStrs = {'good trials','correction trials'};
        end
        
        %check
        remainder=totalTrialsPerDay-sum(allTypes);
        if any(remainder<0)
            error('something fishy .. overlapping types!')
        end
        
        % 1/6/09 - if allTypes only has one column, this plot gets messed up for some reason
        % fix by inserting a column of zeros into allTypes and remainder
        if size(allTypes,2)==1
            allTypes=[allTypes,zeros(size(allTypes,1),1)];
            remainder(end+1)=0;
        end
        
        bar([allTypes; remainder]','stacked'), colormap(bone)
        legendStrs{end+1} = 'unaccounted for';
        set(gca,'FontSize',7);
        %title([subject '; ' datestr(min(d.date),6) '-'
        %datestr(max(d.date),6)])
        
        axis([0.5 size(goodTrialsPerDay,2)+0.5 0 1000])
        
        % legend handling
        typesPlotted = get(gcf,'UserData');
        if ~any(ismember(typesPlotted,plotType))
            legend(legendStrs, 'Location','NorthWest');
            typesPlotted{end+1}=plotType;
            set(gcf,'UserData',typesPlotted);
        end
        
    case 'plotRewardTime'
        
        [d.correctInRow runEnds d.numSwitchesThisRun]=calcAmountCorrectInRow(d.correct,d.response);
        maxN=5;
        [trialsPerDay]=makeDailyRaster(d.correct,d.date);
        [junk secondsRewardTime labelStruc]=calcDailyRewards(d,trialsPerDay,maxN);
        bar(secondsRewardTime,'stacked'), colormap(cool)
        axis([0 length(secondsRewardTime) 0 200])
        text(0.5, 150, [sprintf('x%s \n%3.0f total',char(labelStruc(3)), sum(secondsRewardTime(:)))])
        set(gca,'YTickLabel','')
        set(gca,'XTickLabel','')
        %legend (labelStruc,'Location','NorthOutside','Orientation','horizontal')
        %ylabel('H2O sec')
        %title(subject);
        %xlabel('day')
        
    case 'percentCorrect'
        
        smoothingWidth=50;
        threshold=0.85;
        axMin=0;
        axMax=1;
        dayTransitionsOn=1;
        addSteps=1;
        plotCorrectionTrialsToo=1;
        plotAfterErrorsToo=1;% this could be turned off for the basic plot and moved to "diagnostic performance"
        markTrialsToThreshold=0;
        addManualChangeMarker=1;
        doPlotPercentCorrect(d,goods,smoothingWidth,threshold,axMin,axMax,dayTransitionsOn,addSteps,plotCorrectionTrialsToo,plotAfterErrorsToo,markTrialsToThreshold,addManualChangeMarker);
        legendStrs = {};
        if plotCorrectionTrialsToo & any(d.correctionTrial)
            legendStrs{end+1}='correctionTrials';
        end
        if plotAfterErrorsToo
            legendStrs{end+1}='afterErrors';
        end
        legendStrs{end+1} = 'goodTrials';
        
        axis( [1 max([totalTrials 2]) axMin axMax])
        
        if false
            set(gca,'YTickLabel',sprintf('0%%|50%%|%2.0f%%|100%%',threshold*100))
            set(gca,'YTick',[0 .5 threshold 1])
        else
            set(gca,'YTickLabel','0%|50%|100%')
            set(gca,'YTick',[0 .5 1])
        end
        
        if totalTrials<=0
            totalTrials=1;
        end
        
        if false
            set(gca,'XTick',[0 totalTrials])
            set(gca,'XTickLabel',[num2str(0) '|' num2str(totalTrials)])
        end
        
        %legend Handling
        typesPlotted = get(gcf,'UserData');
        if ~any(ismember(typesPlotted,plotType)) && false
            legend(legendStrs, 'Location','NorthWest');
            typesPlotted{end+1}=plotType;
            set(gcf,'UserData',typesPlotted);
        end
                
    case 'perfBias'
        
        keyboard
        
        alpha=.05;
        c={'r' 'k'};
        
        %         totalAlones=sum(trials);
        %         correctAlones=sum(trials & detailRecords.correct);
        %         responseRightAlones=sum(trials & detailRecords.response==3);
        %         [phat pci]=binofit([correctAlones responseRightAlones],[totalAlones totalAlones],alpha);
        %
        %         ind=1;
        %         type.alone.perf.phat(end+1)=phat(ind);
        %         type.alone.perf.pci(end+1,:)=pci(ind,:);
        %
        %         ind=2;
        %         type.alone.bias.phat(end+1)=phat(ind);
        %         type.alone.bias.pci(end+1,:)=pci(ind,:);
        %
        %         type.sessions.alone(end+1)=i;
        %
        %
        %         makePerfBiasPlot(visual.sessions.alone,visual.alone,c);
        
    case 'plotLickAndRT'
        
        %reaction time and licks
        threshold=10;
        threshedResponseTime=d.responseTime;
        threshedResponseTime(d.responseTime>threshold)=threshold;
        threshedResponseTime(d.responseTime<0)=mean(threshedResponseTime);
        plot(threshedResponseTime,'.','MarkerSize',1,'color',[.6,.8,.6]);
        plot(conv2(single(threshedResponseTime), ones(1,100)/100,'same'),'color',[.4,.6,.4]);
        plot(conv2(single(d.numRequestLicks), ones(1,100)/100,'same'),'.','MarkerSize',1,'color',[.6,.4,.4]); hold off
        %axis( [1 max([totalTrials 2]) 0 10])
        %ylabel('rt (sec) ')
        %xlabel(sprintf('Trial Number (%d good of %d total)', sum(goods), length(goods)))
        
    case 'flankerDpr'
        
        conditionInds=getFlankerConditionInds(d,goods);
        %make fake data of the same size (eventually rand shuffle or monte carlo)
        fakeData.correctResponseIsLeft=int8(rand(1,totalTrials)>0.5);
        fakeData.correctResponseIsLeft(find(fakeData.correctResponseIsLeft==0))=-1;
        fakeData.response=uint8(rand(1,totalTrials)>0.5);
        fakeData.response(find(fakeData.response==1))=3; %set lefts
        fakeData.response(find(fakeData.response==0))=1; %set rights
        %shuffleData.correctResponseIsLeft= randperm(totalTrials) OR randperm(sum(goods))
        
        %d-prime calcs per day
        [trialsPerDay]=makeDailyRaster(d.correct,d.date);
        trialsCompletedBy=cumsum(trialsPerDay);
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
        %         axis( [1 max([totalTrials 2]) -.5 max([max(dpr(~isinf(dpr(:)))) 1])   ])
        %         ylabel('dprime')
        
    case 'plotTemporalROC'
        
        if 0 %analyze per condition
            
            
            
            smoothingWidth=1000; %with four conditions should be about 100 per condition (hits+misses)
            segments=[smoothingWidth:smoothingWidth:(floor(totalTrials/smoothingWidth))*smoothingWidth];
            numColors=min([size(segments,2) 100]);
            blockEnds=[segments totalTrials];
            conditionInds=getFlankerConditionInds(d,goods);
            startColor=[0.9,0.9,0.9;
                0.9,0.9,0.9;
                0.9,0.9,0.9;
                0.9,0.9,0.9;
                0.9,0.9,0.9];
            endColor=[0.9,0.9,0.9; %all his light gray
                0.9,0.1,0.1; %vv is red
                0.5,0.9,0.9; %vh is cyan
                0.5,0.9,0.9; %hv is cyan
                0.5,0.9,0.9];     %hh is cyan
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
        temp=cell2mat(dprStats);
        hits=reshape([temp.hits], size(temp,1),size(temp,2));
        CR=reshape([temp.correctRejects], size(temp,1),size(temp,2));
        misses=reshape([temp.misses], size(temp,1),size(temp,2));
        FA=reshape([temp.falseAlarms], size(temp,1),size(temp,2));
        
        hitRate=[hits./(hits+misses)];
        FARate=[FA./(FA+CR)];
        
        for i=1:size(startColor,1)
            colorplot(FARate(i,:),hitRate(i,:), numColors,startColor(i,:),endColor(i,:));
        end
        title(sprintf ('ROC Curve %s ', subject));
        ylabel('Hit Rate'); xlabel('False Alarm Rate');
        axis([0 1 0 1])
        
    case 'plotBias'
        
        plot(find(goods),bias,'color',[0,0,0.8], 'linewidth', 2);
        plot([0 length(goods)],[0.5 0.5],'color',[0.5,0.5,0.5]);
        
        axis([1 max([totalTrials 2]) 0 1]);
        set(gca,'XTickLabel','')
        set(gca,'YTickLabel',{'L','R'})
        set(gca,'YTick',[0 1])
        
    case 'plotBiasScatter'
        
        biasSegmentWidth=100;
        segments=[biasSegmentWidth:biasSegmentWidth:(floor(totalTrials/biasSegmentWidth))*biasSegmentWidth];
        %numColors=min([size(segments,2) 100]);
        blockEnds=[segments totalTrials];
        alternatingSide=diff([nan side])~=0;
        [alternatingBias colors]=calculateSmoothedPerformances(alternatingSide',50,'boxcar','powerlawBW');
        rectangle('Position',[0.25 0.25 0.5 0.5], 'LineStyle', '--')
        
        h=plot(bias,alternatingBias,'co');  %main
        
        ss=ceil(sum(goods)*0.9); %last 10% of data a different color
        ee=sum(goods);
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
        
    case 'plotRatePerDay'
        
        [trialsPerDay]=makeDailyRaster(d.correct,d.date);
        numDays=length(trialsPerDay);
        trailsByDay=cumsum(trialsPerDay);
        ss=[1 trailsByDay(1:end-1)+1];
        ee=(trailsByDay);
        
        secondsPerDay=60*60*24;
        seccondsPerSession=2*60*60;
        stdInSecs=60; %in seconds
        g= fspecial('gaussian',[1 6*stdInSecs],stdInSecs);
        
        
        timeVec=zeros(numDays,seccondsPerSession);
        for i=1:numDays
            if (trialsPerDay(i))>0
                when=floor((d.date(ss(i):ee(i))-d.date(ss(i)))*secondsPerDay)+1;
                when=when(when<seccondsPerSession);  % don't look at trials after 1st session this day...
                % 3/6/09 - somehow we got non monotonically increasing dates (maybe something changed the clock)
                when(when<=0)=[];
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
            
            %plok peak and pause time
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
        
        
    case 'plotITI'
        
        maxITIseconds=30; %only look at trials with less than 1/2 minute ITI
        hoursBetweenChunks=3;
        hoursPerSession=2;
        
        [junk1 junk2 ss ee]=getSessionStartAndEnd(d,hoursBetweenChunks,hoursPerSession);
        numSessions=length(ee);
        trialsPerSession=diff([0 ee]);
        
        ITIPerSession=nan(length(ee),max(trialsPerSession));
        ITI=[nan diff(d.date*24*60*60)];
        for i=1:numSessions
            if (trialsPerSession(i))>1
                which=logical(zeros(size(goods)));
                which(ss(i):ee(i))=goods(ss(i):ee(i));
                ITIPerSession(i,1:sum(which))=ITI(which);
                ITIPerSession(i,1)=nan; %remove the one that was all of last day
            end
        end
        ITIPerSession(ITIPerSession>maxITIseconds)=nan;
        ITIPerSession(ITIPerSession<0)=nan; %remove trials with "negative durations" (clock reset)
        plot(ITIPerSession','color',[0.9,0.9,0.9])
        
        hasTrials=trialsPerSession>0;
        null=logical(zeros(size(ITIPerSession)));
        hasNums=~isnan(ITIPerSession);
        ind=1;
        for i=1:size(ITIPerSession,2)
            thisTrial=null;
            thisTrial(:,i)=1;
            
            mnITI(ind)=max ([ 0 mean(ITIPerSession(hasNums & thisTrial))]);
            stdITI(ind)=std(ITIPerSession(hasNums & thisTrial));
            ind=ind+1;
        end
        mnITI(mnITI==0)=nan;
        hold on
        stdITI(stdITI==0)=nan;
        if sum (hasTrials)>10
            %plot(mnITI-stdITI,'g')
            %plot(mnITI+stdITI,'g')
            plot(mnITI,'k')
        end
        
        title(subject)
        ylabel('ITI')
        xlabel('trial #')
        
    case 'makeDailyRaster'
        smoothingWidth=100;
        minsPerBin=5;
        junk=makeDailyRaster(d.correct,d.date,goods,smoothingWidth,minsPerBin,subject,true,[],[],true,false); %in terms of good trials, PLOT NOT SAVED
    otherwise
        plotType=plotType
        error('unknown plot type')
end




function succ=confirmDataMembers(d,plotType)

switch plotType
    case 'allTypes'
        requiredFields={'date','info'};
    case 'plotTrialsPerDay'
        requiredFields={'response','correctionTrial'};
    case 'plotRewardTime'
        requiredFields={'correct','response','actualRewardDuration'};
    case 'percentCorrect'
        requiredFields={'correct','step'};
    case 'plotLickAndRT'
        requiredFields={'responseTime','numRequestLicks'};
    case 'flankerDpr'
        requiredFields={'correct','response','targetOrientation','flankerOrientation','correctResponseIsLeft'};
    case 'plotTemporalROC'
        requiredFields={'correct','response','targetOrientation','flankerOrientation','correctResponseIsLeft'};
    case 'plotTheBodyWeights'
        requiredFields={'date'};
    case 'plotBiasScatter'
        requiredFields={'response'};
    case 'plotBias'
        requiredFields={'response'};
    case 'plotRatePerDay'
        requiredFields={'date'};
    case 'plotITI'
        requiredFields={'date'};
    case 'makeDailyRaster'
        requiredFields={'date','correct'};
    case 'perfBias'
        requiredFields={'date','correct','response','step','correctionTrial'};
    otherwise
        plotType=plotType
        error('unknown plot type')
end

succ=0;
f=fields(d);
for i=1:size(requiredFields,2)
    if ~any(strcmp(requiredFields{i},f))
        error(sprintf('data must have %s field for %s analysis',requiredFields{i},plotType))
    end
    
    %checks: all data the same length (for each trial)
    if max(size(d.info.subject))>1
        d.info.subject
        error('something really wrong; only one rat allowed in data file')
    end
end
succ=1;
