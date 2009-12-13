function doCuedGoNoGoAnalysis 
%this function does the analysis for 


renderNoLickTirals=0;

location=-2;  % -2 is local, empty or 1 is from philip's male server
dateRange=[]; %empty is everything
d=getSmalls('demo1',dateRange,location);

% Note: in the future we would like to implement this in order to check
% targetIsPresent=checkTargetIsPresent(sm,details);
% however, currently there isn't method to do the switch protocolType so
% for the time being d.targetContrast shall be used in order to check if
% target is present.

targetIsPresent = d.targetContrast~=0;

correctHits= targetIsPresent==1 & d.correct==1;
correctRejects= targetIsPresent==0 & d.correct==1;
falseAlarms = targetIsPresent==0 & d.correct==0;
falseMisses = targetIsPresent==1 & d.correct==0;

trialsWithLicks=cellfun(@(x) ~isnan(x(1)),d.lickTimes);
processOrder = [find(correctHits) find(falseAlarms) find(correctRejects) find(falseMisses)];
groupID=[ones(1,sum(correctHits)) 2*ones(1,sum(falseAlarms)) 3*ones(1,sum(correctRejects)) 4*ones(1,sum(falseMisses))];
colors=[1 0 0; 0 0 1; 0 1 0; 1 1 0];
counter=0;
figure(1);
hold on;
n=length(processOrder);
fill([.01 .21, .21, .01], [-n -n n n],[.8 .8 .8])
for i=(1:length(processOrder))
    trialNumber=processOrder(i);
    if renderNoLickTirals
    counter=counter+1;
    else
        if trialsWithLicks(trialNumber)
            counter=counter+1;
        end
    end
    plot(d.lickTimes{trialNumber}, -counter, '.', 'Color', colors(groupID(i),:));
    if groupID(i)==1 | groupID(i)==2
        plot(d.lickTimes{trialNumber}(end), -counter, 'ok');
    end
end
xlabel('time')
axis([-10 4 -counter 0])
set(gca, 'yTick', [-36 -34 -27 -10], 'yTickLabel', {'flaseMisses', 'correctReject', 'falseAlarms', 'correctHits'});

%interesting figure to look at maybe...
figure(2); hold on;
fill([.01 .21, .21, .01], [0 0 length(d.trialNumber) length(d.trialNumber)],[.8 .8 .8])
for i=(1:length(d.trialNumber))
    if correctHits(i)==1
        plot(d.lickTimes{i}, d.trialNumber(i), '.', 'Color', [1 0 0])
        plot(d.lickTimes{i}(end), d.trialNumber(i), 'ok');
    elseif falseAlarms(i)==1
        plot(d.lickTimes{i}, d.trialNumber(i), '.', 'Color', [0 0 1])
        plot(d.lickTimes{i}(end), d.trialNumber(i), 'ok');
    elseif correctRejects(i)==1
        plot(d.lickTimes{i}, d.trialNumber(i), '.', 'Color', [0 1 0])
    elseif falseMisses(i)==1
        plot(d.lickTimes{i}, d.trialNumber(i), '.', 'Color', [1 1 0])
    end
xlabel('time')
ylabel('trials')
end    
% 
% %this was something I was trying out... can ignore.
% figure 
% hold on
% plot(d.trialNumber, 6+correctHits, '.', 'Color', [1 0 0])
% plot(d.trialNumber, 6, '.', 'Color', [1 1 1])
% plot(d.trialNumber, 4+falseAlarms, '.', 'Color', [0 1 0])
% plot(d.trialNumber, 4, '.', 'Color', [1 1 1])
% plot(d.trialNumber, 2+correctRejects, '.', 'Color', [0 0 1])
% plot(d.trialNumber, 2, '.', 'Color', [1 1 1])
% plot(d.trialNumber, falseMiss, '.', 'Color', [1 0 1])
% plot(d.trialNumber, 0, '.', 'Color', [0 0 0])
% set(gca, 'yTick', [1 3 5 7 9], 'yTickLabel', {'falseMiss', 'correctMiss', 'falseHits', 'correctHits', 'all'})
% 
% figure
% hist(d.discrimStart)  % shows the various delays
% d.lickTimes % all the lick times
% lickTimes=cell2mat(d.lickTimes);
% 
% h=scatterplot(lickTimes)
% title('cuedGoNoGo')
% xlabel('time')
% ylabel('licks')
% 
% which=d.correct==1 & d.step~=11;  % a filter of logicals
% x=removeSomeSmalls(d,which);
% 
% %another example of filtering
% trialsWithoutLicks=cellfun(@(x) isnan(x(1)),d.lickTimes);
% x=removeSomeSmalls(d,trialsWithoutLicks);
% 
% allLickTimes=cell2mat(d.lickTimes);  % throws out trial info, but good quick check
% allLickTimes(isnan(allLickTimes))=[];
% hist(allLickTimes) % many licks are before the discrim time = 0
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
