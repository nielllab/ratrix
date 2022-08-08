function [ df ] = openVars4analysis2()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    [f p] = uigetfile('*.mat','maps file');
    load(fullfile(p,f));
    df = dfof_bg;
    
    %return df

end

