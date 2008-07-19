function pass=hasAllFieldsInThatOrder(f,allowedFields)

pass=0;

for i=1:size(f,1)
    if ~strcmp(f{i},allowedFields{i})
        error(sprintf('expected ''%s'' but found ''%s''',allowedFields{i},f{i}))
    end
end

%just confirm neither one has extra fields at the end...
pass=hasAllFieldsAndNoMore(f,allowedFields);

