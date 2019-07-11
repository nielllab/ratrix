%% script to run topo test for mesoscope
close all; clear all;dbstop if error;warning off

[fileName,pathname] = uigetfile('*.tif','topo file');
cd(pathname)
% visStimFile = uigetfile('*.mat','stimulus file');

disp(fileName)
% disp(visStimFile)

%% get the first frame

%DO WHATEVER ON VISSTIMFILE TO GET FIRST FRAME AND IF YOU WANT FRAME TIMES
% first_frame = 470 %do this here
% last_frame = first_frame + 2150;

first_frame = 666 %do this here
last_frame = first_frame + 1885;

%% get the acquisition rate (resample if you want)

acqrate = 8.33 %set this here;
desired_rate = 10 %the rate you want acquisition to be

%% run the code
map = {};
map{1} = topo2pTestTif(fileName,acqrate,first_frame,last_frame);

save([fileName(1:end-4) '_map.mat'],'map')
frm = imread(fileName, 1);
imwrite(frm,[fileName(1:end-4) '_frame.tif'])

