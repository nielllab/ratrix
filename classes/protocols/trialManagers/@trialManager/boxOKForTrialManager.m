function out=boxOKForTrialManager(t,b,r)
if isa(b,'box') && isa(r,'ratrix')
    out=0;
    stations=getStationsForBoxID(r,getID(b));
    for i=1:length(stations)
        if stationOKForTrialManager(t,stations(i))
            out=1;
        end
    end
else
    error('need a box and ratrix object')
end