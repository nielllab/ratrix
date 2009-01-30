function [ind height width hz]=chooseLargestResForHzsDepthRatio(resolutions,hzs,depth,maxWidth,maxHeight)

if ismac
    hzs=union(hzs,0); %have to add zero for osx, cuz screen('resolutions') returns all hz as 0
    maxWidth=1920; %erik's macbook pro has timing problems (red flashing exclamation point) at 800x600
    maxHeight=1200;
end

ratio=maxWidth/maxHeight;

hzs=sort(hzs,'descend');

for i=1:length(hzs)
    hz=hzs(i);
    inds=find([[resolutions.hz]==hz & [resolutions.pixelSize]==depth] & ([resolutions.width]./[resolutions.height])==ratio & [resolutions.width]<=maxWidth & [resolutions.height]<=maxHeight);
    pix=[resolutions(inds).height] .* [resolutions(inds).width];
    ind=find(pix==max(pix));
    ind=inds(ind);
    if length(ind)>1
        warning('didn''t find unique ind')
        ind=inds(1);
    end
    if length(ind)==1
        height = resolutions(ind).height;
        width = resolutions(ind).width;
        if hz==0
            warning('resorting to hz=0 (screen(resolutions) reports 0 hz in osx)')
        end
        return
    end
end
ind=nan;
x=Screen('Resolution',max(Screen('Screens'))); %error -- this may not be the screen, but we don't have a handle to it...
height=x.height;
width=x.width;
hz=x.hz;
warning('no match')