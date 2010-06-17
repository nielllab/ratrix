function [trialsPerDay correctPerDay]=makeDailyRaster(correct,response,date,which,smoothingWidthForPerformance,minsPerBin,subject,usingPerformance,handles,subplotParams,plotResponseDensity,plotResponseRaster,savePath)
%[trialsPerDay correctPerDay]=makeDailyRaster(d.correct,d.date);
%[trialsPerDay correctPerDay]=makeDailyRaster(d.correct,d.date,[],100,60*12,subject,1,1,savePath);
%junk=makeDailyRaster(d.correct,d.date,goods,smoothingWidth,5,subject,1,handles,subplotParams,plotResponseDensity,plotResponseRaster); %in terms of good trials, PLOT NOT SAVED
%[trialsPerDay correctPerDay]=makeDailyRaster(d.correct,d.date,goods,100,60*12,subject,0,[],[],0,0);


if ~exist('which','var') | isempty(which)
    which=true(1,length(date));
end

if ~exist('minsPerBin','var'); minsPerBin=[]; end
if isempty(minsPerBin)
     minsPerBin=12*60;  %half a day is fast and won't error
end
   

if ~exist('usingPerformance','var'); usingPerformance=[]; end
if isempty(usingPerformance)
     usingPerformance=0;  
end

if ~exist('plotResponseDensity','var'); plotResponseDensity=[]; end
if isempty(plotResponseDensity)
     plotResponseDensity=0;
end

if ~exist('plotResponseRaster','var'); plotResponseRaster=[]; end
if isempty(plotResponseRaster)
     plotResponseRaster=0;
end


