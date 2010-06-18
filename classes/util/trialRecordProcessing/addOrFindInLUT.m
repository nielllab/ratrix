function [indices LUT] = addOrFindInLUT(LUT, fields)
% this function takes in an existing LUT and fields, both as cell arrays
% and tries to find each element in fields in the LUT.
% if the field does not exist in LUT, then it is added to the LUT
% returns the updated LUT, and indices, which is an array of the same size as fields that contains the index for each element in fields
% whether or not it was added.

indices=zeros(1,length(fields));
for i=1:length(fields)
    if ischar(fields{i})
        result=find(strcmp(LUT,fields{i}));
        if isempty(result) % did not find in LUT - ADD
            LUT{end+1} = fields{i};
            result=length(LUT);
        end
        indices(i)=result;
    elseif isempty(fields{i}) 
        % don't add the empty set, tho it is a number according to matlab
        indices(i)=nan;
    elseif isnumeric(fields{i})
        result=find(cellfun(@(x) isnumeric(x)&&all(x==fields{i}), LUT));
        if isempty(result) % did not find in LUT - ADD 
            LUT{end+1} = fields{i};
            result=length(LUT);
        end
        indices(i)=result;
    else
        error('can only add strings and numerics to the LUT');
    end
end

end % end function