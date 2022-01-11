function plotPrePostBaselineOnsetDfVsFrames(onsetDf,date,subjName,baselineIdx)
% This function takes the mean across trials of the whole cropped FOV in onsetDf, plots dfof vs frames, 
% then subtracts the baseline from the mean dfof trace, then plots that to show that the pre-stim frames 
% start at/around zero, as they should. 

    %looking at the average trace over time for onsetDf PRE BASELINE

    % take mean across whole image, all trials/conditions
    mnAcrossDim1 = squeeze(mean(onsetDf,1)); % mean across row pix
    mnAcrossDim2 = squeeze(mean(mnAcrossDim1,1)); % mean across column pix
    mnAcrossDim3 = mean(mnAcrossDim2,2); % mean across trials
    mnAcrossDim3 = mnAcrossDim3';
    mnOnsetChunk = mnAcrossDim3; % now I have 1 x # frames

    % plot mean dfof (acriss trials) vs frames of whole cropped video for onset chunk time frames
    numFrames = [1:length(mnOnsetChunk)]; % x axis 
    numSec = (numFrames)*0.1;

    figure

    clear titleText
    titleText = sprintf('\n dfof vs peri-onset frames, mean across trials, all conditions');
    suptitle(sprintf('%s ',date,subjName,titleText))
    
    yMax = 0.02;

    for j = 1:2 % pre & post baselined plots

        if j == 1

            % plot mean chunk trace
            subplot(1,2,j)
            plot(numFrames,mnOnsetChunk)
            ylim([-0.01 yMax])
            xlim([0 length(numFrames)])
            xlabel('frame') 
            ylabel('df/f')
            clear titleText
            % titleText = sprintf();
            % title(sprintf('%s ',titleText))

        end 

        if j == 2  

            % POST Baseline

            % index into just the baseline frames of the mean chunk
            allBaseMnOnsetChunk = mnOnsetChunk(1,baselineIdx);
            % get mean for 1st 4 frames
            meanBaseOnsetChunk = mean(allBaseMnOnsetChunk,2);
            %subtract mean from each cell in mnChunkOnset vector
            baselinedMnOnsetChunk = mnOnsetChunk-meanBaseOnsetChunk;
            % plot
            clear x_axis
            x_axis = 1:length(baselinedMnOnsetChunk);
            subplot(1,2,j)
            plot(x_axis,baselinedMnOnsetChunk)
            ylim([-0.01 yMax])
            xlim([0 length(numFrames)])
            xlabel('frame') 
            ylabel('df/f')
            clear titleText
            titleText = sprintf('baselined');
            title(sprintf('%s ',titleText))

        end

    end

end

