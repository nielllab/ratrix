function quit=updateRatrixRevisionIfNecessary(args)
quit=false;
[runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
properties = getSVNPropertiesForPath(url,{'commit'});
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
        ((isempty(targetRevNum) && properties.commit~=runningSVNversion) || ...
            (~isempty(targetRevNum) && targetRevNum~=runningSVNversion))
    writeSVNUpdateCommand(targetSVNurl,targetRevNum);
%     fprintf('we need to update\n');

    quit=true;
else
%     fprintf('no need to update\n');
end
end % end function
