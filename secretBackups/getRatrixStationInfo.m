function out=getRatrixStationInfo(mac)
stations = {...
    %mac            id1	id2	rack	row	col	server
    {'?'        	1	'A'	1       1	1	'132.239.158.154'}...  %old 3
    {'?'        	2	'B'	1       1	2	'132.239.158.154'}...  %old 1
    {'?'        	3	'C'	1       2	1	'132.239.158.154'}...  %old 2
    {'?'        	4	'D'	1       2	2	'132.239.158.154'}...  %old x
    {'?'        	5	'E'	1       3	1	'132.239.158.154'}...  %old 
    {'?'        	6	'F'	1       3	2	'132.239.158.154'}...  %old 
    ...    %7-9 reserved
    ...%
    {'0018F35DFADB'	10	'A'	2       1	1	'132.239.158.156'}...
    {'0018F35DEE62'	11	'B'	2       1	2	'132.239.158.156'}...
    {'0018F34EAE45'	12	'C'	2       1	3	'132.239.158.156'}...
    ...%{'001D7DA810C9'	13	'D'	2       2	1	'132.239.158.169'}... %adam's for testing upstairs
    {'001A4D9326C2'	13	'D'	2       2	1	'132.239.158.156'}...
    {'001A4D523D5C'	14	'E'	2       2	2	'132.239.158.156'}...
    {'001D7D9ACF80'	15	'F'	2       2	3	'132.239.158.156'}...
    ...    %16-18 reserved
        ...%
    {'001D7DA5B8EE'	19	'A'	3       1	1	'132.239.158.172'}... %157 in viv.
    {'001D7D9ACF5D'	20	'B'	3       1	2	'132.239.158.172'}...
    {'001D7D9EC809'	21	'C'	3       1	3	'132.239.158.172'}...
    {'001D7D9ED6B7'	22	'D'	3       2	1	'132.239.158.172'}...
    {'001A4D513BFD'	23	'E'	3       2	2	'132.239.158.172'}...
    {'001D7D9ACF8F'	24	'F'	3       2	3	'132.239.158.172'}...
    {'001A4D5026E6'	25	'G'	3       3	1	'132.239.158.172'}...
    {'001D7DA5D253'	26	'H'	3       3	2	'132.239.158.172'}...
    {'001A4D932760'	27	'I'	3       3	3	'132.239.158.172'}...
    };

out=[];

if isempty(mac)
    out=stations;
    return
end

if isscalar(mac) && isnumeric(mac)
    out={};
    for i=1:length(stations)
        if stations{i}{4}==mac
            out{end+1}={stations{i}{3} getRatrixStationInfo({mac stations{i}{3}})};
        end
    end
    return
end

if iscell(mac) && isvector(mac) && length(mac)==2  && isnumeric(mac{1}) &&  ischar(mac{2})

    positions={};
    for i=1:length(stations)
        if stations{i}{4}==mac{1} && stations{i}{3}==mac{2}
            if isempty(out)
                out{1}=[stations{i}{5} stations{i}{6}];
                out{2}=stations{i}{1};
            else
                error('multiple entries for that rack/station letter')
            end
        end
    end
    if isempty(out)
        error('no entry for that rack/station letter')
    end
    return
end

if ischar(mac)

    done=false;
    for i=1:length(stations)
        if strcmp(stations{i}{1},mac)


            out.id1=stations{i}{2};
            out.id2=stations{i}{3};
            out.rack=stations{i}{4};
            out.row=stations{i}{5};
            out.col=stations{i}{6};
            out.server=stations{i}{7};

            if any(getRatrixRackInfo(out.rack)<[out.row out.col]) || any([out.row out.col]<=0)
                getRatrixRackInfo(out.rack)
                out.row 
                out.col
                error('bad row/col listed for station')
            end

            if done
                error('multiple entries for that mac')
            else
                done=true;
            end
        end
    end

    if ~done
        error('mac address not found')
    end
    return
end

error('mac must be [] (to get all stations), a MAC address string, a rackNum, or {rackNum letterID}')