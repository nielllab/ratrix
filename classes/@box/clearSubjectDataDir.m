function clearSubjectDataDir(b)
%subPath = [b.path 'subjectData' filesep]; %used to have an additional filesep before subjectData?
subPath = getSujbectDataDir(b);
files=dir(subPath);

if ~isempty(files)
    disp(sprintf('found old subjectData files for box, backing up'))
    timestamp = datestr(now,30);
    
    [success,message,msgid] = movefile(subPath,fullfile(b.path, ['oldSubjectData.' timestamp]));
    if ~success
        message
        msgid
        error('could not create backup dir')
    end
end

