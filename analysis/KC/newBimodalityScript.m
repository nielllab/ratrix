
% get group cell arrays made first in a  seperate loop

% at this point, vars 4 indivisual & group analysis have already been created

% have matlab ask me how many mice I wann3a average over for the present group
clear nGroup
nGroup = input('how many sessions in this group?')

% put that number into a for loop, have me get the var mat files that many of times

clear nthVarsFilePaths
clear n
for n = 1:nGroup
    
    [f p] = uigetfile('*.mat',sprintf('session # %0.00f vars4IndAndGroupAnalyses',n));
    
    % make cell array w/ sessions for columns
    % & file names/paths for values down the rows
    
    nthVarsFilePaths{1,n} = f;
    nthVarsFilePaths{2,n} = p;
    
    % load the nth var mat file
    load(fullfile(p,f));
    
    % put each var (could be a struct, double, etc) into a column of a cell array: 
    % all group cell arays will be % 1 x # sessions
    groupStimDetails{1,n} = stimDetails;
    groupSubjData{1,n} = subjData; 
    groupSubjName{1,n} = subjName;
    groupDate{1,n} = date;
    groupTrialCond{1,n} = trialCond;
    groupNumPreStimFrames{1,n} = numPreStimFrames;
    groupNumPostStimFrames{1,n} = numPostStimFrames;
    groupIdxOnsetsMeetsCriteria{1,n} = idxOnsetsMeetsCriteria;
    groupPeakFrameIdx{1,n} = peakFrameIdx;
    groupStimOnsetFrame{1,n} = stimOnsetFrame;
    groupBaselineIdx{1,n} = baselineIdx;
    groupBaselinedActIm{1,n} = baselinedActIm;
    groupRoundXpts{1,n} = RoundXpts;
    groupRoundYpts{1,n} = RoundYpts;
    groupPTSdfof{1,n} = PTSdfof;
    groupMeanSpeedAllTrials{1,n} = meanSpeedAllTrials;
    groupIdxRunTrials{1,n} = idxRunTrials;
    groupIdxStatTrials{1,n} = idxStatTrials;
    
end % now I have the group analysis vars for each session

%%

% add path to functions/scripts
addpath C:\Users\nlab\Desktop\GitHub\ratrix\analysis\KC\KC_thresh_functions

%% STATIONARY HISTO

% one point, one dur, all cons, STATIONARY 

numBins = 20;

yMax = 0.2;
yLimit = [0 yMax];

xMax = 0.25;
xLimit = [-0.1 xMax];
xTickRange = [-0.1:0.05:xMax];
xTickLabelRange = [-0.1:0.1:xMax];

durat = 1;
%durat = 1:length(uniqueDurations);

%cont = 1:length(uniqueContrasts)
%cont

visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

figure
formatSpec = 'vis area: %1.f (STAT)';
titleText = sprintf(formatSpec,visArea);
suptitle(titleText)


% NEED this for UNIQUE CONS for C loop:

% EXTRACT VARS from GROUP CELL ARRAYS
clear n
n = 1
nthStimDetailsStruct = groupStimDetails{n};
nthTrialCond = groupTrialCond{1,n};
nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n};

% CONTRAST calc's
clear con
clear conOrderedByTrial  
clear conOrderedByTrialMeetCriteria 
clear uniqueContrasts
clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
end
conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueContrasts = unique(con); % for looping over contrast values later

%  DURATION Calc's
clear dur
clear durOrderedByTrial  
clear durOrderedByTrialMeetCriteria 
clear uniqueDurations
% extract duration field from stimDetails
clear durs
for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
end
durOrderedByTrial = dur(nthTrialCond); 
durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueDurations = unique(dur);

% CON & DUR TOGETHER
clear conAndDur 
clear conAndDurOrderedByTrial 
clear conAndDurOrderedByTrialMeetCriteria
conAndDur = [con; dur];
conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);


