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


stimClassToAnalyze={'all'}; timeRangePerTrialSecs=[0 Inf];
% path='\\132.239.158.183\rlab_storage\pmeier\backup\devNeuralData_090310'; %b/c i can't see datanet_storage folder on .179
% path='\\132.239.158.183\rlab_storage\pmeier\backup\neuralData_090505';
% path='C:\Documents and Settings\rlab\Desktop\neural';
path='\\132.239.158.179\datanet_storage'


spikeDetectionParams=[];
spikeDetectionParams.method='OSORT';
spikeDetectionParams.ISIviolationMS=2; % just for human reports

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
spikeSortingParams.alignParam=2; %(optional) alignParam to be passed in to osort's realigneSpikes method; only for post upsampling jitter, only used if peakAlignMethod is 1=peak; if so (1: peak is max, 2: peak is min, 3: mixed)

spikeSortingParams.distanceWeightMode=1; %(optional) mode of distance weight calculation used by osort's setDistanceWeight method, 1= weight equally; 2= weight peak more, and falloff gaussian, but check if peak center garaunteed to be 95, also its hard coded to 1 in assignToWaveform
spikeSortingParams.minClusterSize=50; %(optional) minimum number of elements in each cluster; passed in to osort's createMeanWaveforms method
spikeSortingParams.maxDistance=30; %(optional) maxDistance parameter passed in to osort's assignToWaveform method; set the thrshold for inclusion to a cluster based on MSE between waveforms, units: std [3-20]
spikeSortingParams.envelopeSize=10; %(optional) parameter passed in to osort's assignToWaveform method; additionally must fall withing mean +/- envelopeSize*std (i think at every timepoint of waveform); [0.5-3]; set large (>100) for negnigable influence
        

if 1 %use klusta
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
 spikeSortingParams.postProcessing='largestNonNoiseClusterOnly';
end

%  [spikes spikeWaveforms spikeTimestamps assignedClusters rankedClusters photoDiode]=...
%                         getSpikesFromNeuralData(neuralData(1:maxTime,3),neuralDataTimes(1:maxTime),spikeDetectionParams,spikeSortingParams);


%demo1 % 263 % [1 13] [173 191] [226 236]anethSTA  [240 250]awake [257] [309 320] [304]
%test2 [8]
%test3 [122 139] [126 130]sta [154]rep4 [157]20rep-whitebox [159]20rep-noWhitebox [164]20rep-noWhitebox [166]smallerstripes [168]moreradii

%test4 [108 115]spatial  [130-155]spatial"Binary" [157 ] [226-259]quadrant
%[296-396] [397-399]ffBinary [401 520]wakingUp [401 420]iso [489 499]awake
%[] [555 558] cell2 spatial 

%test6 realrat [66 ]
%
% rat 164 [591 648]spatial bin;  [654 680]bipartiteLoc=0.9; [692 730]bin
%131dev 
%   cell1 [132 139]
%   cell2: [184] TRF [264 320]off screen? ;[363 378] spatial sta; [382 393] small sta


%subjectID = 'demo1'; cellBoundary={'physLog',{'06.03.2009','all','last'}};
%subjectID = '131';cellBoundary={'trialRange',[7]} % TRF
%subjectID = '131';cellBoundary={'trialRange',[54 ]} % binSTA at 17 inches from screen
subjectID = '131';cellBoundary={'trialRange',[54 131]}; % binSTA at 17 inches from screen
%subjectID = '131dev3';cellBoundary={'trialRange',[6 22]}; % sparse grid [12 x 16]
subjectID = '131dev4';cellBoundary={'trialRange',[74 80]}; % sparse grid [12 x 16]
subjectID = '131dev4';cellBoundary={'trialRange',[75 ]}; % sparse grid%[12 x 16]
%subjectID = '131';cellBoundary={'trialRange',[243 350 ]}; % sparse grid%[12 x 16]
subjectID = '303';cellBoundary={'trialRange',[1 27 ]}; % all
subjectID = '303';cellBoundary={'trialRange',[7]} % sparse grid%[12 x 16]
subjectID = 'test1';cellBoundary={'trialRange',[116 Inf]} % sparse grid%[12 x 16]

subjectID = '262';cellBoundary={'trialRange',[34 41]} % ffgwn - has temporal STA
subjectID = '262';cellBoundary={'trialRange',[42 44]} % bin - has no spatial
subjectID = '262';cellBoundary={'trialRange',[54]} % bars ... failing do to ISI too small
subjectID = '262';cellBoundary={'trialRange',[70]} % gratingsSF
%subjectID = '262';cellBoundary={'trialRange',[71]} % gratingsOR
subjectID = '262';cellBoundary={'trialRange',[75 85]} % spatial binary
subjectID = '262';cellBoundary={'trialRange',[75 85]} % spatial binary
%subjectID = '262';cellBoundary={'trialRange',[95 96]} % rat closer
% subjectID = '262';cellBoundary={'trialRange',[105 108]} % ffwgn
% subjectID = '262';cellBoundary={'trialRange',[111 115 ]} % ffgwn after tuning out high freq "cell"
 subjectID = '262';cellBoundary={'trialRange',[118 123]} % spatial binary
