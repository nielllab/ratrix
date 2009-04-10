function str=dhms(timestamp,format)
secsAgo=etime(datevec(datenum(timestamp,format)),datevec(now));

if secsAgo>0
    error('only works for past times')
end

secsAgo=-secsAgo;
days=floor(secsAgo/60/60/24);
secsAgo=secsAgo-days*24*60*60;
hours=floor(secsAgo/60/60);
secsAgo=secsAgo-hours*60*60;
mins=floor(secsAgo/60);
secsAgo=secsAgo-mins*60;
secs=floor(secsAgo);

str='';
if days>0
    str=sprintf('%d days ',days);
end
if hours>0 || days>0
    str=sprintf('%s%02d:%02d:%02d',str,hours,mins,secs);
elseif mins>0
    str=sprintf('%02d:%02d',mins,secs);
else
    str=sprintf('%d secs',secs);
end
str=sprintf('%s ago',str);