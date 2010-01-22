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
path='H:\datanetOutput'

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
spikeSortingParams.minClusters=4; % (optional) (default 20) min number of initial clusters - final number may be different due to splitting/deleting
spikeSortingParams.maxClusters=8;  %%(optional) (default 30) max number of initial clusters - final number may be different due to splitting/deleting
spikeSortingParams.nStarts=4; %     (optional) (default 1) number of starts of the algorithm for each initial cluster count
spikeSortingParams.splitEvery=10; %  (optional) (default 50) Test to see if any clusters should be split every n steps. 0 means don't split.
spikeSortingParams.maxPossibleClusters=10; %(optional) (default 100) Cluster splitting can produce no more than this many clusters.
spikeSortingParams.features={'wavePC123'}; 
%spikeSortingParams.features={'wavePC1','peakToValley','wavePC2'}; 
%spikeSortingParams.features={'spikeWidth','peakToValley','energy'};
%spikeSortingParams.features={'energy','wavePC1','waveFFT'}; 
spikeSortingParams.features={'wavePC1','peakToValley','wavePC2'};
spikeSortingParams.postProcessing= 'biggestAverageAmplitudeCluster'; %'largestNonNoiseClusterOnly';
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
%subjectID = '131';cellBoundary={'trialRange',[7]}; % TRF
%subjectID = '131';cellBoundary={'trialRange',[54 ]}; % binSTA at 17 inches from screen
subjectID = '131';cellBoundary={'trialRange',[54 131]}; % binSTA at 17 inches from screen
%subjectID = '131dev3';cellBoundary={'trialRange',[6 22]}; % sparse grid [12 x 16]
subjectID = '131dev4';cellBoundary={'trialRange',[74 80]}; % sparse grid [12 x 16]
subjectID = '131dev4';cellBoundary={'trialRange',[75 ]}; % sparse grid%[12 x 16]
%subjectID = '131';cellBoundary={'trialRange',[243 350 ]}; % sparse grid%[12 x 16]
subjectID = '303';cellBoundary={'trialRange',[1 27 ]}; % all
subjectID = '303';cellBoundary={'trialRange',[7]}; % sparse grid%[12 x 16]
subjectID = 'test1';cellBoundary={'trialRange',[116 Inf]}; % sparse grid%[12 x 16]

subjectID = '262';cellBoundary={'trialRange',[34 41]}; % ffgwn - has temporal STA
subjectID = '262';cellBoundary={'trialRange',[42 44]}; % bin - has no spatial
subjectID = '262';cellBoundary={'trialRange',[54]}; % bars ... failing do to ISI too small
subjectID = '262';cellBoundary={'trialRange',[70]}; % gratingsSF
%subjectID = '262';cellBoundary={'trialRange',[71]} % gratingsOR
subjectID = '262';cellBoundary={'trialRange',[75 85]}; % spatial binary
subjectID = '262';cellBoundary={'trialRange',[75 85]}; % spatial binary
%subjectID = '262';cellBoundary={'trialRange',[95 96]}; % rat closer
% subjectID = '262';cellBoundary={'trialRange',[105 108]}; % ffwgn
% subjectID = '262';cellBoundary={'trialRange',[111 115 ]}; % ffgwn after tuning out high freq "cell"
 subjectID = '262';cellBoundary={'trialRange',[118 123]}; % spatial binary
% subjectID = '262';cellBoundary={'trialRange',[126]} % ffwgn
subjectID = '262';cellBoundary={'trialRange',[128 149]}; % spatial binary
% subjectID = '262';cellBoundary={'trialRange',[157]}; % flankers, the target and bottom flanker are on the screen
% subjectID = '262';cellBoundary={'trialRange',[159]}; % SF
 subjectID = '262';cellBoundary={'trialRange',[172]}; % flankers, 5 lambda
