function [detectionAndSortingParamsValidated spikeDetectionParams spikeSortingParams] = ...
    validateAndSetDetectionAndSortingParams(spikeDetectionParams,spikeSortingParams,channelAnalysisMode,trodes,channelConfiguration)
% This deals with the logic of when spikeDetectionParams and
% spikeSortingParams are set. When the trodes are pre-specified, then this
% function is called without channelConfiguration. Else, channelConfiguration
% is required.

if ~exist('spikeDetectionParams','var') || ~exist('spikeSortingParams','var')
    error('spikeDetectionParams and spikeSortingParams should exist here');
end
    
detectionAndSortingParamsValidated = false;
switch channelAnalysisMode
    case 'onlySomeChannels'
        % here trodes data should exist and this determines how many
        % channels. 
        if ~exist('trodes','var')|| isempty(trodes)
            error('channelAnalysisMode:''%s'' requires the variable trode',channelAnalysisMode);
        end
        numTrodes = length(trodes);
    case 'allPhysChannels'
        % it typically comes in here only when we dont know what the
        % channels we want to analyze are.
        % make sure that channelConfiguration exists
        if ~exist('channelConfiguration','var') || isempty(channelConfiguration)
            warning('channelConfiguration is needed for channelAnalysisMode:''%s''. returning input values for params',channelAnalysisMode);
            return;
        end
        
        % what does the neuralData say about trode info?
        trodesFromNeuralData = {};
        % find the physInds
        allPhysInds = find(~cellfun(@isempty, strfind(channelConfiguration,'phys')));
        for thisPhysInd = allPhysInds
            tokens = regexpi(channelConfiguration{thisPhysInd},'phys(\d+)','tokens');
            trodesFromNeuralData{end+1} = str2num(tokens{1}{1});
        end
        
        if ~exist('trodes','var') || isempty(trodes)
            trodes = trodesFromNeuralData;
        end
        numTrodes = length(trodes);
        
    otherwise
        error('channelAnalysisMode: ''%s'' is not supported',channelAnalysisMode);
end

% now we have all the trode nums. if spikeDetection and spikesortingParams 
% have same length as numTrodes, return them; if spikeSortingParams and
% spikeDetectionParams are empty, create standard ones; if they
% have length 1, repmat.

% spikeDetectionParams
switch length(spikeDetectionParams)
    case 0
        % provide standard values
        % spikeDetectionParams
        spikeDetectionParams.method = 'oSort';
        spikeDetectionParams.ISIviolationMS=2;
        spikeDetectionParams = repmat(spikeDetectionParams,numTrodes,1);
        for i = 1:numTrodes
            spikeDetectionParams(i).trodeChans = trodes{i};
        end
    case 1
        % either we are given active paramfile location or we are given the param file
        % spikeDetectionParams
        if strcmp(spikeDetectionParams.method,'activeSortingParams')
            % get the active paramfile and error check
            spikeDetectionParams = load(spikeDetectionParams.activeParamLocation,'spikeDetectionParams');
            % error check. right now only check for number of leads.
            % maybe later check for trodeChans
            if length(spikeDetectionParams) ~= numTrodes
                spikeDetectionParams
                numTrodes
                error('activeParamLocation does not have spikeDetectionParams with the right number of trodes');
            end
        else
            % here just repmat, and name the trodes
            spikeDetectionParams = repmat(spikeDetectionParams,numTrodes,1);
            % error check. right now only check for number of leads.
            % maybe later check for trodeChans
            for i = 1:numTrodes
                spikeDetectionParams(i).trodeChans = trodes{i};
            end
        end
        
    case numTrodes
        % do nothing
    otherwise
        spikeDetectionParams        
        numTrodes
        error('given parameter length for spikeDetectionParams and number of trodes do not match')
end

% spikeSortingParams
switch length(spikeSortingParams)
    case 0
        % provide standard values
        spikeSortingParams.method = 'oSort';
        spikeSortingParams = repmat(spikeSortingParams,numTrodes,1)
        for i = 1:numTrodes
            spikeSortingParams(i).trodeChans = trodes{i};
        end
    case 1
        % either we are given active paramfile location or we are given the param file
        % spikeDetectionParams
        if strcmp(spikeSortingParams.method,'activeSortingParams')
            % get the active paramfile and error check
            spikeSortingParams = load(spikeSortingParams.activeParamLocation,'spikeSortingParams');
            % error check. right now only check for number of leads.
            % maybe later check for trodeChans
            if length(spikeSortingParams) ~= numTrodes
                spikeSortingParams
                numTrodes
                error('activeParamLocation does not have spikeSortingParams with the right number of trodes');
            end
        else
            % here just repmat, and name the trodes
            spikeSortingParams = repmat(spikeSortingParams,numTrodes,1);
            % error check. right now only check for number of leads.
            % maybe later check for trodeChans
            for i = 1:numTrodes
                spikeSortingParams(i).trodeChans = trodes{i};
            end
        end        
    case numTrodes
        % do nothing
    otherwise
        spikeSortingParams
        numTrodes
        error('given parameter length for spikeSortingParams and number of trodes do not match')
end
detectionAndSortingParamsValidated = true;            
end
