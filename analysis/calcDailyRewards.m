function [fractionRewardTime secOpenTimePerDay labelStruc]=calcDailyRewards(d,trialsPerDay,maxN)
%This tells you the amount of reward open time per day
%as well as the amount of reward per Nth correct in a row
%maxN sets the number correct  in a row after which they are all grouped in
%the plot

debuggingOn=0;

numDays = size(trialsPerDay,2);
trialsAtEndOfDay = cumsum(trialsPerDay);
trialsAtStartOfDay = [1 trialsAtEndOfDay+1];
msecOpenTimePerDay = zeros(1,numDays);
correctInRow=d.correctInRow;
correctInRow(correctInRow>maxN)=maxN;

uniqueRunLengths=unique(correctInRow)

for i=1:numDays
    for j=1:maxN

        which=intersect([trialsAtStartOfDay(i):trialsAtEndOfDay(i)],find(correctInRow==j));

        %THIS SHOULD CLUMP!

        secOpenTimePerDay(i,j) = sum(d.actualRewardDuration(which));

        if debuggingOn
            figure(2)
            hist(d.actualRewardDuration(which),20)
            pause

            count(i,j)=length(which);
        end
    end
end

%this is mean time per condition
for j=1:maxN
    which=find(correctInRow==j);
    meanOpenTimePerCondition(j) = mean(d.actualRewardDuration(which));
    r3=100; % knownAmountOfRewardForFirstTrial
    labelStruc{j}=sprintf('%2.1f', meanOpenTimePerCondition(j)*1000/r3);
end

%disp(labelStruc)


if debuggingOn
    count
    secOpenTimePerDay*1000
    secOpenTimePerDay*1000./count
end

fractionRewardTime=secOpenTimePerDay./repmat(sum(secOpenTimePerDay')',1,maxN);
rewardTime=secOpenTimePerDay./repmat(sum(secOpenTimePerDay')',1,maxN);

plotOn=0
if plotOn
    figure
    subplot(211); bar(secOpenTimePerDay,'stacked'), colormap(cool)
    title ('reward per correct run length')
    ylabel('water (secondsValveOpenTime)')
    legend (labelStruc,'Location','NorthOutside','Orientation','horizontal')
    subplot (212); bar(fractionRewardTime,'stacked'), colormap(cool)
    ylabel('fraction of water')
    xlabel('day')
end
