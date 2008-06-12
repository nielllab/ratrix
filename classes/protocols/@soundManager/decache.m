function s=decache(s)

for i=1:length(s.clips)
    s.clips{i}=decache(s.clips{i});
end

s.records=struct([]);