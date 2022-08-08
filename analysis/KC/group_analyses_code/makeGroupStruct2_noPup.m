function [nGroup, nthVarsFilePaths, groupStimDetails, groupSubjData, groupSubjName, groupDate, groupTrialCond, groupNumPreStimFrames, groupNumPostStimFrames, groupIdxOnsetsMeetsCriteria, groupOnsetDf, groupPeakFrameIdx, groupStimOnsetFrame, groupBaselineIdx, groupBaselinedActIm, groupRoundXpts, groupRoundYpts, groupPTSdfof, groupMeanSpeedAllTrials, groupEarliestTrial, groupNumLateTrialsSubtract] = makeGroupStruct2_noPup()
% This function asks user how many experiment sessions to get individual
% analysis variables for. This function is the first step in running group
% analyses

    % at this point, vars 4 indivisual & group analysis have already been created

    % have matlab ask me how many mice I wanna average over for the present
    % group
    nGroup = input('how many sessions in this group?')

    % put that number into a for loop, have me get the var mat files that many of times

    clear nthVarsFilePaths
    clear n
    for n = 1:nGroup

        [f p] = uigetfile('*.mat',sprintf('session # %0.00f newVars4IndAndGroupAnalyses',n));

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
        groupOnsetDf{1,n} = onsetDf;
        groupPeakFrameIdx{1,n} = peakFrameIdx;
        groupStimOnsetFrame{1,n} = stimOnsetFrame;
        groupBaselineIdx{1,n} = baselineIdx;
        groupBaselinedActIm{1,n} = baselinedActIm;
        groupRoundXpts{1,n} = RoundXpts;
        groupRoundYpts{1,n} = RoundYpts;
        groupPTSdfof{1,n} = PTSdfof;
        groupMeanSpeedAllTrials{1,n} = meanSpeedAllTrials;
        %groupIdxRunTrials{1,n} = idxRunTrials;
        %groupIdxStatTrials{1,n} = idxStatTrials;
        %groupIdxSmallPupilTrials{1,n} = idxSmallPupilTrials;
        %groupIdxLargePupilTrials{1,n} = idxLargePupilTrials;
        %groupLongAxis{1,n} = longaxis;
        %groupMeanPupilDiameterAllTrials{1,n} = meanPupilDiameterAllTrials;
        %groupRunThresh{1,n} = runThresh;
        %groupPupThresh{1,n} = pupThreshold;
        groupEarliestTrial{1,n} = earliestTrial;
        groupNumLateTrialsSubtract{1,n} = numLateTrialsSubtract;

    end % now I have the group analysis vars for each session

end

