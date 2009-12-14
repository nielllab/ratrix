close all

useKlusta = true;

stimClassToAnalyze={'all'}; timeRangePerTrialSecs=[0 Inf];

%% spikesortingParams
spikeSortingParams=[];
spikeSortingParams.method='oSort';
spikeSortingParams.doPostDetectionFiltering=0; % - (optional) specify whether or not to do post-detection filtering; see postDetectionFilter.m
%only allow if 'none' which stops realigning;  otherwise deault is same as detection params, 
%will error if not the same as detection params, *unless* detection is 'MTEO' in which case allow 'maxPeak' 'minPeak' 'maxMinPeak' 'power'
%Q: why can't we call MTEO for the realligning as well?
spikeSortingParams.peakAlignMethod=1; %(optional)    peak alignment method used by osort's realigneSpikes method;  only for post upsampling jitter, 1=peak, 2=none, 3= power; 
spikeSortingParams.alignParam=2; %(optional) alignParam to be passed in to osort's realigneSpikes method; only for post upsampling jitter, only used if peakAlignMethod is 1=peak; if so (1: peak is max, 2: peak is min, 3: mixed)
spikeSortingParams.distanceWeightMode=1; %(optional) mode of distance weight calculation used by osort's setDistanceWeight method, 1= weight equally; 2= weight peak more, and falloff gaussian, but check if peak center garaunteed to be 95, also its hard coded to 1 in assignToWaveform
spikeSortingParams.minClusterSize=50; %(optional) minimum number of elements in each cluster; passed in to osort's createMeanWaveforms method
spikeSortingParams.maxDistance=30; %(optional) maxDistance parameter passed in to osort's assignToWaveform method; set the thrshold for inclusion to a cluster based on MSE between waveforms, units: std [3-20]
spikeSortingParams.envelopeSize=10; %(optional) parameter passed in to osort's assignToWaveform method; additionally must fall withing mean +/- envelopeSize*std (i think at every timepoint of waveform); [0.5-3]; set large (>100) for negnigable influence
spikeSortingParams=[];
spikeSortingParams.method='KlustaKwik';
spikeSortingParams.minClusters=2; % (optional) (default 20) min number of initial clusters - final number may be different due to splitting/deleting
spikeSortingParams.maxClusters=3;  %%(optional) (default 30) max number of initial clusters - final number may be different due to splitting/deleting
spikeSortingParams.nStarts=1; %     (optional) (default 1) number of starts of the algorithm for each initial cluster count
spikeSortingParams.splitEvery=50; %  (optional) (default 50) Test to see if any clusters should be split every n steps. 0 means don't split.
spikeSortingParams.maxPossibleClusters=4; %(optional) (default 100) Cluster splitting can produce no more than this many clusters.
spikeSortingParams.features={'wavePC123'}; 
%spikeSortingParams.features={'wavePC1','peakToValley','wavePC2'}; 
%spikeSortingParams.features={'spikeWidth','peakToValley','energy'};
%spikeSortingParams.features={'energy','wavePC1','waveFFT'}; 
spikeSortingParams.features={'wavePC1','peakToValley','wavePC2'};
spikeSortingParams.postProcessing='largestNonNoiseClusterOnly';
spikeSortingParams.plotSortingForTesting = false; 

%% spikeDetectionParams
spikeDetectionParams=[];
spikeDetectionParams.method='OSORT';
spikeDetectionParams.ISIviolationMS=2; % just for human reports
spikeDetectionParams.nrNoiseTraces=0;   % what does this do for us? any effect if set to 2?

spikeDetectionParams.peakAlignMethod=1;  % 1-> find peak, 2->none, 3->peak of power signal (broken), 4->peak of MTEO signal.
spikeDetectionParams.alignMethod=2;  %only used if peakAlignMethod is 1=peak; if so (1: peak is max, 2: peak is min, 3: mixed)

spikeDetectionParams.prewhiten = 0;  %will error if true, and less than 400,000 samples ~10 secs / trial; need to understand whittening with Linear Predictor Coefficients to lax requirements (help lpc)
spikeDetectionParams.limit = 2000;
spikeDetectionParams.detectionMethod=3 % 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
spikeDetectionParams.kernelSize=25;
%         spikeDetectionParams.detectionMethod=5
%         spikeDetectionParams.scaleRanges = [0.5 1.0];
%         spikeDetectionParams.waveletName = 'haar';


spikeDetectionParams.detectionMethod=3; % 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
spikeDetectionParams.extractionThreshold =6;
spikeDetectionParams.sampleLFP = true; %false; %
spikeDetectionParams.LFPSamplingRateHz =500;
spikeDetectionParams.LFPBandPass = [1 30];

%% plottingParams
% This section determines what to plot and what not to plot
plottingParams.showSpikeAnalysis = false;
plottingParams.showLFPAnalysis = true;
plottingParams.plotSortingForTesting = false; % change this if no need for seeing how good the sort is

overwriteAll=1; % if not set, analysis wont sort spikes again, do we need?: 0=do if not there, and write, 1= do always and overwrite, 2= do always, only write if not there or user confirm?
usePhotoDiodeSpikes=0;
%spikeDetectionParams.method='activeSortingParametersThisAnalysis';  % will override this files choices with the active params for this *subject*
%spikeSortingParams.method='activeSortingParametersThisAnalysis';



