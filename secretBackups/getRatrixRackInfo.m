function out=getRatrixRackInfo(rack)
racks={...
    %rackNum    %numShelves     %numColumns
    {1,         3,              2},...
    {2,         2,              3},...
    {3,         3,              3}};

done=false;
for i=1:length(racks)
    if rack==racks{i}{1}
        if ~done
            out=[racks{i}{1,2:3}];
            done=true;
        else
            error('multiple entries for that rack')
        end
    end
end
if ~done
    error('rack not found')
end