clear d  % for each duration
%for d = 1:length(uniqueDurations) % only 1 duration
for d = durat % duration variable 
            
    % for one POINT
    clear i 
    %for i = 2 % v1 
    for i = visArea

        clear c % for each contrast
        for c = 1:length(uniqueContrasts) 
            
            % this is for storing different length-ed cth trial vectors for all sessions (concatenated)
            clear allSessCthPeakDfEachTrial
            allSessCthPeakDfEachTrial = []; 
    
            clear n 
            for n = 1:nGroup % for each session/mouse
                
                % EXTRACT VARS from GROUP CELL ARRAYS
                nthStimDetailsStruct = groupStimDetails{n};
                nthTrialCond = groupTrialCond{1,n};
                nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n}; 
               
                % CON & DUR VALUES AT EACH TRIAL - these values get calculated anew for each session 
        
                % CONTRAST calc's
                clear con
                clear conOrderedByTrial  
                clear conOrderedByTrialMeetCriteria 
                clear uniqueContrasts
                clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
                for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
                    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
                end
                conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
                conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueContrasts = unique(con); % for looping over contrast values later
                
                %  DURATION Calc's
                clear dur
                clear durOrderedByTrial  
                clear durOrderedByTrialMeetCriteria 
                clear uniqueDurations
                % extract duration field from stimDetails
                clear durs
                for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
                    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
                end
                durOrderedByTrial = dur(nthTrialCond); 
                durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueDurations = unique(dur);
        
                % CON & DUR TOGETHER
                clear conAndDur 
                clear conAndDurOrderedByTrial 
                clear conAndDurOrderedByTrialMeetCriteria
                conAndDur = [con; dur];
                conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
                conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                
                % in preparation for making pixel wise figures of fluroescene at different stim conditions,
                % make figure legends
                [reigons,cons4Legend,cons4axes,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations);
                % durs4Legend = {'16 ms','33 ms', '66 ms', '133 ms', '266 ms'}
                durs4Legend = {'100 ms'};
        
                % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
                nthPTSdfof = groupPTSdfof{1,n};
                nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
                nthBaselineIdx = groupBaselineIdx{1,n};
                
                % EXTRACT RUN vs STAT TRIAL INDICIES
                nthIdxRunTrials = groupIdxRunTrials{1,n};
                nthIdxStatTrials = groupIdxStatTrials{1,n}; 
        
                % get CTH DTH STAT trials
                
                clear dthCthTrials
                dthCthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
                
                clear idxCthDthTrial
                idxCthDthTrial = find(dthCthTrials == 1);
                 
                clear nthIdxCthDthSTATtrials
                idxCthDthSTATtrials = intersect(idxCthDthTrial,nthIdxStatTrials);
                    
                clear numIdxCthDthSTATtrials
                numIdxCthDthSTATtrials = length(idxCthDthSTATtrials)
                
                % GET DFof for PEAK FRAMES
                
                % take df/f data for ith pt, peak frames, cth dth stat trials
                allPeakFramesCthDthTrialsIthPt = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxCthDthSTATtrials)); 
                meanPeakFramesCthDthTrialsIthPt = mean(allPeakFramesCthDthTrialsIthPt,1); % gives 1 x #trials
                % ^ CANT do: store output vectors for each contrast
                % b/c every vectoris a different length (num trials), so can't 'collect'
                % Better to just plot directly on the subplot here
                    
                % get BASELINE @ cth dth state trials
                
                clear allBaselineFrames
                allBaselineFrames = squeeze(nthPTSdfof(i,nthBaselineIdx,idxCthDthSTATtrials));
                % get one mean baseline value over all frames & trials
                meanBaselineFrames = mean(allBaselineFrames,1); % mean over frames
                meanBaselineFrames = mean(meanBaselineFrames,2); % mean over trials
                
                % SUBTract BASeline from vector of mean df/f across peak frames, cthdth stat trials
        
                meanPeakFramesCthDthTrialsIthPtMinusBase = meanPeakFramesCthDthTrialsIthPt-meanBaselineFrames;
                % ^this is a 1 x # trials vector
                    
                % b/c each meanPeakFramesCthDthTrialsIthPtMinusBase var is a different length, 
                % we can't store in a session matrix. 
                % but, since this is a group analysis, and since I'm not calulating stderr, 
                % I can concatenate each session's trials at a particular contrast and plot one
                % subplot/contrast at a time
                
                % SAVE EACH CTH mean Df for peak frames of cth dth stat trials
                
                % this is all trials at this stim cond over 3 sessions
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                % so stderr should take the mean over *sessions*
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(3);
                %stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
                stDevEachSess(n,:) = std(meanPeakFramesCthDthTrialsIthPtMinusBase)/sqrt(3);
                
            end % end n loop - 
            %have vector for all trials across all sessions at 1 contrast now
            % move to next contrast
                
            %allSessMeanPeakFramesCthDthTrialsIthPtMinusBase = 
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            h1 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            %histogram(allSessCthPeakDfEachTrial,numBins)
            %hist(allSessCthPeakDfEachTrial,numBins)
            hold on
%             
            clear x_axis
            x_axis = meanAllSessCthPeakDfAcrossTrials;
            clear y_axis
            y_axis = 0
            
            h2 = scatter(x_axis,y_axis,'*','r')
            
            formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
            title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
            
            %title(uniqueContrasts(c))
            
            xlabel('peak df/f')
            ylabel('fraction of trials')
            ylim(yLimit)
            xlim(xLimit)
            
            %set(gca,'XTick',-0.1:0.05:0.2)
            %set(gca,'XTickLabel',-0.1:0.1:0.2)
            
            hold on  
            
            stDevEachSessPerCon(:,:,c) = stDevEachSess;
                    
        end % end c loop - move to next contrast/subplot
                
    end % end i loop (only 1 point
    
end % end d loop (only 1 dur)
                    
numTrialsOneCon = size(allSessCthPeakDfEachTrial)







%% RUNNING HISTO

% one point, one dur, all cons, RUNNING

numBins = 20;

yMax = 0.25;
yLimit = [0 yMax];

xMax = 0.3;
xLimit = [-0.1 xMax];
xTickRange = [-0.1:0.05:xMax];
xTickLabelRange = [-0.1:0.1:xMax];

durat = 1;

visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

figure
formatSpec = 'vis area: %1.f (RUN)';
titleText = sprintf(formatSpec,visArea);
suptitle(titleText)

% NEED this for UNIQUE CONS for C loop:

% EXTRACT VARS from GROUP CELL ARRAYS
clear n
n = 1
nthStimDetailsStruct = groupStimDetails{n};
nthTrialCond = groupTrialCond{1,n};
nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n};

% CONTRAST calc's
clear con
clear conOrderedByTrial  
clear conOrderedByTrialMeetCriteria 
clear uniqueContrasts
clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
end
conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueContrasts = unique(con); % for looping over contrast values later

%  DURATION Calc's
clear dur
clear durOrderedByTrial  
clear durOrderedByTrialMeetCriteria 
clear uniqueDurations
% extract duration field from stimDetails
clear durs
for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
end
durOrderedByTrial = dur(nthTrialCond); 
durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueDurations = unique(dur);

% CON & DUR TOGETHER
clear conAndDur 
clear conAndDurOrderedByTrial 
clear conAndDurOrderedByTrialMeetCriteria
conAndDur = [con; dur];
conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);


