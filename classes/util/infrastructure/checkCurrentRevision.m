function checkCurrentRevision
% This function checks the currently running version of code and makes sure it is in compliance with subject-specific permanent storage/
% The path must be either tag v0.8 or higher, or trunk. The revision must be 1550 or higher.

% This function should be called at the start of ratrixServer (to check server-side code) and bootstrap (to check client-side code)
% bootstrap also calls checkForUpdate, which might allow the client to "update" to bad code
% Do we want to prevent this from happening, or should we just call checkCurrentRevision after checkForUpdate, and error if client did something bad?

% 9/24/08 - no, we can prevent client from updating to bad code by also modifying checkTargetRevision to do these checks

[wcRev, repRev, url] = getSVNRevisionFromXML(getRatrixPath);
svnProperties = getSVNPropertiesForPath(url, {'commit'});
wcTrueRev = svnProperties.commit;

% check that wcTrueRev is newer than minRev
minRev = 1550;
if wcTrueRev < minRev
    error('current SVN revision is prior to earlist allowed revision number - please update code');
end

% check that the url is either trunk or tag v0.8 (should replace with some automated tag checking later)
if ~checkSVNPath(url)
    error('current SVN path is not allowed - please switch to either the trunk or tag v0.8');
end

end % end function
