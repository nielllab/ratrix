function r=setMsPenalty(r, value)
% 8.25.15 - edf modified to allow ==0, used to be >0 -- any reason not ok?
if isscalar(value) && isreal(value) && value>=0 && isnumeric(value)
   r.msPenalty = value;
else
    error('scalar must be a number >= 0')
end