function r = setProtocolMike(r,subjIDs)
%small change

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

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

freq = 20; 
amps = [0 1];
stereoStim = stereoDiscrim(interTrialLuminance,freq,amps,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

svnRev = {'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode = 'session';

ts1 = trainingStep(nafc, stereoStim, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);

p = protocol('mike discrim',{ts1});

for i = 1:length(subjIDs),
    subj = getSubjectFromID(r,subjIDs{i});
    stepNum = uint8(1);
    [subj r] = setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
end