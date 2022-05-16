%% group pupil diameter distributions (non-normalized) & 99 pt-something-th & percentile lines

p_hi = [99.5];
%p_lo = [1];

nbins = 50;

fig1 = figure
%formatSpec = '%s \n'; % \n
titleText = sprintf('%s \n','group pupil diameter distributions (non-normalized)');
suptitle(titleText)
for n = 1:nGroup;
    
    clear nthMeanPupilDiameterAllTrials
    nthMeanPupilDiameterAllTrials = groupMeanPupilDiameterAllTrials{1,n};
    
    if nGroup < 4
        subplot(1,nGroup,n)  
    else
        numCol = 5;
        subplot(ceil(nGroup/numCol),5,n)
    end 

    h = histogram(nthMeanPupilDiameterAllTrials,nbins,'normalization','probability')
    
    hold on

    yMax = max(h.Values);
    y = [0:(yMax/10):yMax];

    Percentile_hi = prctile(nthMeanPupilDiameterAllTrials,p_hi);
    %Percentile_lo = prctile(nthMeanPupilDiameterAllTrials,p_lo);

    clear x1
    x1(1,1:length(y)) = Percentile_hi;
    %clear x2
    %x2(1,1:length(y)) = Percentile_lo;

    hold on
    plot(x1,y,'r')
    %hold on 
    %plot(x2,y,'r')

    xlim([min(meanPupDiameterAllTrials_eachSesss) max(meanPupDiameterAllTrials_eachSesss)])
    xlabel('normalized pupil diameter (a.u.)')
    ylabel('fraction of trials')
    
    hold on

end % end n loop

%% normalized group distribution of pupil diameter

numCol = 5; 
p_hi = [99.95];

nbins = 50;

clear lessThan1_meanPupVal_normalized_allTrial_allSess
clear normalized_meanPupDiameterAllTrials_allSessAsOneVector
normalized_meanPupDiameterAllTrials_allSessAsOneVector = [ ];

for n = 1:nGroup;
    
    % get hi percentile value for nth session
    Percentile_hi = prctile(groupMeanPupilDiameterAllTrials{1,n},p_hi);
    
    clear meanPupVal_normalized_allTrial

    % normalize the pupil diamter vector for nth session (already set so min value = 0)
    % 'groupMeanPupilDiameterAllTrials{1,n}' is made in group analysis script

    % normalize each trial/mean pupil diameter value & collect each sess for plotting later
    % collect each session for scatter plot later
    meanPupVal_normalized_allTrial_allSess{1,n} = groupMeanPupilDiameterAllTrials{1,n}/Percentile_hi; % minimum is zero so don't need to subtract in num & denom

    % then filter out any normalized values greater than 1 (outliers)
    lessThan1_percentile_idx = find(meanPupVal_normalized_allTrial_allSess{1,n}<1);
    lessThan1_meanPupVal_normalized_allTrial_allSess{1,n} = meanPupVal_normalized_allTrial_allSess{1,n}(lessThan1_percentile_idx);

    % now have normalized pupil vector session ('lessThan1_meanPupVal_normalized_allTrial_allSess')
    
    % need this for setting x limit later:
    normalized_meanPupDiameterAllTrials_allSessAsOneVector = [normalized_meanPupDiameterAllTrials_allSessAsOneVector,lessThan1_meanPupVal_normalized_allTrial_allSess{1,n}];
    
    % get histo output vals for each session 1st, so can set yMax on each subplot to the max
    % y value across all sessions
    h = histogram(lessThan1_meanPupVal_normalized_allTrial_allSess{1,n},nbins,'normalization','probability')
    
    % save max frequency value for each session, to use as max for
    % subplots later
    maxHvals_allSess(1,n) = max(h.Values);

end % end n loop


nbins = 50;

fig2 = figure
titleText = sprintf('%s \n','normalized group pupil diameter distributions');
suptitle(titleText)

for n = 1:nGroup
    
    % subplot dimensions based on number of sessions (plotting each session on one fig)
    if nGroup < 4
        subplot(1,nGroup+1,n)  
    else
        numCol = 5;
        subplot(ceil(nGroup/numCol),5,n)
    end 

    % make histogram of normalized pupil diameter values
    h = histogram(lessThan1_meanPupVal_normalized_allTrial_allSess{1,n},nbins,'normalization','probability')
    hold on
    
    y_tot_Max = max(maxHvals_allSess)
    ylim([0 y_tot_Max+0.005])
    ylabel('fraction of trials')
    formatSpec = 'session %1.0d'
    titleText = sprintf(formatSpec,n)
    title(titleText)

    % 'meanPupDiameterAllTrials_eachSesss' made in group analysis script,
  
    xlim([min(normalized_meanPupDiameterAllTrials_allSessAsOneVector)-0.01 max(normalized_meanPupDiameterAllTrials_allSessAsOneVector)+0.01])
    xlabel('normalized pupil diameter (a.u.)')
    
    hold on

