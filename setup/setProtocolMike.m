function r = setProtocolMike(r,subjIDs)
%small change

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeIntensityDiscrimSoundManager();

rewardSizeULorMS          = 80;
requestRewardSizeULorMS   = 0;
msPenalty                 = 1000;
requestMode               = 'first';
fractionOpenTimeSoundIsOn = 1;
fractionPenaltySoundIsOn  = 1;
scalar                    = 1;
msAirpuff                 = msPenalty;

eyeController = [];
dropFrames = false;

percentCorrectionTrials = .5;

noRequest = constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
nafc = nAFC(sm,percentCorrectionTrials,noRequest,eyeController,{'off'},dropFrames,'ptb','center');

maxWidth = 1920;
maxHeight = 1080;
scaleFactor = 0;

interTrialLuminance = .5;

% soundType='allOctaves';
soundType='uniformWhiteNoise';
soundParams.freq = [];
soundParams.duration=50; %ms
%soundParams.amps = [0 1]; %for stereoDiscrim (left or right)
maxSPL=80; %measured max level attainable by speakers
ampsdB=40:5:maxSPL; %requested amps in dB
amplitudes=10.^((ampsdB -maxSPL)/20); %amplitudes = line level, 0 to 1
soundParams.amps = amplitudes; %for intensityDisrim
discrimBoundarydB=mean(ampsdB);
discrimBoundary=10.^((discrimBoundarydB -maxSPL)/20);
soundParams.discrimBoundary=discrimBoundary; %classification boundary for use by calcStim
soundParams.discrimSide=1; %boolean. if true, stimuli < classification boundary go to left


% soundParams.duration=100;
% stereoStim = stereoDiscrim(interTrialLuminance,freq,amps,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
stereoStim = stereoDiscrim(interTrialLuminance,soundType,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

svnRev = {'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode = 'session';

ts1 = trainingStep(nafc, stereoStim, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);

p = protocol('mike discrim',{ts1});

for i = 1:length(subjIDs),
    subj = getSubjectFromID(r,subjIDs{i});
    stepNum = uint8(1);
    [subj r] = setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
end