% subjectID = 'test1';cellBoundary={'trialRange',[145]}; % test if flankers drop frames (it says they drop every one, but parens are 0) ie.  drops: high(0)
% subjectID = 'test1';cellBoundary={'trialRange',[155]}; % test if flankers drop frames (it says they drop ~ every 10sec, but parens are 0) ie.  drops: 27(0)
% subjectID = 'test1';cellBoundary={'trialRange',[162]}; % test if flankers drop frames (some at beginning) ie.  drops: 3(0)% subjectID = 'test1';cellBoundary={'trialRange',[167]}; % test if flankers drop frames (some at beginning) ie.  drops: 3(0)
% subjectID = 'test1';cellBoundary={'trialRange',[178 180]}; % spatial test

% subjectID = '261';cellBoundary={'trialRange',[25]}; % 
% subjectID = '261';cellBoundary={'trialRange',[40]}; % sf
% subjectID = '261';cellBoundary={'trialRange',[42]}; % sparse brighter grid
% subjectID = '261';cellBoundary={'trialRange',[43]}; % horiz bars
% subjectID = '261';cellBoundary={'trialRange',[44]}; % vert bars
% subjectID = '261';cellBoundary={'trialRange',[41]}; % orient
% subjectID = '261';cellBoundary={'trialRange',[54 60]}; % binary localized
% subjectID = '261';cellBoundary={'trialRange',[65]}; % annuli ;  v1
 subjectID = '261';cellBoundary={'trialRange',[118 121]}; % ffgwn ; 
% subjectID = '261';cellBoundary={'trialRange',[127 128]}; % bars ;   move
% subjectID = '261';cellBoundary={'trialRange',[132 140]}; % binary ; 
% subjectID = '261';cellBoundary={'trialRange',[142 143]} % binary ; 
% subjectID = '261';cellBoundary={'trialRange',[155 159]} % h-bar ; 
% subjectID = '261';cellBoundary={'trialRange',[160 164]} % v-bar ; 
% subjectID = '261';cellBoundary={'trialRange',[166 169]} % bar ; 
% subjectID = '261';cellBoundary={'trialRange',[171 177]} % bar ; 
% subjectID = '261';cellBoundary={'trialRange',[181 185]} % ffgwn ;   NEXT CELL, same penetration
% subjectID = '261';cellBoundary={'trialRange',[187 188]}; % ffgwn ;   
% subjectID = '261';cellBoundary={'trialRange',[197 200]}; % ffgwn ;  
% subjectID = '261';cellBoundary={'trialRange',[205]}; % gratings ;   
% subjectID = '261';cellBoundary={'trialRange',[228]}; % sparse grid  ;   
% subjectID = '261';cellBoundary={'trialRange',[243 250]}; % ffgwn  ;   NEXT CELL; same penetration
% subjectID = '261';cellBoundary={'trialRange',[257 259]}; % binary white noise; 
% subjectID = '261';cellBoundary={'trialRange',[257 261]}; % binary white noise; 
% subjectID = '261';cellBoundary={'trialRange',[262]}; % spatial frequency gratings; 
% subjectID = '261';cellBoundary={'trialRange',[271 272]}; % ffgwn; 
% subjectID = '261';cellBoundary={'trialRange',[288 293]}; % ffgwn NEW cell
% subjectID = '261';cellBoundary={'trialRange',[294]}; % spat freq gratings
% subjectID = '261';cellBoundary={'trialRange',[295]}; % orientation
% subjectID = '261';cellBoundary={'trialRange',[296]}; % binary flicker
% subjectID = '261';cellBoundary={'trialRange',[302 304]}; % bars
% subjectID = '261';cellBoundary={'trialRange',[324 332]}; % [324 338?] bin grid, 3x4
% %subjectID = '261';cellBoundary={'trialRange',[341 346]}; % bin grid, 6x8, 347 has issues sorting
% subjectID = '261';cellBoundary={'trialRange',[351 359]}; % bin grid, 6x8
% subjectID = '261';cellBoundary={'trialRange',[365]}; % bin grid, 6x8
% subjectID = '261';cellBoundary={'trialRange',[366 369]}; % bars
% subjectID = '261';cellBoundary={'trialRange',[370 372]}; % bars
% subjectID = '261';cellBoundary={'trialRange',[377 378]}; % more bars, moved rat
% subjectID = '261';cellBoundary={'trialRange',[380 383]}; % more bars, 

