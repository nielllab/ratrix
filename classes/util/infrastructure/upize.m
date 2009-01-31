function out=upize(subjectIDs, rackID)
%accept a set of ID strings and transform them into the equivalent string
%for upstairs, by adding ('up') to the end
%
%example: subjectIDs=upize({'155'}, 101)

% old:
% rackID='101A'
%rig=sscanf(rackID,'%d%s',1)
%expect the rackID to be between 101 and 110 for rigs upstairs

if rig>100 && rig<110
    rigStr=num2str(rig-100)
else
    error('unexpected rigID...can only upize for upstairs')
end

for i=length(subjectIDs)
    out{i}=[subjectIDs{i} 'up' rigStr];
end


