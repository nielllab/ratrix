function out = boxOKForStimManager(stimManager,b,r)

if isa(b,'box') && isa(r,'ratrix')
    out=1;
    stations=getStationsForBoxID(r,getID(b));
    for i=1:length(stations)
        if ~stationOKForStimManager(stimManager,stations(i))
            out=0;
        end
    end
else
    error('need a box and ratrix object')
end


end % end function