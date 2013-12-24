function [out scale] = errorStim(stimManager,numFrames)
if false %itl
scale = 0;
out = .5;
end

[~,a]=getMACaddress;
switch a
    case 'C8600060B768' %gcamp imaging
        ifi = 1; %dirty
        tm = []; %dirty
        lastFrame = 1; % dirty
        [out, type, startFrame, scale, numFrames] = correctStim(stimManager,numFrames,ifi,tm,lastFrame);
                 
%          sca
%          keyboard

        out = out.stim.stimulus;

    otherwise
        [out, scale] = errorStim(stimManager.stimManager,numFrames);        
end