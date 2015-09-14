close all
clear all

global vid src;
vid = videoinput('gige', 1, 'Mono8'); %create object for camera
src = getselectedsource(vid); %create video source object to adjust settings
src.FrameStartTriggerMode = 'Off'; %turn off triggering so settings are accessible
src.AcquisitionFrameRateAbs = 10; %frame rate (doesn't matter for triggering)
src.ExposureTimeAbs = 50000; %exposure time


triggerconfig(vid, 'hardware', 'DeviceSpecific', 'DeviceSpecific'); %set to trigger from hardware
vid.ROIPosition = [500 550 176 125]; %set ROI
vid.FramesPerTrigger = 1; %1 frame per trigger
vid.TriggerRepeat = Inf; %set number of times trigger can repeat
vid.LoggingMode = 'memory'; %set logging mode
src.FrameStartTriggerMode = 'On'; %turn triggering on
src.FrameStartTriggerSource = 'Line2'; %set camera source for trigger (Line 2 = TTL)

start(vid) %start the camera
preview(vid); %show preview (won't see anything until triggering starts)

stoppreview(vid); %stop preview
stop(vid); %stop camera

totalFrames = vid.FramesAvailable; %find number of frames in memory
data = squeeze(getdata(vid,totalFrames)); %put frames into variable 'data'
save('C:\Users\JLH\Documents\MATLAB\test3.mat', 'data'); %save to file

clear data vid src;