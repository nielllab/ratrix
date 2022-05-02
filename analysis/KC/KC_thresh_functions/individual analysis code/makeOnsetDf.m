function [onsetDf] = makeOnsetDf(onsetImFrames,dfCROP,numPreStimFrames,numPostStimFrames)
% This function makes a matrix containing a "chunk" of frames before,
% during, and after stimulus presentation, for each trial. 

    % use the indicies for the 1st imaging frame following stimulus onset,
    % plus the num pre & post frames defined earlier in this script,
    % to index into dF % take 'chunks' of video around each stim onset

    clear i
    clear onsetDf

    for i = 1:length(onsetImFrames) % for each onset imaging frames
        % then select only the imaging frames right before & after the onset imaging frame of each stim
        onsetDf(:,:,:,i) = dfCROP(:,:,onsetImFrames(i)-numPreStimFrames:onsetImFrames(i)+numPostStimFrames);
    end

    sizeOfOnsetDf = size(onsetDf)

end

