function plotBodyWeights(subjects,lastNdays,subplotParams,figureHandle,useBodyWeightCache)
% this function plots an array of body weight checks
% subject is a cell array of subject names
% subplotParams has single numbers x and y, and an index for every subject
% figureHandle specifies which figure to plot in
% useBodyWeightCache is a logical of whether or not to skip loading and use
% the cache

if ~exist('subjects','var'); subjects=[]; end
if isempty(subjects)
    % HEAT       %1        %2       %3        %4     %overnight
    subjects={'rat_140','rat_141','rat_142','rat_143','rat_144';... %3  upper-left
        'rat_145','rat_146','rat_147','rat_148','rat_129';... %11 upper-right
        'rat_112','rat_126','rat_102','rat_106','rat_127';... %1  middle-left
        'rat_115','rat_116','rat_117','rat_130','rat_114';... %9  middle-right
        'rat_132','rat_133','rat_138','rat_139','rat_128';... %2  lower-left
        'rat_134','rat_135','rat_136','rat_137','rat_131'};   %4  lower-right

    if ~exist('subplotParams','var'); subplotParams = []; end
    if isempty(subplotParams)

        subplotParams.x = size(subjects,1);
        subplotParams.y = size(subjects,2);
        subplotParams.index = 1: size(subjects,1)*size(subjects,2);
    end

end
numSubjects=size(subjects,1)*size(subjects,2);

if ~exist('subplotParams','var'); subplotParams = []; end
if isempty(subplotParams)
    subplotParams.x=1;
    subplotParams.y = 1;
    subplotParams.index = 1;
    %     subplotParams.x = size(subjects,1);
    %     subplotParams.y = size(subjects,2);
    %     subplotParams.index = 1: numSubjects;
end


if ~exist('figureHandle','var'); figureHandle = []; end
if isempty(figureHandle)
    figureHandle = -1;
    subplotParams.index=1;
    subplotParams.x=1;
    subplotParams.y=1;

else
    % check to see that there is an index for each subject
    if numSubjects ~= size(subplotParams.index, 2)
        error('there must be a plot location for each subject');
    end
end

if ~exist('lastNdays','var'); lastNdays = []; end
if isempty(lastNdays)
    lastNdays = 9999;
end

if ~exist('useBodyWeightCache','var'); useBodyWeightCache = []; end
if isempty(useBodyWeightCache)
    useBodyWeightCache = 0;
end

if useBodyWeightCache
    % this won't get new body weights, but loads a local copy
    load(fullfile('tempVariables', 'BWs'),'s');
else

    for i=1:numSubjects
        disp(['getting bodyweights for ' subjects{i}])
        [weights BWdates thresh] = getBodyWeightHistory(subjects{i});

        s{i}.ID=subjects{i};
        s{i}.weights=weights;
        s{i}.BWdates=BWdates;
        s{i}.thresh=thresh;
    end
    %save(fullfile('tempVariables', 'BWs'),'s');
    % because we have commented out the line above, there is no more cache
    % the last cache is way out of date, generated on Mar 10, 2008
end

% converting s{}.ID to a usable format
for i = 1:size(s,2)
    IDs{i} = s{i}.ID;
end

thresholdInDataBase=0.85;  % this must be sync'd with the definition in the database!


%% basic

if figureHandle == -1
    %figureHandle = figure;
else
    figure(figureHandle);
end

