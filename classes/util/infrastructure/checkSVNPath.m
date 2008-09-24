function pathIsOkay = checkSVNPath(url)
% This function checks that the given svn url is a valid path (trunk, or a tag >= 0.8)
% Should be called in both checkCurrentRevision and checkTargetRevision (to check the svn path in each)

pathIsOkay = false;


if strmatch(url, 'svn://132.239.158.177/projects/ratrix/trunk')
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