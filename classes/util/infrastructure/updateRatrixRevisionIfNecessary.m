function quit=updateRatrixRevisionIfNecessary(args)
quit=false;
[runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
properties = getSVNPropertiesForPath(url,{'commit'});
lastCommitVersion = properties.commit;
[targetSVNurl targetRevNum] =checkTargetRevision(args);


%     runningSVNversion
%     repositorySVNversion
%     url
%     lastCommitVersion
%     targetSVNurl
%     targetRevNum

if ~strcmp(url,targetSVNurl) || ...
        ((isempty(targetRevNum) && runningSVNversion~=repositorySVNversion && runningSVNversion<lastCommitVersion) || ...
            (~isempty(targetRevNum) && targetRevNum~=runningSVNversion))
%     writeSVNUpdateCommand(targetSVNurl,targetRevNum);
    fprintf('we need to update\n');

    quit=true;
else
    fprintf('no need to update\n');
end