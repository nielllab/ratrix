function spikeDetails = postProcessSpikeClusters(assignedClusters,rankedClusters,spikeSortingParams)
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
    case 'treatAllNonNoiseAsSpike'
        % all spikes belonging to non-noise cluster set to 1, noise set to 0
        spikeDetails.processedClusters=assignedClusters;
        spikeDetails.processedClusters(spikeDetails.processedClusters~=rankedClusters(end))=1;
        spikeDetails.processedClusters(spikeDetails.processedClusters==rankedClusters(end))=0;
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
    otherwise
        error('unsupported method for postProcessing spike clusters');
end


end % end function
        