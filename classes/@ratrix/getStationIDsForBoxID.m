function out=getStationIDsForBoxID(r,bid)
    out={};
    stns=getStationsForBoxID(r,bid);
    for i=1:length(stns)
%         out={out getID(stns(i))}; %changed to be cell cuz station id's are now strings, not ints ERROR: included empty set as a station .. pmm 03/26/2008 
          out{end+1}=getID(stns(i)); %remove the empty set from above
    end