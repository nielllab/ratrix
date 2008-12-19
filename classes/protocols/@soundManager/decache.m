function s=decache(s)

for i=1:length(s.clips)
    s.clips{i}=decache(s.clips{i});
end
s.players={};
s.playingNonLoop=false(1,length(s.clips));
s.playingLoop=false(1,length(s.clips));
s.clipDurs=zeros(1,length(s.clips));