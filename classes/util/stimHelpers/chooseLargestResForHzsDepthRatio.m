function [ind height width hz]=chooseLargestResForHzsDepthRatio(resolutions,hzs,depth,maxWidth,maxHeight)

ratio=maxWidth/maxHeight;
hzs=sort(hzs,'descend');

for i=1:length(hzs)
    hz=hzs(i);    
    inds=find([[resolutions.hz]==hz & [resolutions.pixelSize]==depth] & ([resolutions.width]./[resolutions.height])==ratio & [resolutions.width]<=maxWidth & [resolutions.height]<=maxHeight);
    pix=[resolutions(inds).height] .* [resolutions(inds).width];
    ind=find(pix==max(pix));
    ind=inds(ind);
    if length(ind)>1
        error('didn''t find unique ind')
    elseif length(ind)==1
        height = resolutions(ind).height;
        width = resolutions(ind).width;
        return    
    end
end
ind=nan;
x=Screen('Resolution',max(Screen('Screens'))); %error -- this may not be the screen, but we don't have a handle to it...
height=x.height;
width=x.width;
hz=x.hz;
warning('no match')