verbose=0;
numTrials=size(date,2);
if numTrials>0

    %make sure the bins come from the same time bin, regardless which are selected for analysis
         correct=[correct(1) correct(which) correct(end)];
         date=[date(1) date(which) date(end)]; 
         response=[response(1) response(which) response(end)]; % only used for raster dots now. not core
      
    
    
    if usingPerformance
        [performance]=calculateSmoothedPerformances(correct',smoothingWidthForPerformance,'boxcar','powerlawBW');
    else
        performance=zeros(1,length(correct));
    end


    if verbose
        disp(['calculating dates in daily raster for ' num2str(numTrials) ' trials'])
    end

    empty=zeros(1,length(date));

    [year month day hour minute seconds]=datevec(date);
    absDay=datenum(year, month, day);
    pctTime=datenum(empty, empty, empty, hour, minute, seconds);

    [dayAfterStart b dayIndex]=unique(absDay);
    dayAfterStart=dayAfterStart-dayAfterStart(1)+1;

    %minsPerBin=5;
    numTimeBins=floor(24*60./minsPerBin);
    numDays=max(absDay)-min(absDay)+1;

    if verbose
        disp('building density in daily raster')
    end

    dayEdges=floor(min(date)):ceil(max(date));
    numTimeBins=floor(24*60./minsPerBin);
    timeEdges=[0:numTimeBins]./numTimeBins;
    trialsPerDay=histc(date,dayEdges);
    trialsPerDay=trialsPerDay(1:end-1); %removes the excess bin usually equal to 0 but only equal to 1 if last trial happens exactly at midnight
    dayEnd=[cumsum(trialsPerDay)];
    dayStart=[1 dayEnd(1:end-1)+1];
    numDays=size(trialsPerDay,2);
    count=zeros(numDays,numTimeBins);
    correctCount=zeros(numDays,numTimeBins);
    pctCorrectDensity=0.5*ones(numDays,numTimeBins);
    for i=1:numDays
            %trialsPerTimeThisDay could be used to skip the second forloop if not using performance
            [trialsPerTimeThisDay bin]=histc(date(dayStart(i):dayEnd(i))-dayEdges(i),timeEdges);
            performanceChunk=performance(dayStart(i):dayEnd(i));
            correctChunk=correct(dayStart(i):dayEnd(i));
        for j=1:numTimeBins
            which=(bin==j);
            count(i,j)= sum(which);
            correctCount(i,j)= sum(correctChunk(which));
            wrongCount(i,j)= sum(correctChunk(which)~=1);
            if ~isempty(performanceChunk) && sum(which)>0
                sum(which);
                pctCorrectDensity(i,j)=mean(performanceChunk(which));
            end
        end
    end


    %trialsPerTimeOfDay=sum(count);
    trialsPerDay=sum(count,2)';
    correctPerDay=sum(correctCount,2)';
    
    %remove the ones added to fix the time range
    trialsPerDay(1)=trialsPerDay(1)-1;
    trialsPerDay(end)=trialsPerDay(end)-1;
    correctPerDay(1)=correctPerDay(1)-1;
    correctPerDay(end)=correctPerDay(end)-1;
    

    if plotResponseDensity

        rgbIm=zeros(size(count));
        %rgbIm(:,:,1)=uint8(count);
        %rgbIm(:,:,2)=uint8(correctCount);
        %rgbIm(:,:,3)=uint8(wrongCount);

        % threeIm(:,:,1)=0.4*correctCount/max(count(:)); %Hue 0--> 0.4 = incorrect --> correct
        % threeIm(:,:,2)=count/max(count(:)); %Saturation = trialRate
        % threeIm(:,:,3)=correctCount/max(count(:)); %Value = bias  OVERRIDE
        % threeIm(:,:,3)=0.5*ones(size(count));      %Value = bias

        nonLinearWarp= @(x) atan(x*4*pi) / atan(4*pi);
        %plot(nonLinearWarp([0:.01:1]))  %non linearity
        correctIm=correctCount./count;
        countIm=nonLinearWarp(count./max(count(:)));
        correctIm=correctIm-.5;
        correctIm(correctIm<0)=0; % below chance plotted the same color
        correctIm=correctIm*.8; %Hue 0--> 0.4 = chance --> correct
        
        threeIm(:,:,1)=(correctIm); 
        threeIm(:,:,2)=1*ones(size(count));      %Saturation =  could be bias! OVERRIDE
        threeIm(:,:,3)=countIm; %Value = trialRate
        rgbIm=hsv2rgb(threeIm);

        %squarify
        if size(rgbIm,1)<size(rgbIm,2)
            vertStrech=floor(size(rgbIm,2)/size(rgbIm,1));
            rgbIm=imresize(rgbIm,[size(rgbIm,1)*vertStrech size(rgbIm,2)]);
        end 
        
        imshow(rgbIm);
        C=hsv2rgb([linspace(0, .4, 256);...
            linspace(1, 1, 256);...
            linspace(.9, .9, 256)]');
        colormap(C)
        colorbar
        %colormap(0.85*hsv(256));  % approximate colormap --> make better
        %rgbImFig=gcf;
    end


    if plotResponseRaster
        %error('turned off.. handle figures  better')
        contextInfo=[subject ' between ' datestr(min(date),22) ' and ' datestr(max(date),22)];
        correct=logical(correct);
        response=response-2; %making it -/+ 1 for left/right
        hold on; plot(pctTime( correct),0.1*response( correct)+dayAfterStart(dayIndex( correct)),'g.');
        hold on;  plot(pctTime(~correct),0.1*response(~correct)+dayAfterStart(dayIndex(~correct)),'r.'); 
        %plot(pctTime(~response),0.1+dayAfterStart(dayIndex(~response==1)),'r.'); %after the -2 these are the rightwards
        title(['Right and Wrong Raster for ' contextInfo])
        

        
        xlabel('Time of Day')
        ylabel(['Days after ' datestr(max(date),22)])
        set(gca,'YTick',[0 max(dayAfterStart)])
        set(gca,'YTickLabel',sprintf('day %s|%d ',datestr(max(date),22), max(dayAfterStart)))
        set(gca,'XTick',[0.25 0.5 0.75 1])
        set(gca,'XTickLabel',('dawn|noon|dusk|midnight'))
        %responseRasterFig=gcf;
        %figure; imagesc(rgbIm)
        %figure; bar(trialsPerTimeOfDay); title(['Time Of Day Trials Completed- ' contextInfo])
    end

    %if exist('savePath','var')
    %imwrite(uint8(count),['out/' subject '/responseDensity.jpg'],'Quality',100);
    %imwrite(rgbIm,['out/' subject '/rightWrongDensity.jpg'],'Quality',100);
    %imwrite(uint8(255*pctCorrectDensity),['out/' subject '/pctCorrectDensity.jpg'],'Quality',100);
    %saveas(responseRasterFig,[savePath '/graphs/' subject '-ResponseRaster-' datestr(max(date),29) '.png'],'png');
    %saveas(rgbImFig,[savePath '/graphs/' subject '-ResponseDensity-' datestr(max(date),29) '.png'],'png');
    %end
    %
else
    trialsPerDay=0;
    correctPerDay=0;
end