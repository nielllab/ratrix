function [range,colorMapOrNot] = pickImageToCrop(df,subjName,date)
% The purpose of this funciton is to crop the imaging movie ('df') so that visual cortex is centered and the rest is cropped out. 
% For input, this function needs subjName and date, which are created in loadSubjSessInfo()
% This function prompts the user to pick a a 'range' value for imagesc(), then uses imagesc() to display the standard deviation of fluorescnce 
% (variation in activity) across entire imaging movie. After displying the image, OUTSIDE of this function, the larger script should
% asks the user whether the image is acceptable for cropping, or whether the user would like to try again with a different range value. 
% This function does not perform the crop itself, because this function itself may need to be looped thru several times 
% This function outputs range & colorMapOrNot b/c they're needed in next function, doCrop().

    % SELECT RANGE/PICK IMAGE TO CROP from df
    range = input('from 0-1, what range values to use? Enter in bracket form with low & high end values: ')
    colorMapOrNot = input('use colormap jet or no (yes = , no = 2)?: ')
    
    % std of df gives us a general sense of how much variation there is across al trials
    % we use image to crop in next section
    stdMap = std(df(:,:,1:10:end),[],3); % only take every 10 frames of df (don't need all, why?). taking std across 3rd dimension, time
    
    figure;
    
    clear titleText
    titleText = 'stDev of dfof across time (whole thresh movie)';
    title(sprintf('%s ',date,subjName,titleText))
    imagesc(stdMap,range) 
    
    if colorMapOrNot == 1
        colormap jet
    end
      
end