clear d  % for each duration
for d = durat
    % for d = 1:length(uniqueDurations) % only 1 duration
            
    % for one POINT
    clear i 
    %for i = 2 % v1 
    for i = visArea

        clear c % for each contrast
        for c = 1:length(uniqueContrasts) 
            
            % this is for storing different length-ed cth trial vectors for all sessions (concatenated)
            clear allSessCthPeakDfEachTrial
            allSessCthPeakDfEachTrial = []; 
    
            clear n 
            for n = 1:nGroup % for each session/mouse
                
                % EXTRACT VARS from GROUP CELL ARRAYS
                nthStimDetailsStruct = groupStimDetails{n};
                nthTrialCond = groupTrialCond{1,n};
                nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n}; 
               
                % CON & DUR VALUES AT EACH TRIAL - these values get calculated anew for each session 
        
                % CONTRAST calc's
                clear con
                clear conOrderedByTrial  
                clear conOrderedByTrialMeetCriteria 
                clear uniqueContrasts
                clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
                for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
                    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
                end
                conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
                conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueContrasts = unique(con); % for looping over contrast values later
                
                %  DURATION Calc's
                clear dur
                clear durOrderedByTrial  
                clear durOrderedByTrialMeetCriteria 
                clear uniqueDurations
                % extract duration field from stimDetails
                clear durs
                for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
                    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
                end
                durOrderedByTrial = dur(nthTrialCond); 
                durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueDurations = unique(dur);
        
                % CON & DUR TOGETHER
                clear conAndDur 
                clear conAndDurOrderedByTrial 
                clear conAndDurOrderedByTrialMeetCriteria
                conAndDur = [con; dur];
                conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
                conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                
                % in preparation for making pixel wise figures of fluroescene at different stim conditions,
                % make figure legends
                [reigons,cons4Legend,cons4axes,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations);
                % durs4Legend = {'16 ms','33 ms', '66 ms', '133 ms', '266 ms'}
                durs4Legend = {'100 ms'};
        
                % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
                nthPTSdfof = groupPTSdfof{1,n};
                nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
                nthBaselineIdx = groupBaselineIdx{1,n};
                
                % EXTRACT RUN vs STAT TRIAL INDICIES
                nthIdxRunTrials = groupIdxRunTrials{1,n};
                nthIdxStatTrials = groupIdxStatTrials{1,n}; 
        
                % get CTH DTH STAT trials
                
                clear dthCthTrials
                dthCthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
                
                clear idxCthDthTrial
                idxCthDthTrial = find(dthCthTrials == 1);
                 
                clear nthIdxCthDthRUNtrials
                idxCthDthRUNtrials = intersect(idxCthDthTrial,nthIdxRunTrials);
                    
                clear numIdxCthDthRUNtrials
                numIdxCthDthRUNtrials = length(idxCthDthRUNtrials)
                
                % GET DFof for PEAK FRAMES
                
                % take df/f data for ith pt, peak frames, cth dth stat trials
                allPeakFramesCthDthTrialsIthPt = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxCthDthRUNtrials)); 
                meanPeakFramesCthDthTrialsIthPt = mean(allPeakFramesCthDthTrialsIthPt,1); % gives 1 x #trials
                % ^ CANT do: store output vectors for each contrast
                % b/c every vectoris a different length (num trials), so can't 'collect'
                % Better to just plot directly on the subplot here
                    
                % get BASELINE @ cth dth state trials
                
                clear allBaselineFrames
                allBaselineFrames = squeeze(nthPTSdfof(i,nthBaselineIdx,idxCthDthRUNtrials));
                % get one mean baseline value over all frames & trials
                meanBaselineFrames = mean(allBaselineFrames,1); % mean over frames
                meanBaselineFrames = mean(meanBaselineFrames,2); % mean over trials
                
                % SUBTract BASeline from vector of mean df/f across peak frames, cthdth stat trials
        
                meanPeakFramesCthDthTrialsIthPtMinusBase = meanPeakFramesCthDthTrialsIthPt-meanBaselineFrames;
                % ^this is a 1 x # trials vector
                    
                % b/c each meanPeakFramesCthDthTrialsIthPtMinusBase var is a different length, 
                % we can't store in a session matrix. 
                % but, since this is a group analysis, and since I'm not calulating stderr, 
                % I can concatenate each session's trials at a particular contrast and plot one
                % subplot/contrast at a time
                
                % take mean & save for stdev later 
                meanMeanEachSess(n,:) = mean(meanPeakFramesCthDthTrialsIthPtMinusBase);
                stDevEachSess(n,:) = std(meanPeakFramesCthDthTrialsIthPtMinusBase)/sqrt(length(meanPeakFramesCthDthTrialsIthPtMinusBase));
                % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(3);
                %stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
                stDevEachSess(n,:) = std(meanPeakFramesCthDthTrialsIthPtMinusBase)/sqrt(3);
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
            
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            h1 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            
            hold on
            
            clear x_axis
            x_axis = meanAllSessCthPeakDfAcrossTrials;
            clear y_axis
            y_axis = 0
            
            h2 = scatter(x_axis,y_axis,'*','r')
            
            formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
            title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
            
            xlabel('peak df/f')
            ylabel('fraction of trials')
            ylim(yLimit)
            xlim(xLimit)
            
            %set(gca,'XTick',-0.1:0.05:0.2)
           % set(gca,'XTickLabel',-0.1:0.1:0.2)
            
            hold on  
            
            % session x std value x contrast
        stDevEachSessPerCon(:,:,c) = stDevEachSess
                    
        end % end c loop - move to next contrast/subplot
        
        
                
    end % end i loop (only 1 point
    
end % end d loop (only 1 dur)
                    
numTrialsOneCon = size(allSessCthPeakDfEachTrial)




%% RUN VS STAT HISTO

% one point, one dur, all cons

numBins = 30;

yMax = 0.15;
yLimit = [0 yMax];

xMax = 0.2;
xMin = -0.15;
xLimit = [xMin  xMax];
xTickRange = [xMin:0.05:xMax];
xTickLabelRange = [xMin:0.1:xMax];

durat = 5;

visArea = 1; % V1
%visArea = 2; % LM
%visArea = 3; % RL
%visArea = 4; % AM 
%visArea = 5; % control

figure
suptitle(', 100 ms')
%formatSpec = 'area %1.f, duration %1.f'
%titleText = sprintf(formatSpec,visArea,durat)
%suptitle(titleText)
%formatSpec = 'vis area: %1.f (STAT vs RUN)';
%titleText = sprintf(formatSpec,visArea);
%titleText = '100ms, RUN vs STAT';
%suptitle(titleText)


% NEED this for UNIQUE CONS for C loop:

% EXTRACT VARS from GROUP CELL ARRAYS
clear n
n = 1
nthStimDetailsStruct = groupStimDetails{n};
nthTrialCond = groupTrialCond{1,n};
nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n};

