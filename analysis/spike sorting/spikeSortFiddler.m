% this is a temporary working m-file for testing out the settings of spike sorting
% it is not meant to be called as a function; 

%% first get a file to work with
%loc='\\132.239.158.179\datanet_storage\demo1\neuralRecords\neuralRecords_33-20090122T175736.mat'
% loc='\\132.239.158.179\datanet_storage\demo1\neuralRecords\neuralRecords_261-20090205T173104.mat' %longer
% loc='\\132.239.158.179\datanet_storage\demo1\neuralRecords\neuralRecords_256-20090205T171510.mat' %long
% loc='\\132.239.158.179\datanet_storage\demo1\neuralRecords\neuralRecords_253-20090205T170914.mat'; % short
%loc='\\132.239.158.179\datanet_storage\demo1\neuralRecords\neuralRecords_255-20090205T171323.mat'; %med
% load(loc)
% maxTime=400000; %just for testing, its faster if we process less.
% maxTime=size(neuralData,1)

%% twiddle the params and sort it
close all

spikeDetectionParams=[];
spikeDetectionParams.method='OSORT';
spikeDetectionParams.ISIviolationMS=2; % just for human reports

% spikeDetectionParams.samplingFreq=samplingRate; % don't define if using analysis manager, just for temp testing of getSpikesFromNeuralData
% Wn = [300 4000]/(spikeDetectionParams.samplingFreq/2); % default to bandpass 300Hz - 4000Hz
% [b,a] = butter(4,Wn); Hd=[]; Hd{1}=b; Hd{2}=a;      
spikeDetectionParams.nrNoiseTraces=0;   % what does this do for us? any effect if set to 2?
spikeDetectionParams.extractionThreshold =8;
%should be replaced with a string that collapses these two confusing categories into one value;  'maxPeak' 'minPeak' 'maxMinPeak' 'power' 'MTEO'
% why is 3=power broken? can we fix it?
spikeDetectionParams.peakAlignMethod=1;  % 1-> find peak, 2->none, 3->peak of power signal (broken), 4->peak of MTEO signal.
spikeDetectionParams.alignMethod=2;  %only used if peakAlignMethod is 1=peak; if so (1: peak is max, 2: peak is min, 3: mixed)

spikeDetectionParams.prewhiten = 0;  %will error if true, and less than 400,000 samples ~10 secs / trial; need to understand whittening with Linear Predictor Coefficients to lax requirements (help lpc)
spikeDetectionParams.limit = 2000;
spikeDetectionParams.detectionMethod=3 % 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
spikeDetectionParams.kernelSize=25;
%         spikeDetectionParams.detectionMethod=5
%         spikeDetectionParams.scaleRanges = [0.5 1.0];
%         spikeDetectionParams.waveletName = 'haar';


spikeSortingParams=[];
spikeSortingParams.method='oSort';
spikeSortingParams.doPostDetectionFiltering=0; % - (optional) specify whether or not to do post-detection filtering; see postDetectionFilter.m
%only allow if 'none' which stops realigning;  otherwise deault is same as detection params, 
%will error if not the same as detection params, *unless* detection is 'MTEO' in which case allow 'maxPeak' 'minPeak' 'maxMinPeak' 'power'
%Q: why can't we call MTEO for the realligning as well?
spikeSortingParams.peakAlignMethod=1; %(optional)    peak alignment method used by osort's realigneSpikes method;  only for post upsampling jitter, 1=peak, 2=none, 3= power; 
spikeSortingParams.alignParam=3; %(optional) alignParam to be passed in to osort's realigneSpikes method; only for post upsampling jitter, only used if peakAlignMethod is 1=peak; if so (1: peak is max, 2: peak is min, 3: mixed)

spikeSortingParams.distanceWeightMode=1; %(optional) mode of distance weight calculation used by osort's setDistanceWeight method, 1= weight equally; 2= weight peak more, and falloff gaussian, but check if peak center garaunteed to be 95, also its hard coded to 1 in assignToWaveform
spikeSortingParams.minClusterSize=50; %(optional) minimum number of elements in each cluster; passed in to osort's createMeanWaveforms method
spikeSortingParams.maxDistance=30; %(optional) maxDistance parameter passed in to osort's assignToWaveform method; set the thrshold for inclusion to a cluster based on MSE between waveforms, units: std [3-20]
spikeSortingParams.envelopeSize=10; %(optional) parameter passed in to osort's assignToWaveform method; additionally must fall withing mean +/- envelopeSize*std (i think at every timepoint of waveform); [0.5-3]; set large (>100) for negnigable influence
        

if 1 %try klusta
spikeSortingParams=[];
spikeSortingParams.method='KlustaKwik';
spikeSortingParams.minClusters=20; % (optional) (default 20) min number of initial clusters - final number may be different due to splitting/deleting
spikeSortingParams.maxClusters=30;  %%(optional) (default 30) max number of initial clusters - final number may be different due to splitting/deleting
spikeSortingParams.nStarts=1; %     (optional) (default 1) number of starts of the algorithm for each initial cluster count
spikeSortingParams.splitEvery=50; %  (optional) (default 50) Test to see if any clusters should be split every n steps. 0 means don't split.
spikeSortingParams.maxPossibleClusters=30; %(optional) (default 100) Cluster splitting can produce no more than this many clusters.
spikeSortingParams.features={'wavePC123'}; 
%spikeSortingParams.features={'wavePC1','peakToValley','wavePC2'}; 
%spikeSortingParams.features={'spikeWidth','peakToValley','energy'};
%spikeSortingParams.features={'energy','wavePC1','waveFFT'}; 
 spikeSortingParams.postProcessing='largestNonNoiseClusterOnly';
end

%  [spikes spikeWaveforms spikeTimestamps assignedClusters rankedClusters photoDiode]=...
%                         getSpikesFromNeuralData(neuralData(1:maxTime,3),neuralDataTimes(1:maxTime),spikeDetectionParams,spikeSortingParams);



% CANT USE analysisManager yet on white noise b/c trials keep failing the

% quality test // dropped frames adjustmented
overwriteAll=1; % if not set, analysis wont sort spikes again, do we need?: 0=do if not there, and write, 1= do always and overwrite, 2= do always, only write if not there or user confirm?
classesAnalyzed=[];%{'filteredNoise'};
%demo1 % 263 % [1 13] [173 191] [226 236]anethSTA  [240 250]awake [257] [309 320] [304]
%test2 [8]
%test3 [122 139] [126 130]sta [154]rep4 [157]20rep-whitebox [159]20rep-noWhitebox [164]20rep-noWhitebox [166]smallerstripes [168]moreradii

%test4 [108 115]spatial  [130-155]spatial"Binary" [157 ] [226-259]quadrant
%[296-396] [397-399]ffBinary [401 520]wakingUp [401 420]iso [489 499]awake
%[] [555 558] cell2 spatial 

%test6 realrat [66 ]
%
% rat 164 [591 648]spatial bin;  [654 680]bipartiteLoc=0.9; [692 730]bin
% trialRange=[238 ]; %test [44]
% path='\\132.239.158.183\rlab_storage\pmeier\backup\devNeuralData_090310'; %b/c i can't see datanet_storage folder on .179
% backupPath='C:\Documents and Settings\rlab\Desktop\neural';
cellBoundary={'physLog','05.14.2009','all','last'};
path=getRatrixPath
usePhotoDiodeSpikes=0;
subjectID = 'fan_demo1'; % demo1 test
stimClassToAnalyze='all';
analysisManagerByChunk(subjectID, path, cellBoundary, spikeDetectionParams, spikeSortingParams,...
    timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes)