function out=structize(s)
    out=struct(s);
    if ~isempty(s.super)
        disp(sprintf('structable base: structizing a %s, which subclasses %s',class(s),class(getSuper(s))))
        out.(class(s.super))=structize(s.super);
    else
        disp(sprintf('structizing a %s, which has no superclass',class(s)))
    end