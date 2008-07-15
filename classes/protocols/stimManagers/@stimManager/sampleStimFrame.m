function [image details]= sampleStimFrame(stimManager,trialManagerClass)
%returns a single image from calc stim movie

%defaults
    totalPorts=[3];
    responsePorts=[3];
    width=getMaxWidth(stimManager);
    height=getMaxHeight(stimManager);
    trialRecords=[];
    %trialManagerClass = 'nAFC'
    frameRate = [];

     frame=1;
        

[t updateTM out LUT scaleFactor type targetPorts distractorPorts details] =calcStim(stimManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
image = reshape(out(:, :, frame), size(out,1), size(out,2));
