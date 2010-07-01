% this is a temporary working m-file for testing out the settings of spike sorting
% it is not meant to be called as a function; 

%% twiddle the params and sort it
close all


% path='\\132.239.158.183\rlab_storage\pmeier\backup\devNeuralData_090310'; %b/c i can't see datanet_storage folder on .179
% path='\\132.239.158.183\rlab_storage\pmeier\backup\neuralData_090505';
% path='C:\Documents and Settings\rlab\Desktop\neural';
%path='\\132.239.158.179\datanet_storage' % streaming to C:
path='H:\datanetOutput'  % local

path='\\132.239.158.179\datanetOutput'  %on the G drive remote
path='C:\Documents and Settings\rlab\My Documents\work\physiology data'  %on the G drive remote
% path='C:\Documents and Settings\rlab\My Documents\work\physiology data'  %local computer



if 1 %use filteredThresh
    spikeDetectionParams=[];
    spikeDetectionParams.method = 'filteredThresh';
    spikeDetectionParams.freqLowHi = [200 10000];
    spikeDetectionParams.threshHoldVolts = [-0.1 Inf];
    spikeDetectionParams.waveformWindowMs= 1.5;
    spikeDetectionParams.peakWindowMs= 0.6;
    spikeDetectionParams.alignMethod = 'atPeak'; %atCrossing
    spikeDetectionParams.peakAlignment = 'filtered'; % 'raw'
    spikeDetectionParams.returnedSpikes = 'filtered'; % 'raw'
else
    spikeDetectionParams=[];
    spikeDetectionParams.method='oSort';
    % spikeDetectionParams.samplingFreq=samplingRate; % don't define if using analysis manager, just for temp testing of getSpikesFromNeuralData
    % Wn = [300 4000]/(spikeDetectionParams.samplingFreq/2); % default to bandpass 300Hz - 4000Hz
    % [b,a] = butter(4,Wn); Hd=[]; Hd{1}=b; Hd{2}=a;
    spikeDetectionParams.nrNoiseTraces=0;   % what does this do for us? any effect if set to 2?
    %should be replaced with a string that collapses these two confusing categories into one value;  'maxPeak' 'minPeak' 'maxMinPeak' 'power' 'MTEO'
    % why is 3=power broken? can we fix it?
    spikeDetectionParams.peakAlignMethod=1;  % 1-> find peak, 2->none, 3->peak of power signal (broken), 4->peak of MTEO signal.
    spikeDetectionParams.alignMethod=2;  %only used if peakAlignMethod is 1=peak; if so (1: peak is max, 2: peak is min, 3: mixed)
    spikeDetectionParams.prewhiten = 0;  %will error if true, and less than 400,000 samples ~10 secs / trial; need to understand whittening with Linear Predictor Coefficients to lax requirements (help lpc)
    spikeDetectionParams.limit = 2000;
    spikeDetectionParams.detectionMethod=3; % 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
    spikeDetectionParams.kernelSize=25;
    %         spikeDetectionParams.detectionMethod=5
    %         spikeDetectionParams.scaleRanges = [0.5 1.0];
    %         spikeDetectionParams.waveletName = 'haar';
end

spikeDetectionParams.ISIviolationMS=2; % just for human reports
    
if 1 %use klusta
    spikeSortingParams=[];
    spikeSortingParams.method='KlustaKwik';
    spikeSortingParams.minClusters=4; % (optional) (default 20) min number of initial clusters - final number may be different due to splitting/deleting
    spikeSortingParams.maxClusters=8;  %%(optional) (default 30) max number of initial clusters - final number may be different due to splitting/deleting
    spikeSortingParams.nStarts=1; %     (optional) (default 1) number of starts of the algorithm for each initial cluster count
    spikeSortingParams.splitEvery=10; %  (optional) (default 50) Test to see if any clusters should be split every n steps. 0 means don't split.
    spikeSortingParams.maxPossibleClusters=10; %(optional) (default 100) Cluster splitting can produce no more than this many clusters.
    %spikeSortingParams.features={'wavePC1','peakToValley','wavePC2'};
    %spikeSortingParams.features={'spikeWidth','peakToValley','energy'};
    %spikeSortingParams.features={'energy','wavePC1','waveFFT'};
    spikeSortingParams.features={'wavePC1','peakToValley','wavePC2'};  % peak to valley prob a bad idea for multiple leads, cuz we are not sensitive to per lead facts
    spikeSortingParams.features={'wavePC123'};
    spikeSortingParams.postProcessing= 'biggestAverageAmplitudeCluster'; %'largestNonNoiseClusterOnly';
