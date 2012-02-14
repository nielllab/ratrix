function sub = setID(sub,id)
if isvector(id) && ischar(id)
    sub.id=id;
else
    error('id must be string')
end
end