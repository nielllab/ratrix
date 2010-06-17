%qDoesNumLicksPredictChoice?

dateRange=[pmmEvent('last139problem') pmmEvent('startBlocking10rats')];  % before blocking this data is differnent...
 %  - performance is NOT very different for multiple lick.  
 %  - multiple licks are rare, <7%
            % how come rats lick more often when multilick have no effect 
            % on the stimulus? (in the next daterange closer to 30% of the time, dominated by double licks...)
            % were they trying to hold back and only lick once?
%dateRange=[pmmEvent('startBlocking10rats') now]  

d=getSmalls('130',dateRange)
d=removeSomeSmalls(d,~getGoods(d,'withoutAfterError'));
ones=removeSomeSmalls(d,d.numRequests~=1);
twos=removeSomeSmalls(d,d.numRequests~=2);
threes=removeSomeSmalls(d,d.numRequests~=3);
x1=sum(ones.correct);
x2=sum(twos.correct);
n1=length(ones.correct);
n2=length(twos.correct);
[x1/n1 x2/n2]
[delta CI]=diffOfBino(x1,x2,n1,n2,'wald',0.05)
% 130 does signicantly better if he licks twice, about 6%
% but not even better if he licks 3 times (atcually its worse for 3 than 2)


%%

x1=sum(ones.response==1);
x2=sum(twos.response==1);
n1=sum(ismember(ones.response,[1 3]));
n2=sum(ismember(twos.response,[1 3]));
[x1/n1 x2/n2]
% whether there are 1 or two licks, there is a tendency to favor the left response ("no")
% if there are 2 licks, then the animal is more likely to go to the left (not to the right)
% this effect is  small (1.5%), and just BARELY significant 
% in terms of the range of the wald interval-0.077%<0... seems questionable
% the point is that this effect if opposite the trend that *appears to be
% true* in the nice video of 130 (130-flankers-dec16-2008_0001.wmv)
[delta CI]=diffOfBino(x1,x2,n1,n2,'wald',0.05)
% if two licks corresponse

%% fraction that have 2 licks --> 29% for rat 130
length(twos.date)/length(d.date)

histc(d.numRequests,[0 1 2 3 4 5 6 7 8])/length(d.date)



 dateRange=[0 pmmEvent('endToggle')];

