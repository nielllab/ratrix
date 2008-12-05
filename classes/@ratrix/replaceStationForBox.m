function r=replaceStationForBox(r,s)
if isa(s,'station') && checkPath(getPath(s))
    b=getBoxIDForStationID(r,getID(s));

    %could make a method: r=removeStationFromBoxID(r,b);
    if size(r.assignments{b}{1},1)==1 && boxIDEmpty(r,b) && ~boxIDRunning(r,b)
        r.assignments{b}{1}={};
        saveDB(r,0);
    else
        error('box did not have exactly one station, contained one or more subjects, or was running')
    end

    r=addStationToBoxID(r,s,b);
else
    error('s was not a station or box id not in ratrix or couldn''t get to station path')
end
end