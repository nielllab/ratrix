function [dateList sessionIDsPerChunk]=getDateListForBlocks(sourcePath,daysPerChunk,daysOverLap,lastNDaysAvoided,verbose)

%determine oldest and newest allowed data file

for fileNum=1:length(sourcePath)
    f=dir([sourcePath{fileNum} '\*trialRecords*']);
    dates(fileNum)=datenum(f.date);
end

%old method was not sensitive to dates of specific subject. 
%files=dir([sourcePath '*ubjectData*']);
% for fileNum=1:length(files)
%     dates(fileNum)=datenum(files(fileNum).date);
% end

oldest=min(dates);
newest=now-lastNDaysAvoided;

numDays=newest-oldest;
newDaysPerChunk=daysPerChunk-daysOverLap;
numChunks=ceil(numDays/(newDaysPerChunk));

if verbose
    display(sprintf('planning to load %d days in %d chunks',round(numDays),numChunks))
end

%determine the start and end of each chunk 
daySequence=newDaysPerChunk.*[0:numChunks-1; 1:numChunks]'+repmat([0,daysOverLap],numChunks,1);  % start with days
dateList=daySequence+oldest(ones(numChunks,2)); %then turn into dates
dateList(find(dateList>newest))=newest; %restrict the last chunk to the allowed range

%confirm there are some files in each block,else remove from dateList
remove=[];
for i=1:numChunks
    numFilesPerChunk(i)=sum(dates>=dateList(i,1) & dates<dateList(i,2));
   
    if numFilesPerChunk(i)>=1
        if verbose
              display(sprintf('there are %d files in chunk number %d',numFilesPerChunk(i),i))
        end
    else
         if verbose
            warning('A whole chunk had no files in it, will remove this date range from the dateList')
         end
        remove=[remove i];
    end
end
dateList(remove,:)=[]; %take out empty chunks

%determine sessionIDsPerChunk if requested
if  nargout>1
    for i=1:numChunks
        %we're not actually loading we're just checking the file IDs
        %that we would load.
        [junk sessionIDs]=loadRatrixData(path,subjects,'betweenDates',[dateList(i,1) dateList(i,2)],1);
        sessionIDsPerChunk{i}.IDs=sessionIDs;
    end
end
        
if verbose
        display(sprintf('new plan to load %d days in %d chunks',round(max(dateList(:))-min(dateList(:))),size(dateList,1)))
end

