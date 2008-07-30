function [r rx tf]=registerClient(r,c,mac,zone,rx,subjects)
tf=false;
if clientIsRegistered(r,c)
    error('that client already exists in the register')
elseif isMACaddress(mac) && isinteger(zone) && zone>0
    s=getStationByMACaddress(rx,mac);
    if ~isempty(s)

        for i=1:length(subjects)
            %subjects{i}{2}{2}
            if strcmp(subjects{i}{2}{2},mac)

                rx=putSubjectInBox(rx,subjects{i}{1},getBoxIDForStationID(rx,getID(s)),'ratrix');
                tf=true;

            end
        end

        if tf
            r.serverRegister{size(r.serverRegister,1)+1,1}=c; %holding on to these might be what's keeping java from clearing
            r.serverRegister{size(r.serverRegister,1),2}=mac;
            r.serverRegister{size(r.serverRegister,1),3}=zone;
            r.serverRegister{size(r.serverRegister,1),4}=[]; %reward waits
            r.serverRegister{size(r.serverRegister,1),5}=[]; %reward durs
        else
            warning('no subject for that mac')
        end

    else
        warning('no station for that mac')
    end
else
    error('not a good mac address or not a good zone')
end