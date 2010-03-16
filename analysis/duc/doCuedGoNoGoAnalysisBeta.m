function doCuedGoNoGoAnalysisBeta

dateRange=[];
getLicks=true;
location= -2; %-2 is local, 1 is server
d=getSmalls('demo1',dateRange,location,1,getLicks);

targetIsPresent = d.targetContrast~=0;
correct = d.correct==1;
incorrect = d.correct==0;
earlyPenalty = isnan(d.correct);

correctHits= targetIsPresent==1 & correct==1;
correctRejects= targetIsPresent==0 & correct==1;
falseAlarms = targetIsPresent==0 & incorrect==1;
falseMisses = targetIsPresent==1 & incorrect==1;
falseTrigger = earlyPenalty==1;

if ~isnan(d.discrimStartRaw)
    normalizedStart=d.discrimStartRaw;
else
    normalizedStart=d.trialStartRaw + d.expectedPreRequestDurSec; %add this + d.responseWindowStartSec; preResponse is punished
end

normalizedStop=mean(d.responseWindowStopSec); %add this -d.responseWindowStartSec); when preResponse is punished

figure(1); hold on;
fill([0 .1, .1, 0], [0 0 length(d.trialNumber) length(d.trialNumber)],[.8 .8 .8])
fill([normalizedStop normalizedStop+0.1, normalizedStop+0.1, normalizedStop], [0 0 length(d.trialNumber) length(d.trialNumber)],[.8 .8 .8])
for i=(1:length(d.trialNumber))
    if correctHits(i)==1
        plot((d.lickTimes(:,i)-normalizedStart(i)), d.trialNumber(i), '.', 'Color', [1 0 0])
        plot((d.lickTimes(1,i)-normalizedStart(i)), d.trialNumber(i), 'ok')
    elseif falseAlarms(i)==1
        plot((d.lickTimes(:,i)-normalizedStart(i)), d.trialNumber(i), '.', 'Color', [0 0 1])
        plot((d.lickTimes(1,i)-normalizedStart(i)), d.trialNumber(i), 'ok')
    elseif falseTrigger(i)==1
        plot((d.lickTimes(:,i)-normalizedStart(i)), d.trialNumber(i), '.', 'Color', [0 1 0])
        plot((d.lickTimes(1,i)-normalizedStart(i)), d.trialNumber(i), 'ok')
%There is no lickTimes for this, so pointless really
%     elseif correctRejects(i)==1
%         plot(d.compiledTrialRecords.lickTimes(1,i), d.compiledTrialRecords.trialNumber(i), '.', 'Color', [0 1 1])
%         plot(d.compiledTrialRecords.lickTimes(1,i), d.compiledTrialRecords.trialNumber(i), 'ok')
%     elseif falseMisses(i)==1
%         plot(d.compiledTrialRecords.lickTimes(1,i), d.compiledTrialRecords.trialNumber(i), '.', 'Color', [1 1 0])
%         plot(d.compiledTrialRecords.lickTimes(1,i),
%         d.compiledTrialRecords.trialNumber(i), 'ok')
    end
xlabel('time')
ylabel('trials')
end    

processOrder = [find(correctHits) find(falseAlarms) find(falseTrigger)];
groupID=[ones(1,sum(correctHits)) 2*ones(1,sum(falseAlarms)) 3*ones(1,sum(falseTrigger))];
colors=[1 0 0; 0 0 1; 0 1 0];
counter=0;
figure(2); hold off;
n=length(processOrder);
hold on;
for i=(1:length(processOrder))
    trialID=processOrder(i); % isn't necc the "trialNumber" because we don't have all the data
    counter=counter+1;
    plot((d.lickTimes(:,trialID)-normalizedStart(trialID)), -counter, '.', 'Color', colors(groupID(i),:));
    if groupID(i)==1 | groupID(i)==2 | groupID(i)==3 
        lastLickLogged=max(find(~isnan(d.lickTimes(1,trialID))));  %since we collect rev chronologically, this really is the last
        plot((d.lickTimes(1,trialID)-normalizedStart(trialID)), -counter, 'ok');
    end
end
axis([-13 13 -counter 0])
fill([0 .1, .1, 0], [-counter -counter 0 0],[.8 .8 .8])
fill([normalizedStop normalizedStop+0.1, normalizedStop+0.1, normalizedStop], [-counter -counter 0 0],[.8 .8 .8])
set(gca, 'xTick', [-6 0.3 6], 'xTickLabel', {'earlyPenaltyPhase', 'discrimPhase', 'otherPhases'});
set(gca, 'yTick', [-45 -30 -10], 'yTickLabel', {'falseTrigger', 'falseAlarms', 'correctHIts'});


%Performance plot (this should include all even the correctRejects and
%falseMisses
figure(3); hold on;

for i=(1:length(d.trialNumber))
    pctCorrectHits(i)=(sum(correctHits(1:i))./i);
    pctFalseAlarms(i)=(sum(falseAlarms(1:i))./i);
    pctFalseTrigger(i)=(sum(falseTrigger(1:i))./i);
    pctCorrectRejects(i)=(sum(correctRejects(1:i))./i);
    pctFalseMisses(i)=(sum(falseMisses(1:i))./i);
end
plot(d.trialNumber,pctCorrectHits, 'Color', [1 0 0]) %red
plot(d.trialNumber,pctFalseAlarms, 'Color', [0 0 1]) %blue
plot(d.trialNumber,pctFalseTrigger, 'Color', [0 1 0]) %green
plot(d.trialNumber,pctCorrectRejects, 'Color', [1 0 1]) %magenta
plot(d.trialNumber,pctFalseMisses, 'Color', [1 1 0]) %yellow