for which =1:numSubjects
    disp(subjects(which))
    i = find(strcmp(subjects(which),IDs)); % find the index of the subject
    sp2(i)=subplot(subplotParams.y, subplotParams.x, subplotParams.index(which));
    hold on;
    %    get(h(i));
    %children = get(figureHandle, 'children');
    %a2(i)=children(end);  %save the most recent addition for later

    %a2(i)=get(h(i),'children');  %save this one for later
    %a2(i)=axes;
    a2(i)=sp2(i);
    set(a2(i),'YAxisLocation','right')  %for left plots
    %a1(i)=axes;
    sp1(i)=subplot(subplotParams.y, subplotParams.x, subplotParams.index(which), 'align');
    a1(i) = sp1(i);
    set(a1(i),'YAxisLocation','left')
    hold on;

    %     s
    %     size(s)
    %     datestr(s{1}.BWdates(end))
    %     datestr(floor(now-lastNdays))
    %     i
    %     subjects(which)
    %     IDs
    dateFilter=s{i}.BWdates>floor(now)-lastNdays;
    under=(s{i}.weights<s{i}.thresh);
    ref=s{i}.BWdates(1); %reference date --should be the birthday!  now using first measure
    lastWeekBoundary=floor(now)-7.5-ref;
    weekFilter=s{i}.BWdates>floor(now)-7.5;
    ref=s{i}.BWdates(1); %reference date --should be the birthday!  now using first measure

    title(IDs(i));

    if sum(dateFilter)>0 %plot if there is data

        %set the left axis
        labeledY1=unique(floor(sort([min(s{i}.weights(dateFilter)),max(s{i}.weights(dateFilter)),max(s{i}.thresh(dateFilter))])));
        set(a1(i),'YTick',labeledY1)
        set(a1(i),'YTickLabel',labeledY1)

        %set the scale of both axis equal
        forceToGlobalYLim=1;
        globalYLim=[0 1.2];
        if forceToGlobalYLim
            theLim=globalYLim*max(s{i}.thresh(~isnan(s{i}.thresh)))/thresholdInDataBase;
            set(a1(i),'YLim',theLim)
            set(a2(i),'YLim',theLim)
        else
            set(a2(i),'YLim',get(a1(i),'YLim'))
        end
        theXLim=[min(s{i}.BWdates(dateFilter)-ref), max(s{i}.BWdates(dateFilter)-ref)];
        if isempty(theXLim)
            theXLim=floor([now-ref-lastNdays now-ref]);
        end
        set(a1(i),'XLim',theXLim)
        set(a2(i),'XLim',theXLim)

        %set the right axis
        averageWeight=max(s{i}.thresh(dateFilter))/thresholdInDataBase;  %this is the expected weight of a healthy animal for the most recent sample
        labeledY2= unique(sort([s{i}.weights(end),max(s{i}.thresh(~isnan(s{i}.thresh)))]));
        labeledY2val=labeledY2/averageWeight;
        if length(labeledY2)==2
            labeledY2str={num2str(labeledY2val(1),2),num2str(labeledY2val(2),2)};
        else %must only be one... happens ocassionaly from the unique
            labeledY2str={num2str(labeledY2val(1),2)};
        end
        set(a2(i),'XTick',[])
        set(a2(i),'YTick',labeledY2)
        set(a2(i),'YTickLabel',labeledY2str)
        %axes('position', RECT)


        indicator=0;
        if indicator
            %calculate problems in the last week
            indicatorX=lastWeekBoundary;
            indicatorY=1.1*max(s{i}.thresh(~isnan(s{i}.thresh)))/thresholdInDataBase;
            hx=scatter(indicatorX,indicatorY);
            if sum(weekFilter)>0
                fractionUnder=sum(weekFilter & under)/sum(weekFilter);
                if fractionUnder>0.45
                    %BAD! indicate with big x
                    set(hx,'CData',[1,0,0],'Marker', 'x','SizeData',700,'LineWidth',4)
                elseif fractionUnder>0
                    %warning!
                    set(hx,'CData',[1,1,0],'Marker', 'o','SizeData',700,'LineWidth',4)
                else
                    set(hx,'CData',[0,1,0],'Marker', '.','SizeData',700,'LineWidth',4)
                end
            else
                %no data to judge!
                set(hx,'CData',[1,0.5,0],'Marker', 'd','SizeData',700,'LineWidth',4)
                htxt=text(lastWeekBoundary,1.1*max(s{i}.thresh)/thresholdInDataBase,'no data')
            end
        end


        %plot the lines
        hw(i)=plot(s{i}.BWdates(dateFilter)-ref,s{i}.weights(dateFilter)); %animals measured wieght
        ht(i)=plot(s{i}.BWdates(dateFilter)-ref,s{i}.thresh(dateFilter)); %threshold as defined in dataBase
        havg(i)=plot(s{i}.BWdates(dateFilter)-ref,s{i}.thresh(dateFilter)/thresholdInDataBase,'--'); %freewater animal
        hb(i)=plot([lastWeekBoundary,lastWeekBoundary],get(gca,'YLim')); %boundary a week ago
        set(hw(i),  'color',[0.9,0.9,1])
        set(ht(i),  'color',[0,0,0])
        set(havg(i),'color',[0.9,0.9,0.9])
        set(hb(i),'color',[0.7,0.7,0.7])

        %color the data points
        hu(i)=scatter(s{i}.BWdates(under & dateFilter)-ref,s{i}.weights(under & dateFilter));
        ho(i)=scatter(s{i}.BWdates(~under & dateFilter)-ref,s{i}.weights(~under & dateFilter));
        set(ho(i),'CData',[0,0.8,0],'Marker', '.')
        set(hu(i),'CData',[0,0.5,0],'Marker', '+')




        %normalized=(s{i}.weights(dateFilter)./s{i}.thresh(dateFilter))';
        %danger=(NdaysAgoBW-currentBW)<fractionLoss;

        %test
        %     normalized=[ 0.7*ones(1,20) 0.6*ones(1,20)];
        %         dateFilter=logical(ones(size(normalized)))'
        %             hd(i)=scatter(s{i}.BWdates(danger & dateFilter)-ref,normalized(danger & dateFilter));
        %             scatter(s{i}.BWdates(dateFilter)-ref,normalized(dateFilter));


        %test different danger setting
        BWs=s{i}.weights';

        overNdays=10;
        fractionChange=0.003;
        sustainedDays=3;
        lackOfGrowth=findBadBWs(BWs,overNdays,fractionChange,sustainedDays);
        %hlg(i)=scatter(s{i}.BWdates(lackOfGrowth & dateFilter)-ref,s{i}.weights(lackOfGrowth & dateFilter));
        %set(hlg(i),'CData',[0.8,0.2,1],'Marker', '.','SizeData',20)
        %     sum(lackOfGrowth)
        %     sum(dateFilter)
        %     size(lackOfGrowth)
        %     size(dateFilter)
        if sum(lackOfGrowth & dateFilter)>0

            hlg(i)=plot(s{i}.BWdates(lackOfGrowth & dateFilter)-ref,s{i}.weights(lackOfGrowth & dateFilter),'.');
            set(hlg(i),'Color',[0.8,0.2,1],'Marker', '.','MarkerSize',10)
        end

        overNdays=3;
        fractionChange=-0.03;
        sustainedDays=1;
        danger=findBadBWs(BWs,overNdays,fractionChange,sustainedDays);
        %hd(i)=scatter(s{i}.BWdates(danger & dateFilter)-ref,s{i}.weights(danger & dateFilter));
        %set(hd(i),'CData',[1,0.8,0],'Marker', '.','SizeData',20)
        if sum(danger & dateFilter)>0
            hd(i)=plot(s{i}.BWdates(danger & dateFilter)-ref,s{i}.weights(danger & dateFilter),'.');
            set(hd(i),'Color',[1,0.8,0],'Marker', '.','MarkerSize',10)
        end

        overNdays=4;
        fractionChange=-0.04;
        sustainedDays=2;
        sustainedDanger=findBadBWs(BWs,overNdays,fractionChange,sustainedDays);
        %hsd(i)=scatter(s{i}.BWdates(sustainedDanger & dateFilter)-ref,s{i}.weights(sustainedDanger & dateFilter));
        %set(hsd(i),'CData',[1,0.1,.1],'Marker', '.','SizeData',20)
        if sum(sustainedDanger & dateFilter)>0
            hsd(i)=plot(s{i}.BWdates(sustainedDanger & dateFilter)-ref,s{i}.weights(sustainedDanger & dateFilter),'.');
            set(hsd(i),'Color',[.8,0.1,.1],'Marker', '.','MarkerSize',20)
        end




        if strcmp(subjects{i},'102')

        end

        %the legend
        %     %legend(a1(i),subjects{i},'Location','northWest') % TOO BIG


        %     if size(subjects,2) == 1
        %         % if plotting one rat at a time
        %             title(IDs(1));
        %             % if you don't do this, everyone ends up with the same name
        %     else
        %         % if plotting multpile rat at a time
        %             title(IDs(which));
        %     end

        title(IDs(i));

        %set the left axis
        labeledY1=unique(floor(sort([min(s{i}.weights(dateFilter)),max(s{i}.weights(dateFilter)),max(s{i}.thresh(dateFilter))])));
        set(a1(i),'YTick',labeledY1)
        set(a1(i),'YTickLabel',labeledY1)

        %set the scale of both axis equal
        forceToGlobalYLim=1;
        globalYLim=[0 1.2];
        if forceToGlobalYLim
            theLim=globalYLim*max(s{i}.thresh(~isnan(s{i}.thresh)))/thresholdInDataBase;
            set(a1(i),'YLim',theLim)
            set(a2(i),'YLim',theLim)
        else
            set(a2(i),'YLim',get(a1(i),'YLim'))
        end
        theXLim=[min(s{i}.BWdates(dateFilter)-ref), max(s{i}.BWdates(dateFilter)-ref)];
        set(a1(i),'XLim',theXLim)
        set(a2(i),'XLim',theXLim)

        %set the right axis
        averageWeight=max(s{i}.thresh(dateFilter))/thresholdInDataBase;  %this is the expected weight of a healthy animal for the most recent sample
        labeledY2= unique(sort([s{i}.weights(end),max(s{i}.thresh(~isnan(s{i}.thresh)))]));
        labeledY2val=labeledY2/averageWeight;   
        if length(labeledY2)==2
            labeledY2str={num2str(labeledY2val(1),2),num2str(labeledY2val(2),2)};
        else %must only be one... happens ocassionaly from the unique
            labeledY2str={num2str(labeledY2val(1),2)};
        end        
        set(a2(i),'XTick',[])
        set(a2(i),'YTick',labeledY2)
        set(a2(i),'YTickLabel',labeledY2str)
        %axes('position', RECT)
    else
        text(.5,.5,sprintf('no weight measured\n in last %d days',lastNdays))
    end
