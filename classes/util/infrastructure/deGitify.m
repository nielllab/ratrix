function newPathList=deGitify(pathList)

%adapted from ptb's RemoveSVNPaths

pathElements = textscan(pathList, '%s', 'delimiter', pathsep);
pathElements = pathElements{1}.';

qNotSVN = cellfun(@isempty,strfind(pathElements,[filesep '.git']));
pathElements = pathElements(qNotSVN);

if ~isempty(pathElements)
    pathElements = [pathElements; repmat({pathsep},1,length(pathElements))];
    newPathList  = [pathElements{:}];
    newPathList(end) = [];
end