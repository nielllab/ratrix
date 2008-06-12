function s=setSuper(s,sup)
    if isobject(sup) %or do we want isstruct(sup)?
        s.super=sup;
    end