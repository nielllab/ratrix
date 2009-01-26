function times=flushPorts(dursSec,numSquirts,ifi,st)

if ~exist('dursSec','var')
    dursSec=2;  
end


if ~exist('numSquirts','var')
    numSquirts=1;
end

if ~exist('ifi','var')
    ifi=.1;
end

if ~exist('st','var')
 r = getRatrix;
 bids=getBoxIDs(r);
    boxID=bids(1);
    st=getStationsForBoxID(r,boxID);
end

numPorts=getNumPorts(st);

if all(size(dursSec)==1)
    squirtDuration = dursSec*ones(1,3);
else
%     squirtDuration=durMs;
    squirtDuration=dursSec;
    if length(dursSec) ~= getNumPorts(st)
        %check that there are only as many args as available ports;
        error('durMs bust be length of num ports')
    end
end

%set bag pressure to just below letters that say "PRESSURE"

%doFlush(squirtDuration)  % does all at once

i=1;
times=zeros(3,numSquirts);
for i=1:numSquirts
    for j=1:numPorts
        valvesUsed=zeros(1,numPorts);
        valvesUsed(j)=1;
        
        setValves(st,valvesUsed); %open
        
        times(j,i)=GetSecs();
        WaitSecs(squirtDuration(j));
        times(j,i)=GetSecs()-times(j,i);

        setValves(st,zeros(1,numPorts)); %close

        WaitSecs(ifi);
    end
end