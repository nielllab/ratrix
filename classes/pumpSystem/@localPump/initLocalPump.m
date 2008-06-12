function s=initLocalPump(s,st,pportaddr)

if ~ispc
    error('pump systems only supported on pc')
end

if isa(st,'station')
    s.station=st;
else
    error('need a station')
end

if ischar(pportaddr) && strcmp(pportaddr,'0378')
    %pass
else
    error('local pump only works for parallel port address 0378')
end



daqreset; %probably a bad idea
s.rezValveDIO=digitalio('parallel');
pa=get(s.rezValveDIO,'PortAddress');
if ~strcmp(pa(1:2),'0x') || str2num(pa(3:end)) ~= str2num(pportaddr)
    pa
    error('bad port address from digitalio(''parallel'')')
end

hwinfo=daqhwinfo(s.rezValveDIO);
DATA_PORT=1;
ls=hwinfo.Port(DATA_PORT) ;
lines = addline(s.rezValveDIO,ls.LineIDs,ls.ID,'out');

gotOne=false;
dels=[];
for i=1:length(s.rezValveDIO.line)
    if ~strcmp(s.rezValveDIO.line(i).LineName,['Pin' num2str(s.rezValvePin)])
        dels=[dels i];
    else
        if gotOne
            error('more than one matching line for that pin')
        else
            gotOne=true;
        end
    end
end
delete(s.rezValveDIO.line([dels]));
if ~gotOne || length(s.rezValveDIO.line)~=1
    error('couldn''t find matching line for that pin')
end
%s.rezValveDIO.line


s.inited=true;


setRezValve(s,s.const.valveOff);
[s.pump durs]=openPump(s.pump);


s=resetPosition(s);
