function [p, out, did] = exec(p,dontWait)
if isempty(p.record)
    error('must call init first')
end

if ~busy(p)
    leds(p,[]);
end

if ~exist('dontWait','var') || isempty(dontWait)
    dontWait = false;
end

did = false;
out = inf;

if p.ind>0
    when = p.record(5,p.ind) + p.rate;
    out = GetSecs - when;
else
    when = 0;
end

if out>=-p.msTolerance && p.ind<p.n && ~(dontWait && busy(p))    
    did = true;
    p.ind = p.ind+1;
    
    % disp(['doing ' num2str(p.ind)])
    p.record([2 4],p.ind) = 0;
    
    p.record(1,p.ind) = WaitSecs('UntilTime', when);
    while ~dontWait && busy(p)
        p.record(2,p.ind) = p.record(2,p.ind) + 1;
    end
    
    p.record(3,p.ind) = GetSecs;
    p = trig(p,true);
    
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