% subjectID = '262';cellBoundary={'trialRange',[126]} % ffwgn
subjectID = '262';cellBoundary={'trialRange',[128 149]} % spatial binary
% subjectID = '262';cellBoundary={'trialRange',[157]} % flankers, the target and bottom flanker are on the screen
% subjectID = '262';cellBoundary={'trialRange',[159]} % SF
% subjectID = '262';cellBoundary={'trialRange',[172]} % flankers, 5 lambda
% subjectID = 'test1';cellBoundary={'trialRange',[145]} % test if flankers drop frames (it says they drop every one, but parens are 0) ie.  drops: high(0)
% subjectID = 'test1';cellBoundary={'trialRange',[155]} % test if flankers drop frames (it says they drop ~ every 10sec, but parens are 0) ie.  drops: 27(0)
% subjectID = 'test1';cellBoundary={'trialRange',[162]} % test if flankers drop frames (some at beginning) ie.  drops: 3(0)
subjectID = 'test1';cellBoundary={'trialRange',[167]} % test if flankers drop frames (some at beginning) ie.  drops: 3(0)
subjectID = 'test1';cellBoundary={'trialRange',[178 180]} % spatial test

subjectID = '261';cellBoundary={'trialRange',[25]} % 
subjectID = '261';cellBoundary={'trialRange',[40]} % sf
subjectID = '261';cellBoundary={'trialRange',[42]} % sparse brighter grid
subjectID = '261';cellBoundary={'trialRange',[43]} % horiz bars
%subjectID = '261';cellBoundary={'trialRange',[44]} % vert bars
%subjectID = '261';cellBoundary={'trialRange',[41]} % orient
subjectID = '261';cellBoundary={'trialRange',[54 60]} % binary localized
subjectID = '261';cellBoundary={'trialRange',[65]} % annuli ;  v1
subjectID = '261';cellBoundary={'trialRange',[118 121]} % ffgwn ; 
subjectID = '261';cellBoundary={'trialRange',[127 128]} % bars ;   move
subjectID = '261';cellBoundary={'trialRange',[132 140]} % binary ; 
subjectID = '261';cellBoundary={'trialRange',[142 143]} % binary ; 
subjectID = '261';cellBoundary={'trialRange',[155 159]} % h-bar ; 
subjectID = '261';cellBoundary={'trialRange',[160 164]} % v-bar ; 
subjectID = '261';cellBoundary={'trialRange',[166 169]} % bar ; 
subjectID = '261';cellBoundary={'trialRange',[171 177]} % bar ; 
subjectID = '261';cellBoundary={'trialRange',[181 185]} % ffgwn ;   NEXT CELL, same penetration
subjectID = '261';cellBoundary={'trialRange',[187 188]} % ffgwn ;   
subjectID = '261';cellBoundary={'trialRange',[197 200]} % ffgwn ;  
subjectID = '261';cellBoundary={'trialRange',[205]} % gratings ;   
subjectID = '261';cellBoundary={'trialRange',[228]} % sparse grid  ;   
subjectID = '261';cellBoundary={'trialRange',[243 250]} % ffgwn  ;   NEXT CELL; same penetration
subjectID = '261';cellBoundary={'trialRange',[257 259]} % binary white noise; 
subjectID = '261';cellBoundary={'trialRange',[257 261]} % binary white noise; 
subjectID = '261';cellBoundary={'trialRange',[262]} % spatial frequency gratings; 
subjectID = '261';cellBoundary={'trialRange',[271 272]} % ffgwn; 
subjectID = '261';cellBoundary={'trialRange',[288 293]} % ffgwn NEW cell
subjectID = '261';cellBoundary={'trialRange',[294]} % spat freq gratings
subjectID = '261';cellBoundary={'trialRange',[295]} % orientation
subjectID = '261';cellBoundary={'trialRange',[296]} % binary flicker
subjectID = '261';cellBoundary={'trialRange',[302 304]} % bars
subjectID = '261';cellBoundary={'trialRange',[324 332]} % [324 338?] bin grid, 3x4
%subjectID = '261';cellBoundary={'trialRange',[341 346]} % bin grid, 6x8, 347 has issues sorting
subjectID = '261';cellBoundary={'trialRange',[351 359]} % bin grid, 6x8
subjectID = '261';cellBoundary={'trialRange',[365]} % bin grid, 6x8
subjectID = '261';cellBoundary={'trialRange',[366 369]} % bars
subjectID = '261';cellBoundary={'trialRange',[370 372]} % bars
subjectID = '261';cellBoundary={'trialRange',[377 378]} % more bars, moved rat
subjectID = '261';cellBoundary={'trialRange',[380 383]} % more bars, 

subjectID = '261';cellBoundary={'trialRange',[398 404]} % ffgwn, poor sort, MUA
subjectID = '261';cellBoundary={'trialRange',[406 408]} % bin grid
subjectID = '261';cellBoundary={'trialRange',[415]} % bin grid

spikeDetectionParams.detectionMethod=3 % 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
spikeDetectionParams.extractionThreshold =9;
overwriteAll=1; % if not set, analysis wont sort spikes again, do we need?: 0=do if not there, and write, 1= do always and overwrite, 2= do always, only write if not there or user confirm?
usePhotoDiodeSpikes=0;
analysisManagerByChunk(subjectID, path, cellBoundary, spikeDetectionParams, spikeSortingParams,...
    timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes)
