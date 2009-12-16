function t=setPhase(t, value)

if isvector(value) && isnumeric(value)
    t.phase=value;
    %force recache?
else
    value=value
    error('phase must a vector of numbers')
end
    