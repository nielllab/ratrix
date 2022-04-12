
%cdfplot(df_stat)

%% RUN VS STAT or BAR

% UNCOMMENT for STAT OR RUN

% one point, one dur, all cons, STATIONARY 

durat = 1;

visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

figure
formatSpec = 'area %1.f, duration %1.f'
titleText = sprintf(formatSpec,visArea,durat)
suptitle(titleText)

% BEH STATE

%state = 'loRun'
state = 'hiRun'

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
    for i = 1 % v1 
    %for i = visArea

        clear c % for each contrast
        %for c = 1:length(uniqueContrasts) 
         for c = 7

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
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
                
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            %subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            %numBins = 50;
            %h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            if state == 'loRun'
                ba = bar(allSessCthPeakDfEachTrial)
                ba.FaceColor = 'b';

                hold on

                %clear x_axis
                %x_axis = meanAllSessCthPeakDfAcrossTrials;
                %clear y_axis
                %y_axis = 0

                %h2 = scatter(x_axis,y_axis,'*','g')

                %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
                %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
                title(uniqueContrasts(c))

                xlabel('trial')
                ylabel('df')
                %ylim([0 0.15])
                xlim([1 length(allSessCthPeakDfEachTrial)])

                %set(gca,'XTick',-0.1:0.05:0.2)
               % set(gca,'XTickLabel',-0.1:0.1:0.2)

                hold on  
                
            end % end 'plot if'
            
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
                
                % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
                
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            %subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            %numBins = 50;
            %h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            if state == 'hiRun'
                
                ba = bar(allSessCthPeakDfEachTrial)
                ba.FaceColor = 'r';
            
                hold on
            
                %clear x_axis
                %x_axis = meanAllSessCthPeakDfAcrossTrials;
                %clear y_axis
                %y_axis = 0

                %h2 = scatter(x_axis,y_axis,'*','g')

                %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
                %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
                title(uniqueContrasts(c))
            
                xlabel('trial')
                ylabel('df')
                %ylim([0 0.15])
                %xlim([-0.1 0.2])

                %set(gca,'XTick',-0.1:0.05:0.2)
               % set(gca,'XTickLabel',-0.1:0.1:0.2)

                hold on  
                
            end % end 'plot if'

        end % end c loop - move to next contrast/subplot
        
        %legendInfo = {'stat','run'};
        %legend(legendInfo)
                
    end % end i loop (only 1 point
    
end % end d loop (only 1 dur)
                    
numTrialsOneCon = size(allSessCthPeakDfEachTrial)




%% STAT - BAR/SORT

% one point, one dur, all cons, STATIONARY 

durat = 1;

cont = 7;

visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

figure
formatSpec = 'area %1.f, duration %1.f'
titleText = sprintf(formatSpec,visArea,durat)
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
        %for c = 1:length(uniqueContrasts) 
         for c = cont

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
                
                % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
                
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            %subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            %numBins = 50;
            %h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            sortSessCthPeakDfEachTrial = sort(allSessCthPeakDfEachTrial)
            ba = bar(sortSessCthPeakDfEachTrial)
            ba.FaceColor = 'b';
            
            hold on
            
            %clear x_axis
            %x_axis = meanAllSessCthPeakDfAcrossTrials;
            %clear y_axis
            %y_axis = 0
            
            %h2 = scatter(x_axis,y_axis,'*','g')
            
            %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
            %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
            title(uniqueContrasts(c))
            
            xlabel('trial')
            ylabel('df')
            ylim([-0.15 0.15])
            xlim([1 length(allSessCthPeakDfEachTrial)])
            
            %set(gca,'XTick',-0.1:0.05:0.2)
           % set(gca,'XTickLabel',-0.1:0.1:0.2)
            
            hold on  
            
            % go back into n loop, do it all again at this contrast but for
            % RUN trials
            
            % this is for storing different length-ed cth trial vectors for all sessions (concatenated)
%           clear allSessCthPeakDfEachTrial
%           allSessCthPeakDfEachTrial = []; 
    
%             clear n 
%             for n = 1:nGroup % for each session/mouse
%                 
%                 % EXTRACT VARS from GROUP CELL ARRAYS
%                 nthStimDetailsStruct = groupStimDetails{n};
%                 nthTrialCond = groupTrialCond{1,n};
%                 nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n}; 
%                
%                 % CON & DUR VALUES AT EACH TRIAL - these values get calculated anew for each session 
%         
%                 % CONTRAST calc's
%                 clear con
%                 clear conOrderedByTrial  
%                 clear conOrderedByTrialMeetCriteria 
%                 clear uniqueContrasts
%                 clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
%                 for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
%                     con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
%                 end
%                 conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
%                 conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
%                 uniqueContrasts = unique(con); % for looping over contrast values later
%                 
%                 %  DURATION Calc's
%                 clear dur
%                 clear durOrderedByTrial  
%                 clear durOrderedByTrialMeetCriteria 
%                 clear uniqueDurations
%                 % extract duration field from stimDetails
%                 clear durs
%                 for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
%                     dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
%                 end
%                 durOrderedByTrial = dur(nthTrialCond); 
%                 durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
%                 uniqueDurations = unique(dur);
%         
%                 % CON & DUR TOGETHER
%                 clear conAndDur 
%                 clear conAndDurOrderedByTrial 
%                 clear conAndDurOrderedByTrialMeetCriteria
%                 conAndDur = [con; dur];
%                 conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
%                 conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
%                 
%                 % in preparation for making pixel wise figures of fluroescene at different stim conditions,
%                 % make figure legends
%                 [reigons,cons4Legend,cons4axes,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations);
%                 % durs4Legend = {'16 ms','33 ms', '66 ms', '133 ms', '266 ms'}
%                 durs4Legend = {'100 ms'};
%         
%                 % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
%                 nthPTSdfof = groupPTSdfof{1,n};
%                 nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
%                 nthBaselineIdx = groupBaselineIdx{1,n};
%                 
%                 % EXTRACT RUN vs STAT TRIAL INDICIES
%                 nthIdxRunTrials = groupIdxRunTrials{1,n};
%                 nthIdxStatTrials = groupIdxStatTrials{1,n}; 
%         
%                 % get CTH DTH STAT trials
%                 
%                 clear dthCthTrials
%                 dthCthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
%                 
%                 clear idxCthDthTrial
%                 idxCthDthTrial = find(dthCthTrials == 1);
%                  
%                 clear nthIdxCthDthRUNtrials
%                 idxCthDthRUNtrials = intersect(idxCthDthTrial,nthIdxRunTrials);
%                     
%                 clear numIdxCthDthRUNtrials
%                 numIdxCthDthRUNtrials = length(idxCthDthRUNtrials)
%                 
%                 % GET DFof for PEAK FRAMES
%                 
%                 % take df/f data for ith pt, peak frames, cth dth stat trials
%                 allPeakFramesCthDthTrialsIthPt = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxCthDthRUNtrials)); 
%                 meanPeakFramesCthDthTrialsIthPt = mean(allPeakFramesCthDthTrialsIthPt,1); % gives 1 x #trials
%                 % ^ CANT do: store output vectors for each contrast
%                 % b/c every vectoris a different length (num trials), so can't 'collect'
%                 % Better to just plot directly on the subplot here
%                     
%                 % get BASELINE @ cth dth state trials
%                 
%                 clear allBaselineFrames
%                 allBaselineFrames = squeeze(nthPTSdfof(i,nthBaselineIdx,idxCthDthRUNtrials));
%                 % get one mean baseline value over all frames & trials
%                 meanBaselineFrames = mean(allBaselineFrames,1); % mean over frames
%                 meanBaselineFrames = mean(meanBaselineFrames,2); % mean over trials
%                 
%                 % SUBTract BASeline from vector of mean df/f across peak frames, cthdth stat trials
%         
%                 meanPeakFramesCthDthTrialsIthPtMinusBase = meanPeakFramesCthDthTrialsIthPt-meanBaselineFrames;
%                 % ^this is a 1 x # trials vector
%                     
%                 % b/c each meanPeakFramesCthDthTrialsIthPtMinusBase var is a different length, 
%                 % we can't store in a session matrix. 
%                 % but, since this is a group analysis, and since I'm not calulating stderr, 
%                 % I can concatenate each session's trials at a particular contrast and plot one
%                 % subplot/contrast at a time
%                 
%                 % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
%                 
%                 allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
%                 meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
%                 stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
%                 stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
%                 
%             end % end n loop - have vector for all trials across all sessions at 1 contrast now
%                 
%             % PLOT - one contrast at a time
%     
%             % once I have the peak activity for the cth contrast for all trials across all sessions, 
%             % I can make a histogram
%     
%             %subplot(2,4,c) % make a subplot for each contrast
%             %title(sprintf('c = %0.3d',uniqueContrasts(c)))
%                 
%             %numBins = 50;
%             %h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
%             ba = bar(allSessCthPeakDfEachTrial)
%             ba.FaceColor = 'r';
%             
%             hold on
%             
%             %clear x_axis
%             %x_axis = meanAllSessCthPeakDfAcrossTrials;
%             %clear y_axis
%             %y_axis = 0
%             
%             %h2 = scatter(x_axis,y_axis,'*','g')
%             
%             %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
%             %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
%             title(uniqueContrasts(c))
%             
%             xlabel('trial')
%             ylabel('df')
%             %ylim([0 0.15])
%             %xlim([-0.1 0.2])
%             
%             %set(gca,'XTick',-0.1:0.05:0.2)
%            % set(gca,'XTickLabel',-0.1:0.1:0.2)
%             
%             hold on  
                    
        end % end c loop - move to next contrast/subplot
        
        %legendInfo = {'stat','run'};
        %legend(legendInfo)
                
    end % end i loop (only 1 point
    
end % end d loop (only 1 dur)
                    
numTrialsOneCon = size(allSessCthPeakDfEachTrial)


%% RUN - BAR/SORT

% one point, one dur, all cons, STATIONARY 

durat = 1;

cont = 7;

visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

figure
formatSpec = 'area %1.f, duration %1.f'
titleText = sprintf(formatSpec,visArea,durat)
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
        %for c = 1:length(uniqueContrasts) 
         for c = cont

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
                    
                clear numIdxCthDthSTATtrials
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
                
                % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
                
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            %subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            %numBins = 50;
            %h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            sortSessCthPeakDfEachTrial = sort(allSessCthPeakDfEachTrial)
            ba = bar(sortSessCthPeakDfEachTrial)
            ba.FaceColor = 'b';
            
            hold on
            
            %clear x_axis
            %x_axis = meanAllSessCthPeakDfAcrossTrials;
            %clear y_axis
            %y_axis = 0
            
            %h2 = scatter(x_axis,y_axis,'*','g')
            
            %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
            %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
            title(uniqueContrasts(c))
            
            xlabel('trial')
            ylabel('df')
            ylim([-0.1 0.18])
            xlim([1 length(allSessCthPeakDfEachTrial)])
            
            %set(gca,'XTick',-0.1:0.05:0.2)
           % set(gca,'XTickLabel',-0.1:0.1:0.2)
            
            hold on  
            
            % go back into n loop, do it all again at this contrast but for
            % RUN trials
            
            % this is for storing different length-ed cth trial vectors for all sessions (concatenated)
%           clear allSessCthPeakDfEachTrial
%           allSessCthPeakDfEachTrial = []; 
    
%             clear n 
%             for n = 1:nGroup % for each session/mouse
%                 
%                 % EXTRACT VARS from GROUP CELL ARRAYS
%                 nthStimDetailsStruct = groupStimDetails{n};
%                 nthTrialCond = groupTrialCond{1,n};
%                 nthIdxOnsetsMeetsCriteria = groupIdxOnsetsMeetsCriteria{1,n}; 
%                
%                 % CON & DUR VALUES AT EACH TRIAL - these values get calculated anew for each session 
%         
%                 % CONTRAST calc's
%                 clear con
%                 clear conOrderedByTrial  
%                 clear conOrderedByTrialMeetCriteria 
%                 clear uniqueContrasts
%                 clear cons % % still in session loop, for each stim condition, get contrast value, store all in vector
%                 for cons = 1:length(nthStimDetailsStruct); % 1x96 struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
%                     con(cons) = nthStimDetailsStruct(cons).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
%                 end
%                 conOrderedByTrial = con(nthTrialCond); % trial cond is all conditions ordered by trial..its indicies for rows in stimDetail
%                 conOrderedByTrialMeetCriteria = conOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
%                 uniqueContrasts = unique(con); % for looping over contrast values later
%                 
%                 %  DURATION Calc's
%                 clear dur
%                 clear durOrderedByTrial  
%                 clear durOrderedByTrialMeetCriteria 
%                 clear uniqueDurations
%                 % extract duration field from stimDetails
%                 clear durs
%                 for durs = 1:length(nthStimDetailsStruct); % 1 by # stim conditions struct, each row is a stim condition , w/colums fields like sf, correctResp, contrasts, duration, etc
%                     dur(durs) = nthStimDetailsStruct(durs).duration; % making vector with list of stim duration for each condition - some of these will be repeating, since there are only 5? durations but many stimulus conditions (phase, etc)
%                 end
%                 durOrderedByTrial = dur(nthTrialCond); 
%                 durOrderedByTrialMeetCriteria = durOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
%                 uniqueDurations = unique(dur);
%         
%                 % CON & DUR TOGETHER
%                 clear conAndDur 
%                 clear conAndDurOrderedByTrial 
%                 clear conAndDurOrderedByTrialMeetCriteria
%                 conAndDur = [con; dur];
%                 conAndDurOrderedByTrial = conAndDur(:,nthTrialCond); % gives 2 x #trials
%                 conAndDurOrderedByTrialMeetCriteria = conAndDurOrderedByTrial(:,nthIdxOnsetsMeetsCriteria);
%                 
%                 % in preparation for making pixel wise figures of fluroescene at different stim conditions,
%                 % make figure legends
%                 [reigons,cons4Legend,cons4axes,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations);
%                 % durs4Legend = {'16 ms','33 ms', '66 ms', '133 ms', '266 ms'}
%                 durs4Legend = {'100 ms'};
%         
%                 % EXTRACT PEAK FRAMES BASELINE,and PTSDFOF
%                 nthPTSdfof = groupPTSdfof{1,n};
%                 nthPeakFrameIdx = groupPeakFrameIdx{1,n}; 
%                 nthBaselineIdx = groupBaselineIdx{1,n};
%                 
%                 % EXTRACT RUN vs STAT TRIAL INDICIES
%                 nthIdxRunTrials = groupIdxRunTrials{1,n};
%                 nthIdxStatTrials = groupIdxStatTrials{1,n}; 
%         
%                 % get CTH DTH STAT trials
%                 
%                 clear dthCthTrials
%                 dthCthTrials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
%                 
%                 clear idxCthDthTrial
%                 idxCthDthTrial = find(dthCthTrials == 1);
%                  
%                 clear nthIdxCthDthRUNtrials
%                 idxCthDthRUNtrials = intersect(idxCthDthTrial,nthIdxRunTrials);
%                     
%                 clear numIdxCthDthRUNtrials
%                 numIdxCthDthRUNtrials = length(idxCthDthRUNtrials)
%                 
%                 % GET DFof for PEAK FRAMES
%                 
%                 % take df/f data for ith pt, peak frames, cth dth stat trials
%                 allPeakFramesCthDthTrialsIthPt = squeeze(nthPTSdfof(i,nthPeakFrameIdx,idxCthDthRUNtrials)); 
%                 meanPeakFramesCthDthTrialsIthPt = mean(allPeakFramesCthDthTrialsIthPt,1); % gives 1 x #trials
%                 % ^ CANT do: store output vectors for each contrast
%                 % b/c every vectoris a different length (num trials), so can't 'collect'
%                 % Better to just plot directly on the subplot here
%                     
%                 % get BASELINE @ cth dth state trials
%                 
%                 clear allBaselineFrames
%                 allBaselineFrames = squeeze(nthPTSdfof(i,nthBaselineIdx,idxCthDthRUNtrials));
%                 % get one mean baseline value over all frames & trials
%                 meanBaselineFrames = mean(allBaselineFrames,1); % mean over frames
%                 meanBaselineFrames = mean(meanBaselineFrames,2); % mean over trials
%                 
%                 % SUBTract BASeline from vector of mean df/f across peak frames, cthdth stat trials
%         
%                 meanPeakFramesCthDthTrialsIthPtMinusBase = meanPeakFramesCthDthTrialsIthPt-meanBaselineFrames;
%                 % ^this is a 1 x # trials vector
%                     
%                 % b/c each meanPeakFramesCthDthTrialsIthPtMinusBase var is a different length, 
%                 % we can't store in a session matrix. 
%                 % but, since this is a group analysis, and since I'm not calulating stderr, 
%                 % I can concatenate each session's trials at a particular contrast and plot one
%                 % subplot/contrast at a time
%                 
%                 % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
%                 
%                 allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
%                 meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
%                 stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
%                 stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
%                 
%             end % end n loop - have vector for all trials across all sessions at 1 contrast now
%                 
%             % PLOT - one contrast at a time
%     
%             % once I have the peak activity for the cth contrast for all trials across all sessions, 
%             % I can make a histogram
%     
%             %subplot(2,4,c) % make a subplot for each contrast
%             %title(sprintf('c = %0.3d',uniqueContrasts(c)))
%                 
%             %numBins = 50;
%             %h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
%             ba = bar(allSessCthPeakDfEachTrial)
%             ba.FaceColor = 'r';
%             
%             hold on
%             
%             %clear x_axis
%             %x_axis = meanAllSessCthPeakDfAcrossTrials;
%             %clear y_axis
%             %y_axis = 0
%             
%             %h2 = scatter(x_axis,y_axis,'*','g')
%             
%             %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
%             %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
%             title(uniqueContrasts(c))
%             
%             xlabel('trial')
%             ylabel('df')
%             %ylim([0 0.15])
%             %xlim([-0.1 0.2])
%             
%             %set(gca,'XTick',-0.1:0.05:0.2)
%            % set(gca,'XTickLabel',-0.1:0.1:0.2)
%             
%             hold on  
                    
        end % end c loop - move to next contrast/subplot
        
        %legendInfo = {'stat','run'};
        %legend(legendInfo)
                
    end % end i loop (only 1 point
    
end % end d loop (only 1 dur)
                    
numTrialsOneCon = size(allSessCthPeakDfEachTrial)


%% CRIS better way to compare these: cdfplot(df_stat); cdfplot(df_run)

%% run + stat same fig bar

% one point, one dur, all cons, STATIONARY 

yMax = 0.25;
yMin = -0.1;
yLimit = [yMin yMax];

xLimit = [-0.1 0.25];

durat = 1;

cont = 7;

visArea = 1; % V1
%visArea = 2; % RL
%visArea = 3; % AL
%visArea = 4; % AM 
%visArea = 5; % control

figure
%formatSpec = 'area %1.f, duration %1.f, con %1.f'
%titleText = sprintf(formatSpec,visArea,durat,cont)
%titleText = 'V1, 0% Contrast'
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

        clear c % for each contrast
        %for c = 1:length(uniqueContrasts) 
         for c = cont

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
                
                % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
                
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            %subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            %numBins = 50;
            %h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            STATsortSessCthPeakDfEachTrial = sort(allSessCthPeakDfEachTrial)
            
            subplot(2,1,1)
            ba = bar(STATsortSessCthPeakDfEachTrial);
            ba.FaceColor = 'b';
            
            %hold on
            
            nearZeroIdx = find(STATsortSessCthPeakDfEachTrial > -0.0008 & STATsortSessCthPeakDfEachTrial < 0.0008);
            mnNearZeroValue = mean(STATsortSessCthPeakDfEachTrial(nearZeroIdx));
            clear belowZeroIdx
            belowZeroIdx = find(STATsortSessCthPeakDfEachTrial < mnNearZeroValue);
            numBelowZeroIdx = length(belowZeroIdx);
            percentSTATBelowZeroIdx = (numBelowZeroIdx/length(STATsortSessCthPeakDfEachTrial))*100
            
%             clear x_axis
%             x_axis = nearZeroIdx;
%             clear y_axis
%             y_axis = 0
%             
%             scatter(x_axis,y_axis,'*','r')
            
            hold on
            
            %clear x_axis
            %x_axis = meanAllSessCthPeakDfAcrossTrials;
            %clear y_axis
            %y_axis = 0
            
            %h2 = scatter(x_axis,y_axis,'*','g')
            
            %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
            %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
            %title(uniqueContrasts(c))
            
            xlabel('trial')
            ylabel('df')
            ylim(yLimit)
            xlim([1 length(STATsortSessCthPeakDfEachTrial)])
            
            %set(gca,'XTick',-0.1:0.05:0.2)
           % set(gca,'XTickLabel',-0.1:0.1:0.2)
            
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
                
                % SAVE EACH CTH mean Df for peck frames of cth dth stat trials
                
                allSessCthPeakDfEachTrial = [allSessCthPeakDfEachTrial,meanPeakFramesCthDthTrialsIthPtMinusBase]; 
                meanAllSessCthPeakDfAcrossTrials = mean(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial);
                stdAllSessCthPeakDfAcrossTrials = std(allSessCthPeakDfEachTrial)/sqrt(length(allSessCthPeakDfEachTrial)); % sum trials, not length
                
            end % end n loop - have vector for all trials across all sessions at 1 contrast now
                
            % PLOT - one contrast at a time
    
            % once I have the peak activity for the cth contrast for all trials across all sessions, 
            % I can make a histogram
    
            %subplot(2,4,c) % make a subplot for each contrast
            %title(sprintf('c = %0.3d',uniqueContrasts(c)))
                
            %numBins = 50;
            %h3 = histogram(allSessCthPeakDfEachTrial,numBins,'Normalization','probability')
            RUNsortAllSessCthPeakDfEachTrial = sort(allSessCthPeakDfEachTrial);
            
            subplot(2,1,2)
            ba = bar(RUNsortAllSessCthPeakDfEachTrial);
            ba.FaceColor = 'r';
            
            hold on
            
            nearZeroIdx = find(RUNsortAllSessCthPeakDfEachTrial > -0.0008 & RUNsortAllSessCthPeakDfEachTrial < 0.0008);
            mnNearZeroValue = mean(RUNsortAllSessCthPeakDfEachTrial(nearZeroIdx));
            belowZeroIdx = find(RUNsortAllSessCthPeakDfEachTrial < mnNearZeroValue);
            numBelowZeroIdx = length(belowZeroIdx);
            percentRUNBelowZeroIdx = (numBelowZeroIdx/length(RUNsortAllSessCthPeakDfEachTrial))*100
            
            %clear x_axis
            %x_axis = meanAllSessCthPeakDfAcrossTrials;
            %clear y_axis
            %y_axis = 0
            
            %h2 = scatter(x_axis,y_axis,'*','g')
            
            %formatSpec = 'c=%s, mn=%0.3f, st=%0.3f';
            %title(sprintf(formatSpec,cons4axes{c},meanAllSessCthPeakDfAcrossTrials,stdAllSessCthPeakDfAcrossTrials));
            %title(uniqueContrasts(c))
            
            xlabel('trial')
            ylabel('df')
            ylim(yLimit)
            xlim([1 length(RUNsortAllSessCthPeakDfEachTrial)])
            
            %set(gca,'XTick',-0.1:0.05:0.2)
           % set(gca,'XTickLabel',-0.1:0.1:0.2)
            
            hold on  
                    
        end % end c loop - move to next contrast/subplot
        
        %legendInfo = {'stat','run'};
        %legend(legendInfo)
                
    end % end i loop (only 1 point
    
end % end d loop (only 1 dur)
                    
numTrialsOneCon = size(allSessCthPeakDfEachTrial)


% CDF only

figure
formatSpec = 'area %1.f, duration %1.f, con %1.f'
titleText = sprintf(formatSpec,visArea,durat,cont)
suptitle(titleText)

cdfplot(STATsortSessCthPeakDfEachTrial)
hold on
cdfplot(RUNsortAllSessCthPeakDfEachTrial)

xlim(xLimit)
legend('stat','run')

