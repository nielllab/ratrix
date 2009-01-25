function out=isHumanSubjectID(id)
% is it three letters and (maybe but not required) then some numbers
% example: 'pmm', 'pmm2', 'edf10009'


if ischar(id)
    id={id};
end

for i=1:length(id)
    if ischar(id{i})
        out(i)=all(isstrprop(id{i}(1:3), 'alpha')) && all(isstrprop(id{i}(4:end), 'digit'));
    else
        id
        error('id must be a char')
    end
end