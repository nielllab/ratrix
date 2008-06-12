function newPathList=removeSecretBackups(pathList)

    pathElements = strread(pathList, '%s', 'delimiter', pathsep);

    newPathList = [];
    for i = 1:length(pathElements)
        if isempty(findstr(pathElements{i}, 'secretBackups'))
            newPathList = [newPathList, pathElements{i}, pathsep];
        else
            %['excluding *** ' pathElements{i}]
        end
    end

    % Drop the last path separator if the new path list is non-empty.
    if ~isempty(newPathList)
        newPathList = newPathList(1:end-1);
    end