function t=setCriterion(t,c)
if isa(c, 'criterion')
    t.criterion = c ;
else
    error('must be a criterion')
end