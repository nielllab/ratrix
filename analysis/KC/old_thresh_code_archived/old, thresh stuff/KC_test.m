%%
% first getting rounded version of x & y coordinate vectors into new
% vector. Using these to index single cells in onsetDf.
RoundXpts = round(abs(ypts)) %switch x & y
RoundYpts = round(abs(xpts))

%% 
% now for every value in xpts, use that value to index onsetDf. store the
% indexed cells/frames/trials in a new matrix
clear PTSdfof % just in case
for i = 1:length(xpts) % make sure which dimension [length() vs size()]
    % bit confused how we go from 4 indexed dimensions in onsefDf to 3 in PTSdfof
    % is it because the i in PTSdfof is the info from the one cell
    % indicated by RoundXpts(i),RoundYpts(i)... it's because we end up
    % w/single dimensions after indexing onsetDf? would have thought needed
    % squeseze first
    PTSdfof(i,:,:) = onsetDf(RoundXpts(i),RoundYpts(i),:,:); % 1st x & y point, all frames, all trials/stim presentations
    % note: PTSdfof is points (rows) x frames (columns) x trials (3rd-D)
end

%%
% now were gonna plot dfof for each point on a different graph, many lines
% because each is a trial over 50 frames (x axis)
frameNum = 1:size(onsetDf,3); % making the x axis frame number - 3rd dimension onf onsetDf 
for i = 1:length(xpts)
    figure
    plot(frameNum,squeeze(PTSdfof(i,:,:))) % grabbing one point at a time, so get rid of single dimension w/squeeze
    % Q: size(squeeze(PTSdfof(1,:,:))) = 51 x 286... so how does plot()
    % plot the y coordinate? well for the x-coordinate, it just plots the
    % values inside the one row vector that is frame number. Do we need it
    % to average over trials? Yes future graph...
    % ... somewhere in last code block we go from 4-dims in onsetDf to 3
    % dims in PTSdfof
    % so plot() is plotting 286 series (trials, dim 2) of flurescence
    % values over 51 frames (dim1). dfof is the cell value. 
    ylim([-0.225 0.225]) 
    xlim([0 51])
    hold on 
    % here's plotting the mean over trials (dimension 2 in PTSdfof)
    plot(mean(squeeze(PTSdfof(i,:,:)),2),'linewidth',4)
end
 
%% 
% Like the last code, but plot each graph for each point as subplot 
% on the same main plot

figure % make one figure for all subplots
suptitle(sprintf('dfof vs frames for each pt & mean of all pts'))
for i = 1:length(xpts) % for each point
    subplot(2,3,i)% 
    plot(frameNum,squeeze(PTSdfof(i,:,:)))% plot dfof the first point vs frames for all trials trial
    hold on
    plot(mean(squeeze(PTSdfof(i,:,:)),2),'linewidth',4) 
    ylim([-0.225 0.225]) 
    xlim([0 51])
    
end

hold on % now plot the mean for each point on the 6th subplot
for j = 1:length(xpts)
    subplot(2,3,6)
    plot(mean(squeeze(PTSdfof(j,:,:)),2),'linewidth',1) % here's plotting the mean over trials (dimension 2 in PTSdfof)
    ylim([-0.1 0.1]) 
    xlim([0 51])
    hold on
end

%% want the same as last graph, but 3 seperate figures, one for each contrast

% need to make vectors with contrast values (no flankers yet)
for i=1:length(stimDetails); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    % note: stim details contains info (incl. contrast values) for every 
    % possible condition. It is NOT ordered by trial.
    tc(i) = stimDetails(i).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
end

% note: trial cond is a list of indicies for tc/stimdetails.targContrast.
% These indicies *are* ordered by trial
% so now, by using trialCond to index into tc, we can get a list of target
% contrasts in the order that they were presented:
tcTrial = tc(trialCond); % use trial cond to index into vector of 
% target contrast value for that condition during each trial, save in new
% vector 'tcTrial' that is a list of trial conditions ordered by trial

% so now let's make the same subplot as above but 3 seperate figures, one
% for each contrast 
contrasts = unique(tc); % gets a list of the contrast value options, 
% so we know how many contrasts to loop over