end
%% For Reference
if 0
    figure; hold on
    for i=1:numSubjects
        plot(s{i}.BWdates,s{i}.weights);
    end

    %normalized to first entry and weight
    figure; hold on
    for i=1:numSubjects
        hw(i)=plot(s{i}.BWdates-ref,s{i}.weights/s{i}.weights(1));
        set(hw(i),'color',[0.8,0.8,0.8])
    end

    %normalized to first entry
    figure; hold on
    for i=1:numSubjects
        ref=s{i}.BWdates(1); %reference date --should be the birthday!  now using first measure
        hw(i)=plot(s{i}.BWdates-ref,s{i}.weights);
        set(hw(i),'color',[0.8,0.8,0.8])
    end



    which=26;
    %legend(subjects{which},'Location','SouthEast')
    for i=which
        hw(i)=plot(s{i}.BWdates-ref,s{i}.weights);
        ht(i)=plot(s{i}.BWdates-ref,s{i}.thresh);
        set(hw(i),'color',[0,0,1])
        set(ht(i),'color',[0,0,0])
        under=(s{i}.weights<s{i}.thresh);
        ref=s{i}.BWdates(1); %reference date --should be the birthday!  now using first measure
        hu(i)=scatter(s{i}.BWdates(under)-ref,s{i}.weights(under));
        ho(i)=scatter(s{i}.BWdates(~under)-ref,s{i}.weights(~under));
        set(ho(i),'CData',[0,0.6,0],'Marker', '.');
        set(hu(i),'CData',[0.6,0,0],'Marker', '+');
    end
end


function sustainedDanger=findBadBWs(BWs,overNdays,fractionChange,sustainedDays)
NdaysAgoBW=[BWs zeros(1,overNdays) ];
currentBW=[ones(1,overNdays) BWs ];
unacceptableChange=fractionChange*NdaysAgoBW;
danger=(NdaysAgoBW-currentBW)<unacceptableChange;
danger=[zeros(1,overNdays) danger( overNdays+1:end-overNdays )]';
[sustainedDanger runEnds]=calcAmountCorrectInRow(danger');
sustainedDanger=(sustainedDanger>=sustainedDays)';