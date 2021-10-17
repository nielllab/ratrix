function [percentSlippedImagingFrames,timeStampsStopAndRespFramesAlltrialsMinusT0,percentSlippedMonitorFrames] = checkImagingAndMonitorFrames(frameT,allStop,allResp,subjName,date)
% The point of this function is to make figures that will diagnose any issues with the triggering 
% of imaging acquistion (10Hz) or stimulus/monitor frame presentation (60 Hz) - ideally, the time 
% between sucessive frames should be equal, and of the correct value...
% This function takes in frameT (imaging frame time stamps, loaded from maps file in loadStage2Vars()), 
% and allResp & allStop(stimulus/trial/session timestamps/info, loaded from balldata folder in loadStage2subjSessVars()), 
% and outputs a vector of monitor frame timestamps (timeStampsStopAndRespFramesAlltrials), and the percentage of "slipped" 
% imaging & monitor frames, as well as diagnostic figures. It needs the subjectName & date for figure titles.
% There are a lot of other useful calulations in this function that just need to be uncommented/have output arguments added. 


    %%% CHECKing dt BETWEEN IMAGING FRAME TIMES  %%%
    % to make sure our imaging frames are equal intervals apart

    diffFrameT = diff(frameT);
    % plotting the difference between each successive value in frameT
    % LINE plot
    figure
    clear titleText
    titleText = 'inter-frame interval: IMAGING';
    suptitle(sprintf('%s ',date,subjName,titleText));
    plot(diffFrameT)
    xlim([0 length(frameT)])
    ylim([0 0.7])
    xlabel('frame number')
    ylabel('seconds')
    clear titleText
    titleText = 'difference in time between all imaging frames, vs time';
    title(sprintf('%s ',titleText))
    % HISTO - distribution of dt's
    figure
    % numBins = 10;
    histogram(diffFrameT,'normalization','probability')
    xlabel('seconds between imaging frames')
    ylabel('fraction of frames')
    clear titleText
    titleText = 'distribution of inter-frame time intervals: IMAGING';
    title(sprintf('%s ',titleText))
    % indicies of slipped frames
    idxDiffFrameToverPt12 = find(diffFrameT>0.12);
    idxDiffFrameTunderPt08 = find(diffFrameT<0.08);
    idxUnderOrOver = [idxDiffFrameTunderPt08,idxDiffFrameToverPt12]; % concatenate
    idxUnderOrOverInOrder = sort(idxUnderOrOver); % put indicies in order
    % raw numbers of frames
    numImagingFrames = length(frameT)
    numIdxDiffFrameToverPt12 = length(idxDiffFrameToverPt12);
    numIdxDiffFrameTunderPt08 = length(idxDiffFrameTunderPt08);
    numSlippedImagingFrames = length(idxUnderOrOverInOrder);
    % percentanges
    percentFrameToverPt12 = (numIdxDiffFrameToverPt12/length(diffFrameT))*100;
    percentFrameTunderPt08 = (numIdxDiffFrameTunderPt08/length(diffFrameT))*100;
    percentSlippedImagingFrames = length(idxUnderOrOverInOrder)/length(diffFrameT)*100
    % number of frames apart slipped frames are
    diffBetweenSlippedImagingFrames = diff(idxUnderOrOverInOrder); % number of frames apart each slipped frame is
    meanNumFramesBetweenSlippedImagingFrames = mean(diffBetweenSlippedImagingFrames,2);
    sterrMeanNumFramesBetweenSlippedImagingFrames = std(diffBetweenSlippedImagingFrames,[],2)/sqrt(length(diffBetweenSlippedImagingFrames));
    % plot DIST for NUM FRAMES between SLIPped frames
    figure
    numBins = 100;
    histogram(diffBetweenSlippedImagingFrames,numBins,'normalization','probability')
    title('distribution of the number of *frames* between SLIPPED frames')
    xlabel('number of frames between slipped frames')
    ylabel('fraction of frames')
    % the actual dt values of slipped frames
    slippedDtValues = diffFrameT(idxUnderOrOverInOrder);
    meanTimeBetweenSlipppedFrames = mean(slippedDtValues,2);
    sterrTimeBetweenSlipppedFrames = std(slippedDtValues,[],2)/sqrt(length(slippedDtValues));
    % plot DIST of actual slipped dt values
    figure
    numBins = 100;
    histogram(slippedDtValues,numBins,'normalization','probability')
    title('distribution of the amount of *time* between SLIPPED frames')
    xlabel('time in seconds')
    ylabel('fraction of frames')
    % PLOT differnce in time (not frames) between slipped frames (diffFrameT), vs time/frames
    slippedDtValuesInOrderOfAcquistion = sort(slippedDtValues);
    figure
    clear x_axis
    x_axis = [1:length(slippedDtValues)]; % x axis is frames
    plot(x_axis,slippedDtValues)
    xlabel('frames/time')
    ylabel('dt')
    title('magnitude of time between SLIPPED frames, vs time/frames')

    
    %%% Getting all TIME STAMPS for CURSOR MEASUREMENTS (60 hz) [prep for dt monitor calculations] %%%

    % for one session, concatenate frameT time stamps from each TRIAL
    clear timeStampsStopAndRespFramesAlltrials
    timeStampsStopAndRespFramesAlltrialsMinusT0 = []; % to store all time stamps in order - 1st stop, 1st resp, 2nd stop, 2nd resp etc
    clear tr % for each trial trial
    for tr = 1:length(allStop) % for each row/trial in the struct array
        % STOP period is before response period
        % extract time stamps
        clear timeStampsTthTrialAllStop % clear - note that there's a new number of frames/coordinates each trial
        timeStampsTthTrialAllStop = allStop(tr).frameT; % this is the time of each frame during the tr_th trial
        % now do time stamps for RESPonse period
        clear timeStampsTthTrialAllResp
        timeStampsTthTrialAllResp = allResp(tr).frameT;
        % stitch together all timestamps in order of frames/trials
        timeStampsStopAndRespFramesAlltrialsMinusT0 = [timeStampsStopAndRespFramesAlltrialsMinusT0,timeStampsTthTrialAllStop,timeStampsTthTrialAllResp];
    end
    % set TIMESTAMPS RELATIVE to 1ST FRAME of the 1ST TRIAL
    % put timeStampsStopAndRespFramesAlltrials in time that is relative to the first frame
    % of the trial, which is allStop.frameT(1) -
    % this is the very first frame of the very first trial in of the session, which is a
    % stop trial. the stim could come a few frames later or right away.
    t0 = allStop(1).frameT(1); % 1st frame for 1st trial
    clear ts
    % for each time stamp
    for ts = 1:length(timeStampsStopAndRespFramesAlltrialsMinusT0) % probably could have done this w/o a for loop?
        % subtract t0 so that time is relative to 1st frame onset
        timeStampsForCursorAFramesAlltrialsMinusT0(1,ts) = timeStampsStopAndRespFramesAlltrialsMinusT0(ts)-t0; % units is seconds I beleive
    end
    sizeOfTimeStampsForCursorAFramesAlltrialsMinusT0 = size(timeStampsStopAndRespFramesAlltrialsMinusT0);
    figure
    plot(timeStampsStopAndRespFramesAlltrialsMinusT0)
    ylabel('computer time')
    xlabel('frames')
    title('time stamps vs frames/time')
    

    %%% CHECK dt BETWEEN MONITOR FRAME TIMES (needs cursor/monitor time stamps) %%%

    dtMonitorFrames = diff(timeStampsStopAndRespFramesAlltrialsMinusT0);
    % plotting the difference between each successive value in timeStampsStopAndRespFramesAlltrialsMinusT0
    figure
    clear titleText
    titleText = 'inter-frame time interval: MONITOR';
    suptitle(sprintf('%s ',date,subjName,titleText));
    % line PLOT dt monitor frames vs time/frames
    x_axis = [1:length(dtMonitorFrames)];
    plot(x_axis,dtMonitorFrames)
    xlim([0 length(dtMonitorFrames)])
    %ylim([0 0.02])
    xlabel('frame number')
    ylabel('seconds between frames')
    clear titleText
    titleText = 'difference in time between all MONITOR frames';
    title(sprintf('%s ',titleText))
    % HISTO - frequency distribution of dt for monitor frames
    figure
    % numBins = 10;
    histogram(dtMonitorFrames,'normalization','probability')
    xlabel('seconds between monitor frames')
    ylabel('fraction of frames')
    clear titleText
    titleText = 'distribution of inter-frame time intervals: MONITOR';
    title(sprintf('%s ',titleText))
    % indicies
    clear idxAllRespOverPt18
    idxAllRespOverPt18 = find(dtMonitorFrames>0.018);
    clear idxAllRespUnderPt14
    idxAllRespUnderPt14 = find(dtMonitorFrames<0.014);
    clear idxUnderOrOver
    idxUnderOrOver = [idxAllRespUnderPt14,idxAllRespOverPt18]; % concatenate
    clear idxUnderOrOverInOrder
    idxUnderOrOverInOrder = sort(idxUnderOrOver); % put in order of acquisition
    % raw numbers
    numMonitorFrames = length(dtMonitorFrames)
    numIdxAllRespOverPt18 = length(idxAllRespOverPt18);
    numIdxAllRespUnderPt14 = length(idxAllRespUnderPt14);
    numAllSlippedMonitorFrames = length(idxUnderOrOverInOrder);
    % percentages
    percentIdxAllRespOverPt18 = (numIdxAllRespOverPt18/length(dtMonitorFrames))*100;
    percentIdxAllRespUnderPt14 = (numIdxAllRespUnderPt14/length(dtMonitorFrames))*100;
    percentSlippedMonitorFrames = length(idxUnderOrOverInOrder)/length(dtMonitorFrames)*100
    % what are the mean dt values for the slipped frames?
    dtMonitorFramesOverPt18 = dtMonitorFrames(idxAllRespOverPt18);
    meanDtMonitorFramesOverPt18 = mean(dtMonitorFramesOverPt18,2);
    sterrDtMonitorFramesOverPt18 = std(dtMonitorFramesOverPt18,[],2)/sqrt(length(dtMonitorFramesOverPt18));
    dtMonitorFramesUnderPt14 = dtMonitorFrames(idxAllRespUnderPt14);
    meanDtMonitorFramesUnderPt14 = mean(dtMonitorFramesUnderPt14,2);
    sterrDtMonitorFramesUnderPt14 = std(dtMonitorFramesUnderPt14,[],2)/sqrt(length(dtMonitorFramesUnderPt14));
    dtAllSlippedMonitorFramesInOrder = dtMonitorFrames(idxUnderOrOverInOrder);
    meanDtAllSlippedMonitorFrames = mean(dtAllSlippedMonitorFramesInOrder,2);
    sterrDtAllSlippedMonitorFrames = std(dtAllSlippedMonitorFramesInOrder,[],2)/sqrt(length(dtAllSlippedMonitorFramesInOrder));
    % number of frames apart slipped frames are
    numFramesBetweenSlippedFramesTooLarge = diff(idxAllRespOverPt18);
    numFramesFramesBetweenSlippedFramesTooSmall = diff(idxAllRespUnderPt14);
    diffBetweenAllSlippedMonitorFrames = diff(idxUnderOrOverInOrder); % number of frames apart each slipped frame is
    meanNumFramesBetweenSlippedImagingFrames = mean(diffBetweenAllSlippedMonitorFrames,2);
    sterrMeanNumFramesBetweenSlippedImagingFrames = std(diffBetweenAllSlippedMonitorFrames,[],2)/sqrt(length(diffBetweenAllSlippedMonitorFrames));
    % plot DIST for NUM FRAMES between SLIPped frames
    figure
    numBins = 100;
    histogram(diffBetweenAllSlippedMonitorFrames,numBins,'normalization','probability')
    title('monitor: distribution of the number of frames between SLIPPED frames')
    xlabel('number of frames between slipped frames')
    ylabel('fraction of frames')
    % the actual dt values of slipped frames:
    clear slippedDtValues
    slippedDtValues = dtMonitorFrames(idxUnderOrOverInOrder);
    meanSlippedDtValues = mean(slippedDtValues,2);
    sterrSlippedDtValues = std(slippedDtValues,[],2)/sqrt(length(slippedDtValues));
    % ALMOST EVERY SLIPPED DT IS 6 FRAMES APART?
    % plot DIST of actual slipped dt values
    figure
    numBins = 100;
    histogram(slippedDtValues,numBins,'normalization','probability')
    title('monitor: distribution of the amount of time between SLIPPED frames')
    xlabel('time in seconds')
    ylabel('fraction of frames')
    % PLOT difference in time (not frames) between slipped frames (diffFrameT), vs frames/time
    slippedDtValuesInOrderOfAcquistion = sort(slippedDtValues);
    figure
    clear x_axis
    x_axis = [1:length(slippedDtValues)]; % x axis is frames
    plot(x_axis,slippedDtValues)
    xlabel('frames/time')
    ylabel('seconds')
    title('time interval between SLIPPED frames, vs frames/time: MONITOR')
    % relationship between imaging & monitor frame slips
    numImagingFrames;
    numSlippedImagingFrames;
    percentSlippedImagingFrames;
    numMonitorFrames;
    numAllSlippedMonitorFrames;
    percentSlippedMonitorFrames;
    numSlipMONframesAreThisPercentOfTotImgFrames = numAllSlippedMonitorFrames/numImagingFrames*100;
    numSlipIMGframesAreThisPercentOfTotMONFrames = numSlippedImagingFrames/numMonitorFrames*100;
    % I should check to see if the timestamps for slipped img & slipped mon frames lines up or anything like that...

end

