
% numVals=256;  %(256 is full, less to test)
% stim =uint8(zeros(1,1,3,numVals));         % [height width 3 numFrames] matrix specifying indices into the CLUT background - the background RGB values, specified as indices into the CLUT
% ramp=uint8(linspace(0,255,numVals));
% stim(:,:,1,:)=ramp;
% stim(:,:,2,:)=ramp;
% stim(:,:,3,:)=ramp;
stim=[];
mode='256RGB'; %256RGB gray

patchRect= [.2 .2 .8 .8];       % - where to draw the stim on the background
interValueRGB=uint8([255, 255,255]); % - the RGB values to show between frames of stim, specified as indices into the CLUT
numFramesPerValue=uint16(500);   %300  % - how many frames to hold each frame of the stim
numInterValueFrames=uint16(100);      % - how many frames of interValueRGB to show between each set of frames in stim   
background={0.5,'fromRaw'};
methodType='stimInBoxOnBackground';
method={methodType,background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames};
cmd_line=sprintf('round1-%s-%s-%2.2f_%s-Rect[%2.2f_%2.2f_%2.2f_%2.2f]-%d-%d-%d',mode,methodType,background{1},background{2}...
    ,patchRect,unique(interValueRGB),numFramesPerValue,numInterValueFrames)
screenNum=1;  % 1 for phys rig, 0 or empty for single monitor

%%
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

[measuredValues currentCLUT linearizedCLUT validationValues details] = calibrateMonitor(stim,method,mode,screenType,fitMethod,writeToOracle,cmd_line,screenNum)


if 1 % load back in example
    [suc mac]=getMACAddress();  % now correct supported method
    %mac='0018F35DFAC0'  %old (b4 july2009) hack universal storage, b/c all calibs were being stored under a single (incorrect) testing ID
    %mac='00095B8E6171': %to view phys rig remotely
    conn=dbconn();
    x=getCalibrationData(conn,mac,[0 Inf]);
    closeConn(conn);
    
    figure; 
   
    subplot(2,2,1)
    plot(x.measuredR,'r'); hold on
    plot(x.measuredG,'g'); 
    plot(x.measuredB,'b');
    ylabel('cd^2')
    xlabel('normalized voltage')
    title('raw input-output')
    
    subplot(2,2,2)
    totalRange=sum([range(x.measuredR) range(x.measuredG) range(x.measuredB)]);
    % floorGuess=max([min(x.measuredR) min(x.measuredG) min(x.measuredB)]);  
    % the floor is not identical for each channel, b/c a mean screen of
    % that color is present, scattering light differently, so guessing is bad
    realFloor=min(x.validationValues)
    expected=linspace(realFloor,realFloor+totalRange,length(x.measuredR));
    plot(x.validationValues,'k'); hold on
    plot(expected,'m--')
    legend({'validation','expected = sum(R,G,B)'})
    title('linearized')
    xlabel('clut index')
    subplot(2,2,3)
    
    error=(expected-x.validationValues);%./expected;
    plot([0 255],[0 0],'color',[.8 .8 .8]); hold on
 plot(error,'k')
    ylim=get(gca,'ylim')
    fracError=abs(error./((expected+x.validationValues)/2))
    maxFracError=max(fracError);
    maxErrorInd=find(maxFracError==fracError);
    meanFracError=mean(fracError);
    plot(maxErrorInd,error(maxErrorInd),'r.')
    text(128,ylim(1)+range(ylim)*.8,sprintf('max frac error: %2.2g\nmean frac error: %2.2g',maxFracError,meanFracError),'HorizontalAlignment','center')
%hist(error)
ylabel('absolute error (cd^2)')
    xlabel('clut index')
    title('error')
    
    subplot(2,2,4)
    title('color stability')
    spyderVal=x.details.validationDetails.spyderData;       
    plot(spyderVal); legend({'X','Y','Z'})
    plot(spyderVal./(repmat((sum(spyderVal'))',1,3))); legend({'x','y','z'})
    %%
end