end % end n loop

subplot(ceil(nGroup/numCol),5,nGroup+1)

histogram(normalized_meanPupDiameterAllTrials_allSessAsOneVector,nbins,'normalization','probability')

y_tot_Max = max(maxHvals_allSess)
ylim([0 y_tot_Max+0.005])
ylabel('fraction of trials (*all* sessions)')
xlim([min(normalized_meanPupDiameterAllTrials_allSessAsOneVector)-0.01 max(normalized_meanPupDiameterAllTrials_allSessAsOneVector)+0.01])
xlabel('normalized pupil diameter (a.u.)')
title('all sessions')

%% pup vs run (norm or not) scatter 

figure

for n = 1:nGroup
    
    % subplot dimensions based on number of sessions (plotting each session on one fig)
    if nGroup < 4
        subplot(1,nGroup+1,n)  
    else
        numCol = 5;
        subplot(ceil(nGroup/numCol),5,n)
    end 

    %scatter(groupMeanSpeedAllTrials{1,n},meanPupVal_normalized_allTrial_allSess{1,n})
    scatter(meanRunVal_normalized_allTrial_allSess{1,n},meanPupVal_normalized_allTrial_allSess{1,n})
    hold on
    
    clear x_thresh
    x_thresh = [0:0.01:max(meanPupVal_normalized_allTrial_allSess{1,n})];
    clear y_thresh
    y_thresh(1,1:length(x_thresh)) = 0.5;
    
    plot(x_thresh,y_thresh,'m','lineWidth',1)
    
    xlabel('normalized locomotion speed')
    ylabel('normalized pupil diameter')
    formatSpec = 'session %1.0d'
    titleText = sprintf(formatSpec,n)
    title(titleText)
    
    ylim([0 1.2])
    xlim([0 1.2])
    
    hold on

end

for n = 1:nGroup
    
    % subplot dimensions based on number of sessions (plotting each session on one fig)
    if nGroup < 4
        subplot(1,nGroup+1,nGroup+1)  
    else
        numCol = 5;
        subplot(ceil(nGroup/numCol),5,nGroup+1)
    end 
    
    %scatter(groupMeanSpeedAllTrials{1,n},meanPupVal_normalized_allTrial_allSess{1,n})
    scatter(meanRunVal_normalized_allTrial_allSess{1,n},meanPupVal_normalized_allTrial_allSess{1,n})
    
    hold on
    
    plot(x_thresh,y_thresh,'g','lineWidth',1)
    
    xlabel('normalized locomotion speed')
    ylabel('normalized pupil diameter')
    title('all sessions')
    
    ylim([0 1.2])
    xlim([0 1.2])
    
    hold on 
    
    
end 


%% normalized group distribution of LOCO diameter

p_hi = [99.95];

nbins = 50;

clear lessThan1_meanRunVal_normalized_allTrial_allSess
clear normalized_meanRunSpeedAllTrials_allSessAsOneVector
normalized_meanRunSpeedAllTrials_allSessAsOneVector = [ ];

for n = 1:nGroup;
    
    % get hi percentile value for nth session
    Percentile_hi = prctile(groupMeanSpeedAllTrials{1,n},p_hi);
    
    clear meanRunVal_normalized_allTrial

    % normalize the pupil diamter vector for nth session (already set so min value = 0)
    % 'groupMeanPupilDiameterAllTrials{1,n}' is made in group analysis script

    % normalize each trial/mean pupil diameter value & collect each sess for plotting later
    % collect each session for scatter plot later
    meanRunVal_normalized_allTrial_allSess{1,n} = groupMeanSpeedAllTrials{1,n}/Percentile_hi; % minimum is zero so don't need to subtract in num & denom

    % then filter out any normalized values greater than 1 (outliers)
    lessThan1_percentile_idx = find(meanRunVal_normalized_allTrial_allSess{1,n}<1);
    lessThan1_meanRunVal_normalized_allTrial_allSess{1,n} = meanRunVal_normalized_allTrial_allSess{1,n}(lessThan1_percentile_idx);

    % now have normalized pupil vector session ('lessThan1_meanPupVal_normalized_allTrial_allSess')
    
    % need this for setting x limit later:
    normalized_meanRunSpeedAllTrials_allSessAsOneVector = [normalized_meanRunSpeedAllTrials_allSessAsOneVector,lessThan1_meanRunVal_normalized_allTrial_allSess{1,n}];
    
    % get histo output vals for each session 1st, so can set yMax on each subplot to the max
    % y value across all sessions
    h = histogram(lessThan1_meanRunVal_normalized_allTrial_allSess{1,n},nbins,'normalization','probability')
    
    % save max frequency value for each session, to use as max for
    % subplots later
    maxHvals_allSess_run(1,n) = max(h.Values);

