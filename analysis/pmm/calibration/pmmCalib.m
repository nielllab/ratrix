
numVals=256;  %(256 is full, less to test)
stim =uint8(zeros(1,1,3,numVals));         % [height width 3 numFrames] matrix specifying indices into the CLUT background - the background RGB values, specified as indices into the CLUT
ramp=uint8(linspace(0,255,numVals));
stim(:,:,1,:)=ramp;
stim(:,:,2,:)=ramp;
stim(:,:,3,:)=ramp;

patchRect= [.2 .2 .8 .8];       % - where to draw the stim on the background
interValueRGB=uint8([255, 255,255]); % - the RGB values to show between frames of stim, specified as indices into the CLUT
numFramesPerValue=uint16(300);   %300  % - how many frames to hold each frame of the stim
numInterValueFrames=uint16(100);      % - how many frames of interValueRGB to show between each set of frames in stim   
background={0.5,'fromRaw'};
method={'stimInBoxOnBackground',stim,background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames};
cmd_line='basic 256 gray Trinitron';
screenNum=1;  % 1 for phys rig, 0 or empty for single monitor

screenType='CRT';      % - 'LCD' or 'CRT'
fitMethod = 'linear';  % - 'linear' 'power'
writeToOracle= true; % - a flag indicating whether or not to write to oracle
%   cmd_line (optional) - the string to store into the oracle field
%   "cmd_line"
% OUTPUTS:
%   measuredValues - xyz measurements corresponding to rawValues with native gamma
%   currentCLUT - the native CLUT
%   linearizedCLUT - direct inversion normalized LUT entry (interp1 w/linear) 
%   validationValues - xyz measurements corresponding to rawValues with linearizedCLUT
%   details - stuff that might be used to do further validation (and
%   specify how we got our calibration data); to be stored in BLOB

[measuredValues currentCLUT linearizedCLUT validationValues details] = calibrateMonitor(method,screenType,fitMethod,writeToOracle,cmd_line,screenNum)