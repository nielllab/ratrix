function quit=updateRatrixRevisionIfNecessary(args)
quit=false;
[runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
% properties = getSVNPropertiesForPath(url,{'commit'});
% lastCommitVersion = properties.commit;
[targetSVNurl targetRevNum] =checkTargetRevision(args);


%     runningSVNversion
%     repositorySVNversion
%     url
%     lastCommitVersion
%     targetSVNurl
%     targetRevNum

% write update command in the following cases:
% 1) if the current url and targetSVNurl do not match
% 2) if the current revision number and targetRevNum do not match
% 3) in the case that no targetRevNum is specified (defaults to HEAD), then update when
%       a change has occurred to any folder except for 'setup' since our local copy
%       (check that the runningSVNversion is at least as recent as the commitVersion of all folders except 'setup')

if ~strcmp(url,targetSVNurl) || ...
        ((isempty(targetRevNum) && checkAllRatrixFoldersExceptSetup) || ...
            (~isempty(targetRevNum) && targetRevNum~=runningSVNversion))
    writeSVNUpdateCommand(targetSVNurl,targetRevNum);
%     fprintf('we need to update\n');

    quit=true;
else
%     fprintf('no need to update\n');
end
end % end function

function update = checkAllRatrixFoldersExceptSetup
update = false;

d = dir(getRatrixPath);
for i=1:length(d)
    if (d(i).isdir==1) && ~strcmp(d(i).name, '.svn') && ~strcmp(d(i).name,'setup') && ~strcmp(d(i).name, '.') && ~strcmp(d(i).name, '..')
        % any directory that is not .svn or setup
        [runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(fullfile(getRatrixPath, d(i).name));
        properties = getSVNPropertiesForPath(url, {'commit'});
        % if the commit is after runningSVNversion, flag update
%         properties.commit
%         runningSVNversion
%         d(i).name
        if properties.commit > runningSVNversion
            update = true;
        end
    end
end

end % end function