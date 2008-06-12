function [data]=loadRatrixData(path,subjects,lastNfiles)

files=dir([path '*ubjectData*']);
for fileNum=1:length(files)
    dates(fileNum)=datenum(files(fileNum).date);
end

[sorted order] = sort(dates,'descend');
files=files(order);

if exist('lastNfiles','var') && lastNfiles > 0
    lastNfiles=min(lastNfiles,size(files,1));
    files=files(1:lastNfiles)
end

currFile=1;
for fileNum=1:length(files)
    thisPath=[path files(fileNum).name];
    subDirs=dir(thisPath);
    if isempty(subjects)
        subDirs=subDirs(~ismember({subDirs.name},{'..','.'}));
    else
        subDirs=subDirs(ismember({subDirs.name},subjects));
    end
    numSubDirs=length(subDirs);
    dirNames={};
    if numSubDirs>0

        %files2{currFile:currFile+numSubDirs-1}=[thisPath '\' subDirs.name];
        %assigns{currFile:currFile+numSubDirs-1}=subDirs.name;
        %2006b gives this error: ??? The right hand side of this assignment has too few values to satisfy the left hand side.
        %it worked in r14.  figure out why...
        %so replace with:
        dirNames={subDirs.name};
        file_ns = currFile:currFile+numSubDirs-1;
        for file_n=1:length(file_ns)
            files2{file_ns(file_n)}=[thisPath '\' dirNames{file_n}];
            assigns{file_ns(file_n)}=dirNames{file_n};
        end
        
        currFile=currFile+numSubDirs;
    end
end

for fileNum=1:length(files2)
    fileName='trialRecords.mat';
    thisPath=[files2{fileNum} '\' fileName];

    test=dir(thisPath);

    if length(test)==1 && strcmp(fileName,test.name)
        disp(sprintf('loading %s',thisPath))
        data{fileNum,1}=load(thisPath);
        data{fileNum,2}=assigns{fileNum};
    else
        disp(sprintf('%s has no datafile',files2{fileNum}))
    end
end