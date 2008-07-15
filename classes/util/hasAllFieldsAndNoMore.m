function pass = hasAllFieldsAndNoMore(f,allowedFields)

pass=0;

missingFields = setdiff(allowedFields,f);
if ~isempty(missingFields)
    disp('the following fields are missing from the parameterStructure:');
    for i=1:size(missingFields,2)
        disp(char(missingFields{i}));
    end
    error('missing fields for trial manager input');
end

extraFields = setdiff(f,allowedFields);
if ~isempty(extraFields)
    disp('the following fields are not allowed in the parameterStructure:');
    for i=1:size(extraFields,2)
        disp(char(extraFields{i}));
    end
    error('missing fields for trial manager input');
end

pass=1;
