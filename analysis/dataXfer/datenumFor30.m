function n=datenumFor30(x)
%converts text strings of iso 8601 into matlab's datenum
%oddly datenum does not support this type, maybe it's the 'T'
%
%x='20071013T000552'
%y=datenumFor30 (x)
year=str2num(x(1:4));
month=str2num(x(5:6));
day=str2num(x(7:8));
hour=str2num(x(10:11));
minute=str2num(x(12:13));
second=str2num(x(14:15));

n = datenum(year,month,day,hour,minute,second);

%test
if ~strcmp(x,datestr(n,30))
    x
    datestr(n,30)
    error ('fails to preserve ID of that time')
end