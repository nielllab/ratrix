function v=getPhysicalLocationForBoxID(r,b)
s=getStationsForBoxID(r,b);
if length(s)==1
    v=getPhysicalLocation(s);
else
    error('zero or multiple stations for that box id or no boxes with that id')
end