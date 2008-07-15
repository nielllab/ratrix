function out = miniCalcStim(s, numStims)

if ~exist ('numStims', 'var')
    numStims =1
end

s=s;
%trialManagerClass=class(trialManager);
trialManagerClass='nAFC';
frameRate=-99;
responsePorts=[1 3];
totalPorts=3;
width=1024;
height=768; 
trialRecords= [];
%this should update, add:
%trialPhase='discriminandum'

for i=1:numStims
    [s updateTM stimStruct LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(s,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
    size(stimStruct)
    im=stimStruct(:,:,1); %In toggle mode, frequently the second frame is the main stim frame, but for some reason the first frame works - pmm 07/10/06
    imagesc (im);   
    figure (1)
    pause(1) 
    
    %imagesc(reshape(stim(:,:,1),768,1024));
    %saveas(gcf, 'output', 'jpg')
end

out = stimStruct;