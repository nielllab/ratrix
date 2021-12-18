function [tifPic] = pickVisAreaPts3figs(meanpolar,ypts,xpts,baselinedActIm,df,range)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    figure
    title('test')

    % TOPO MAP w/AREA BOUNDARIES
    % meanpolar made in do_topography
    subplot(1,3,1)
    imshow(polarMap(meanpolar{2},95))
    hold on
    plot(ypts,xpts,'w.','Markersize',2)
    axis equal

    % IMAGE FOR PICKING POINTS
    % the function pickPeakActIm4Points() generates an output var called
    % baselinedActIm, which is needed for the figure to pick 5 points
    hold on 
    subplot(1,3,2)
    imagesc(baselinedActIm,range)
    axis equal

    % RAW TIF SHOWING BLOOD VESSELS
    % pick a tif pic, either matlab prompts user or manually navigate to right 
    % folder
    % CHANGE FILE NAME!
    addpath C:\Users\nlab\Desktop\KC_tif_pics
    tifPic = imread('F:\Kristen\Widefield2\305RT\070421_G6H305RT_RIG2\070421_G6H305RT_RIG2_THRESH');
    tifPic = flip(tifPic,2);
    hold on
    subplot(1,3,3)
    imagesc(tifPic)
    axis equal
    
    sizeTopoIm = size(polarMap(meanpolar{2},95))
    sizeDfUnCropped = size(df) 
    sizePeakActIm = size(baselinedActIm)
    sizeTifPic = size(tifPic)
    
end

