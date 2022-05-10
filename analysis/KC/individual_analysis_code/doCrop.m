function [xPtsCrop,yPtsCrop,dfCROP] = doCrop(df,range,colorMapOrNot,date,subjName)
% This function takes in df and the range defined in pickImageToCrop() and
% outputs a cropped version of the imaging movie, 'dfCROP'. It then generates a 
% pixel-wise image of the cropped movie's standard deviation (over frames).  
% note: this function also uses colorMapOrNot, which is defined in pickImageToCrop()
% Also needs date & subjName. Saving out xPtsCrop & yPtsCrop just in case. 

    % SHOW image for cropping, using range & color jet setting defined in pickImageToCrop()
    
    % std of df gives us a general sense of how much variation there is across al trials
    stdMap = std(df(:,:,1:10:end),[],3); % only take every 10 frames of df. taking std across 3rd dimension, time
    
    figure;
    imagesc(stdMap,range) 
    
    if colorMapOrNot == 1
        colormap jet
    end
    
    clear titleText
    titleText = 'stDev of dfof across time (whole thresh movie)';
    title(sprintf('%s ',date,subjName,titleText))
      
    % DO the CROP
    
    % crop manually by picking top left and then bottom right corners of a rectangle
    [xPtsCrop yPtsCrop] = ginput(2);
    dfCROP = df(yPtsCrop(1):yPtsCrop(2),xPtsCrop(1):xPtsCrop(2),:); % cropping df to be area I select 

    % SHOW the CROPPED image
    
    stdMap = std(dfCROP(:,:,1:10:end),[],3); % dfCROP this time
    
    figure
        
    imagesc(stdMap,range)
    %imshow(stdMap,range)
    axis equal
    
    if colorMapOrNot == 1
        colormap jet
    
    clear titleText
    titleText = 'CROPPED stDev of dfof across time';
    title(sprintf('%s ',date,subjName,titleText))

    axis equal
    
end

