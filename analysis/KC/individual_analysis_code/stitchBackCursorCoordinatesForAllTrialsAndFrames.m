function [allXYcursorCoordinatesStopAndRespFramesAlltrials] = stitchBackCursorCoordinatesForAllTrialsAndFrames(allStop,allResp)
% This is usually the 1st step of running analysis - the figures are mainly
% diagnostic. 
% Remember that there's a different number of frames in each trial(row in allResp/Stop)... 
% This function takes allResp and allStop, extracts optical mouse recordings, "stitches them back" 
% in order of time/trial presentationand, and generates the variable 'allCoordinatesStopAndRespFramesAlltrials'.
% it also plots magnitude of x & y coordinates over time, as well as "running path".
% note that, while timestamps for monitor frames were calulated in checkImAndMonitorFrames(), 
% they ere not needed here.

    % for one SESSION, concatenate X values & Y values from each TRIAL,
    % including both the STOP & RESP periods

    % coordinates from each trial will be extracted and saved to a variable within
    % the for loop. Then I concatenate the x & y coordinate vectors outside
    % of the loop. 

    % Because the number of frames/coordinates is different for each trial,
    % I have to define these variable here as empty matricies so that 
    % I can keep adding to them in the loop.. there might be another way to do this but idk

    % make empty vectors to store all stop & resp x/y points from all
    % trials:
    
    % x & y coordinates allSTOP
    clear allXCoordinatesAllTrialsOneSessAllStop 
    allXCoordinatesAllTrialsOneSessAllStop = []; 
    clear allYCoordinatesAllTrialsOneSessAllStop 
    allYCoordinatesAllTrialsOneSessAllStop = [];

    % x & y coordinates allRESP
    clear allXCoordinatesAllTrialsOneSessAllResp 
    allXCoordinatesAllTrialsOneSessAllResp = [];
    clear allYCoordinatesAllTrialsOneSessAllResp 
    allYCoordinatesAllTrialsOneSessAllResp = [];

    % for x & y coordinates stitched back in order
    clear XCoordinatesStopAndRespFramesAlltrials 
    XCoordinatesStopAndRespFramesAlltrials = []; % to store all x coordinates in order - 1st stop, 1st resp, 2nd stop, 2nd resp etc
    clear YCoordinatesStopAndRespFramesAlltrials
    YCoordinatesStopAndRespFramesAlltrials = []; % same but for y

    % extract x & y coordinates for each trial & concatenate them in the temporal order in which they were recorded:
    
    clear tr
    for tr = 1:length(allStop) % for each row/trial in the allResp struct array  

        % the stop period is before the response period
        % extract x & y coordinate values for each frame in the stop period of the tr-th trial
        
        clear allXCoordinatesTthTrialAllStop % clear - note that there's a new number of frames/coordinates each trial
        allXCoordinatesTthTrialAllStop = allStop(tr).dx; % this is the x value at each frame during the trial
        clear allYCoordinatesTthTrialAllStop
        allYCoordinatesTthTrialAllStop = allStop(tr).dy;

        % now do coordinates for RESPonse period

        clear allXCoordinatesTthTrialAllResp 
        allXCoordinatesTthTrialAllResp = allResp(tr).xpos; % this is the x value at each frame during the tr_th trial 
        clear allYCoordinatesTthTrialAllResp
        allYCoordinatesTthTrialAllResp = allResp(tr).ypos;

        % stitch together all x & cordinates in order of frames/trials
        
        XCoordinatesStopAndRespFramesAlltrials = [XCoordinatesStopAndRespFramesAlltrials,allXCoordinatesTthTrialAllStop,allXCoordinatesTthTrialAllResp];
        YCoordinatesStopAndRespFramesAlltrials = [YCoordinatesStopAndRespFramesAlltrials,allYCoordinatesTthTrialAllStop,allYCoordinatesTthTrialAllResp];

    end

    % concatenate x & y coordinates for all frames/trials:
   
    clear allCoordinatesStopAndRespFramesAlltrials
    allXYcursorCoordinatesStopAndRespFramesAlltrials = [XCoordinatesStopAndRespFramesAlltrials;YCoordinatesStopAndRespFramesAlltrials];
    
    sizeOf_allXYcursorCoordinatesStopAndRespFramesAlltrials = size(allXYcursorCoordinatesStopAndRespFramesAlltrials)
    
    % plot raw x & y coordinates over time:
    figure
    clear x_axis
    x_axis = [1:length(allXYcursorCoordinatesStopAndRespFramesAlltrials)]; % x axis is one 60 hz (16 ms) frame for each coordinate
    plot(x_axis,allXYcursorCoordinatesStopAndRespFramesAlltrials(1,:)) % plot x coordinates over whole session
    hold on
    plot(x_axis,allXYcursorCoordinatesStopAndRespFramesAlltrials(2,:)) % plot y coordinates over whole session
    title(' x & y coordinate values over time for one session')
    xlabel('frames (16 ms apart)')
    ylabel('coordinate value')
    xlim([0 length(x_axis)])
    legend({'x','y'})


    % optical mouse 'position'/"running path" for ALL trials/one session -
    % plot the x coordinates vs the y coordinates as a line
    % this will show the "running path" over time (cursor pattern on screen):
    figure
    plot(allXYcursorCoordinatesStopAndRespFramesAlltrials(1,:),allXYcursorCoordinatesStopAndRespFramesAlltrials(2,:))
    title('"location" over time/"running path" for one trial')
    xlabel('x coordinate')
    ylabel('y coordinate')
    legend('running path')

end

