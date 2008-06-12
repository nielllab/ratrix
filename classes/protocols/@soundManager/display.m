function d=display(s)
    d=[];
    for i=1:length(s.clips)
        d=[d '\n\t\t\t\t' display(s.clips{i})];

    end
    d=sprintf(d);