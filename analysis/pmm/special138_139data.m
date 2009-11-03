function out=special138_139data(d)


 out=ismember(d.info.subject,{'138','139'}) && all(d.date<datenum('Mar.18,2008'))...
     && all(d.step==2);  % this last is incedentally true, just makes sure you don't get a pass on any other data from these rats
 
    %special pass given to sf contrast sweep for two rats that happened to
    %include "0" contrast, which violates the detection rule, strictly
    %speaking.. these rats are both contrast on right rats
    %startSweepDate=datenum('Feb.21,2008');
    %endSweepDate=datenum('Mar.18,2008');
    
    
locateRegion=0
if locateRegion
    d=getSmalls('138')
    
    ss=min(find(d.targetContrast==0.5))-500
    ee=max(find(d.targetContrast==0.5))+500
    d=removeSomeSmalls(d,d.trialNumber<ss | d.trialNumber>ee)
    
    startSweepDate=datenum('Feb.21,2008')
    endSweepDate=datenum('Mar.18,2008')
    d=removeSomeSmalls(d,d.date<startSweepDate | d.date>endSweepDate)
    plot(d.targetContrast,'r.')
    d=removeSomeSmalls(d,d.step~=2)
    unique(d.stdGaussMask)
    length(d.trialNumber)
end