% CONTRAST calc's
clear con
clear conOrderedByTrial  
clear conOrderedByTrialMeetCriteria 
clear uniqueContrasts
clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
end
conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueContrasts = unique(con); % for looping over contrast values later

%  DURATION Calc's
clear dur
clear durOrderedByTrial  
clear durOrderedByTrialMeetCriteria 
clear uniqueDurations
% extract duration field from stimDetails
clear durs
for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
end
durOrderedByTrial = dur(nthTrialCond); 
durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueDurations = unique(dur);

% CON & DUR TOGETHER
clear conAndDur 
clear conAndDurOrderedByTrial 
clear conAndDurOrderedByTrialMeetCriteria
conAndDur = [con; dur];
conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);


clear d  % for each duration
%for d = 1:length(uniqueDurations) % only 1 duration
for d = durat % duration variable 
            
    % for one POINT
    clear i 
    %for i = 2 % v1 
    for i = visArea
        
        clear numSTATTrialsEachConAllSess
        clear numRUNTrialsEachConAllSess

        clear c % for each contrast
        for c = 1:length(uniqueContrasts) 
            
            % this is for storing different length-ed cth trial vectors for all sessions (concatenated)
            clear allSessCthPeakDfEachTrial
            allSessCthPeakDfEachTrial = []; 
    
            clear n 
            for n = 1:nGroup % for each session/mouse
                
                % EXTRACT VARS from GROUP CELL ARRAYS
                nthStimDetailsStruct = groupStimDetails{n};
                nthTrialCond = groupTrialCond{1,n};
                nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n}; 
               
                % CON & DUR VALUES AT EACH TRIAL - these values get calculated anew for each session 
        
                % CONTRAST calc's
                clear con
                clear conOrderedByTrial  
                clear conOrderedByTrialMeetCriteria 
                clear uniqueContrasts
                clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
                for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
                    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
                end
                conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
                conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueContrasts = unique(con); % for looping over contrast values later
                
                %  DURATION Calc's
                clear dur
                clear durOrderedByTrial  
                clear durOrderedByTrialMeetCriteria 
                clear uniqueDurations
                % extract duration field from stimDetails
                clear durs
                for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
                    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
                end
                durOrderedByTrial = dur(nthTrialCond); 
                durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueDurations = unique(dur);
        
                % CON & DUR TOGETHER
                clear conAndDur 
                clear conAndDurOrderedByTrial 
                clear conAndDurOrderedByTrialMeetCriteria
                conAndDur = [con; dur];
                conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
                conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                
                % in preparation for making pixel wise figures of fluroescene at different stim conditions,
                % make figure legends
                [reigons,cons4Legend,cons4axes,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations);
                % durs4Legend = {'16 ms','33 ms', '66 ms', '133 ms', '266 ms'}
                %durs4Legend = {'100 ms'};
        
                % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
                nthPTSdfof = groupPTSdfof{1,n};
                nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
                nthBaselineIdx = groupBaselineIdx{1,n};
                
                % EXTRACT RUN vs STAT TRIAL INDICIES
                nthIdxRunTrials = groupIdxRunTrials{1,n};
                nthIdxStatTrials = groupIdxStatTrials{1,n}; 
        
                % get CTH DTH STAT trials
                
                clear dthCthTrials
                dthCthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
                
                clear idxCthDthTrial
                idxCthDthTrial = find(dthCthTrials == 1);
                 
                clear nthIdxCthDthSTATtrials
                idxCthDthSTATtrials = intersect(idxCthDthTrial,nthIdxStatTrials);
                    
                clear numIdxCthDthSTATtrials
                numIdxCthDthSTATtrials = length(idxCthDthSTATtrials)
                
                % GET DFof for PEAK FRAMES
                
                % take df/f data for ith pt, peak frames, cth dth stat trials
                allPeakFramesCthDthTrialsIthPt = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxCthDthSTATtrials)); 
                meanPeakFramesCthDthTrialsIthPt = mean(allPeakFramesCthDthTrialsIthPt,1); % gives 1 x #trials
                % ^ CANT do: store output vectors for each contrast
                % b/c every vectoris a different length (num trials), so can't 'collect'
                % Better to just plot directly on the subplot here
                    
                % get BASELINE @ cth dth state trials
                
                clear allBaselineFrames
                allBaselineFrames = squeeze(nthPTSdfof(i,nthBaselineIdx,idxCthDthSTATtrials));
                % get one mean baseline value over all frames & trials
                meanBaselineFrames = mean(allBaselineFrames,1); % mean over frames
                meanBaselineFrames = mean(meanBaselineFrames,2); % mean over trials
                
                % SUBTract BASeline from vector of mean df/f across peak frames, cthdth stat trials
        
                meanPeakFramesCthDthTrialsIthPtMinusBase = meanPeakFramesCthDthTrialsIthPt-meanBaselineFrames;
                % ^this is a 1 x # trials vector
                    
                % b/c each meanPeakFramesCthDthTrialsIthPtMinusBase var is a different length, 
                % we can't store in a session matrix. 
                % but, since this is a group analysis, and since I'm not calulating stderr, 
                % I can concatenate each session's trials at a particular contrast and plot one
                % subplot/contrast at a time
                
                % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
                numSTATTrialsEachConAllSess(:,c,n) = length(allSessCthPeakDfEachTrial); % should give a 1 x 7 x 3
                %numSTATTrialsEachConAllSess = squeeze(numSTATTrialsEachConAllSess);
                statTrialSumEachCon = sum(numSTATTrialsEachConAllSess,3);
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
                
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            h1 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            %histogram(allSessCthPeakDfEachTrial,numBins)
            %hist(allSessCthPeakDfEachTrial,numBins)
            hold on
