function [wcRev,repRev,url] = getSVNRevisionFromXML(svnDir)
% [wcRev,repRev] = getSVNRevisionFromXML(svnDir)
%
% This function returns the revision numbers for the working copy
% and the repository associated with the given directory
%
% svnDir - Directory where the working copy of the code resides
%
% wcRev - The revision of the working copy
% repRev - The revision of the repository

%%% note http://tech.groups.yahoo.com/group/psychtoolbox/message/8379
%why are our svn:// commands still working?  only an issue for checkout?
%might need to switch to https in future

% SVN XML returns two important items, the working copy revision number (entry), and the
% repository location, which can then be used to determine the repository
% revision number

% change directory
oldWD = pwd;
cd(svnDir);

% call getSVNPropertiesForPath to get wcRev and url
path = '';
properties = {'revision', 'url'};
svnProperties = getSVNPropertiesForPath(path, properties); % use new function
wcRev = svnProperties.revision; % assign wcRev
url = svnProperties.url; % assign url

% clear svnProperties and call again to get repRev
svnProperties = [];
path = url;
properties = {'revision'};
svnProperties = getSVNPropertiesForPath(path, properties);
repRev = svnProperties.revision; % assign repRev


% Change back to the original directory
cd(oldWD);