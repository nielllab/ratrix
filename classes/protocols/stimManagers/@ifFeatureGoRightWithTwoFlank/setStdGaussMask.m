function t=setStdGaussMask(t, value)

if all(size(value)==[1 1]) && value>=0 && value<=1
    t.stdGaussMask=value;
else
    value=value
    error('setStdGaussMask must a single number be between 0 and 1')
end
    