% subjectID = '261';cellBoundary={'trialRange',[398 404]} % ffgwn, poor sort, MUA
% subjectID = '261';cellBoundary={'trialRange',[406 408]} % bin grid
% subjectID = '261';cellBoundary={'trialRange',[415]} % bin grid


% subjectID = '138';cellBoundary={'trialRange',[8 12]} % ffgwn
% subjectID = '138';cellBoundary={'trialRange',[13 20]} % ffgwn
% subjectID = '138';cellBoundary={'trialRange',[25 29]} % ffgwn,  new pen, new cell
% subjectID = '138';cellBoundary={'trialRange',[31]} % sf,  very broad drives it
% subjectID = '138';cellBoundary={'trialRange',[37 47]} % sf,  very broad drives it
% subjectID = '138';cellBoundary={'trialRange',[53]} % sparse bin
% subjectID = '138';cellBoundary={'trialRange',[54 58]} % bars h

%subjectID = '249';cellBoundary={'trialRange',[42]} % ffwgn
subjectID = '249';cellBoundary={'trialRange',[43 50]} % ffwgn
%subjectID = '249';cellBoundary={'trialRange',[60 70]} % ffwgn
subjectID = '249';cellBoundary={'trialRange',[78]} % gratings
subjectID = '249';cellBoundary={'trialRange',[102]} % gratings  START OF NEW CELL AROUND HERE SOMEWHERE>?
subjectID = '249';cellBoundary={'trialRange',[150 151]} % ffwgn
subjectID = '249';cellBoundary={'trialRange',[158]} % bigSlow many orientations
%subjectID = '249';cellBoundary={'trialRange',[160 166]} %binary grid
%subjectID = '249';cellBoundary={'trialRange',[168 173]} % horz
%subjectID = '249';cellBoundary={'trialRange',[174 180]} %vert
%subjectID = '249';cellBoundary={'trialRange',[181 183]} %vert
%subjectID = '249';cellBoundary={'trialRange',[187]} %spatial freq gratings
% subjectID = '249';cellBoundary={'trialRange',[196 198]} %ffgwn
% subjectID = '249';cellBoundary={'trialRange',[197 198]} %ffgwn
% subjectID = '249';cellBoundary={'trialRange',[239]} %vert  NEW CELL
% subjectID = '249';cellBoundary={'trialRange',[243 256]} %ffgwn
% subjectID = '249';cellBoundary={'trialRange',[259 264]} %bin grid
% subjectID = '249';cellBoundary={'trialRange',[296 298]} %horiz %NEW CELL, HAS SPATIAL! 
% subjectID = '249';cellBoundary={'trialRange',[299 301]} %more horiz background theta 4hz
% subjectID = '249';cellBoundary={'trialRange',[302]} %trf
% subjectID = '249';cellBoundary={'trialRange',[305 317]} %trf -  there might be more than one cell here
% subjectID = '249';cellBoundary={'trialRange',[323]} %
% subjectID = '249';cellBoundary={'trialRange',[339 356]} %bin3x4 -  very sparse now... iso?  bpm=30
% subjectID = '249';cellBoundary={'trialRange',[365 370]} %bin3x4 -  very sparse now... iso?  bpm=30
% subjectID = '249';cellBoundary={'trialRange',[376]} %bin3x4 -  very sparse now... iso?  bpm=48
% subjectID = '249';cellBoundary={'trialRange',[377]} %bin6x8 - 
% subjectID = '249';cellBoundary={'trialRange',[405]} %ffgwn 
% subjectID = '249';cellBoundary={'trialRange',[407 411]} %horiz 
% subjectID = '249';cellBoundary={'trialRange',[423]} % slow gratings
% subjectID = '249';cellBoundary={'trialRange',[429 439]} %
% subjectID = '249';cellBoundary={'trialRange',[450]} %horiz
% subjectID = '249';cellBoundary={'trialRange',[451]} %vert
subjectID = '249';cellBoundary={'trialRange',[455]} %many slow orients... responded reasonable well. 16 orients for the v1 comparison
%subjectID = '249';cellBoundary={'trialRange',[457 464]} %3x4
%subjectID = '249';cellBoundary={'trialRange',[469]} %horiz 
%subjectID = '249';cellBoundary={'trialRange',[470]} %horiz 
%subjectID = '249';cellBoundary={'trialRange',[475 477]} %3x4 
%subjectID = '249';cellBoundary={'trialRange',[482 493]} %6x8 sparse brighter 
%subjectID = '249';cellBoundary={'trialRange',[495 505]} %6 horiz - not much spatial
%subjectID = '249';cellBoundary={'trialRange',[508 521]} %6 vert - not much spatial
%subjectID = '249';cellBoundary={'trialRange',[523 533]}
%subjectID = '249';cellBoundary={'trialRange',[523 555]}

