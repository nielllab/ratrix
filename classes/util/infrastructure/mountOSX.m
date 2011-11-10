function mountOSX(targ,loc,login,pw)
if ismac
    if ~exist('targ','var')
        targ='/Volumes/rlab';
    end
    if ~exist('loc','var')
        loc='@132.239.158.181/rlab ';
    end
    if ~exist('login','var')
        login='rodent';
    end
    if ~exist('pw','var')
        pw='1Mouse';
    end


    [stat res]=system('mount');
    if stat==0
        if isempty(findstr(res,sprintf('%son %s',loc,targ)))
            
            [status,message,messageid] = mkdir(targ);
            if status
                [stat res]=system(sprintf('mount -o nodev,nosuid -t smbfs //%s:%s%s %s',login,pw,loc,targ));
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