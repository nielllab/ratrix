function p = exec(p)
if isempty(p.record)
    error('must call init first')
end

if (p.ind==0 || GetSecs-p.record(5,p.ind)>=p.rate) && p.ind<p.n
    p.ind = p.ind+1;
    p.record([2 4],p.ind) = 0;
    
    p.record(1,p.ind) = GetSecs;
    while busy(p)
        p.record(2,p.ind) = p.record(2,p.ind) + 1;
    end
    
    p.record(3,p.ind) = GetSecs;
    trig(p,true);
    
    while ~busy(p)
        p.record(4,p.ind) = p.record(4,p.ind) + 1;
    end
    p.record(5,p.ind) = GetSecs;
    
    trig(p,false);
end

    function out = busy(p)
        out = pp(p.busy,[],p.slowChecks,[],p.addr);
    end
end