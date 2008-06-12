%given a scalar struct and a vector of structs, add the fields/values in the scalar struct to the vector of structs
%in case of field name clashes, the scalar wins
function s2=combineStructs(s1,s2)
if isstruct(s1) && isstruct(s2) && isscalar(s1) && isvector(s2)
    fieldNames=fields(s1);
    for i=1:length(fieldNames)
        [s2.(fieldNames{i})]=deal(s1.(fieldNames{i}));
    end
else
    error('both inputs must be structs, the first a scalar and the second a vector')
end