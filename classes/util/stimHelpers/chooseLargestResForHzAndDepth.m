function [ind height width]=chooseLargestResForHzAndDepth(resolutions,hzs,depth)
hzs=sort(hzs,'descend');

for i=1:length(hzs)
    hz=hzs(i);
    inds=find([[resolutions.hz]==hz & [resolutions.pixelSize]==depth]);
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

error('should never get here')