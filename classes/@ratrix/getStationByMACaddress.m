function s=getStationByMACaddress(r,m)
s=[];
stations=getStations(r);
for i=1:length(stations)
%     getMACaddress(stations(i))
%     strcmp(getMACaddress(stations(i)),m)
    if strcmp(getMACaddress(stations(i)),m)
        if isempty(s)
            s=stations(i);
        else
            error('found more than one station with that MAC address')
        end
    end
end