%             
            clear x_axis
            x_axis = meanAllSessCthPeakDfAcrossTrials;
            clear y_axis
            y_axis = 0
            
            h2 = scatter(x_axis,y_axis,'*','r')
            
            %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
            %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
            
            xlabel('peak df/f')
            ylabel('fraction of trials')
            ylim(yLimit)
            xlim(xLimit)
            
            %set(gca,'XTick',xTickRange)
            %set(gca,'XTickLabel',xTickLabelRange)
            
            hold on  
            
            % go back into n loop, do it all again at this contrast but for
            
            % RUN trials
            
            % this is for storing different length-ed cth trial vectors for all sessions (concatenated)
            clear allSessCthPeakDfEachTrial
            allSessCthPeakDfEachTrial = []; 
    
            clear n 
            for n = 1:nGroup % for each session/mouse
                
                % EXTRACT VARS from GROUP CELL ARRAYS
                nthStimDetailsStruct = groupStimDetails{n};
                nthTrialCond = groupTrialCond{1,n};
                nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n}; 
               
                % CON & DUR VALUES AT EACH TRIAL - these values get calculated anew for each session 
        
                % CONTRAST calc's
                clear con
                clear conOrderedByTrial  
                clear conOrderedByTrialMeetCriteria 
                clear uniqueContrasts
                clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
                for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
                    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
                end
                conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
                conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueContrasts = unique(con); % for looping over contrast values later
                
                %  DURATION Calc's
                clear dur
                clear durOrderedByTrial  
                clear durOrderedByTrialMeetCriteria 
                clear uniqueDurations
                % extract duration field from stimDetails
                clear durs
                for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
                    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
                end
                durOrderedByTrial = dur(nthTrialCond); 
                durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueDurations = unique(dur);
        
                % CON & DUR TOGETHER
                clear conAndDur 
                clear conAndDurOrderedByTrial 
                clear conAndDurOrderedByTrialMeetCriteria
                conAndDur = [con; dur];
                conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
                conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                
                % in preparation for making pixel wise figures of fluroescene at different stim conditions,
                % make figure legends
                [reigons,cons4Legend,cons4axes,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations);
                % durs4Legend = {'16 ms','33 ms', '66 ms', '133 ms', '266 ms'}
                %durs4Legend = {'100 ms'};
        
                % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
                nthPTSdfof = groupPTSdfof{1,n};
                nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
                nthBaselineIdx = groupBaselineIdx{1,n};
                
                % EXTRACT RUN vs STAT TRIAL INDICIES
                nthIdxRunTrials = groupIdxRunTrials{1,n};
                nthIdxStatTrials = groupIdxStatTrials{1,n}; 
        
                % get CTH DTH STAT trials
                
                clear dthCthTrials
                dthCthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
                
                clear idxCthDthTrial
                idxCthDthTrial = find(dthCthTrials == 1);
                 
                clear nthIdxCthDthRUNtrials
                idxCthDthRUNtrials = intersect(idxCthDthTrial,nthIdxRunTrials);
                    
                clear numIdxCthDthRUNtrials
                numIdxCthDthRUNtrials = length(idxCthDthRUNtrials);
                
                % GET DFof for PEAK FRAMES
                
                % take df/f data for ith pt, peak frames, cth dth stat trials
                allPeakFramesCthDthTrialsIthPt = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxCthDthRUNtrials)); 
                meanPeakFramesCthDthTrialsIthPt = mean(allPeakFramesCthDthTrialsIthPt,1); % gives 1 x #trials
                % ^ CANT do: store output vectors for each contrast
                % b/c every vectoris a different length (num trials), so can't 'collect'
                % Better to just plot directly on the subplot here
                    
                % get BASELINE @ cth dth state trials
                
                clear allBaselineFrames
                allBaselineFrames = squeeze(nthPTSdfof(i,nthBaselineIdx,idxCthDthRUNtrials));
                % get one mean baseline value over all frames & trials
                meanBaselineFrames = mean(allBaselineFrames,1); % mean over frames
                meanBaselineFrames = mean(meanBaselineFrames,2); % mean over trials
                
                % SUBTract BASeline from vector of mean df/f across peak frames, cthdth stat trials
        
                meanPeakFramesCthDthTrialsIthPtMinusBase = meanPeakFramesCthDthTrialsIthPt-meanBaselineFrames;
                % ^this is a 1 x # trials vector
                    
                % b/c each meanPeakFramesCthDthTrialsIthPtMinusBase var is a different length, 
                % we can't store in a session matrix. 
                % but, since this is a group analysis, and since I'm not calulating stderr, 
                % I can concatenate each session's trials at a particular contrast and plot one
                % subplot/contrast at a time
                
                % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
                % for each session, at each contrast condition, save the number of trials
                numRUNTrialsEachConAllSess(:,c,n) = length(allSessCthPeakDfEachTrial); % should give a 1 x 7 x 3
                %runTrialSumEachCon = sum(numRUNTrialsEachConAllSess,3)
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
                
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            
            hold on
            
            clear x_axis
            x_axis = meanAllSessCthPeakDfAcrossTrials;
            clear y_axis
            y_axis = 0
            
            h2 = scatter(x_axis,y_axis,'*','g');
            
            %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
            %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
            title(uniqueContrasts(c))
            xlabel('peak df/f')
            ylabel('fraction of trials')
            
            ylim(yLimit)
            xlim(xLimit)
            
            set(gca,'XTick',xTickRange)
            %set(gca,'XTickLabel',xTickLabelRange)
            
            hold on  
                    
        end % end c loop - move to next contrast/subplot
        
        %legendInfo = {'stat','run'};
        %legend(legendInfo)
                
    end % end i loop (only 1 point
    
end % end d loop (only 1 dur)
                    
mnNumRUNTrialsEachConAllSess = mean(squeeze(numRUNTrialsEachConAllSess),2)
mnNumSTATTrialsEachConAllSess = mean(squeeze(numSTATTrialsEachConAllSess),2)



%% TRACES - stationary & run

yLimit = [-0.15 0.25];

durat = 1;

visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

figure
titleText = 'stat';
suptitle(titleText)
%formatSpec = 'vis area: %1.f (STAT)';
%titleText = sprintf(formatSpec,visArea);
% titleText = '100ms, STAT'
% suptitle(titleText)


% NEED this for UNIQUE CONS for C loop:

% EXTRACT VARS from GROUP CELL ARRAYS
clear n
n = 1
nthStimDetailsStruct = groupStimDetails{n};
nthTrialCond = groupTrialCond{1,n};
nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n};

