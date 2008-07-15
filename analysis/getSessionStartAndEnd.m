function [startTimes endTimes startInds endInds]=getSessionStartAndEnd(d,hoursBetweenChunks,hoursPerSession)

if ~exist('hoursBetweenChunks','var') 
hoursBetweenChunks = 4;
end

if ~exist('hoursPerSession','var') 
hoursPerSession = 2;
end

startTimes = [d.date(1) d.date(find(diff(d.date)> hoursBetweenChunks/24 ) +1)]; 
endTimes = startTimes + hoursPerSession/24;

for i=1:size(startTimes,2)
    startInds(i)=find(d.date==startTimes(i));
end

endInds=[[startInds(2:end)-1] size(d.date,2)];