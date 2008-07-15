function setRes

%hardcoded for now (FE-992)
width=1024;
height=768;
hz=100;
depth=32;
scrNum=max(screen('screens'));

resolutions=Screen('Resolutions', scrNum);

match=[[resolutions.width]==width; [resolutions.height]==height; [resolutions.hz]==hz; [resolutions.pixelSize]==depth];

ind=find(sum(match)==4);

if length(ind)~=1
    error('target res not available')
end

Screen('Resolution', scrNum, width, height, hz, depth);

res=Screen('Resolution', scrNum);
if ~all([res.width==width res.height==height res.pixelSize==depth res.hz==hz])
    error('failed to get desired res')
end