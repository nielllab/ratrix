function d=getDist(s)

d=zeros(1,length(s.trialDistribution));
for i=1:length(s.trialDistribution)
    d(i)=s.trialDistribution{i}{2};
end
d=d/sum(d);