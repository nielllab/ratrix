function [dataFilePaths ]=selectSubsetOfDataFiles(path,subject,method,methodParams,subjectFoldersInsideDataFolder, verbose,removeInProgressFiles)
%selectSubsetOfDataFile(path,subject,'all',[])
%selectSubsetOfDataFile(path,subject,'sinceDate',dateNum)
%selectSubsetOfDataFile(path,subject,'lastNFiles',numFilesToLoad)
%selectSubsetOfDataFile(path,subject,'betweenDates',[now-5 now],1)


if ~exist('removeInProgressFiles','var')
    removeInProgressFiles=1;
end
isInProgress=[]; %initialize; assume none are at first

files=dir([path '*Data*']);
if size(files,1)>0

    for fileNum=1:length(files)
        %determine the dates based on the name of the file
        dates(fileNum)= getSessionIDsFromFilePaths(files(fileNum).name);
        %dates(fileNum)=datenum(files(fileNum).date); old method
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
            error('that is not a known method of loading ratrix data, check loadMethod')
    end

    if ~subjectFoldersInsideDataFolder

        for fileNum=1:length(files)
            dataFilePaths{fileNum}=[path files(fileNum).name];

            if removeInProgressFiles
                % specifically ignore: 'subjectData';  okay: 'oldSubjectData'
                isInProgress(fileNum)=~isempty(cell2mat(strfind(dataFilePaths(fileNum),'subjectData')))
            end

        end

    else %subjectFoldersInsideDataFolder

        currFile=1;
        files2={};
        for fileNum=1:length(files)
            thisPath=[path files(fileNum).name];
            subDirs=dir(thisPath);
            if isempty(subject)
                subDirs=subDirs(~ismember({subDirs.name},{'..','.'}));
            else
                subDirs=subDirs(ismember({subDirs.name},subject));
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

        dataFilePaths=files2;
    end
else
    dataFilePaths=[];
    if verbose
        path
        subject
        method
        methodParams
        disp('couldn''t find any files');
    end
end


if removeInProgressFiles
    remove=find(isInProgress);
    dataFilePaths(remove)=[];
    if size(remove,1)>0
        remove=find(isInProgress)
        warning(sprintf('beware ongoing sessions like: %s',char(dataFilePaths(find(isInProgress)))))
    end
else
    if any(isInProgress)
        warning(sprintf('beware ongoing sessions like: %s',char(dataFilePaths(find(isInProgress)))))
    end
end






