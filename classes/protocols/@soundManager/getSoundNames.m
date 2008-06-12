function s=getSoundNames(sm)
    s={};
    for i=1:length(sm.clips)
        s{i}=getName(sm.clips{i});
    end