function replicateChecker(paths,whatToDoIfThere)
% This function just check if there are files that need to be tranfered
input_paths = paths;

subDirs=struct([]);
boxDirs=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData','Boxes');
boxDirsToCheck=dir(boxDirs);
for b=1:length(boxDirsToCheck)
    boxDir=boxDirsToCheck(b).name;
    if findstr('box',boxDir)==1
        subjectDirs=fullfile(boxDirs,boxDir,'subjectData');
        subjectDirsToCheck=dir(subjectDirs);
        for s=1:length(subjectDirsToCheck)
            subDir=subjectDirsToCheck(s).name;
            if ~ismember(subDir,{'.','..'}) %&& findstr('test',lower(subDir))~=1
                subName=subDir;
                subDir=fullfile(subjectDirs,subName);
                if length(dir(fullfile(subDir,'trialRecords.mat')))==1
                    subDirs(end+1).dir=subDir; %fullfile(subjectDirs,subDir);
                    subDirs(end).name=subName;
                    subDirs(end).file='trialRecords.mat';
                    %subDirs(end+1)=sub;
                end
            end
        end
    end
end

for f=1:length(subDirs)
    subjectName=subDirs(f).name
    filePath=subDirs(f).dir
    fileName=subDirs(f).file
end

if length(subDirs)>0
    switch whatToDoIfThere
        case 'warn'
            warning('there are some files there that might not replicate')
        case 'error'
            error('there are some files there that probably didn''t replicate')
        case 'keyboard'
            keyboard
            %is  trialRecords = 0x0 struct array with no fields?  what does
            %that mean?
            error('there are some files there that probably didn''t replicate')
    end
end
