function kk=klustaModelTextToStruct(modelFile)

fid=fopen(modelFile,'r');  % this is only the first one!
if fid==-1
    modelFile
    error('bad file')
end
kk.headerJunk= fgetl(fid);
ranges= str2num(fgetl(fid));
sz=str2num(fgetl(fid));
kk.numDims=sz(1);
kk.numClust=sz(2);
kk.numOtherThing=sz(3); % this is not num features? 
kk.ranges=reshape(ranges,[],kk.numDims);
kk.mean=nan(kk.numClust,kk.numDims);
xx.cov=nan(kk.numDims,kk.numDims,kk.numClust);
for c=1:kk.numClust
    clustHeader=str2num(fgetl(fid));
    if clustHeader(1)~=c-1
        %just double check
        error('wrong cluster')
    end
    kk.mean(c,:)=str2num(fgetl(fid));
    kk.weight(c)=clustHeader(2);
    for i=1:kk.numDims
        kk.cov(i,:,c)=str2num(fgetl(fid));
    end
end
fclose(fid);
end