subjectID = '250';cellBoundary={'trialRange',[178 190]}
subjectID = '250';cellBoundary={'trialRange',[211 215]} %eyes start moving after this... a loll
subjectID = '250';cellBoundary={'trialRange',[223 229]}
subjectID = '250';cellBoundary={'trialRange',[238 250]} % eyes more stable again
subjectID = '250';cellBoundary={'trialRange',[238 250]} % eyes more stable again
subjectID = '250';cellBoundary={'trialRange',[389]} % +16D sf
subjectID = '250';cellBoundary={'trialRange',[388]} % -16D sf
subjectID = '250';cellBoundary={'trialRange',[391]} % -12D sf
subjectID = '250';cellBoundary={'trialRange',[392]} % -8D sf
subjectID = '250';cellBoundary={'trialRange',[393]} % -6D sf
subjectID = '250';cellBoundary={'trialRange',[394]} % -4D sf
subjectID = '250';cellBoundary={'trialRange',[395]} % -2D sf
subjectID = '250';cellBoundary={'trialRange',[396]} % -1D sf
subjectID = '250';cellBoundary={'trialRange',[414]} % +32 sf


subjectID = '250';cellBoundary={'trialRange',[420 428]} % ffgwn

subjectID = '250';cellBoundary={'trialRange',[432 465]} % ffgwn
%to get contrast, all trials were set at:
%%'useThisMonitorsUncorrectedGamma';  p.rangeOfMonitorLinearized=[0.0 1] to
subjectID = '250';cellBoundary={'trialRange',[468]} %768 ppc, no well centered, flankers worth analyzing
subjectID = '250';cellBoundary={'trialRange',[478]} %256 ppc well centered, with good annulus precending it
subjectID = '250';cellBoundary={'trialRange',[483]} % 128 ppc, well centered
subjectID = '250';cellBoundary={'trialRange',[485]} % 128 ppc, 4lambda well centered
subjectID = '250';cellBoundary={'trialRange',[489 491]} % 128 ppc, 3lambda well centered
subjectID = '250';cellBoundary={'trialRange',[489 491]} % 128 ppc, 3lambda well, gaussian ... oddly the same trial numbers reoccur (maybe cuased by force quitting the stim computer when it hung on 491 the first time around?)
subjectID = '250';cellBoundary={'trialRange',[492]} % 128 ppc, 3lambda well, gaussian ... after the overlap
subjectID = '250';cellBoundary={'trialRange',[496]} % 64 ppc, 3lambda well, gaussian
subjectID = '250';cellBoundary={'trialRange',[498]} % 32 ppc, 3lambda well, gaussian
subjectID = '250';cellBoundary={'trialRange',[501]} % 32 ppc, 3lambda well, gaussian, linearized drives it poorly
subjectID = '250';cellBoundary={'trialRange',[502]} % confirm annulus blocks
%subjectID = '250';cellBoundary={'trialRange',[507]} % target flanker contrast
%subjectID = '250';cellBoundary={'trialRange',[508]} % confirm annulus blocks

%NEW CELL 4 lido
subjectID = '250';cellBoundary={'trialRange',[531 535]} % ffgwn

% Balaji recording session
subjectID = '250';cellBoundary={'trialRange',[550 555]} % ffgwn

% NEW CELL high SNR
subjectID = '250';cellBoundary={'trialRange',[558 563]} % ffgwn

% Changed rig state
subjectID = '250';cellBoundary={'trialRange',[564 567]} % ffgwn
subjectID = '250';cellBoundary={'trialRange',[569]} % TRF
subjectID = '250';cellBoundary={'trialRange',[578 581]} % ffgwn
subjectID = '250';cellBoundary={'trialRange',[582 583]} % binary flicker drives cell well

