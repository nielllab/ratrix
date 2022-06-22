function [tifPic] = compareDfImages2(meanpolar,ypts,xpts,baselinedActIm,range)
% UNTITLED2 Summary of this function goes here
% Detailed explanation goes here

    figure
    
    
    % plot RAW TIF SHOWING BLOOD VESSELS
    % pick a tif pic, either matlab prompts user or manually navigate to right 
    % folder
    [f p] = uigetfile('*.tif','thresh tif file');
    tifPic = imread(fullfile(p,f));
    tifPic = flip(tifPic,2);
    
    % plot
    subplot(1,3,1)
    imagesc(tifPic)
    %colormap copper
    
    axis equal
    set(gca,'Visible','off')
    
    
    % plot TOPO MAP w/AREA BOUNDARIES
    % meanpolar made in do_topography
    subplot(1,3,2)
    imagesc(polarMap(meanpolar{2},95))
    
    hold on
    
    plot(ypts,xpts,'w.','Markersize',2)
    
    axis equal
    set(gca,'Visible','off') 
    
    
%     % plot UnCroped Df
%     % std of df gives us a general sense of how much variation there is across al trials
%     % we use image to crop in next section
%     stdMap = std(df(:,:,1:10:end),[],3); % only take every 10 frames of df (don't need all, why?). taking std across 3rd dimension, time
%     
%     subplot(1,2,3)
%     imagesc(stdMap,range) 
%     
%     colormap jet
%     
%     axis equal
%     set(gca,'Visible','off') 
    
    
    
    % plot IMAGE used for FOR PICKING POINTS
    % the function pickPeakActIm4Points() generates an output var called
    % baselinedActIm, which is needed for the figure to pick 5 points
    subplot(1,3,3)
    imagesc(baselinedActIm,range)
    
    colormap jet
    
    axis equal
    set(gca,'Visible','off') 
    
    hold on 
        
    % plot BOXES around points picked  
    % note: 1st point - each pt is one pixel 
    %[RoundXpts(1,1),RoundYpts(1,1)]
    % make a box around each point
    devitation = 2;
    global visArea
    for i = visArea

        global RoundXpts
        global RoundYpts
    
        x = [RoundXpts(1,i)-devitation:1:RoundXpts(1,i)+devitation];
        y1 = [(RoundYpts(1,i)+devitation)*ones(1,length(x))];
        y2 = [(RoundYpts(1,i)-devitation)*ones(1,length(x))];

        % reverse x & y...
        plot(y1,x,'w','lineWidth',2)
        hold on
        plot(y2,x,'w','lineWidth',2)
        hold on

        x1 = [(RoundXpts(1,i)+devitation)*ones(1,length(x))];
        x2 = [(RoundXpts(1,i)-devitation)*ones(1,length(x))];
        y = [RoundYpts(1,i)-devitation:1:RoundYpts(1,i)+devitation];

        % reverse x & y...
        plot(y,x1,'w','lineWidth',2)
        hold on 
        plot(y,x2,'w','lineWidth',2)
        
        axis equal
        set(gca,'Visible','off') 
        
        hold on 
        
    end % end i loop
    
    
    % print size of images
    sizeTifPic = size(tifPic)
    sizeTopoIm = size(polarMap(meanpolar{2},95))
    %sizeDfUnCropped = size(df) 
    sizePeakActIm = size(baselinedActIm)
    
     
end

