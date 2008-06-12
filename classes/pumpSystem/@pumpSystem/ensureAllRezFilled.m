function durs=ensureAllRezFilled(s)
durs=zeros(1,length(s.zones));
for i=1:length(s.zones)
    durs(i)=ensureRezFilled(s.zones{i});
end