for c = 1:length(contrasts)
    figure % need a diff figure for each contrast value
    suptitle(sprintf('by contrast'))
    clear trials
    % note: 'tcTrial' is a list of trial conditions ordered by trial
    trials =  abs(tcTrial)==contrasts(c); % for each contrast, create a vector 
    %'trials' that has a zero if that trial has the c-th condtion and a zero
    %if it doesn't (Q: here's were I get confused - how will we use this to
    %index the correct trials?)
    for i = 1:length(xpts) % for each point 
        subplot(2,3,i)% each point gets its own subplot
        set(gcf,'Name',sprintf('tc = %0.3f  n = %d',contrasts(c),sum(trials)));
        plot(frameNum,squeeze(PTSdfof(i,:,trials)))% instead of taking all trials, just take the ones indicated by 'trials' vector 
        % Q: again, how, since trials is only 1's and zeros? 
        hold on
        % plotting dfof of each point vs frames but only for the c-th
        % contrast:
        plot(mean(squeeze(PTSdfof(i,:,trials)),2),'linewidth',4) 
        ylim([-0.225 0.225]) 
        xlim([0 51])
    end
    % note: need this next part to be w/in main loop, because we want it on
    % each contrast figure
    
    % now for each contrast figure, I want the 6th subplot to be the
    % mean trace for each point at that contrast
    hold on
    for j = 1:length(xpts)
        subplot(2,3,6)
        plot(mean(squeeze(PTSdfof(j,:,trials)),2),'linewidth',1) % here's plotting the mean over trials (dimension 2 in PTSdfof)
        ylim([-0.1 0.1]) 
        xlim([0 51])
        hold on
    end
end

%% now we're going to plot one figure, and each subplot is for one point with
% 3 traces - dfofof of each point over over frames per contrast

figure % only making 1 figure
suptitle(sprintf('dfof of each point vs frames, all contrasts'))   
clear i
for i = 1:length(xpts) % for each point
    subplot(2,3,i) % give each point it's own subplot
    % on each subplot plot the mean dfof across trials, vs frames
    
    % now on each subplot/for each point we're going 
    % to plot the mean across trials at each contrast, for each contrast
    clear c
    for c = 1:length(contrasts) 
        clear trials
        trials =  abs(tcTrial)==contrasts(c)
        meanOverTrialsPTSdfof = mean(PTSdfof(i,:,trials),3) % creating a 
        % 1x51 variable that has dfof of one point averaged across trials
        % at the c-th contrast, for all frames
        plot(frameNum,meanOverTrialsPTSdfof)
        ylim([-0.1 0.1]) 
        xlim([0 51])
        hold on
    end 
end

%% now we want the CSF - subplot of dfof at each point, averaged over time and trials, vs contrast on x axis

% plotting mean
figure 
for i = 1:length(xpts)
    
    clear c 
    for c = 1:length(contrasts)
        clear trials
        trials =  abs(tcTrial)==contrasts(c)
        meanOverTrialsPTSdfof = mean(PTSdfof(i,:,trials),3)
        meanOverFramesTrialsPTSdfof(c) = mean(meanOverTrialsPTSdfof,2) 
    end 
    x_axis = [1 2 3];
    subplot(2,3,i)
    plot(x_axis, meanOverFramesTrialsPTSdfof)
end 

% same but for max
clear c
clear i
x_axis = [1 2 3];
figure;
for i = 1:length(xpts)
    clear maxContRespOverFramesTrialsPTSdfof % clear this so the mean dfof for each points dont write over each other, plotting nonsense
    for c = 1:length(contrasts)
        clear trials
        trials =  abs(tcTrial)==contrasts(c); % pick trials
        meanOverTrialsPTSdfof = mean(PTSdfof(i,:,trials),3); % take the mean trace across trials, leaving dfof vs frames
        maxOverFramesTrialsPTSdfof = max(meanOverTrialsPTSdfof); % take the max value from that trace
        % save that value each time it's calculated in this loop:
        maxContRespOverFramesTrialsPTSdfof(1,c) = maxOverFramesTrialsPTSdfof
    end
    % still w/in the points for loop, now that we've collected vector of
    % means for each contrast, plot on subplot for each point
    subplot(2,3,i)
    scatter(x_axis,maxContRespOverFramesTrialsPTSdfof)
    ylim([-0.1 0.1]) 
end

%% to save all matlab variables 

save('MOUSE_ID__output_ThreshPassAnalysis')
save('EE81LT_010621__output_ThreshPassAnalysis')
save('EE81LT_020421__output_ThreshPassAnalysis')
save('277RT_020421__output_ThreshPassAnalysis')
save('analyzePass_G6H277RT_020421')
% this should automatically save all variables in the workspace as a mat file with this name
 % supposedly these two lines of code ban be used to exclude just some
 % variables.. second code is for if the variable is available as a string:
 
% save('test', '-regexp', '^(?!(a|d)$).')
 
% avoidVariable = 'a';
% save('test', '-regexp', ['^(?!', avoidVariable,'$).'])

%% findingLatency
 
% latency is the time from stim onset to peak activity. That would be the x
% value (in frames) for the y-axis value that is the max dfof value

find(meanOverTrialsPTSdfof == maxOverFramesTrialsPTSdfof(1))
%%

Y = log2(X)

contrastValues = [0 0.03 0.063 0.125 0.25 0.5 1];

logCont = log2(contrastValues)
logCont(1,1) = 0













       