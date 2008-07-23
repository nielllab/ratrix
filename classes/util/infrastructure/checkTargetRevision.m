function [targetSVNurl revNum] =checkTargetRevision(args)

if isempty(args)
    error('disallowing emtpy svn update command')
end

if iscell(args) && isvector(args) && length(args)<=2 && length(args)>0
    if ischar(args{1}) && isvector(args{1}) && strmatch('svn://132.239.158.177/projects/ratrix/',args{1})
        %how also check that this is a valid top-level ratrix path -- ie, one that directly contains the bootstrap directory?
        targetSVNurl=args{1};

        revNum=uint32([]);

        if length(args)==2 && ~isempty(args{2})
            minRev=1372;%the lowest revision that knows how to update to newer revisions
            
            if (isinteger(args{2}) || isNearInteger(args{2})) && args{2}>minRev && isscalar(args{2})
                %isNearInteger needed cuz of http://132.239.158.177/trac/rlab_hardware/ticket/102
                revNum = uint32(args{2});
            else
                args{2}
                error('bad svn revision number')
            end
        end
    else
        args{1}
        error('bad svn url')
    end
else
    args
    error('bad svn target revision args')
end