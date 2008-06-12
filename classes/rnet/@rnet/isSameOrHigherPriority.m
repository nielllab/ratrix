function out=isSameOrHigherPriority(r,a,b)


    if ~isValidPriority(r,a) || ~isValidPriority(r,b)
        error('invalid priority')
    end
    
    ps=getSortedPrioritiesHighestFirst(r);
    

    out= find(a==ps)<=find(b==ps);