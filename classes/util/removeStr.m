function out=removeStr(s,str)
    found=0;
    ind=1;
    out={};
    for i=1:length(s)
        if strcmp(s{i},str)
            if found
                error('found mulitple copies of str in list s')
            end
            found=1;
        else
            out{ind}=s{i};
            ind=ind+1;
        end
    end

    if ~found
        error('list s didn''t contain str')
    end