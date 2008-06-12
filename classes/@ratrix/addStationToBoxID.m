function r=addStationToBoxID(r,s,b)
bx=getBoxFromID(r,b);
if isa(s,'station') && ~isempty(bx) && checkPath(getPath(s))
    if isempty(getStationByID(r,getID(s)))
        if isempty(getStationsForBoxID(r,b)) || all(getPhysicalLocationForBoxID(r,b)==getPhysicalLocation(s))
            %TODO: should also check that no other boxes are at this
            %physical location
            
            if isempty(getStationByMACaddress(r,getMACaddress(s)))
                r.assignments{b}{1}{end+1,1}=s;
                r.assignments{b}{1}{end,2}=0;
                saveDB(r,0);
            else
                error('MAC address for that station already assigned to another station in this ratrix')
            end
        else
            error('box contains stations at other physical locations')
        end
    else
        error('station id already exists in ratrix')
    end
else
    error('s was not a station or box id not in ratrix or couldn''t get to station path')
end