% CONTRAST calc's
clear con
clear conOrderedByTrial  
clear conOrderedByTrialMeetCriteria 
clear uniqueContrasts
clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
end
conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueContrasts = unique(con); % for looping over contrast values later

%  DURATION Calc's
clear dur
clear durOrderedByTrial  
clear durOrderedByTrialMeetCriteria 
clear uniqueDurations
% extract duration field from stimDetails
clear durs
for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
end
durOrderedByTrial = dur(nthTrialCond); 
durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueDurations = unique(dur);

% CON & DUR TOGETHER
clear conAndDur 
clear conAndDurOrderedByTrial 
clear conAndDurOrderedByTrialMeetCriteria
conAndDur = [con; dur];
conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);


%figure % make one figure for all subplots
% clear titleText
% titleText = ': df/f vs frames for diff contrasts, dur = 266 ms'; % making char variables for sprintf/title later
% % suptitle(sprintf('%s', date, subjName, titleText));
% suptitle('neural activity vs frames, duration = 266 ms')


clear i
for i = visArea
    
    for d = durat
        
        loopCounter = 1;
        
        for c = 1:length(uniqueContrasts)
            
            clear n 
            for n = 1:nGroup % for each session/mouse
                
                % EXTRACT VARS from GROUP CELL ARRAYS
                nthStimDetailsStruct = groupStimDetails{n};
                nthTrialCond = groupTrialCond{1,n};
                nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n}; 
               
                % CON & DUR VALUES AT EACH TRIAL - these values get calculated anew for each session 
        
                % CONTRAST calc's
                clear con
                clear conOrderedByTrial  
                clear conOrderedByTrialMeetCriteria 
                clear uniqueContrasts
                clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
                for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
                    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
                end
                conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
                conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueContrasts = unique(con); % for looping over contrast values later
                
                %  DURATION Calc's
                clear dur
                clear durOrderedByTrial  
                clear durOrderedByTrialMeetCriteria 
                clear uniqueDurations
                % extract duration field from stimDetails
                clear durs
                for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
                    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
                end
                durOrderedByTrial = dur(nthTrialCond); 
                durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueDurations = unique(dur);
        
                % CON & DUR TOGETHER
                clear conAndDur 
                clear conAndDurOrderedByTrial 
                clear conAndDurOrderedByTrialMeetCriteria
                conAndDur = [con; dur];
                conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
                conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                
                % in preparation for making pixel wise figures of fluroescene at different stim conditions,
                % make figure legends
                [reigons,cons4Legend,cons4axes,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations);
                % durs4Legend = {'16 ms','33 ms', '66 ms', '133 ms', '266 ms'}
                durs4Legend = {'100 ms'};
        
                % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
                nthPTSdfof = groupPTSdfof{1,n};
                nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
                nthBaselineIdx = groupBaselineIdx{1,n};
                
                % EXTRACT RUN vs STAT TRIAL INDICIES
                nthIdxRunTrials = groupIdxRunTrials{1,n};
                nthIdxStatTrials = groupIdxStatTrials{1,n}; 
        
                % get CTH DTH STAT trials
                
                clear dthCthTrials
                dthCthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
                
                clear idxCthDthTrial
                idxCthDthTrial = find(dthCthTrials == 1);
                 
                clear nthIdxCthDthSTATtrials
                idxCthDthSTATtrials = intersect(idxCthDthTrial,nthIdxStatTrials);
                    
                clear numIdxCthDthSTATtrials
                numIdxCthDthSTATtrials = length(idxCthDthSTATtrials)

                % part directly from old script
                
                clear recomboOnePtAllFramesAllTrialMinusMeanBase
                clear meanRecomboOnePtAllFramesAllTrialMinusMeanBase

                % collect all cth dth trials over all frames for the ith point
                clear onePtAllFramesAndTrials % new var each point
                onePtAllFramesAndTrials = squeeze(nthPTSdfof(i,:,idxCthDthSTATtrials)); 
                onePtAllFramesAndTrials = onePtAllFramesAndTrials';

                % for every trace, subtract the baseline value at that point from each frame value
                clear tr % for each trial in onePtAllFramesAndTrial
                for tr = 1:size(onePtAllFramesAndTrials,1) % 1st dim is trials, 2nd is frames

                    % getting TRIAL VECTOR
                    clear onePtAllFramesOneTrial % make new var for each trial
                    % index into each trace/vector & save as variable
                    onePtAllFramesOneTrial = onePtAllFramesAndTrials(tr,:);

                    % getting MEAN BASEline VALUE for each TRIAL
                    clear allBaseFramesOnePtOneTrial % new baseline frames for each trial
                    % collect 4 baseline frames for tr-th ith trial
                    allBaseFramesOnePtOneTrial = onePtAllFramesOneTrial(1,nthBaselineIdx);

                    clear mean4baseFramesOnePtOneTrial
                    % get mean value of baseline values for ith point
                    mean4baseFramesOnePtOneTrial = mean(allBaseFramesOnePtOneTrial,2);
                    mean4baseFramesOnePtOneTrial = squeeze(mean4baseFramesOnePtOneTrial);

                    % BASEline CORRECTion of TRIAL VECTOR
                    % new baseline-corrected trace for each trial
                    onePtAllFramesOneTrialMinusMeanBase = onePtAllFramesOneTrial-mean4baseFramesOnePtOneTrial;

                    % collect CORRECTed TRIAL VECTORS in matrix
                    % (only clear this outside the loop for each point)
                    recomboOnePtAllFramesAllTrialMinusMeanBase(tr,:) = onePtAllFramesOneTrialMinusMeanBase;

                    % PLOT
                    clear x_axis
                    x_axis = 1:length(onePtAllFramesOneTrialMinusMeanBase); % length of frames

                    % plot one baseline corrected trace at a time
                    subplot(2,4,c)
                    plot(x_axis,onePtAllFramesOneTrialMinusMeanBase)
                    title(uniqueContrasts(c))
                    
                    ylim(yLimit)
                    xlim([1 length(x_axis)])

                    hold on % hold for next trial
                
                end % end tr loop
      
                hold on % hold for plotting mean over subplot
                
            end % end n loop - now have all trials for all sesstions at cth contrast plotted
        
            % get mean baselined trace across all trials
            statMeanRecomboOnePtAllFramesAllTrialMinusMeanBase = mean(recomboOnePtAllFramesAllTrialMinusMeanBase,1); % mean across trials
            allConsStatMeanRecomboOnePtAllFramesAllTrialMinusMeanBase(c,:) = statMeanRecomboOnePtAllFramesAllTrialMinusMeanBase;
            
            subplot(2,4,c)
            plot(x_axis,statMeanRecomboOnePtAllFramesAllTrialMinusMeanBase,'color','y','linewidth',1)
            title(uniqueContrasts(c))

            ylim(yLimit)
            xlim([1 length(x_axis)])

            %ax = gca;
            %x.XTick = [1:1:length(x_axis)];

            loopCounter = loopCounter + 1;
        
            % go to next contrast after plotting mean trace
            
        end % end c loop
        
    end % end d loop
    
    % save for each point
    allPtsAllConsSTATMeanRecomboOnePtAllFramesAllTrialMinusMeanBase(:,:,i) = allConsStatMeanRecomboOnePtAllFramesAllTrialMinusMeanBase;
       
