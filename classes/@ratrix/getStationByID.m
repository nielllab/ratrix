function s=getStationByID(r,id)
found=0;
s=[];

for bx=1:length(r.assignments)
    if ~isempty(r.assignments{bx})
        for st=1:size(r.assignments{bx}{1},1)
            if strcmp(getID(r.assignments{bx}{1}{st,1}),id) %changed from sid's being ints and checking w/==
                if found
                    error('found multiple stations with that id')
                else
                    found=1;
                    s=[s r.assignments{bx}{1}{st,1}];
                end
            end
        end
    end
end