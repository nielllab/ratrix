function data=makeLargeDataChunk(files2,assigns);

for fileNum=1:length(files2)
    fileName='trialRecords.mat';
    thisPath=[files2{fileNum} '\' fileName];

    test=dir(thisPath);

    if length(test)==1 && strcmp(fileName,test.name)
        disp(sprintf('loading %s',thisPath))
        data{fileNum,1}=load(thisPath);
        data{fileNum,2}=assigns{fileNum}; %I think this is just which rat it is... Could have a method where one name applies to all. 
    else
        disp(sprintf('%s has no datafile',files2{fileNum}))
    end
end