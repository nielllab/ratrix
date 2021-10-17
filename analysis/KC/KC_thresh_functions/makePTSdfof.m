function [RoundXpts,RoundYpts,PTSdfof] = makePTSdfof(xPickedPts,yPickedPts,onsetDf)
% This function used the points selected in the previous step to index into onsetDf

    % SELECT ALL PTS from ONSET DF

    RoundXpts = round(abs(yPickedPts)); %switch x & y cuz matlab stores the x coorindate in rows & vice versa
    RoundYpts = round(abs(xPickedPts));

%     clear PTSdfof 
%     for i = 1:length(xPickedPts)
%         PTSdfof(i,:,:) = onsetDf(RoundXpts(i),RoundYpts(i),:,:);
%     end

    clear PTSdfof 
    for i = 1:length(xPickedPts)
        
        % dims in xPTSdfof are point, xpts, ypt, frames, trials
        xPTSdfof = onsetDf(RoundXpts(i)-1:RoundXpts(i)+1,RoundYpts(i),:,:); % select x +/- 1, y is just y
        meanXPTSdfof = mean(xPTSdfof,1); % take mean across the x dimension to get mean x dfof value
        % ^ has mean-ed x value but only 1 y vale
        meanXPTSdfof = squeeze(meanXPTSdfof);
        
        yPTSdfof = onsetDf(RoundXpts(i),RoundYpts(i)-1:RoundYpts(i)+1,:,:); % select x +/- 1, y is just y
        meanYPTSdfof = mean(yPTSdfof,2); % take mean across the x dimension to get mean x dfof value
        % ^ has mean-ed y value but only 1 x vale
        meanYPTSdfof = squeeze(meanYPTSdfof);
        
        % Can I just take the mean of the 2 mean-ed matricies?
        catXandMeanYptsDfof = cat(3,meanXPTSdfof,meanYPTSdfof); % concatenates in 3rd dimension
        meanXandMeanYptsDfof = mean(catXandMeanYptsDfof,3); % mean across both the x and y range versions...
        
        PTSdfof(i,:,:) = meanXandMeanYptsDfof; % collct for each point
        
    end

    sizePTSdfof = size(PTSdfof)

end