%NEW CELL
subjectID = '250';cellBoundary={'trialRange',[592 597]} % binary flicker

subjectID = '250';cellBoundary={'trialRange',[605 606]} % binary flicker

% NEW DAY
subjectID = '138';cellBoundary={'trialRange',[138 143]} % ffgwn
subjectID = '138';cellBoundary={'trialRange',[159 164]} % bars
subjectID = '138';cellBoundary={'trialRange',[184]} % annuli... new cell, always spikes for all annuli
subjectID = '138';cellBoundary={'trialRange',[185]} % flankers... does not drive very well

subjectID = '138';cellBoundary={'trialRange',[201]} % LOCALIZED HASH, annuli
subjectID = '138';cellBoundary={'trialRange',[202 204]} % ffgwn



%V1
subjectID = '252';cellBoundary={'trialRange',[9 19]} % sparse bin 6x8
subjectID = '252';cellBoundary={'trialRange',[23 26]} % h bars  .. maybe sopmething weak
subjectID = '252';cellBoundary={'trialRange',[27 33]} % ffgwn
subjectID = '252';cellBoundary={'trialRange',[41]} % orient sine 4hz
subjectID = '252';cellBoundary={'trialRange',[43]} % orient sine 2hz
subjectID = '252';cellBoundary={'trialRange',[46]} % orient square 2hz

subjectID = '252';cellBoundary={'trialRange',[50]} % %51 mannuli
subjectID = '252';cellBoundary={'trialRange',[51]} % %51 annuli
subjectID = '252';cellBoundary={'trialRange',[53]} % flanks 2 small
%subjectID = '252';cellBoundary={'trialRange',[51]} % %56 annuli

subjectID = '252';cellBoundary={'trialRange',[56]} % an
subjectID = '252';cellBoundary={'trialRange',[57]} % flankers
subjectID = '252';cellBoundary={'trialRange',[58]} % an

subjectID = '252';cellBoundary={'trialRange',[60]} % an
subjectID = '252';cellBoundary={'trialRange',[61]} % flankersMatter random seed, 113 seconds till noise event

%MAYBE SAME CELL?
subjectID = '252';cellBoundary={'trialRange',[70 72]} % ffgwn .. maybe but very weak
subjectID = '252';cellBoundary={'trialRange',[74 79]} % h bars
subjectID = '252';cellBoundary={'trialRange',[84]} % orients
subjectID = '252';cellBoundary={'trialRange',[86]} % big slow


subjectID = '252';cellBoundary={'trialRange',[88 112]} % vert bars ... has STA in 1 bar
subjectID = '252';cellBoundary={'trialRange',[113 126]} % horiz bars


subjectID = '252';cellBoundary={'trialRange',[139]} % flankers are too small
subjectID = '252';cellBoundary={'trialRange',[140]} % an

subjectID = '252';cellBoundary={'trialRange',[144]} % flankers are okay.  sparse response.  maybe precise to onset, but not reliable.
%subjectID = '252';cellBoundary={'trialRange',[145]} % flankers are okay.  sparse response.  maybe precise to onset, but not reliable.

