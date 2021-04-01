
% navigate to balldata folder, load subj file, then navigate back to
% widefield2 folder for saving figures
load('G6H277RT_subj.mat')

subjName = subjData{1,1}.name % subjNameStr is a char, not string
titleText = ' : df/f for each TRIAL OVER TIME' % making char variables for sprintf/title later

reigons = {'V1','HVA1','HVA2','HVA3','HVA4'}
r = 1 % since I know the number of reigions is equal to the number of xpts, i'll just index regions
% w/in the xpts loop and add 1 to the index each time. the 'r' index should be equal to i at the end
% ALL TRIALS - ONE FIG, SUBPLOTS = POINTS, ALL TRACES/trials, df/f vs frames

% after the first subplot, I don't want to include the axes labels.
% I'm going to try to use a counter and an if/then statement to include the
% labels the first run thru the loop only

subplotNum = 1

figure % make one figure for all subplots
t = suptitle(sprintf('%s', subjName, titleText))
set(t, 'FontSize', 12)
% t = '277RT_020421: df/f for each TRIAL OVER TIME';
% st = sprintf(reigon{r});
% a = axes
% suptitle(sprintf('t'))

for i = 1:length(xpts) % for each point
    subplot(2,3,i)% 
    plot(frameNum,squeeze(PTSdfof(i,:,:))) % plot dfof the first point vs frames for all trials trial

    if subplotNum == 1
        ylabel('df/f')
        xlabel ('frames')
    else
        set(gca,'XTick',[], 'YTick', [])
    end
    
    hold on % hold on needs to be here, not at end of loop b/c we want the thick mean line to plot over the same subplot
    % plot mean on top of all traces
    plot(mean(squeeze(PTSdfof(i,:,:)),2),'linewidth',4) 
    ylim([-0.225 0.225]) 
    xlim([0 51])
    
    st = title(sprintf('%s', reigons{r}))
    set(st, 'FontSize', 10)
    
    r = r+1
    subplotNum = subplotNum+1
    
end
    
hold on % now plot the mean for each point on the 6th subplot
for j = 1:length(xpts)
    subplot(2,3,6)
    plot(mean(squeeze(PTSdfof(j,:,:)),2),'linewidth',1) % here's plotting the mean over trials (dimension 2 in PTSdfof)
    ylim([-0.05 0.05]) 
    xlim([0 51])
    set(gca,'XTick',[])
    st = title('MEAN df/f per VA')
    set(st, 'FontSize', 10)
    hold on
end
legend(reigons)