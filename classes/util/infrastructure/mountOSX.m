function mountOSX(targ,loc)
if ismac
    if ~exist('targ','var')
        targ='/Volumes/rlab';
    end
    if ~exist('loc','var')
        loc='@132.239.158.181/rlab ';
    end
    
    [stat res]=system('mount');
    if stat==0
        if isempty(findstr(res,sprintf('%son %s',loc,targ)))
            
            [status,message,messageid] = mkdir(targ);
            if status
                [stat res]=system(sprintf('mount -o nodev,nosuid -t smbfs //rodent:1Mouse%s %s',loc,targ));
                if stat~=0
                    stat
                    res
                    error('couldn''t mount rlab')
                end
            else
                targ
                message
                messageid
                error('couldn''t mkdir')
            end
        end
    else
        stat
        res
        error('couldn''t check mounts')
    end
else
    error('only works on mac')
end