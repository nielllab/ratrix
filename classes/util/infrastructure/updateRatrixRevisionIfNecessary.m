function quit=updateRatrixRevisionIfNecessary(args)
quit=false;
[runningSVNversion repositorySVNversion url]=getSVNRevisionFromXML(getRatrixPath);
[targetSVNurl targetRevNum] =checkTargetRevision(args);

if ~strcmp(url,targetSVNurl) || ((isempty(targetRevNum) && runningSVNversion~=repositorySVNversion) || (~isempty(targetRevNum) && targetRevNum~=runningSVNversion))
    writeSVNUpdateCommand(targetSVNurl,targetRevNum);
    quit=true;
end