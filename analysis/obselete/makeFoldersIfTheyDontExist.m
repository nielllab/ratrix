function makeFoldersIfTheyDontExist(dataStoragePath,folderName,contentFolders)

for i=1:size(folderName,2)
    newFolder=lower(char(folderName(i)));
    dirs=dir(sprintf('%s/*%s',dataStoragePath,newFolder));

    if size(dirs,1)==1
        %continue
    elseif size(dirs,1)==0
        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(dataStoragePath,newFolder);
        for j=1:size(contentFolders,2)
            [SUCCESS,MESSAGE,MESSAGEID] = mkdir(fullfile(dataStoragePath,newFolder),contentFolders{j});
        end
        disp(sprintf('making a new directory for %s', newFolder));
    else
        error('unexpected number of directories with the same name.')
    end
end
