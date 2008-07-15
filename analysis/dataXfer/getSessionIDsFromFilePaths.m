function [sessionIDs subjectIDs] = getSessionIDsFromFilePaths(filePaths, verbose)
%This function works for getting ID's from paths that end in
%'.../oldSubjectData.x' where x is an iso 8601 date.

sessionIDs=Inf;

if ~exist ('verbose', 'var')
    verbose = 0;
end

if strcmp(class(filePaths), 'cell')
    numFiles=size(filePaths,2);
else
    numFiles=1;
end

for i=1:numFiles

    %dealing with the fact that filePath might be cell or char
    if strcmp(class(filePaths), 'cell')
        filePath = filePaths{i};
    else
        filePath = filePaths;
    end

    ss=strfind(filePath,'Data.20')+5;
    if isempty(ss)
        endPath{i}=[];%this is empty because this session has not ended and has no end date.
    else
        endPath{i}=(filePath(ss:end));
        %This session ID still has the subject name in it but you could
        %remove the name and compress the date and still be a uniqe
        %identifier.
        %sadly datenum has no back compatibilty for date type 30.
        %eventually replace this with a single ID number.
    end

    if verbose
        disp(filePath);
        disp(sprintf('location in string is: %s', num2str(ss)));
        disp(endPath{i});
    end

    if size(strfind(endPath{i},filesep),2)>0
        containsSubjectID=1;
        [namedDate subjectIDs{i}]=fileparts(endPath{i});
    else
        containsSubjectID=0;
        namedDate=endPath{i};
    end


    if size (namedDate,2)>0 %only convert namedDates if cells have content, i.e. session not still in progress
        sessionIDs(i)= datenumFor30(namedDate);
    else
        sessionIDs(i)= nan;
    end

end

if isempty(filePaths)
    sessionIDs=[];
end
    

