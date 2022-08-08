function [subjData,sessionFile,allStop,allResp,stimDetails,trialCond] = loadStage2subjSessVars()
% This function prompts the user to select the ball data folder path,
% and select and load the subject file and sessions file. Then it returns
% the vars needed for stage 2 analysis, including for generating
% figure title, legend, and axes info. 

    % LOADING RECORDING SESSION VARIABLES - saved out by doBehavior_yoked 

    % add PATH to ball data

    ballDataFolderPath = uigetdir(path,'ball data folder path'); 
    addpath(ballDataFolderPath)

    % load SUBJ mat file from w/in ball data folders: 

    [subjFile subjPath] = uigetfile('*.mat','subj file');
    load(fullfile(subjPath,subjFile));
    
    % save vars i need:
    subjData = subjData;
    
    % load SESSIONS mat file (doBehavior generates one of these files per session):

    [sessionFile sessionPath] = uigetfile('*.mat','session file');
    load(fullfile(sessionPath,sessionFile));
    
    % return the vars that I need
    
    allStop = allStop;
    allResp = allResp;
    stimDetails = stimDetails;
    trialCond = trialCond;
    
end

