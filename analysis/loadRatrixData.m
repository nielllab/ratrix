function [data sessionIDs]=loadRatrixData(path,subjects,method,methodParams,dontGetData)
%loadRatrixData(path,subjects,'all',[])
%loadRatrixData(path,subjects,'sinceDate',dateNum) 
%loadRatrixData(path,subjects,'lastNFiles',numFilesToLoad)
%loadRatrixData(path,subjects,'betweenDates',[now-5 now],1)

if ~exist('dontGetData', 'var')
    dontGetData = 0; %the default is to get data
    %only use when sessionIDs without data are desired
end

files=dir([path '*ubjectData*'])
for fileNum=1:length(files)
    dates(fileNum)=datenum(files(fileNum).date);
end

[sorted order] = sort(dates,'descend');
files=files(order);


switch method
    case 'all'
        %do nothing
        %files=files;
    case 'lastNfiles'
        lastNfiles=methodParams;
        if lastNfiles > 0 && isinteger(lastNfiles)
            lastNfiles=min(lastNfiles,size(files,1));
            files=files(1:lastNfiles);
            disp(sprintf('going to load the last %d files',lastNfiles))
        else
            error('lastNfiles must be a positive integer')
        end
    case 'sinceDate'
        sinceDate=methodParams;
        if sinceDate > 0 && sinceDate < now
            for i=1:size(files,1)
                dateNums(i)=datenum(files(i).date);
            end
            filesIndsSinceDate=(dateNums>sinceDate);
            files=files(filesIndsSinceDate);
            disp(sprintf('going to load %d files since %s',size(files,1),datestr(sinceDate)))
        else
            error('sinceDate must be a datenum before now')
        end
    case 'betweenDates'
        startDate=methodParams(1);
        endDate=methodParams(2);
        if startDate>endDate 
            warning('got start and end swtiched - will reverse it')
            temp=startDate;
            startDate=endDate;
            endDate=temp;
        end
        
        if startDate > 0 && endDate < now
            for i=1:size(files,1)
                dateNums(i)=datenum(files(i).date);
            end
            filesInds=(dateNums>startDate)&(dateNums<endDate);
            files=files(filesInds);
            disp(sprintf('scanning %d files between %s and %s',size(files,1),datestr(startDate),datestr(endDate)))
        else
            error('start and endDates must be a datenum before now')
        end
    otherwise
        method
        error('that is not a known method of loading ratrix data, check loadMethod')
end

currFile=1;
files2={}; 
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


sessionIDs={}; 
for fileNum=1:length(files2)
    fileName='trialRecords.mat';
    thisPath=[files2{fileNum} '\' fileName];
    
    test=dir(thisPath);

    if length(test)==1 && strcmp(fileName,test.name)
        if ~dontGetData
            disp(sprintf('loading %s',thisPath))
            data{fileNum,1}=load(thisPath);
        else
            data{fileNum,1}=[];
        end
        
        data{fileNum,2}=assigns{fileNum};

        %code added to track IDs of each session, using endSession as
        %unique stamp pmm 071008.
        sessionIDs{fileNum} = getSessionIDsFromFilePaths (char(files2{fileNum}));
       
        
        
    else
        disp(sprintf('%s has no datafile',files2{fileNum}))
        sessionIDs{fileNum}=[];%this is empty because this session has no data file.
    end
end