subjectID = '252';cellBoundary={'trialRange',[149]} % flanker contrast (found bug where orientations vary when not expected)
subjectID = '252';cellBoundary={'trialRange',[150]} % flanker contrast;  all same orient colin, ran out of memory on 9th repeat
subjectID = '252';cellBoundary={'trialRange',[151]} % an
subjectID = '252';cellBoundary={'trialRange',[152]} % flankerMatters... all parallel (didn't control fpa up till now)  WORTH ANALYZING
subjectID = '252';cellBoundary={'trialRange',[153]} % an

subjectID = '252';cellBoundary={'trialRange',[155]} % an - short
subjectID = '252';cellBoundary={'trialRange',[156]} % flankerMatters... all colin WORTH ANALYZING
subjectID = '252';cellBoundary={'trialRange',[155]} % an


%LGN
subjectID = '252';cellBoundary={'trialRange',[162 169]} % ffgwn  ... has STA
subjectID = '252';cellBoundary={'trialRange',[171]} % sf gratings square
subjectID = '252';cellBoundary={'trialRange',[174]} % sf gratings sine;  drives it weakly

subjectID = '252';cellBoundary={'trialRange',[185]} % sf gratings sine; has +28D
subjectID = '252';cellBoundary={'trialRange',[186]} % sf gratings sine; has +28D
subjectID = '252';cellBoundary={'trialRange',[187]} % sf gratings sine; nolens ; 
%dropped frames a re pretty bad around here

% NEW CELL
subjectID = '252';cellBoundary={'trialRange',[191 194]} % sf gratings sine; nolens ; 

% NEW CELL
subjectID = '252';cellBoundary={'trialRange',[199 209]} % sf gratings sine; nolens ; 
subjectID = '252';cellBoundary={'trialRange',[210]} % sf gratings sine; nolens ; 
subjectID = '252';cellBoundary={'trialRange',[212]} % sf gratings sine; HAS THE LENS
subjectID = '252';cellBoundary={'trialRange',[215]} % ann; HAS THE LENS, both flankers are on the screen
subjectID = '252';cellBoundary={'trialRange',[216]} % flankerMatter colin; HAS THE LENS, both flankers are on the screen, no eye visible
subjectID = '252';cellBoundary={'trialRange',[217]} % ann; HAS THE LENS, both flankers are on the screen

subjectID = '252';cellBoundary={'trialRange',[219]} % an;
subjectID = '252';cellBoundary={'trialRange',[220]} % flContrasts; (ran out of memory)  (2ns 220 is annuli and should be dleted)

subjectID = '252';cellBoundary={'trialRange',[221]} % an
subjectID = '252';cellBoundary={'trialRange',[222]} % flContrasts - longer mean screen gap [200 220]

subjectID = '252';cellBoundary={'trialRange',[224]} % flContrasts - longer mean screen gap [200 220]... i think there are 2 spikes.  tricky sort
%out of memory 33 chunks, 900+ seconds, 5+ repeats

subjectID = '252';cellBoundary={'trialRange',[224]} % flContrasts - longer mean screen gap [200 220]... i think there are 2 spikes.  tricky sort
% out of memory, the 2nd.. (or 3rd?) 224 is annuli, and is complete and looks good

subjectID = '252';cellBoundary={'trialRange',[225]} % flConfig - shorter mean screen gap [40 60]
subjectID = '252';cellBoundary={'trialRange',[229]} % 128 repeat of colin  (always flanks!)


subjectID = '252';cellBoundary={'trialRange',[232 234]} % 16 x12 binary (235-244 had volleys of something odd .. spiking brethaing?)
subjectID = '252';cellBoundary={'trialRange',[232 251]} % 16 x12 binary 
% tuning cell starting 253
subjectID = '252';cellBoundary={'trialRange',[245 261]}; % 16 x12 binary 

subjectID = '252';cellBoundary={'trialRange',[269 285]}; % 32 x24 binary 

subjectID = '252';cellBoundary={'trialRange',[287 317]}; % 64 x48 binary 
% REMOVED LENSES
subjectID = '252';cellBoundary={'trialRange',[320 333]}; % 6x8 binary 
subjectID = '252';cellBoundary={'trialRange',[335 350]}; % 12x16 binary 
subjectID = '252';cellBoundary={'trialRange',[399]}; % ffgwn
subjectID = '252';cellBoundary={'trialRange',[407 412]}; % 12x16 binary 

subjectID = '252';cellBoundary={'trialRange',[425 440]}; % 6x8 binary, +32D, have the eye

subjectID = '252';cellBoundary={'trialRange',[446 472]}; % 24x32 binary, +32D, have the eye, has a spatila, but a bit wak

subjectID = '252';cellBoundary={'trialRange',[479]} % an
subjectID = '252';cellBoundary={'trialRange',[480]}; % 480? flankersOnePhase

subjectID = '252';cellBoundary={'trialRange',[484]}; % ffgwn... some strange state changes... bursting volleys

subjectID = '252';cellBoundary={'trialRange',[490]}; %an .. there is still modulation with big annuli .. this makes analysis suspect
subjectID = '252';cellBoundary={'trialRange',[491]}; %flankersConfig... top flnnker is a little bit off the screen

subjectID = '252';cellBoundary={'trialRange',[496]}; %flankersMatter... top flanker is a little bit off the screen
subjectID = '252';cellBoundary={'trialRange',[497 500]}; %trf

subjectID = '252';cellBoundary={'trialRange',[502]}; %sf
subjectID = '252';cellBoundary={'trialRange',[504]}; %or
subjectID = '252';cellBoundary={'trialRange',[505 530]}; %bin  ... not great at localizing... some hope at trial 516.. but not much

subjectID = '252';cellBoundary={'trialRange',[505 530]}; %bin  ... not great at localizing... some hope at trial 516.. but not much

subjectID = '252';cellBoundary={'trialRange',[494]}; %~8 deg changes
subjectID = '252';cellBoundary={'trialRange',[495]}; %~5 deg changes


%LGN
subjectID = '253';cellBoundary={'trialRange',[13 16]}; %ffgwn
subjectID = '253';cellBoundary={'trialRange',[22]}; %sf gratings (this is from a cell that had virtually no response without a lens)
subjectID = '253';cellBoundary={'trialRange',[24 41]}; %bin 12x16
subjectID = '253';cellBoundary={'trialRange',[43 48]}; %h bars

%NEW CELL
subjectID = '253';cellBoundary={'trialRange',[72 75]}; %FFGWN

subjectID = '253';cellBoundary={'trialRange',[85 95]}; % 6 X 8 spatial binary
subjectID = '253';cellBoundary={'trialRange',[101]}; % annuli
subjectID = '253';cellBoundary={'trialRange',[102 103]}; % flankersMatter fast
subjectID = '253';cellBoundary={'trialRange',[105]}; % an
subjectID = '253';cellBoundary={'trialRange',[105]}; % bipartite

%
subjectID = '253';cellBoundary={'trialRange',[106]}; % flankersMatter slow
% a good slow flanker runs out of memory -   matters x40 slowed to [200 220]
subjectID = '253';cellBoundary={'trialRange',[86]};  %flankerMattersOnePhase slow 128 ppc
subjectID = '253';cellBoundary={'trialRange',[87]}; % an

subjectID = '253';cellBoundary={'trialRange',[88]}; %flankerMattersOnePhase slow  180 ppc
%subjectID = '253';cellBoundary={'trialRange',[89]}; %an - only 1 cyc
subjectID = '253';cellBoundary={'trialRange',[90]}; %flankerMattersOnePhase slow  180 ppc
subjectID = '253';cellBoundary={'trialRange',[92]}; %flankerMattersOnePhase slow  180 ppc
subjectID = '253';cellBoundary={'trialRange',[94]}; %flankerMattersOnePhase slow  180 ppc
subjectID = '253';cellBoundary={'trialRange',[95]}; %flankerMattersOnePhase slow  180 ppc
subjectID = '253';cellBoundary={'trialRange',[97]}; %flankerContrastOnePhase slow 180 ppc - partial trial
subjectID = '253';cellBoundary={'trialRange',[98 101]}; %flankerContrastOnePhase slow 180 ppc

subjectID = '253';cellBoundary={'trialRange',[101]} %flankerContrastOnePhase slow 180 ppc
subjectID = '253';cellBoundary={'trialRange',[156]} % flankerMatters... all colin WORTH ANALYZING
%subjectID = '253';cellBoundary={'trialRange',[102 110]} %ffgwn


%subjectID = 'calib';  %no mask, lights on, CRT
%cellBoundary={'trialRange',[10 12]} %bin
%cellBoundary={'trialRange',[2]} %hv
%cellBoundary={'trialRange',[17]} %hv, lights off, 20 frames
%cellBoundary={'trialRange',[24]} %cw:ccw, otherwise same as hv on 17
%cellBoundary={'trialRange',[31]} %cw:ccw, 1/8 std, 16 phases
%cellBoundary={'trialRange',[34]} %cw:ccw, same as 31 but rotated sensor
%cellBoundary={'trialRange',[37]} %cw:ccw, same as 31 but rotated sensor
%cellBoundary={'trialRange',[42]} %new day, hv, 1/8 std, 16 phases

%subjectID = 'calib'; %add mask
%cellBoundary={'trialRange',[45]} %hv 
%cellBoundary={'trialRange',[47 51]} %bin
%cellBoundary={'trialRange',[55]} %same,  linearized
%cellBoundary={'trialRange',[57]} %same,  linearized, but cw:ccw
%cellBoundary={'trialRange',[59]} %same,  linearized, but cw:ccw, sine
%cellBoundary={'trialRange',[61]} %same,  linearized, but hv, sine

% subjectID = 'calib'; %OLED
% cellBoundary={'trialRange',[77]} %OLED, no mask, bin (not enough data)
% cellBoundary={'trialRange',[81]} %OLED, no mask, hv 
% cellBoundary={'trialRange',[84 90]}   %OLED, mask, bin, screen was 1024 768, stixel was [8 8 ]
% cellBoundary={'trialRange',[93 103]}  %OLED, mask, bin, screen was 800 600, stixel was [32 32 ]
% cellBoundary={'trialRange',[105 121]} %OLED, mask, bin, screen was 800 600, stixel was [16 16 ]
% cellBoundary={'trialRange',131};%[129 131]} %OLED, mask, hv
% ellBoundary={'trialRange',131};%[129 131]} %OLED, mask, hv
% cellBoundary={'trialRange',[133 141]};%OLED, bigger mask, bin, errors mid analysis
% cellBoundary={'trialRange',[143]};%OLED, bigger mask, hv, 
% cellBoundary={'trialRange',[147]};%OLED, bigger mask, hv, native gamma
% cellBoundary={'trialRange',[161 163]};%OLED, moved mask, bin, native gamma
% cellBoundary={'trialRange',[165]};%OLED, mask, hv, native gamma, square like before
% cellBoundary={'trialRange',[170]};%OLED, mask, hv, native gamma, sine
% cellBoundary={'trialRange',[172 178]};%OLED, mask, hv, native gamma, sine, many PPC
% cellBoundary={'trialRange',[182 188]};%OLED, mask, cw-ccw, native gamma, sine, many PPC
% cellBoundary={'trialRange',[183]};%OLED, mask, cw-ccw, native gamma, sine, many PPC
% cellBoundary={'trialRange',[194]};%[193 199]OLED, mask, cw-ccw, native gamma, sine, many PPC, ~10 min long
% cellBoundary={'trialRange',[200]};%OLED, mask, cw-ccw, native gamma, sine, many PPC, ~10 min long

