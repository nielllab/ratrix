function setReinfAssocSecs(sm,s)
if ~all(cellfun(@(f) f(s),{@isscalar @isreal @(x) x>=0 }))
    error('reinfAssocSecs must be scalar real >= 0')
end
sm.reinfAssocSecs = s;
end