else
    spikeSortingParams=[];
    spikeSortingParams.method='oSort';
    spikeSortingParams.doPostDetectionFiltering=0; % - (optional) specify whether or not to do post-detection filtering; see postDetectionFilter. only allow if 'none' which stops realigning;  otherwise deault is same as detection params, will error if not the same as detection params, *unless* detection is 'MTEO' in which case allow 'maxPeak' 'minPeak' 'maxMinPeak' 'power' Q: why can't we call MTEO for the realligning as well?
    spikeSortingParams.peakAlignMethod=1; %(optional)    peak alignment method used by osort's realigneSpikes method;  only for post upsampling jitter, 1=peak, 2=none, 3= power;
    spikeSortingParams.alignParam=2; %(optional) alignParam to be passed in to osort's realigneSpikes method; only for post upsampling jitter, only used if peakAlignMethod is 1=peak; if so (1: peak is max, 2: peak is min, 3: mixed)
    spikeSortingParams.distanceWeightMode=1; %(optional) mode of distance weight calculation used by osort's setDistanceWeight method, 1= weight equally; 2= weight peak more, and falloff gaussian, but check if peak center garaunteed to be 95, also its hard coded to 1 in assignToWaveform
    spikeSortingParams.minClusterSize=50; %(optional) minimum number of elements in each cluster; passed in to osort's createMeanWaveforms method
    spikeSortingParams.maxDistance=30; %(optional) maxDistance parameter passed in to osort's assignToWaveform method; set the thrshold for inclusion to a cluster based on MSE between waveforms, units: std [3-20]
    spikeSortingParams.envelopeSize=10; %(optional) parameter passed in to osort's assignToWaveform method; additionally must fall withing mean +/- envelopeSize*std (i think at every timepoint of waveform); [0.5-3]; set large (>100) for negnigable influence
end

frameThresholds.dropsAcceptableFirstNFrames=2; % first 2 frames won't kill the default quality test
frameThresholds.dropBound = 1.5;   %smallest fractional length of ifi that will cause the long tail to be called a drop(s)
frameThresholds.warningBound = 0.1; %fractional difference that will cause a warning, (after drop adjusting)
frameThresholds.errorBound = 0.6;   %fractional difference of ifi that will cause an error (after drop adjusting)
% this largish value of .6 allows really short frames after drops to not cause errors.  the other way around this is to crank up the drop bound beyond 1.5 but I think thats too dangerous


