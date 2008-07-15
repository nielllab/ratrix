function [d n]=getImageNames(s)

n=[];
names={};
for i=1:length(s.trialDistribution)
    if isempty(n)
        n=length(s.trialDistribution{i}{1});
    elseif n~=length(s.trialDistribution{i}{1})
        error('due to caching of scaled images, all trial entries in distribution must specify same number of images')
    end
    for j=1:length(s.trialDistribution{i}{1})
        names{end+1} = s.trialDistribution{i}{1}{j};
    end
end
d=unique(names); %guaranteed to be sorted