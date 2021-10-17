function [xPickedPts,yPickedPts ] = pickVisAreaPts(baselinedActIm,range,colorMapOrNot)
% Prompts user to pick visual areas points from peak activity image
% 'range' is defined in previous step

    % pick 5 pts - V1, motor ctx, 3 HVAs

    clear xPickedPts 
    clear yPickedPts 

    % show activation image
    
    figure
    suptitle('points picked over peak activation')

    imagesc(baselinedActIm,range)
    
    if colorMapOrNot == 1
        colormap jet
    end 
    
    axis equal

    % pick points
    
    for i = 1:5

        hold on
        [xPickedPts(i) yPickedPts(i)] = ginput(1);
        plot(xPickedPts(i),yPickedPts(i),'*');

    end

end

