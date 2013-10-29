function testStimOGL(trialManager) %laboratory for finding and fixing framedrops - call like testStimOGL(trialManager)

%any of the following will cause frame drops (just on entering new code blocks) on the first subsequent run, but not runs thereafter:
%clear java, clear classes, clear all, clear mex (NOT clear Screen)
%each of these causes the code to be reinterpreted
%note that this is what setupenvironment does!
%mlock protects a file from all of these except clear classes (and sometimes clear functions?) -- but you have to unlock it to read in changes!

%setupEnvironment
clear Screen
clc

try
    [stimManager trialManager station] = setupObjects();

    station=startPTB(station);

    resolutions=getResolutions(station);

    [trialManager.soundMgr garbage]=cacheSounds(trialManager.soundMgr,station);

    [stimManager, ...
        garbage, ...
        resInd, ...
        stim, ...
        LUT, ...
        scaleFactor, ...
        type, ...
        targetPorts, ...
        distractorPorts, ...
        garbage, ...
        interTrialLuminance, ...
        text]= ...
        calcStim(stimManager, ...
        class(trialManager), ...
        resolutions, ...
        getDisplaySize(station), ...
        getLUTbits(station), ...
        getResponsePorts(trialManager,getNumPorts(station)), ...
        getNumPorts(station), ...
        []);

    [station garbage]=setResolution(station,resolutions(resInd));

    stimOGL( ...
        trialManager, ...
        stim, ...
        [], ...
        LUT, ...
        type, ...
        scaleFactor, ...
        union(targetPorts, distractorPorts), ...
        getRequestPorts(trialManager, getNumPorts(station)), ...
        interTrialLuminance, ...
        station, ...
        0, ...
        1, ...
        .1, ... % 10% should be ~1 ms of acceptable frametime error
        0,text,[],'dummy',class(stimManager),'dummyProtocol(1m:1a) step:1/1','session:1 trial:1 (1)',trialManager.eyeTracker,0);

    station=stopPTB(station);
catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    Screen('CloseAll');
    Priority(0);
    ShowCursor(0);
    ListenChar(0);
    clear Screen
end

function [stimManager trialManager station] = setupObjects()
station=makeDummyStation();

sm=makeStandardSoundManager();

rewardSizeULorMS        =50;
msPenalty               =1000;
fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
msAirpuff=msPenalty;

constantRewards=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

msFlushDuration         =1000;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;

requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

trialManager=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,constantRewards);

d=2; %decrease to broaden
gran=100;
x=linspace(-d,d,gran);
[a b]=meshgrid(x);

ports=cellfun(@uint8,{1 3},'UniformOutput',false);
[noiseSpec(1:length(ports)).port]=deal(ports{:});

[noiseSpec.distribution]         =deal('gaussian');
[noiseSpec.origHz]               =deal(0);
[noiseSpec.contrast]             =deal(pickContrast(.5,.01));
[noiseSpec.startFrame]           =deal('randomize');
[noiseSpec.loopDuration]         =deal(1);
[noiseSpec.locationDistribution]=deal(reshape(mvnpdf([a(:) b(:)],[-d/2 d/2]),gran,gran),reshape(mvnpdf([a(:) b(:)],[d/2 d/2]),gran,gran));
[noiseSpec.maskRadius]           =deal(.045);
[noiseSpec.patchDims]            =deal(uint16([50 50]));
[noiseSpec.patchHeight]          =deal(.4);
[noiseSpec.patchWidth]           =deal(.4);
[noiseSpec.background]           =deal(.5);
[noiseSpec.orientation]         =deal(-pi/4,pi/4);
[noiseSpec.kernelSize]           =deal(.5);
[noiseSpec.kernelDuration]       =deal(.2);
[noiseSpec.ratio]                =deal(1/3);
[noiseSpec.filterStrength]       =deal(1);
[noiseSpec.bound]                =deal(.99);

maxWidth               = 1920; %osx has timing problems at 800x600 (red flash at open window)
maxHeight              = 1200;
scaleFactor            = 0;
interTrialLuminance     =.5;

stimManager=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

function st=makeDummyStation()
stationSpec.id                                = '1U';
if ismac
    stationSpec.path                              = '/Users/eflister/Desktop/dummyStation';
else
    stationSpec.path                              = 'C:\Documents and Settings\rlab\Desktop\dummyStation';
end
stationSpec.MACaddress                        = '000000000000';
stationSpec.physicalLocation                  = uint8([1 1 1]);
% stationSpec.screenNum                         = uint8(max(Screen('Screens')));
stationSpec.soundOn                           = true;
% stationSpec.rewardMethod                      = 'localTimed';
% stationSpec.portSpec.parallelPortAddress      = '0378';
% stationSpec.portSpec.valveSpec                = int8([4,3,2]);
% stationSpec.portSpec.sensorPins               = int8([13,10,12]);
% stationSpec.portSpec.framePulsePins           = int8(9);
% stationSpec.portSpec.eyePuffPins              = int8(6);
%
% if ismac
%     stationSpec.portSpec = int8(3);
% elseif ispc
%     %do nothing
% else
%     error('unknown OS')
% end
%st=station(stationSpec);
st=makeDefaultStation(stationSpec.id,stationSpec.path,stationSpec.MACaddress,stationSpec.physicalLocation,[],[],[],stationSpec.soundOn);