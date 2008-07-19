function saveLog = getSaveLog(subjects,dataStoragePath)

switch class(subjects)
    case 'cell'
        numSubjects=size(subjects,2);
    case 'char'
        numSubjects=1;
end

for i=1:numSubjects
    files = dir(fullfile(dataStoragePath, subjects{i}));
    if any(strcmp({files.name},'saveLog.mat'))
        s = load (fullfile(dataStoragePath, subjects{i},'saveLog.mat'), 'saveLog');
        saveLog=s.saveLog;
        %make a back up of the saveLog
        save(fullfile(dataStoragePath, subjects{i},'saveLogHistory',['saveData.' datestr(now,30) '.mat']), 'saveLog');
    else
        saveLog=initializeSaveLogIndToEmpty([],[]);
    end
end