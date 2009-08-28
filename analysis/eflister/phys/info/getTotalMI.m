function mi=getTotalMI(repeatResponses,uniqueResponseIndex)

totEsts=nan*zeros(1,length(uniqueResponseIndex));
for i=1:length(uniqueResponseIndex)
    if ~isempty(uniqueResponseIndex{i})
        locs=uniqueResponseIndex{i}{1}(:);
        sz=cellfun(@(f)(size(f,1)),locs);
        numPos=cellfun(@(f)(size(f,2)),locs);
        numPos(sz==0)=0;
        if ~all(uniqueResponseIndex{i}{3}==numPos')
            error('bad index')
        end

        %subplot(length(uniqueResponseIndex)+1,1,i)
        p=numPos/sum(numPos);
        p=sort(p);
        %plot(p)
        %hold on
        p=p(p>0);
        totEsts(i)=-1*sum(p.*reallog(p))/i; %entropy rate
    end
end

%subplot(length(uniqueResponseIndex)+1,1,length(uniqueResponseIndex)+1)
totLens=1:length(totEsts);
totLens=totLens(~isnan(totEsts));
plot(1./totLens,totEsts,'kx-')
hold on

inds=[2:4];
p=polyfit(1./totLens(inds),totEsts(inds),1);
xs=[0 max(1./totLens(inds))];
ys=p(1)*xs+p(2);
plot(xs,ys,'b')
totalEntropy=ys(1)

maxNoiseEstWordLength=10;
nEsts=zeros(1,maxNoiseEstWordLength);
for i=1:maxNoiseEstWordLength
    rpts=1:size(repeatResponses,2)-i+1;
    rptEnts=zeros(1,max(rpts));
    for j=rpts
        [counts places words] = getCounts(repeatResponses(:,[j j+i-1]),i*ones(1,size(repeatResponses,1)),[]);
        p=counts/sum(counts);
        p=p(p>0);
        rptEnts(j)=-1*sum(p.*reallog(p))/i; %entropy rate
    end
    nEsts(i)=mean(rptEnts);
end

%subplot(length(uniqueResponseIndex)+1,1,length(uniqueResponseIndex)+1)
nLens=1:maxNoiseEstWordLength;
plot(1./nLens,nEsts,'rx-')

inds=[2:maxNoiseEstWordLength];
p=polyfit(1./nLens(inds),nEsts(inds),1);
xs=[0 max(1./nLens(inds))];
ys=p(1)*xs+p(2);
plot(xs,ys,'b')
noiseEntropy=ys(1)

mi=totalEntropy-noiseEntropy