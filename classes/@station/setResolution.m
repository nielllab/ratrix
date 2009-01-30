function [s newRes]=setResolution(s,res)

if res.pixelSize~=32
    error('color depth must be 32')
end

oldRes=Screen('Resolution', s.screenNum);

if oldRes.width~=res.width || oldRes.height~=res.height || oldRes.hz ~=res.hz || oldRes.pixelSize~=res.pixelSize

    resolutions=Screen('Resolutions', s.screenNum);

    match=[[resolutions.width]==res.width; [resolutions.height]==res.height; [resolutions.hz]==res.hz; [resolutions.pixelSize]==res.pixelSize];

    ind=find(sum(match)==4);

    if length(ind)>1
        ind
        warning('multiple matches')
        ind=min(ind);
    elseif length(ind)<1
        res
        unique([resolutions.width])
        unique([resolutions.height])
        unique([resolutions.hz])
        unique([resolutions.pixelSize])
        
        [resolutions.width]==res.width
        [resolutions.height]==res.height
         [resolutions.hz]==res.hz
         [resolutions.pixelSize]==res.pixelSize
        error('target res not available')
    end
%     Screen('Preference', 'SkipSyncTests',1);
    s=stopPTB(s);

    Screen('Resolution', s.screenNum, res.width, res.height, res.hz, res.pixelSize);
    s=startPTB(s);
    
    newRes=Screen('Resolution', s.screenNum);
    if ~all([newRes.width==res.width newRes.height==res.height newRes.pixelSize==res.pixelSize newRes.hz==res.hz])
        requestRes=res
        newRes=newRes
        warning('failed to get desired res') 
        sca
        keyboard
        error('failed to get desired res') %needs to be warning to work with remotedesktop
    end

else
    newRes=oldRes;
end