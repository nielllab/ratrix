function [onsetImFrames] = onsetImagingFrames(filteredStimOnsets,frameT)
% This function matches the stimulus onset frames with their corresponding imaging frames

    % making variable 'onsetImagingFrames', which containf the index for the 1st imaging frame after each stimulus onset
    clear onsetImFrames

    % collecting the index of the first imaging frame that follows each stim onset
    clear f
    for f = 1:length(filteredStimOnsets); % for each stim onset time/frame

        onsetImFrames(f) = find(diff(frameT>filteredStimOnsets(f))); % onsetImagingFrames are the frame indcies for the 
        % imaging frame that matches up with the onset of the stim (filteredOnsets(i))

    end

    sizeOfOnsetImFrames = size(onsetImFrames) % one onset imaging frame for each trial

end

