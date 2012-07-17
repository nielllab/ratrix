function [p, out] = exec(p) %consider adding a bool input "bail if still busy"
if isempty(p.record)
    error('must call init first')
end

out = inf;

if p.ind>0
    out = GetSecs - p.record(5,p.ind) - p.rate;
end

if out>=0 && p.ind<p.n
    p.ind = p.ind+1;
    disp(['doing ' num2str(p.ind)])
    p.record([2 4],p.ind) = 0;
    
    p.record(1,p.ind) = GetSecs;
    while busy(p) %consider adding a bool input "bail if still busy"
        p.record(2,p.ind) = p.record(2,p.ind) + 1;
    end
    
    p.record(3,p.ind) = GetSecs;
    trig(p,true);
    
    while ~busy(p) %pco always ack's our trig immediately with a busy, but if it took a while, we could bail here
        p.record(4,p.ind) = p.record(4,p.ind) + 1;
    end
    p.record(5,p.ind) = GetSecs;
    
    trig(p,false);
end

    function out = busy(p)
        out = pp(p.busy,[],p.slowChecks,[],p.addr);
    end
end