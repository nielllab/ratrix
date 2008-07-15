function targetSVNversion=checkTargetRevision(targetRevision)
minRev=1300;%the lowest revision that knows how to update to the newest revisions

if isempty(targetRevision)
    error('disallowing emtpy svn update command')
    targetSVNversion = repositorySVNversion;
elseif (isinteger(targetRevision) || isNearInteger(targetRevision)) && targetRevision>minRev && isscalar(targetRevision)
    %isNearInteger needed cuz of http://132.239.158.177/trac/rlab_hardware/ticket/102
    targetSVNversion = targetRevision;
elseif ischar(targetRevision) && isvector(targetRevision) && strmatch('svn://132.239.158.177/projects/ratrix/',targetRevision)
    %should also check that this is a valid top-level ratrix path -- ie, one that directly contains the bootstrap directory
    targetSVNversion = targetRevision;
else
    targetRevision
    error('bad svn target revision')
end