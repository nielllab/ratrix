RoundXpts = round(abs(xpts))
RoundYpts = round(abs(ypts))

for i = 1:size(xpts)
    PTSdfof(i) = onsetDf(RoundXpts(i),RoundYpts(i)); % 1st x & y point, all frames, one response session
end

PTSdfof = squeeze(PTSdfof)'
timeInFrames = 1:size(onsetDf,3);
figure
plot(timeInFrames,PTSdfof)



newMatrix = onsetDf(1,1,:,:);
testPTSdfof(1) = onsetDf(RoundXpts(1),RoundYpts(1))












%%

% use xpts & ypts to index into dfof_bg and grab the dfof values, store in 2 new vectors

% I'm trying to use the xpts & ypts as indicies for onsetDf
% had to round xpts & ypts to use as indicies (close enough)
for numPts = 1:length(xpts)
    onsetPTSdfof(1,numPts) = onsetDf(RabsXpts(numPts),RabsYpts(numPts),1,1) %grabbing fluorecence values for x1,x1, x2,ys, etc)
end

% now want to subtract dfof at these space points at 2 different time
% points.. right now it's just one frame one stim presentation... let's do
% across all trials to start

for numPts = 1:length(xpts)
    stimOnsetTimePTSdfof(1,numPts,:,:) = onsetDf(RabsXpts(numPts),RabsYpts(numPts),11,:) % right after onset frames only (frame 11), all stim presentations
    diffTimeptsPTSdfof(1,numPts,:,:) = onsetDf(RabsXpts(numPts),RabsYpts(numPts),3*f,:) % makes 1 row, 5 columns, 286 trials
    % take mean across time dimention for both of these new matricies
    meanStimOnsetPTSdfof = mean(stimOnsetTimePTSdfof,3) 
    meanDiffTimeptsPTSdfof = mean(diffTimeptsPTSdfof,3)
    % note: we're at single frames still right now... the loop will do this
    % for all 12 time points - subtract 11th frame from 3*f frame
    % now subtract the two means:
    diffFromBaseline = (meanDiffTimeptsPTSdfof - meanStimOnsetPTSdfof) % how do several of my means come out to zero?
    bar(diffFromBaseline)
end



% want to plot these fluorescence values over 12 time points - use bar
% graph, y values will be dfof and x values are categorical - brain areas
contrasts = unique(abs(fc));
tcontrasts = unique(tc);
for c = 1:length(contrasts);
    for c2= 1:length(tcontrasts)
        trials = abs(fcTrial)==contrasts(c) & tcTrial ==tcontrasts(c2); % select only trials where targ & flank c are at certain value
        % these trials are basically the new 'chunks' of dfif_bg subsections centered around stim onset
        figure
        suptitle(sprintf('dfof over time for PTS, both targ & flank, targC = %d', c2))
        for f = 1:12;
            % on each subplot, i want a bar graph
            subplot(3,4,f) 
            bar ((mean(onsetDf(xpts,ypts,f*3,trials),4)-mean(onsetDf(xpts,ypts,11,trials),4))