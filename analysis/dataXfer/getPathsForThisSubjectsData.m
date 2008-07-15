function [files2 assigns sessionID]= getPathsForThisSubjectsData(path,subjects,method,methodParams,verbose)
%This function was derived from loadRatrixData
%loadRatrixData(path,subjects,method,methodParams)
%getPathsForThisSubjectsData(path,subjects,method,methodParams)
%getPathsForThisSubjectsData(path,subjects,'all',[])
%getPathsForThisSubjectsData(path,subjects,'sinceDate',dateNum)
%getPathsForThisSubjectsData(path,subjects,'lastNFiles',numFilesToLoad)


if ~exist('verbose','var')
    verbose = 1;
end

files=dir([path '*ubjectData*']);
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
            if verbose
                disp(sprintf('considering the last %d files',lastNfiles))
            end
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
            if verbose
                disp(sprintf('considering %d files since %s',size(files,1),datestr(sinceDate)))
            end
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
            if verbose
                disp(sprintf('considering %d files between %s and %s',size(files,1),datestr(startDate),datestr(endDate)))
            end
        else
            error('start and endDates must be a datenum before now')
        end
    otherwise
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

if verbose
    disp (sprintf('%d files available for rat %s', size(files2,2),subjects));
end

if length(files2)<1
      disp (sprintf('%d files available for rat %s', size(files2,2),subjects));
      error (sprintf('there are no files available with that criteria using method: %s',method))
end

for fileNum=1:length(files2)

    
    ss=strfind(files2{fileNum},'Data.20')+5;
    if isempty(ss)
        sessionID{fileNum}=[assigns(fileNum)];%this is empty because this session has not ended and has no end date.
    else
        sessionID{fileNum}=(files2{fileNum}(ss:end)); 
        %This session ID still has the subject name in it but you could
        %remove the name and compress the date and still be a uniqe
        %identifier.
        %sadly datenum has no back compatibilty for date type 30.
        %eventually replace this with a single ID number.
    end
end