function positionFrame=getDefaultPositionFrame(width,height)
xPos=0.5;
yPos=0.5;
positionFrame = zeros(height, width, 'uint8');
pixFromLeft=round(xPos*width);  % round or floor or ceil?  test fraction with 1/3 of a pixel and 2/3 and 0.5...
pixFromRight=round((1-xPos)*width);
pixFromTop=round(yPos*height);
pixFromBottom=round((1-yPos)*height);
[leftRight, topDown] = meshgrid( -pixFromLeft:pixFromRight-1, -pixFromTop:pixFromBottom-1);
[locationBOTTOM] = ((topDown == round(leftRight*tan(pi/6)) | topDown == round(-leftRight*tan(pi/6))) & (topDown > 0));
[locationTOP] = ((-0.5 <= leftRight & leftRight <= 0.5)& (topDown < 0));
positionFrame(locationBOTTOM | locationTOP) = 255;

end 