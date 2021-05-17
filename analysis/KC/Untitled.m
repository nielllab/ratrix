% MEAN DF/F vs FRAMES for each DURATION, per visual area
% mean TRACE = contrast, SUBPLOT = point

clear subplotNum
subplotNum = 1;
clear r
r = 1;

figure % only making 1 figure
suptitle(sprintf('df/f vs frames for each duration in each visual area'))   

clear i
for i = 1:length(xPickedPts) % for each point
    subplot(2,3,i) % give each point it's own subplot
    % on each subplot plot the mean dfof across trials, vs frames
    
    % now on each subplot/for each point we're going 
    % to plot the mean across trials at each contrast, for each contrast
    clear d
    for d = 1:length(uniqueDurations) 
        clear dthTrials
        %cthConOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetsMeetBothCriteria);
        dthTrials = durOrderedByTrial == uniqueDurations(d); 
        
        meanOverTrialsPTSdfof = mean(PTSdfof(i,:,dthTrials),3); % creating a 
        % 1x51 variable that has dfof of one point averaged across trials
        % at the c-th contrast, for all frames
        
        %STDEV
        err = std(PTSdfof(i,:,dthTrials),[],3)/sqrt(sum(dthTrials)); % across all trials = 3rd dim
        % stdOverTrialsPTSdfof = (std(meanOverTrialsPTSdfof)/sqrt(trials);
        % err = stdOverTrialsPTSdfof*ones(size(meanOverTrialsPTSdfof)); % b/c just one stdev for whole trace across trials at the c-th contrast
        
        % for later group analysis - for each contrast, a trace for the i-th point
        % forGroupMeanOverTrialsPTSdfof(:,:,c) = meanOverTrialsPTSdfof; % all rows (points, ann columns(frames) for this contrast (c)
        clear x_axis
        x_axis = 1:length(meanOverTrialsPTSdfof);
        errorbar(x_axis,meanOverTrialsPTSdfof,err,'linewidth',1)
        
        ylim([-0.025 0.04]) 
        xlim([1 length(x_axis)])
        st = title(sprintf('%s', reigonsTitle{r}));

        
        %if subplotNum == 1
            ylabel('df/f')
            xlabel ('frames')
%         else
%             set(gca,'XTick',[], 'YTick', [])
%         end
        
        hold on
       
    end
    
   % if subplotNum == 1
        legend(durationsTitle)
   % end
    
    subplotNum = subplotNum + 1;
    r = r+1;
    
end 
    
    % collect all the matricies for all the i-th points
%     sqForGroupMeanOverTrialsPTSdfof = squeeze(forGroupMeanOverTrialsPTSdfof);
%     allPtsMeanOverTrialsPTSdfof(:,:,i) = sqForGroupMeanOverTrialsPTSdfof;
    
% now for each contrast figure, I want the 6th subplot to be the
% average trace for each contrast, across visual areas
    
hold on

clear d
for d = 1:length(uniqueDurations)
    
    subplot(2,3,6) 
        
    clear dthTrials
    %cthConOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetsMeetBothCriteria);
    dthTrials = durOrderedByTrial == uniqueDurations(d); 
       
    clear allIthDthMeanSqPTSdfofDthTrials % this gets cleared out in between contrasts, not points
        
    clear i
    for i = 1:length(xPickedPts) 
            
        % collect mean df/f vs frames for each point at the c-th contrast
        allPtsAtDthDurMeanSqPTSdfofDthTrials(i,:) = mean(squeeze(PTSdfof(i,:,dthTrials)),2)';
    
    end
    
    clear meanOverPts4DthConMeanSqPTSdfofDthTrials
    
    % take the mean across points of the matrix we just collected
    % this gives us one trace for all points at the cth contrast
    meanOverPts4DthDurMeanSqPTSdfofDthTrials = mean(allPtsAtDthDurMeanSqPTSdfofDthTrials,1);
   
    plot(meanOverPts4DthDurMeanSqPTSdfofDthTrials,'linewidth',2) 
       
    hold on

end
    
ylim([-0.025 0.04])
xlim([1 length(x_axis)])
sst = title('mean per duration')

%%
% DRF w/ PEAK (MEAN @ LATENCY) --> determined by looking at latency.. just taking mean at these frames, not using max function
% CRF over frames 14-16

% time point = 1.5 seconds, based on latency figs
% 1 frames = 0.1 sec, so 1.5 secs = frame 15

frameRange = 7:1:9;
contrastValues = [0 0.03 0.063 0.125 0.25 0.5 1];

figure
clear i
suptitle('Contrast Response Functions for Each Visual area')
for i = 1:length(xPickedPts)
    
    clear sq5FramesOverTrialsPTSdfof
    clear meanOverFramesSq5FramesOverTrialsPTSdfof
    clear meanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof
    clear contMeanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof
    clear durStdErr
    
    clear durMeanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof
    
    clear d
    for d = 1:length(uniqueDurations)
        
        clear dthTrials
        %cthConOrderedByTrialMeetCriteria = conOrderedByTrial(idxOnsetsMeetBothCriteria);
        dthTrials = durOrderedByTrial == uniqueDurations(d);  
        
        % CRF POINTS for each contrast, i-th point
        % to use a range of frames (reduce noise):
        
        % take the i-th points over the frame range, for the c-th trials
        % returns 3 (frames) by 76 (trials)
        sq5FramesOverTrialsPTSdfof = squeeze(PTSdfof(i,frameRange,dthTrials));
        sq5FramesOverTrialsPTSdfof = sq5FramesOverTrialsPTSdfof;
        
        % take the mean over frames
        %returns 1 x 76 (trials)
        meanOverFramesSq5FramesOverTrialsPTSdfof = mean(sq5FramesOverTrialsPTSdfof,1);
       
        % now I need the mean over trials to get one df/f value representing the
        % average fluorescence over 3 frames and over the c-th trials for the i-th point
        meanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof = mean(meanOverFramesSq5FramesOverTrialsPTSdfof,2);
        
        % now I want to collect each c-th CRF value for this point
        % creates 1 x 7 (contrasts)
        durMeanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof(d) = meanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof;
        
        % STDERR
        % now I want to calulate the StdErr for each CRF point calulated above
        % (one err value for each contrast)
        % that means I want the error over trials, not over frames
        % so that info is in the 'meanOverFramesSq5FramesOverTrialsPTSdfof' variable (1 x76 (trials))
        stdErr = std(meanOverFramesSq5FramesOverTrialsPTSdfof)/sqrt(sum(dthTrials)); % sum trials, not length
        durStdErr(1,d) = stdErr;
        
    end 
 
    % PLOTTING
    % one figure, one subplot for each point, each subplot has CRF for that poin
    % size subplot based on 7 contrasts
    subplot(2,4,i)
    % 7 contrasts for x axis
    x_axis = [1 2 3 4 5];
    errorbar(x_axis,durMeanOverTrialsMeanOverFramesSq5FramesOverTrialsPTSdfof,durStdErr,'-s','MarkerSize',3,...
    'MarkerEdgeColor','blue','MarkerFaceColor','blue') 
    ylim([-0.02 0.05]) 
    xlim([0, 6])
    
    clear xt
    xt={'16'; '33' ; '66' ; '133' ; '266' ;} ; 
    set(gca,'xtick',1:5); 
    set(gca,'xticklabel',xt);
    
    title(reigonsTitle{i})
     ylabel('df/f')
     xlabel('time (ms)')
    
end 

%savefig('G6H277RT_020421_CRF_imThreshPass')
%legend(durationsTitle)
    