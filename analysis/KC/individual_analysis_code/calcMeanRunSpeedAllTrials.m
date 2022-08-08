function [meanSpeedAllTrials] = calcMeanRunSpeedAllTrials(allStop,allResp)
% This function takes in allStop & allResp, and outputs the mean run speed(displacement)for each trial, 'meanSpeedAllTrials'. 

% CALCULATE MEAN RUN SPEED FOR EVERY TRIAL 
% needs ball data loaded, that's it 

% make VECTOR W/MEAN SPEED FOR EACH TRIAL in a recording session

% number of trials this recording session
numTrialsInSession = length(allResp) % num trials this session

clear meanSpeedAllTrials % clear each session's final mean speed per trial vector

% for each TRIAL, calulate MEAN RUN SPEED
clear tr
for tr = 1:length(allResp) % for each row/trial in the allResp struct array

    % extract x & y coordinate value for each frame in the tr-th trial
    clear allXCoordinatesTthTrial % clear - note that there's a new number 
    % of frames/coordinates each trial
    allXCoordinatesTthTrial = allResp(tr).xpos; % this is the x value at each frame 
    % during the first trial of this session
    
    clear allYCoordinatesTthTrial
    allYCoordinatesTthTrial = allResp(tr).ypos; % this is the y value at each frame 
    % during the first trial of this session
    
    numFramesTrthTrial = size(allYCoordinatesTthTrial); % this shows # frames in each trial... uncomment if want
    
    % calculate displacement between each frame
    clear tr_thDiffX
    clear tr_thDiffY
    tr_thDiffX = diff(allXCoordinatesTthTrial);
    tr_thDiffY = diff(allYCoordinatesTthTrial);
    tr_thDisplacement = sqrt(tr_thDiffX.^2+tr_thDiffY.^2); % P. Theorem
    
    size(tr_thDisplacement); % should be = # tr_th frames-1
    
    % the running speed for each trial is the
    % mean displacent for that trial    
    clear tr_thMeanSpeed
    tr_thMeanSpeed = mean(tr_thDisplacement,2); % units are pixels?
    
    % store the mean speed for each trial in a cell in a vector
    meanSpeedAllTrials(1,tr) = tr_thMeanSpeed;
    % should have 1 x # trials vector w/mean speed of each trial in each cell
    
end % end trials loop

% to check if speed was calc'd for each trial
sizeOf_meanSpeedAllTrials = size(meanSpeedAllTrials)

% % line PLOT of mean running speed vs trials/time for this session
% figure
% clear x_axis
% x_axis = [1:length(meanSpeedAllTrials)]; % number of trials
% % plot mean speed vs trials
% plot(x_axis,meanSpeedAllTrials)
% xlabel('trial')
% ylabel('mean running speed')
% title('mean running speed vs trial, one recording session')
% xlim([0 length(meanSpeedAllTrials)])
% ylim([min(meanSpeedAllTrials) max(meanSpeedAllTrials)])
% 
% % BAR plot of same
% figure
% xRangeMin = 800;
% xRangeMax = 1000;
% bar(meanSpeedAllTrials(1,xRangeMin:xRangeMax))
% xlabel('trials')
% ylabel('mean running speed')
% title('mean running speed vs trials')
% xlim([0 length(meanSpeedAllTrials(1,xRangeMin:xRangeMax))])
% ylim([-5 500])
% 
% % HISTO showing FREQuency of different RUNning SPEEDs for FOR EVERY TRIAL
% 
% numTrials = length(meanSpeedAllTrials)
% numBins = 10
% 
% histogram(meanSpeedAllTrials,numBins,'normalization','probability')
% ylabel('fraction of trials')
% xlabel('mean running speed')
% title('percentage of trials at differnt running speeds')
% xlim([0 round(max(meanSpeedAllTrials)+10)])
% set(gca,'xtick',0:25:round(max(meanSpeedAllTrials)+10));
% ylim([0 1])

end