% %LGN - 16 ch - 
% subjectID = '356'; channels={[2:6 9:11]}; thrV=[-0.02 Inf]; cellBoundary={'trialRange',[8]};%ffgwn- LGN
% %subjectID = '356'; channels={[11 10 2 3]}; thrV=[-0.02 Inf]; cellBoundary={'trialRange',[110]};%ffgwn- LGN
% subjectID = '356'; channels={[4 11]}; thrV=[-0.06 Inf]; cellBoundary={'trialRange',[110]};%ffgwn- LGN
% subjectID = '356'; channels={[11 4]}; thrV=[-0.09 Inf]; cellBoundary={'trialRange',[110 118]};%ffgwn- LGN - no temporal STA on these chans (but phys 12 & 15?)
% subjectID = '356'; channels={[8]}; thrV=[-0.09 Inf]; cellBoundary={'trialRange',[110]};%guess 8 is 15? - gets the monitor intensity, 0 lag
% subjectID = '356'; channels={[6]}; thrV=[-0.03 Inf]; cellBoundary={'trialRange',[110 118]};%chart says 6 is 15, this has an STA! yay!
% 
% %3 cells - these leads may or may not have the same cells on them, given their spacing of 50um
% subjectID = '356'; channels={[2:6]}; thrV=[-0.03 Inf]; cellBoundary={'trialRange',[345 354]};%3 cells, gwn
% subjectID = '356'; channels={[2 9:11]}; thrV=[-0.03 Inf]; cellBoundary={'trialRange',[345 354]};%3 cells, gwn
% %subjectID = '356'; channels={[2:6]}; thrV=[-0.03 Inf]; cellBoundary={'trialRange',[377 380]};%3 cells
% subjectID = '356'; channels={[2 9:11]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[345]};%3 cells, gwn
% %LONG PAUSE, but same 3 cells/ location
% subjectID = '356'; channels={[2]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[397 401]};%3 cells, gwn
subjectID = '356'; channels={[2]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[397]};%3 cells, gwn
% subjectID = '356'; channels={[10]}; thrV=[-0.06 Inf]; cellBoundary={'trialRange',[397 403]};
% %subjectID = '356'; channels={[9]}; thrV=[-0.07 Inf]; cellBoundary={'trialRange',[397 403]};
% %subjectID = '356'; channels={[6]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[397 403]}; % has different temporal shape
% %subjectID = '356'; channels={[2]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[432]}; %
% subjectID = '356'; channels={[10]}; thrV=[-0.06 Inf]; cellBoundary={'trialRange',[432 444]}; % has spatial, upper right
% subjectID = '356'; channels={[6]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[432 444]};  % has a different spatial!
% subjectID = '356'; channels={[9]}; thrV=[-0.06 Inf]; cellBoundary={'trialRange',[432 442]};  % this is a bit weaker, same lower center location
% subjectID = '356'; channels={[6]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[377 380]}; %3 cells, stronger response to lower contrast delayed??
% subjectID = '356'; channels={[6]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[377]}; %3 cells, stronger response to lower contrast delayed??
% subjectID = '356'; channels={[6]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[485]}; %fffc about 3 trials near here 482-485ish?
% subjectID = '356'; channels={[6]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[492 498]}; %fffc
% subjectID = '356'; channels={[10]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[492 498]}; %fffc - probably 2 cells lumped into 1 anay
% subjectID = '356'; channels={[2]}; thrV=[-0.05 Inf]; cellBoundary={'trialRange',[492 498]}; %fffc 
% subjectID = '356'; channels={[1],[2]}; thrV=[-0.06 Inf]; cellBoundary={'trialRange',[550]};
%%
spikeSortingParams.postProcessing= 'treatAllNonNoiseAsSpike'; %'treatAllAsSpike'; %'biggestAverageAmplitudeCluster';  %'largestNonNoiseClusterOnly',  
spikeDetectionParams.sampleLFP = false; %true;
spikeDetectionParams.LFPSamplingRateHz =500;
spikeSortingParams.plotSortingForTesting =false;

stimClassToAnalyze={'all'}; timeRangePerTrialSecs=[0 Inf];

switch spikeDetectionParams.method
    case 'oSort'
        spikeDetectionParams.detectionMethod=3; % 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
        spikeDetectionParams.extractionThreshold =4
    case 'filteredThresh'
        spikeDetectionParams.threshHoldVolts=thrV;
        %spikeDetectionParams.threshHoldVolts=[]; spikeDetectionParams.bottomTopCrossingRate=[2 2]
end
overwriteAll=1; % if not set, analysis wont sort spikes again, do we need?: 0=do if not there, and write, 1= do always and overwrite, 2= do always, only write if not there or user confirm?
usePhotoDiodeSpikes=0;
%spikeDetectionParams.method='activeSortingParametersThisAnalysis';  % will override this files choices with the active params for this *subject*
%spikeSortingParams.method='klustaModel';  NEED TO NOT DELETE THE MODEL FOLDER FILE>>>

%% SET THE ANALYSIS MODE HERE
analysisMode = 'overwriteAll';
% analysisMode = 'viewFirst';
% analysisMode = 'detectAndSortOnFirst'; %without user interaction
% analysisMode = 'detectAndSortOnAll'; %without user interaction
% analysisMode = 'interactiveDetectAndSortOnFirst'; %with user interaction
% analysisMode = 'interactiveDetectAndSortOnAll'; %with user interaction
% analysisMode = 'viewContinuous';
% analysisMode = 'viewLast';
% analysisMode = 'analyzeAtEnd';
% analysisMode = 'viewAnalysisOnly';

  
makeBackup = false;
analyzeBoundaryRange(subjectID, path, cellBoundary, channels,spikeDetectionParams, spikeSortingParams,...
        timeRangePerTrialSecs,stimClassToAnalyze,analysisMode,usePhotoDiodeSpikes,[],frameThresholds,makeBackup)

analyzeTrials = false;
if analyzeTrials
    analysisManagerByChunk(subjectID, path, cellBoundary, channels,spikeDetectionParams, spikeSortingParams,...
        timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes,[],frameThresholds)
    optimizeSortingByChannel(subjectID, path, cellBoundary, channels,spikeDetectionParams, spikeSortingParams, ...
        timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes)
end
%edit historicalSpikeFiddlerCalls