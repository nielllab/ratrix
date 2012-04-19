function s = setName(s,n)
if isvector(n) && ischar(n)
	s.name = n;
else
    error('need a string name')
end