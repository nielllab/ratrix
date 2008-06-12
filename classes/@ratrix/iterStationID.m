function out=iterStationID(rx,curr,dir)
s=getStations(rx);
n=[];
for i=1:length(s)
    n=[n getID(s(i))];
end
if curr==0 && ~isempty(n)
    out=min(n);
else
    [tf loc]=ismember(curr,n);
    if tf
        switch dir
            case 'next'
                %loc=loc; %ha
            case 'prev'
                loc=loc-2; %go figure...
            otherwise
                error('bad dir arg -- must be next or prev')
        end
        out=n(mod(loc,length(n))+1);
    else
        error('no stations or no station by that number')
    end
end