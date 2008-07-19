function r=setMsPenalty(r, value)
if all(size(value) == [1 1]) && isnumeric(value) && value>0
   r.msPenalty = value;
else
    error('scalar must be a number > 0')
end