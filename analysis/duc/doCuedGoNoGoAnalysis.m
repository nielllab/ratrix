function [correctHits correctMiss falseHits falseMiss totalLicks]=doCuedGoNoGoAnalysis 
%this function gets and calculate values which will late get plotted later

correctHits=[];
correctMiss=[];
falseHits=[];
falseMiss=[];
totalLicks=[];


location=-2;  % -2 is local, empty or 1 is from philip's male server
dateRange=[]; %empty is everything
d=getSmalls('demo1',[],-2)

hist(d.discrimStart)  % shows the various delays
d.lickTimes % all the lick times
which=d.correct==1 & d.step~=11;  % a filter of logicals
x=removeSomeSmalls(d,which)

%another example of filtering
trialsWithoutLicks=cellfun(@(x) isnan(x(1)),d.lickTimes);
x=removeSomeSmalls(d,trialsWithoutLicks)










