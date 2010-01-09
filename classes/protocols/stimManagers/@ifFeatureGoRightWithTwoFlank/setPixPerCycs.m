function t=setPixPerCycs(t, value)

if isnumeric(value) && isvector(value) && value>=2 
    t.pixPerCycs=value;
else
    value=value
    error('pixPerCycs must a vector of values >=2')
end
    