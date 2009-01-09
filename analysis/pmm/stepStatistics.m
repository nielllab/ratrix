function [days trials]= stepStatistics(subjects, dateRange)

if ~exist('subjects', 'var')
    subjects = {'228', '227','138','139','230','233','234'};
end

if ~exist('dateRange', 'var')
    dateRange=[];
end

numStepsMax = 14;
numSubjects = size(subjects,2);

for i = 1:numSubjects
    d=getSmalls(subjects{i},dateRange);
    goods=getGoods(d);
    for j = 2:numStepsMax
        which=d.step==j;
        days(i,j)=length(unique(floor(d.date(which)))); % all days
        trials(i,j)=sum(which & goods); % only good trials
    end
end

trials(trials==0)=nan;
days(days==0)=nan;
for j = 2:numStepsMax
    meanDays(j)=round(mean(days(~isnan(days(:,j)),j)));
    stdDays(j)=round(std(days(~isnan(days(:,j)),j)));
    meanTrials(j)=round(mean(trials(~isnan(trials(:,j)),j)));
    stdTrials(j)=round(std(trials(~isnan(trials(:,j)),j)));
end
meanDays
stdDays
[1:14]
meanTrials
stdTrials
