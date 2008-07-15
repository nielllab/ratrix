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

        load(f,'targetRevision');
        % Run svn update command
        %         if IsWin
        %             s = dos(update);
        %         else
        %             s = system(update);
        %         end


        svnPath = GetSubversionPath;
        if isempty(targetRevision)
            targetSVNversion = repositorySVNversion;
        elseif isinteger(targetRevision) && targetRevision>0 && isscalar(targetRevision)
            targetSVNversion = targetRevision;
        elseif ischar(targetRevision)
            targetSVNversion = targetRevision;
        else
            targetRevision
            error('bad update command file')
        end

        rPath=getRatrixPath;
        if rPath(end)==filesep
            rPath=rPath(1:end-1); %windows svn requires no trailing slash
        end

        [status result]=system([svnPath 'svn cleanup ' '"' rPath '"']);
        if status~=0
            result
            'bad svn cleanup of ratrix code'
        end

        ptbr=psychtoolboxroot;
        if ptbr(end)==filesep
        ptbr=ptbr(1:end-1); %windows svn requires no trailing slash
        end
        [status result]=system([svnPath 'svn cleanup ' '"' ptbr '"']);
        if status~=0
            result
            'bad svn cleanup of psychtoolbox code'
        end
        
        if ischar(targetRevision)
            % Here targetRevision is a repository location
            update=[svnPath 'svn switch "'  targetRevision '" "' rPath '" && svn cleanup'  ];
        else
            update=[svnPath 'svn update '  num2str(targetRevision) ' "' rPath '"'  ];
        end

        % Must remove the directories from Matlab's path, so they can be
        % deleted if needed
        rPath=getRatrixPath; % Store it so it is not forgotten
        rmpath(RemoveSVNPaths(genpath(rPath)));
        
        [status result]=system(update);
        
        addPath(fullfile(rPath,'bootstrap')); % So basic functions can be used
        % Generate a new list of directories
        addpath(RemoveSVNPaths(genpath(rPath)));
        
        if status~=0 %|| any(strfind(result,'skip'))
            result
            'error updating ratrix code'
        else
            result
            [runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
            if ~ischar(targetSVNversion)
                if runningSVNversion==targetSVNversion
                    delete(f);
                    fprintf('Ratrix code update appeared to succeed\n');
                else
                    runningSVNversion
                    repositorySVNversion
                    'failed svn update -- leaving update file'
                end
            else
                if strcmp(targetSVNversion,url)
                    delete(f);
                    fprintf('Ratrix code changed to different repository/directory successfully\n');
                else
                    targetSVNversion
                    url
                    'failed to svn switch -- leaving update file'
                end
            end
        end

        
        % Update psychtoolbox
        updatePsychtoolboxIfNecessary
        % Remove the update mat

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