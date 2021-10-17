function [df,frameT] = loadStage2MapsVars()
% This function prompts the user to select a maps file
% (threshold stimulus session), then it loads the maps.mat file
% and returns the 2 variables in it that are needed for stage 2 analysis:
% frameT (imaging timestamps) and df (imaging movie).
% save frameT redefined as frameT-frameT(1) as well as 'originalFrameT'.
% Stage 1 of analysis was DfofMovie.

    [f p] = uigetfile('*.mat','thresh maps file');
    load(fullfile(p,f));
    
    % OPTIONAL, not needed w/green light dfofMOvie analysis, just w/blue
    % only sessions:
    %downsize = 0.25; % why resize by this factor?
    %df = imresize(dfof_bg,downsize);
    
    df = dfof_bg; % just cuz I use 'df' var name in rest of code...
    sizeDf = size(df)
    
    frameT = frameT';
    frameT = frameT-frameT(1);
    
    sizeFrameT = size(frameT)

end