end % end i loop




% TRACES - running

%yLimit = [-0.15 0.25];

%durat = 5;

%visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

figure
suptitle('run')
%formatSpec = 'vis area: %1.f (RUN)';
%titleText = sprintf(formatSpec,visArea);
% titleText = '100 ms, RUN'
% suptitle(titleText)


% NEED this for UNIQUE CONS for C loop:

% EXTRACT VARS from GROUP CELL ARRAYS
clear n
n = 1
nthStimDetailsStruct = groupStimDetails{n};
nthTrialCond = groupTrialCond{1,n};
nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n};

% CONTRAST calc's
clear con
clear conOrderedByTrial  
clear conOrderedByTrialMeetCriteria 
clear uniqueContrasts
clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
end
conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueContrasts = unique(con); % for looping over contrast values later

%  DURATION Calc's
clear dur
clear durOrderedByTrial  
clear durOrderedByTrialMeetCriteria 
clear uniqueDurations
% extract duration field from stimDetails
clear durs
for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
end
durOrderedByTrial = dur(nthTrialCond); 
durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
uniqueDurations = unique(dur);

% CON & DUR TOGETHER
clear conAndDur 
clear conAndDurOrderedByTrial 
clear conAndDurOrderedByTrialMeetCriteria
conAndDur = [con; dur];
conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);


%figure % make one figure for all subplots
% clear titleText
% titleText = ': df/f vs frames for diff contrasts, dur = 266 ms'; % making char variables for sprintf/title later
% % suptitle(sprintf('%s', date, subjName, titleText));
% suptitle('neural activity vs frames, duration = 266 ms')


