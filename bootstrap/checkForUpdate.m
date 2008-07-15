function s=checkForUpdate(type)

switch type
    case 'server'
        f = [getRatrixPath 'updateServer.mat'];
    case 'client'
        f = [getRatrixPath 'updateClient.mat'];
    otherwise
        error('checkForUpdate(): Unkown node type');
end

% If the file exists run the update
if exist(f) == 2
    try
        fprintf('Attempting to update ratrix code\n');

        [runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);

        target=load(f);
        [targetSVNurl targetRevNum] =checkTargetRevision({target.targetURL,target.targetRevNum});

        svnPath = GetSubversionPath;

        rPath=getRatrixPath;
        if rPath(end)==filesep
            rPath=rPath(1:end-1); %windows svn requires no trailing slash
        end

        [status result]=system([svnPath 'svn cleanup ' '"' rPath '"']);
        if status~=0
            result
            'bad svn cleanup of ratrix code'
        end

        % Must remove the directories from Matlab's path, so they can be
        % deleted if needed
        rPath=getRatrixPath; % Store it so it is not forgotten
        rmpath(RemoveSVNPaths(genpath(rPath)));

        [status result]=system([svnPath 'svn switch "' targetSVNurl '"@' num2str(targetRevNum) ' "' rPath '" && ' svnPath 'svn cleanup "' rPath '"']);

        % Generate a new list of directories
        addpath(RemoveSVNPaths(genpath(rPath)));

        if status~=0 %|| any(strfind(result,'skip'))
            result
            'error updating ratrix code'
        else
            result
            [runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
            if runningSVNversion==targetRevNum && strcmp(url,targetSVNurl)
                delete(f);
                fprintf('Ratrix code update appeared to succeed\n');
            else
                runningSVNversion
                targetRevNum
                url
                targetSVNurl
                'failed svn update -- leaving update file'
            end
        end

        updatePsychtoolboxIfNecessary

    catch
        x=lasterror
        x.stack.file
        x.stack.line
        x.message
        error('failure in checkForUpdate')
    end
    WaitSecs(3);
    quit
else
    fprintf('Not updating ratrix code\n');
end