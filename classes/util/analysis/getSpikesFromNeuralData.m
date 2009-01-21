function [spikes spikeWaveforms spikeTimestamps assignedClusters rankedClusters photoDiode]= ...
    getSpikesFromNeuralData(neuralData,neuralDataTimes,spikeDetectionParams,spikeSortingParams)
% Get spikes using some spike detection method - plugin to Osort, WaveClus, KlustaKwik
% Outputs:
%   spikes - a logical vector of length n, where n=number of neuralData samples, and 1=a spike occurred here
%   spikeWaveforms - a maitrx containing a 4x32 waveform for each spike
%   spikeTimestamps - timestamp of each spike
%   assignedClusters - which cluster each spike belongs to
%   rankedClusters - some ranking of the clusters - we will specify that by convention, the last element of this array is the "noise" cluster
%   photoDiode - unused for now....

photoDiode=[];
spikes=[];

% =====================================================================================================================
% SPIKE DETECTION

% handle spike detection
% the spikeDetectionParams struct must contain a 'method' field
if isfield(spikeDetectionParams, 'method')
    spikeDetectionMethod = spikeDetectionParams.method;
else
    error('must specify a method for spike detection');
end
% switch on the detection method
switch upper(spikeDetectionMethod)
    case 'OSORT'
        % spikeDetectionParams should look like this:
        %   method - osort
        %   samplingFreq - sampling frequency of raw signal
        %   Hd - (optional) bandpass frequencies
        %   nrNoiseTraces - (optional) number of noise traces as a parameter to osort's extractSpikes
        %   detectionMethod - (optional) spike detection method to use as a parameter to osort's extractSpikes
        %   extractionThreshold - (optional) threshold for extraction as a parameter to osort's extractSpikes
        %   peakAlignMethod - (optional) peak alignment method to use as a parameter to osort's extractSpikes
        %   alignMethod - (optional) align method to use if we are using "find peak" peakAlignMethod
        %   prewhiten - (optional) whether or not to prewhiten
        %   limit - (optional) the maximal absolute valid value (bigger/smaller than this is treated as out of range)
        
        % ============================================================================================================
        % from Osort's extractSpikes
        %extractionThreshold default is 5
        %params.nrNoiseTraces: 0 if no noise should be estimated
        %               >0 : # of noise traces to be used to estimate autocorr of
        %               noise, returned in variable autocorr
        %
        %
        %params.detectionMethod: 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
        %params.detectionParams: depends on detectionMethod. 
        %       if detectionmethod==1, detectionParams.kernelSize
        %       if detectionmethod==4, detectionParams.scaleRanges (the range of scales (2 values))
        %                              detectionParams.waveletName (which wavelet to use)
        %
        %params.peakAlignMethod: 1-> find peak, 2->none, 3->peak of power signal, 4->peak of MTEO signal.
        %params.alignMethod: 1=pos, 2=neg, 3=mix (order if both peaks are sig,otherwise max) - only used if peakAlignMethod==1
        % ============================================================================================================
        
        % check params
        if ~isfield(spikeDetectionParams, 'samplingFreq')
            error('samplingFreq must be defined');
        end
        if isfield(spikeDetectionParams, 'Hd')
            Hd = spikeDetectionParams.Hd;
        else
            % default to bandpass 30Hz - 300Hz
            n = 4;
            Wn = [300 3000]/(spikeDetectionParams.samplingFreq/2);
            [b,a] = butter(n,Wn);
            Hd=[];
            Hd{1}=b;
            Hd{2}=a;
        end
        if ~isfield(spikeDetectionParams, 'nrNoiseTraces')
            warning('nrNoiseTraces not defined - using default value of 0');
        end
        if ~isfield(spikeDetectionParams, 'detectionMethod')
            spikeDetectionParams.detectionMethod=1;
            spikeDetectionParams.kernelSize=25;
            warning('detectionMethod not defined - using default value of 1; also overwriting kernelSize param if set');
        end
        if ~isfield(spikeDetectionParams, 'extractionThreshold')
            spikeDetectionParams.extractionThreshold = 5;
            warning('extractionThreshold not defined - using default value of 5');
        end
        if ~isfield(spikeDetectionParams, 'peakAlignMethod')
            spikeDetectionParams.peakAlignMethod=1;
            warning('peakAlignMethod not defined - using default value of 1');
        end
        if ~isfield(spikeDetectionParams, 'prewhiten')
            spikeDetectionParams.prewhiten = false;
            warning('prewhiten not defined - using default value of false');
        end
        if ~isfield(spikeDetectionParams, 'limit')
            spikeDetectionParams.limit = 2000;
            warning('limit not defined - using default value of 2000');
        end
        % check that correct params exist for given detectionMethods
        if spikeDetectionParams.detectionMethod==1
            if ~isfield(spikeDetectionParams, 'kernelSize')
                warning('kernelSize not defined - using default value of 25');
            end
        elseif spikeDetectionParams.detectionMethod==5
            if ~isfield(spikeDetectionParams, 'scaleRanges')
                warning('scaleRanges not defined - using default value of [0.5 1.0]');
                spikeDetectionParams.scaleRanges = [0.5 1.0];
            end
            if ~isfield(spikeDetectionParams, 'waveletName')
                warning('waveletName not defined - using default value of ''haar''');
                spikeDetectionParams.waveletName = 'haar';
            end
        end
        
        if spikeDetectionParams.peakAlignMethod==1
            if ~isfield(spikeDetectionParams, 'alignMethod')
                warning('alignMethod not defined - using default value of 1');
                spikeDetectionParams.alignMethod = 1;
            end
        end
        

        % call to Osort spike detection
        [rawMean, filteredSignal, rawTraceSpikes,spikeWaveforms, spikeTimestampIndices, runStd2, upperlim, noiseTraces] = ...
            extractSpikes(neuralData, Hd, spikeDetectionParams );
        spikeTimestamps = neuralDataTimes(spikeTimestampIndices);
        spikes=zeros(length(neuralDataTimes),1);
        spikes(spikeTimestampIndices)=1;
        
    otherwise
        error('unsupported spike detection method');
