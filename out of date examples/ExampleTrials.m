clear all
clear classes
close all
clc
format long g

rootPath='C:\Documents and Settings\rlab\Desktop\ratrixDemo\';
pathSep='\';

warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'classes' pathSep]))
warning('on','MATLAB:dispatcher:nameConflict')

r=ratrix([rootPath 'ServerData' pathSep],0);

ids=getSubjectIDs(r);
s=getSubjectFromID(r,ids{1});
b=getBoxIDForSubjectID(r,getID(s));
st=getStationsForBoxID(r,b);

%[s r]=setStepNum(s,1,r,'testing','edf');
%r=doTrials(st(1),r,3);

[s r]=setStepNum(s,2,r,'testing','pmm');

[p sp]=getProtocolAndStep(s);
ts=getTrainingStep(p,sp);

getMaxHeight(getStimManager(ts))
isa(getStimManager(ts),'stimManager')
isa(getStimManager(ts),'cuedGoToFeatureWithTwoFlank')

debuging=0;
if debuging
    [newSM, ...
                    updateSM, ...
                    stim, ...               
                    scaleFactor, ...
                    type, ...
                    targetPorts, ...
                    distractorPorts, ...
                    stimulusDetails, ...
                    interTrialLuminance]=...
                    calcStim(getStimManager(ts), ...
                    class(getTrialManager(ts)), ...
                    100, ...
                    [1 3], ...
                    3, ...
                    1280, ...
                    1024, ...
                    []);
    updateSM
    scaleFactor
    type
    targetPorts
    distractorPorts
    stimulusDetails
    interTrialLuminance

    for i=1:size(stim,3)
        subplot(1,3,i);
        imagesc(stim(:,:,i))
        %pause
    end
end

r=doTrials(st(1),r,5);

%[s r]=setStepNum(s,3,r,'testing','edf');
%r=doTrials(st(1),r,3);