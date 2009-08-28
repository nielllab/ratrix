function [filtsOrthoNormed sigOut]=orthAndFilt(filts,sigIn)

numDims=size(filts,1);
dimLength=size(filts,2);

filtsOrthoNormed=orth(filts');
filtsOrthoNormed=filtsOrthoNormed';

%orth() normalizes already
%for i=1:numDims
%    filtsOrthoNormed(i,:)=filtsOrthoNormed(i,:)/norm(filtsOrthoNormed(i,:));
%end

sigOut=zeros(numDims,length(sigIn));
for d=1:numDims %any way to run multiple filters without a for loop?
    sigOut(d,:)=filter(filtsOrthoNormed(d,:),1,sigIn);
end

if 0 %this proves we know what filter is doing and can do multiple with one matrix multiply
    expandedStim=[zeros(dimLength,ceil((dimLength-1)/2)) sigIn(repmat([1:length(sigIn)-dimLength+1],dimLength,1)+repmat([0:dimLength-1]',1,length(sigIn)-dimLength+1)) zeros(dimLength,floor((dimLength-1)/2))];
    projectedStim2=fliplr(filtsOrthoNormed)*expandedStim;

    figure
    for d=1:numDims
        subplot(numDims,2,2*d-1)
        plot([sigOut(d,:);projectedStim2(d,:)+max(sigOut(d,:))]')
        subplot(numDims,2,2*d)
        plot(xcorr(sigOut(d,:),projectedStim2(d,:)));
    end
    pause
end