clear i
for i = visArea
    
    for d = durat
        
        loopCounter = 1;
        
        for c = 1:length(uniqueContrasts)
            
            clear n 
            for n = 1:nGroup % for each session/mouse
                
                % EXTRACT VARS from GROUP CELL ARRAYS
                nthStimDetailsStruct = groupStimDetails{n};
                nthTrialCond = groupTrialCond{1,n};
                nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n}; 
               
                % CON & DUR VALUES AT EACH TRIAL - these values get calculated anew for each session 
        
                % CONTRAST calc's
                clear con
                clear conOrderedByTrial  
                clear conOrderedByTrialMeetCriteria 
                clear uniqueContrasts
                clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
                for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
                    con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
                end
                conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
                conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueContrasts = unique(con); % for looping over contrast values later
                
                %  DURATION Calc's
                clear dur
                clear durOrderedByTrial  
                clear durOrderedByTrialMeetCriteria 
                clear uniqueDurations
                % extract duration field from stimDetails
                clear durs
                for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
                    dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
                end
                durOrderedByTrial = dur(nthTrialCond); 
                durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                uniqueDurations = unique(dur);
        
                % CON & DUR TOGETHER
                clear conAndDur 
                clear conAndDurOrderedByTrial 
                clear conAndDurOrderedByTrialMeetCriteria
                conAndDur = [con; dur];
                conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
                conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
                
                % in preparation for making pixel wise figures of fluroescene at different stim conditions,
                % make figure legends
                [reigons,cons4Legend,cons4axes,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations);
                % durs4Legend = {'16 ms','33 ms', '66 ms', '133 ms', '266 ms'}
                durs4Legend = {'100 ms'};
        
                % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
                nthPTSdfof = groupPTSdfof{1,n};
                nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
                nthBaselineIdx = groupBaselineIdx{1,n};
                
                % EXTRACT RUN vs STAT TRIAL INDICIES
                nthIdxRunTrials = groupIdxRunTrials{1,n};
                nthIdxStatTrials = groupIdxStatTrials{1,n}; 
        
                % get CTH DTH STAT trials
                
                clear dthCthTrials
                dthCthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
                
                clear idxCthDthTrial
                idxCthDthTrial = find(dthCthTrials == 1);
                 
                clear nthIdxCthDthRUNtrials
                idxCthDthRUNtrials = intersect(idxCthDthTrial,nthIdxRunTrials);
                    
                clear numIdxCthDthRUNtrials
                numIdxCthDthRUNtrials = length(idxCthDthRUNtrials);

                % part directly from old script
                
                clear recomboOnePtAllFramesAllTrialMinusMeanBase
                clear meanRecomboOnePtAllFramesAllTrialMinusMeanBase

                % collect all cth dth trials over all frames for the ith point
                clear onePtAllFramesAndTrials % new var each point
                onePtAllFramesAndTrials = squeeze(nthPTSdfof(i,:,idxCthDthRUNtrials));
                
                if size(onePtAllFramesAndTrials) == [1,size(nthPTSdfof,2)];
                    onePtAllFramesAndTrials = onePtAllFramesAndTrials; % nothinh
                else
                    onePtAllFramesAndTrials = onePtAllFramesAndTrials';
                end 

                % for every trace, subtract the baseline value at that point from each frame value
                clear tr % for each trial in onePtAllFramesAndTrial
                for tr = 1:size(onePtAllFramesAndTrials,1) % 1st dim is trials, 2nd is frames

                    % getting TRIAL VECTOR
                    clear onePtAllFramesOneTrial % make new var for each trial
                    % index into each trace/vector & save as variable
                    onePtAllFramesOneTrial = onePtAllFramesAndTrials(tr,:);

                    % getting MEAN BASEline VALUE for each TRIAL
                    clear allBaseFramesOnePtOneTrial % new baseline frames for each trial
                    % collect 4 baseline frames for tr-th ith trial
                    allBaseFramesOnePtOneTrial = onePtAllFramesOneTrial(1,nthBaselineIdx);

                    clear mean4baseFramesOnePtOneTrial
                    % get mean value of baseline values for ith point
                    mean4baseFramesOnePtOneTrial = mean(allBaseFramesOnePtOneTrial,2);
                    mean4baseFramesOnePtOneTrial = squeeze(mean4baseFramesOnePtOneTrial);

                    % BASEline CORRECTion of TRIAL VECTOR
                    % new baseline-corrected trace for each trial
                    onePtAllFramesOneTrialMinusMeanBase = onePtAllFramesOneTrial-mean4baseFramesOnePtOneTrial;

                    % collect CORRECTed TRIAL VECTORS in matrix
                    % (only clear this outside the loop for each point)
                    recomboOnePtAllFramesAllTrialMinusMeanBase(tr,:) = onePtAllFramesOneTrialMinusMeanBase;

                    % PLOT
                    clear x_axis
                    x_axis = 1:length(onePtAllFramesOneTrialMinusMeanBase); % length of frames

                    % plot one baseline corrected trace at a time
                    subplot(2,4,c)
                    plot(x_axis,onePtAllFramesOneTrialMinusMeanBase)
                    title(uniqueContrasts(c))
                    
                    ylim(yLimit)
                    xlim([1 length(x_axis)])

                    hold on % hold for next trial
                
                end % end tr loop
      
                hold on % hold for plotting mean over subplot
                
            end % end n loop - now have all trials for all sesstions at cth contrast plotted
        
            % get mean baselined trace across all trials
            % get mean baselined trace across all trials
            runMeanRecomboOnePtAllFramesAllTrialMinusMeanBase = mean(recomboOnePtAllFramesAllTrialMinusMeanBase,1); % mean across trials
            allConsRunMeanRecomboOnePtAllFramesAllTrialMinusMeanBase(c,:) = runMeanRecomboOnePtAllFramesAllTrialMinusMeanBase;
            
            subplot(2,4,c)
            plot(x_axis,runMeanRecomboOnePtAllFramesAllTrialMinusMeanBase,'color','g','linewidth',1)
            title(uniqueContrasts(c))

            ylim(yLimit)
            xlim([1 length(x_axis)])

            %ax = gca;
            %x.XTick = [1:1:length(x_axis)];
        
            loopCounter = loopCounter + 1;
            
            % go to next contrast after plotting mean trace
        
        end % end c loop
        
    end % end d loop
    
    % save all cons mean trace for each point
    
    %allPtsAllConsRUNMeanRecomboOnePtAllFramesAllTrialMinusMeanBase(:,:,i) = allConsRunMeanRecomboOnePtAllFramesAllTrialMinusMeanBase;
       
end % end i loop



%% plot MEAN RUN vs MEAN STAT TRACE

yLimit = [-0.02 0.15];

%xLimit = [1 18]; % 1 thru num frames

%durat = 5;

%visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control


figure
suptitle('v1')
        
for c = 1:length(uniqueContrasts)

    % note: mean traces per contrast alrady calualted acrosss
    % sessions, don't need n loop

    subplot(2,4,c)
    plot(allConsStatMeanRecomboOnePtAllFramesAllTrialMinusMeanBase(c,:),'b')
    hold on
    plot(allConsRunMeanRecomboOnePtAllFramesAllTrialMinusMeanBase(c,:),'r')

    ylim(yLimit)
    xlim([1 length(allConsStatMeanRecomboOnePtAllFramesAllTrialMinusMeanBase)])
    
    title(uniqueContrasts(c))
    
    legend({'stat','run'})

    % move to next contrast

end % end c loop
        
