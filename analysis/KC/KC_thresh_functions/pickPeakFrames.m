function [peakFrameIdx] = pickPeakFrames(stimOnsetFrame)
% can change num peak frames in here

    % get PEAK FRAMES

    clear peakFrameIdx
    clear f
    % I don't include the stim onset frame itself b/c that usually has low/no activity,
    % but I define the next 10 frames as the peak response
    for f = 1:10 % average over n# peak frames
       peakFrameIdx(f) = stimOnsetFrame+f;
    end % now you can index the peak frames automatically if you change stim onset
    
    stimOnsetFrame % displaying this to compare to peakFrameIdx
    peakFrameIdx
    
end

