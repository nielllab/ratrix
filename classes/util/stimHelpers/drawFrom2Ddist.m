%dist is 2d matrix of densities
%out is normalized coordinates [x y]
%ex: if dist = [.1 .2;.3 .4] then the most likely out is [2/3 2/3] (corresponding to lower right)
function out=drawFrom2Ddist(dist)
ind=min(find(cumsum(dist(:)/sum(dist(:)))>rand));
[y x]=ind2sub(size(dist),ind);
out=[y x]./(size(dist)+1);
out=fliplr(out);