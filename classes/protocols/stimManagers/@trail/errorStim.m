function [out scale] = errorStim(stimManager,numFrames)
itl = double(getInterTrialLuminance(stimManager)); % .5?

if false %itl
    scale = 0;
    out = itl;
end

[~,a]=getMACaddress;
switch a
    case 'C8600060B768' %gcamp imaging (dirty!)
        ifi = 1/60; %dirty
        tm = []; %dirty
        lastFrame = 1; % dirty
        [out, type, startFrame, scale, nfrms] = correctStim(stimManager,numFrames,ifi,tm,lastFrame);
        
%         sca
%         keyboard
        
        out = out.stim.stimulus;
                
        numFrames = max(numFrames,nfrms);
        
        if false % not quite ready -- need to change errorStim to work like correctStim in updateTrialState
                 % this version is naive and OOM's when lots of frames
                 % we need to be able to pass out the smarter type from correctStim
            tmp = out;
            out = itl * ones([size(tmp,1),size(tmp,2),numFrames],'double');
            out(:,:,1:nfrms) = repmat(tmp,[1 1 nfrms]);
        end
        
    otherwise
        [out, scale] = errorStim(stimManager.stimManager,numFrames);
end