function [df,frameT] = times2()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    [f p] = uigetfile('*.mat','thresh maps file');
    load(fullfile(p,f));
    df = dfof_bg; % just cuz I use 'df' var name in rest of code...
    frameT = frameT';

end