end

% plotting to show results (for testing)
spikePoints=ones(1,length(spikeTimestamps));
subplot(2,1,1)
plot(neuralDataTimes,neuralData);
title('rawSignal and spikes');
hold on
size(spikes)
size(neuralData)
plot(neuralDataTimes,spikes.*neuralData,'.r');
hold off
subplot(2,1,2)
plot(neuralDataTimes,filteredSignal);
title('filteredSignal and spikes');
hold on
plot(neuralDataTimes,spikes.*filteredSignal,'.r');
hold off

% output of spike detection should be spikeTimestamps and spikeWaveforms
% END SPIKE DETECTION
% =====================================================================================================================
% BEGIN SPIKE SORTING
% Inputs are spikeTimestamps, spikeWaveforms

% check for a spike sorting method
if isfield(spikeSortingParams, 'method')
    spikeSortingMethod = spikeSortingParams.method;
else
    error('must specify a spike sorting method');
end

if isempty(spikeTimestamps)
    warning('NO SPIKES FOUND DURING SPIKE DETECTION');
    assignedClusters=[];
    rankedClusters=[];
    return;
end

% switch on the sorting method
switch upper(spikeSortingMethod)
    case 'OSORT'
        % spikeSortingParams can have the following fields:
        %   method - osort
        %   doPostDetectionFiltering - (optional) specify whether or not to do post-detection filtering; see postDetectionFilter.m
        %   alignParam - (optional) alignParam to be passed in to osort's realigneSpikes method
        %   peakAlignMethod - (optional) peak alignment method used by osort's realigneSpikes method
        %   distanceWeightMode - (optional) mode of distance weight calculation used by osort's setDistanceWeight method
        %   minClusterSize - (optional) minimum number of elements in each cluster; passed in to osort's createMeanWaveforms method
        %   maxDistance - (optional) maxDistance parameter passed in to osort's assignToWaveform method; not sure what this does...
        %   envelopeSize - (optional) parameter passed in to osort's assignToWaveform method; not sure what this does...
        
        % check params
        if ~isfield(spikeSortingParams,'doPostDetectionFiltering')
            warning('doPostDetectionFiltering not defined - using default value of false');
            spikeSortingParams.doPostDetectionFiltering = false;
        end
        %alignParam:   this param is only considered if peakAlignMethod=1.
        %      1: positive (peak is max)
        %      2: negative (peak is min)
        %      3: mixed
        if ~isfield(spikeSortingParams,'alignParam')
            warning('alignParam not defined - using default value of 1');
            spikeSortingParams.alignParam=1;
        end
        %peakAlignMethod: (same as in detectSpikesFromPower.m, see for details).  1-> findPeak, 2 ->none, 3-> peak of power signal
        if ~isfield(spikeSortingParams,'peakAlignMethod')
            warning('peakAlignMethod not defined - using default value of 1');
            spikeSortingParams.peakAlignMethod=1;
        end
        %mode==1:mean waveforms
        %mode==2:assignment
        if ~isfield(spikeSortingParams,'distanceWeightMode')
            warning('distanceWeightMode not defined - using default value of 1');
            spikeSortingParams.distanceWeightMode=1;
        end
        % see createMeanWaveforms.m
        if ~isfield(spikeSortingParams,'minClusterSize')
            warning('minClusterSize not defined - using default value of 50');
            spikeSortingParams.minClusterSize=50;
        end
        % see assignToWaveform.m
        if ~isfield(spikeSortingParams,'maxDistance')
            warning('maxDistance not defined - using default value of 3');
            spikeSortingParams.maxDistance=3;
        end
        % see assignToWaveform.m
        if ~isfield(spikeSortingParams,'envelopeSize')
            warning('envelopeSize not defined - using default value of 4');
            spikeSortingParams.envelopeSize=4;
        end
        
        % end param checks
        % ===============================================================================
        % first upsample spikes
        spikeWaveforms=upsampleSpikes(spikeWaveforms);
        % get estimate of std from raw signal
        stdEstimate = std(neuralData); %stdEstimate: std estimate of the raw signal. only used if peakAlignMethod=1.
        
        if spikeSortingParams.doPostDetectionFiltering
            % optional post spike-detection filtering
            %filter raw waveforms to get rid of artifacts, non-real spikes and
            %other shit
            [newSpikes,newTimestamps,didntPass] = postDetectionFilter( spikeWaveforms, spikeTimestamps);
            newSpikes = realigneSpikes(newSpikes,spikeTimestamps,spikeSortingParams.alignParam,stdEstimate,spikeSortingParams.peakAlignMethod);
        else
            newSpikes=spikeWaveforms;
            newTimestamps=spikeTimestamps;
        end
        numSpikes=size(newSpikes);
        numSpikes
        
        %convert to RBF and realign
        [spikesRBF, spikesSolved] = RBFconv( newSpikes );
        spikesSolved = realigneSpikes(spikesSolved,spikeTimestamps,spikeSortingParams.alignParam,stdEstimate,spikeSortingParams.peakAlignMethod);
        
        %calculate threshold
        x=1:size(spikesSolved,2);
        [weights,weightsInv] = setDistanceWeight(x,spikeSortingParams.distanceWeightMode);
        globalMean = mean(spikesSolved);
        globalStd  = std(spikesSolved);
        initialThres = ((globalStd.^2)*weights)/256;

        %cluster to find mean waveforms of cluster
        [NrOfclustersFound, assignedCluster, meanSpikeForms, rankedClusters] = sortBlock(spikesSolved, newTimestamps, initialThres);
        
        %merge mean clusters
        [meanWaveforms,meanClusters] = ...
            createMeanWaveforms( size(spikesSolved,1), meanSpikeForms,rankedClusters,initialThres,spikeSortingParams.minClusterSize);

        %now re-cluster, using this new mean waveforms
        [assignedClusters, rankedClusters] = ...
            assignToWaveform(spikesSolved,newTimestamps,meanClusters,initialThres,stdEstimate,spikeSortingParams.maxDistance,spikeSortingParams.envelopeSize);
        % osort's assignToWaveform gives us rankedClusters as indices into the unique cluster numbers in assignedClusters
        % we want rankedClusters to be the actual cluster numbers, not indices - fix here
        % rankedClusters should be sorted in descending order of number of members in cluster, with noise cluster moved to last element
        uniqueClusters = unique(assignedClusters);
        uniqueClusters(uniqueClusters==999)=[]; % move noise cluster to end
        uniqueClusters(end+1)=999;
        rankedClusters=uniqueClusters;
        
    case 'KLUSTAKWIK'
        % spikeSortingParams can have the following fields:
        %   minClusters - (optional) (default 20) min number of initial clusters - final number may be different due to splitting/deleting
        %   maxClusters - (optional) (default 30) max number of initial clusters - final number may be different due to splitting/deleting
        %   nStarts - (optional) (default 1) number of starts of the algorithm for each initial cluster count
        %   splitEvery - (optional) (default 50) Test to see if any clusters should be split every n steps. 0 means don't split.
        %   maxPossibleClusters - (optional) (default 100) Cluster splitting can produce no more than this many clusters.
        %   useAllFeatures - (optional) (default 1) 1 = use all features (all datapoints of each waveform)
        %                                           2 = use first 10 principal components
        
        % check params
        % minClusters
        if ~isfield(spikeSortingParams,'minClusters')
            warning('minClusters not defined - using default value of 20');
            spikeSortingParams.minClusters=20;
        end
        % maxClusters
        if ~isfield(spikeSortingParams,'maxClusters')
            warning('maxClusters not defined - using default value of 30');
            spikeSortingParams.maxClusters=30;
        end
        % nStarts
        if ~isfield(spikeSortingParams,'nStarts')
            warning('nStarts not defined - using default value of 1');
            spikeSortingParams.nStarts=1;
        end
        % splitEvery
        if ~isfield(spikeSortingParams,'splitEvery')
            warning('splitEvery not defined - using default value of 50');
            spikeSortingParams.splitEvery=50;
        end
        % maxPossibleClusters
        if ~isfield(spikeSortingParams,'maxPossibleClusters')
            warning('maxPossibleClusters not defined - using default value of 100');
            spikeSortingParams.maxPossibleClusters=100;
        end
        % useAllFeatures
        if ~isfield(spikeSortingParams,'useAllFeatures')
            warning('useAllFeatures not defined - using default value of 1');
            spikeSortingParams.useAllFeatures=1;
        end
        
        % we need a file temp.fet.1 as input to KlustaKwik, and the output file will be temp.clu.1
        % change to ratrixPath/KlustaKwik directory
        currentDir=pwd;
        tempDir=fullfile(getRatrixPath,'KlustaKwik');
        cd(tempDir);
        
        % determine the number of datapoints for each spike (either all, or 10 PCs)
        if spikeSortingParams.useAllFeatures == 1
            nrDatapoints=size(spikeWaveforms,2);
            score=spikeWaveforms;
        else
            [pc,score,latent,tsquare] = princomp(spikeWaveforms);
            nrDatapoints=10; %first 10 PCs
        end
        % write the feature file
        fid = fopen('temp.fet.1','w+');
        fprintf(fid,[num2str(nrDatapoints) '\n']);
        for k=1:length(spikeTimestamps)
                fprintf(fid,'%s\n', num2str(score(k,1:nrDatapoints)));        
        end  
        fclose(fid);
        
        % set which features to use
        featuresToUse='';
        for i=1:nrDatapoints
            featuresToUse=[featuresToUse '1'];    
        end

        % now run KlustaKwik
        cmdStr=['KlustaKwik.exe temp 1 -MinClusters ' num2str(spikeSortingParams.minClusters) ' -MaxClusters ' num2str(spikeSortingParams.maxClusters) ...
            ' -nStarts ' num2str(spikeSortingParams.nStarts) ' -SplitEvery ' num2str(spikeSortingParams.splitEvery) ... 
            ' -MaxPossibleClusters ' num2str(spikeSortingParams.maxPossibleClusters) ' -UseFeatures ' featuresToUse];
        system(cmdStr);
        
        % read output temp.clu.1 file
        fid = fopen('temp.clu.1');
        assignedClusters=[];
        while 1
            tline = fgetl(fid);
            if ~ischar(tline),   break,   end
            assignedClusters = [assignedClusters str2num(tline)];
        end
        % throw away first element of assignedClusters - the first line of the cluster file is the number of clusters found
        assignedClusters(1)=[];
        % generate rankedClusters by a simple count of number of members
        rankedClusters = unique(assignedClusters);
        clusterCounts=zeros(length(rankedClusters),2);
        for i=1:size(clusterCounts,1)
            clusterCounts(i,1) = i;
            clusterCounts(i,2) = length(find(assignedClusters==rankedClusters(i)));
        end
        clusterCounts=sortrows(clusterCounts,-2);
        rankedClusters=rankedClusters(clusterCounts(:,1));
        rankedClusters(rankedClusters==1)=[];
        rankedClusters(end+1)=1; % move noise cluster '1' to end
        fclose(fid);
        
        % change back to original directory
        cd(currentDir);
    otherwise
        error('unsupported spike sorting method');
end

% output of spike sorting should be assignedCluster and rankedClusters
% assignedCluster is a 1xN vector, which is the assigned cluster number for each spike (numbers are arbitrary)
% END SPIKE SORTING
% =====================================================================================================================

end % end function