function s=decache(s)

for i=1:length(s.clips)
    s.clips{i}=decache(s.clips{i});
end
s.player=[];
s.playing=[];
s.looping=false;
s.boundaries=[];
s.clipDurs=zeros(1,length(s.clips));