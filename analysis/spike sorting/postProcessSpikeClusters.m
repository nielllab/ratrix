function spikeDetails = postProcessSpikeClusters(assignedClusters,rankedClusters,spikeSortingParams,spikeWaveforms)
% this function does optional post-processing of the assigned clusters for each spike based on spikeSortingParams.postProcessing
% spikeSortingParams.postProcessing can be:
%   'treatAllNonNoiseAsSpike' - (default) all spikes assigned to non-noise clusters will be considered to be true spikes
%   'largestNonNoiseClusterOnly' - only spikes belonging to the largest non-noise cluster will be considered to be true spikes
%   

if isempty(assignedClusters)
    spikeDetails.processedClusters=[];
%     spikeDetails.processedClusterRanks=[];
    return;
end

if ~isfield(spikeSortingParams, 'postProcessing')
    warning('postProcessing not defined - using default value of ''treatAllNonNoiseAsSpike''');
    process = 'treatAllNonNoiseAsSpike';
else
    process = spikeSortingParams.postProcessing;
end

switch process
    case 'treatAllAsSpike'
        spikeDetails.processedClusters=ones(1,length(assignedClusters));
        spikeDetails.processedClusterRanks=[1];
    case 'treatAllNonNoiseAsSpike'
        if length(rankedClusters)~=length(unique(rankedClusters))
            rankedClusters
            error('rankedClusters assumed to be unique... what happened?')
            % check assumption that noise is at the end and how this is done.
        end
        % all spikes belonging to non-noise cluster set to 1, noise set to 0
        spikeDetails.processedClusters=assignedClusters(:)';
        spikeDetails.processedClusters(spikeDetails.processedClusters==rankedClusters(end))=0;
        spikeDetails.processedClusters(spikeDetails.processedClusters~=rankedClusters(end))=1;

        if length(find(spikeDetails.processedClusters==1))>=length(assignedClusters)/2
            % more spikes non-noise
            spikeDetails.processedClusterRanks=[1 0];
        else
            spikeDetails.processedClusterRanks=[0 1];
        end
    case 'largestNonNoiseClusterOnly'
         
        % all spikes belonging to the largest non-noise cluster
        spikeDetails.processedClusters=ones(1,length(assignedClusters));
        % zero out anything not equal to first rankedCluster
        spikeDetails.processedClusters(assignedClusters~=rankedClusters(1))=0;
    case 'biggestAverageAmplitudeCluster'  
        clusterIDs=unique(assignedClusters);
        for i=1:length(clusterIDs)
            avg=mean(spikeWaveforms(assignedClusters==clusterIDs(i),:),1);
            amp(i)=diff(minmax(avg));
        end
        selected=find(amp==max(amp));
        selected=selected(1);
        spikeDetails.processedClusters=assignedClusters'==selected;
    otherwise
        error('unsupported method for postProcessing spike clusters');
end


end % end function
        