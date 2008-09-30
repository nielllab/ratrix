function [targetSVNurl revNum] =checkTargetRevision(args)

targetSVNurl = '';
revNum = [];

if isempty(args)
    error('disallowing emtpy svn update command')
end

% svnRevision={'svn://132.239.158.177/projects/ratrix/tags/v0.8'};

% args can be either a 1-element or 2-element cell array as follows:
% args = {targetPath, [revisionNumber]}

minRev=1550;%the lowest revision that implements subject-specific permanent record storage

% check that the provided input arguments are as specified above
if iscell(args) && isvector(args) && length(args)<=2 && length(args)>0
    % check the first argument (targetPath) and also that it matches the ratrix root directory
    if ischar(args{1}) && isvector(args{1}) && strmatch('svn://132.239.158.177/projects/ratrix/',args{1})
        
        % check that if second argument is provided, it is above minRev
        if length(args)==2 && ~isempty(args{2})
            if (isinteger(args{2}) || isNearInteger(args{2})) && args{2}>minRev && isscalar(args{2})
                %isNearInteger needed cuz of http://132.239.158.177/trac/rlab_hardware/ticket/102
                revNum = uint32(args{2});
                revNumStr = num2str(revNum);
            else
                args{2}
                error('bad svn revision number')
            end
        else % if not provided, use HEAD revision
            revNumStr = 'HEAD';
        end
        
        % check that the path is either trunk or tag v0.8 (should replace with automated checking later)
        if checkSVNPath(args{1})
            % now check that the directory's commit tag revision number is up to date
            SVNproperties = getSVNPropertiesForPath(args{1}, {'commit'});
            commitRevNum = SVNproperties.commit;
            if commitRevNum < minRev
                error('bad svn revision number when applied to specified path');
            else
                % this is the successful case
                targetSVNurl = args{1};
            end
        else
            args{1}
            error('bad svn directory - must be trunk or tag v0.8');
        end
    end
end

end % end function

% HELPER FUNCTION
function pathIsOkay = checkSVNPath(url)
% This function checks that the given svn url is a valid path (trunk, or a tag >= 0.8)
% Should be called in both checkCurrentRevision and checkTargetRevision (to check the svn path in each)

pathIsOkay = false;


if strmatch(url, 'svn://132.239.158.177/projects/ratrix/trunk') || strmatch(url, 'svn://132.239.158.177/projects/ratrix/trunk/bootstrap')
    % check against trunk
    pathIsOkay = true;
else
    % check against tags
    [matches tokens] = regexpi(url, '/tags/v(\d+\.\d+)', 'match', 'tokens');

    % if we have more than one token, should not happen
    if length(tokens) > 1
        url
        error('found more than one tag in this path');
    elseif isempty(tokens)
        url
        error('invalid path specified - must be trunk or a tag');
    else
        version = str2num(tokens{1}{1});
        % also check that this tag even exists in the svn repository (so ppl don't make up paths)
        [s w] = system(sprintf('svn info --xml %s', url));
        if s ~= 0
            pwd
            svnCommand
            s
            w
          error('Unable to execute svn command');
        else
            if regexp(w, 'Not a valid URL')
                url
                error('invalid tag specified');
            end
        end

        % now check against 0.8 or higher
        if version >= 0.8
            pathIsOkay = true;
        end
    end
end
    

end % end function