% subjectID = 'calib'; %
% cellBoundary={'trialRange',[251 256]};%[250 256]%CRT, mask, hv, native gamma, sine, many PPC, ~1 min long WRONG PPC!
% cellBoundary={'trialRange',[264]};%[258 263]%CRT, mask, hv, native gamma, sine, many PPC, ~1 min long
% cellBoundary={'trialRange',[258]};%[250 256]%CRT, mask, hv, native gamma, sine, many PPC, ~1 min long
% cellBoundary={'trialRange',[285]};%[284 290]%OLED, mini-mask, hv, native gamma, sine, many PPC, ~1 min long, kind of noisey

channels={1}
%spikeSortingParams.postProcessing= 'largestNonNoiseClusterOnly';
spikeDetectionParams.detectionMethod=3; % 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
spikeDetectionParams.extractionThreshold =10;
spikeDetectionParams.sampleLFP = false; %true;
spikeDetectionParams.LFPSamplingRateHz =500;

overwriteAll=1; % if not set, analysis wont sort spikes again, do we need?: 0=do if not there, and write, 1= do always and overwrite, 2= do always, only write if not there or user confirm?
usePhotoDiodeSpikes=0;
%spikeDetectionParams.method='activeSortingParametersThisAnalysis';  % will override this files choices with the active params for this *subject*
%spikeSortingParams.method='activeSortingParametersThisAnalysis';

analysisManagerByChunk(subjectID, path, cellBoundary, channels,spikeDetectionParams, spikeSortingParams,...
    timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes)
