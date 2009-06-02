function rlabHist(edges, count, colors)
%a function for better stacked histogram, because Matlab's bar('histc')
%sucks
%
%example:
% rlabHist([10 11 12 13], rand(2,3), [1 0 0; .5 .5 .5])


numGroup=size(count,1);

if ~exist('colors', 'var') || isempty(colors)
    colors=jet(numGroup);
end

numColors=size(colors,1);

if size(edges,1)>1
    error('all count must have the same edges');
end

if numColors==1
    %if only one color make them all the same
    colors=repmat(colors,numGroup,1);
end

if numGroup~=numColors
    numGroup
    numColors
    error('must specify a color for each group, or provide one color for all');
end

if size(edges, 2)==size(count, 2)+1
    %okay
else
    numEdges=size(edges, 2)
    numCountValues=size(count, 2)
    error('we need one more edge than the number of counts');
    %could interpret as equal values as edge centers one day
end


edgeDouble=repmat(edges,2,1);
x=edgeDouble(:)';


y=zeros(numGroup,length(x));
for i=1:numGroup %
    countDouble=repmat(count(i,:),2,1);
    y(i,:)=[0 countDouble(:)' 0];
end

%  x=repmat(x,numGroup,1);
a=area(x,y');
for i=1:numGroup
    %get(a(i))
    set(a(i),'EdgeColor', 'none', 'FaceColor' ,colors(i,:));
end





