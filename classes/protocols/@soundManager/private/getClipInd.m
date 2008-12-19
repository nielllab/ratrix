function match=getClipInd(sm,soundName)
match=0;
for i = 1:length(sm.clips)
    if strcmp(getName(sm.clips{i}),soundName)
        if match>0
            error('found more than 1 clip by same name')
        end
        match = i;
    end
end
if match<=0
    error('found no clip by that name')
end