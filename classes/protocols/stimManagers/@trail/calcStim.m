function [stimulus updateSM resolutionIndex preRequestStim preResponseStim discrimStim LUT targetPorts distractorPorts ...
    details interTrialLuminance text indexPulses imagingTasks sounds] = ...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)

sounds = {};
indexPulses=[];
imagingTasks=[];

LUT=makeStandardLUT(LUTbits);
updateSM=true;

if IsLinux
    depth=24;
end
if ismac
    depth=32;
    if false %this was for trying to record stim in real time, screws up my grey?
    depth=16; % if use 8, screen('openwindow') says it can't open at pixelSize 8, but it can do 16 at pixelSize 8 !??!
    end
end
if IsWin
    depth=32;
    % if use lower:
    % PTB-ERROR: Your display screen 0 is not running at the required color depth of at least 30 bit.
    % PTB-ERROR: This will not work on Microsoft Windows operating systems.
end

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],depth,getMaxWidth(stimulus),getMaxHeight(stimulus));%,true);
if hz==0 %osx
    hz=60;
end

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

stimulus.initialPos=[width height]'/2;
details.nFrames = ceil(stimulus.timeoutSecs*hz);
details.target = stimulus.targetDistance(1)*details.target;

stimulus.mouseIndices=[];
if IsLinux
    [a,b,c]=GetMouseIndices; % http://tech.groups.yahoo.com/group/psychtoolbox/message/13259
    
    for i = 1:length(c) % any way to reliably determine which mouse is which?  ie, who is plugged in to which port?  locationID/interfaceID?
        if isempty(strfind(c{i}.product,'Virtual')) && ~isempty(strfind(c{i}.product,'USB Optical Mouse')) && ~isempty(strfind(c{i}.usageName,'slave pointer'))
            stimulus.mouseIndices = [stimulus.mouseIndices c{i}.index];
            c{i}.locationID
            c{i}.interfaceID
            %check for expected mfg and resolution too
        end
    end
    
    if length(stimulus.mouseIndices) ~= 2
        error('didn''t find exactly 2 mice on linux')
    end
end

dims=[height width]./scaleFactor;

if isa(stimulus.stim,'stimManager')
    if details.target > 0
        subTargetPorts = max(responsePorts);
        subDistractorPorts = min(responsePorts);
    else
        subTargetPorts = min(responsePorts);
        subDistractorPorts = max(responsePorts);
    end

    [~, ~, ~, ~, ~, out.stim, ~, ~, ~, details.subDetails, ~, subText, ~, subImagingTasks, ~] = ...
        calcStim(stimulus.stim,'subTrail',allowRepeats,resolutions(resolutionIndex),displaySize,LUTbits,responsePorts,totalPorts,trialRecords,subTargetPorts,subDistractorPorts,details,text);
end

if true
    type='expert';
    out.height=dims(1);
    out.width=dims(2);
else
    type='dynamic'
    out=zeros(dims); %destrect is set to stretch this to the screen, so dynamic generated stims should be the same size
end

discrimStim=[];
discrimStim.stimulus=out;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;

preRequestStim=discrimStim;
% preRequestStim=[];
% preRequestStim.stimulus=interTrialLuminance;
% preRequestStim.stimType='loop';
% preRequestStim.scaleFactor=0;
% preRequestStim.startFrame=0;
preRequestStim.punishResponses=false;

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;
end