end % end n loop


nbins = 50;

fig2 = figure
titleText = sprintf('%s \n','normalized group locomotion distributions');
suptitle(titleText)

for n = 1:nGroup
    
    % subplot dimensions based on number of sessions (plotting each session on one fig)
    if nGroup < 4
        subplot(1,nGroup+1,n)  
    else
        numCol = 5;
        subplot(ceil(nGroup/numCol),5,n)
    end 

    % make histogram of normalized pupil diameter values
    h = histogram(lessThan1_meanRunVal_normalized_allTrial_allSess{1,n},nbins,'normalization','probability')
    hold on
    
    y_tot_Max = max(maxHvals_allSess_run)
    ylim([0 y_tot_Max+0.005])
    ylabel('fraction of trials')
    formatSpec = 'session %1.0d'
    titleText = sprintf(formatSpec,n)
    title(titleText)

    % 'meanPupDiameterAllTrials_eachSesss' made in group analysis script,
  
    xlim([min(normalized_meanRunSpeedAllTrials_allSessAsOneVector)-0.01 max(normalized_meanRunSpeedAllTrials_allSessAsOneVector)+0.01])
    xlabel('normalized run speed (a.u.))')
    
    hold on

end % end n loop

subplot(ceil(nGroup/numCol),5,nGroup+1)

histogram(normalized_meanRunSpeedAllTrials_allSessAsOneVector,nbins,'normalization','probability')

y_tot_Max = max(maxHvals_allSess)
ylim([0 y_tot_Max+0.005])
ylabel('fraction of trials (*all* sessions)')
xlim([min(normalized_meanRunSpeedAllTrials_allSessAsOneVector)-0.01 max(normalized_meanRunSpeedAllTrials_allSessAsOneVector)+0.01])
xlabel('normalized run speed (a.u.)')
title('all sessions')

%% for each sess, run speed, pup diam, & scatter on same plot 

for n = 1:nGroup

    figure

    formatSpec = 'session %1.0d \n'
    titleText = sprintf(formatSpec,n)
    suptitle(titleText)

    subplot(3,1,1)

    nbins = 50;
    histogram(meanPupVal_normalized_allTrial_allSess{1,n},nbins,'normalization','probability')

    title('distribution of pupil diameters')
    xlabel('locomotion speed')
    ylabel('normalized pupil diameter')
    xlim([min(normalized_meanPupDiameterAllTrials_allSessAsOneVector)-0.01 max(normalized_meanPupDiameterAllTrials_allSessAsOneVector)+0.01])
    xlabel('normalized locomotion speed (a.u.)')
    y_tot_Max = max(maxHvals_allSess)
    ylim([0 y_tot_Max+0.005])

    subplot(3,1,2)

    %edges = [0 0:50:max(meanSpeedAllTrials_eachSess) max(meanSpeedAllTrials_eachSess)];
    nbins = 50;
    histogram(meanRunVal_normalized_allTrial_allSess{1,n},nbins,'normalization','probability')

    title('distribution of running speeds')
    ylabel('fraction of total trials')
    xlabel('running speed')
    xlim([min(normalized_meanPupDiameterAllTrials_allSessAsOneVector)-0.01 max(normalized_meanPupDiameterAllTrials_allSessAsOneVector)+0.01])
    xlabel('normalized pupil diameter (a.u.)')
    y_tot_Max = max(maxHvals_allSess_run)
    ylim([0 y_tot_Max+0.005])

    subplot(3,1,3)

    scatter(meanRunVal_normalized_allTrial_allSess{1,n},meanPupVal_normalized_allTrial_allSess{1,n})
    xlabel('normalized locomotion speed')
    ylabel('normalized run speed')

end 

