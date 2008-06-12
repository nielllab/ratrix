function out=outsidePositionBounds(p)
    %out=p.currentPosition>p.maxPosition || p.currentPosition<p.minPosition;
    out=wdrTooFar(p) || infTooFar(p) || p.currentPosition>p.maxPosition || p.currentPosition<p.minPosition;
    
    if out
        'wdrtoofar:'
        wdrTooFar(p)
        'inftoofar:'
        infTooFar(p)
        '[min cur max]:'
        [p.minPosition p.currentPosition p.maxPosition]
    end