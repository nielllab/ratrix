function s=decache(s)
    if ~isempty(s.protocol)
        s.protocol=decache(s.protocol);
    end