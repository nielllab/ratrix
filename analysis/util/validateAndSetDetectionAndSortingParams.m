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

% spikeSorting and spikeDetection params are going to be structures named
% after the trodesStrs

%% spikeDetectionParams
switch length(spikeDetectionParams)
    case 0
        % provide standard values
        % spikeDetectionParams
        temp.method = 'oSort';
        temp.ISIviolationMS=2;
        for i = 1:numTrodes
            trodeStr = createTrodeName(trodes{i});
            spikeDetectionParams.(trodeStr) = temp;
            spikeDetectionParams.(trodeStr).trodeChans = trodes{i};
        end
    case 1
        % either we are given active paramfile location or we are given the param file
        % spikeDetectionParams
        if strcmp(spikeDetectionParams.method,'activeSortingParams')
            % get the active paramfile and error check
             temp = load(spikeDetectionParams.activeParamLocation,'spikeDetectionParams');
             spikeDetectionParams = temp.spikeDetectionParams;
            % error check if the trodes are the same
            trodes = sort(trodes);
            paramTrodes = sort(fieldnames(spikeDetectionParams));
            if ~all(strcmp(trodes,paramTrodes))
                error('trodes from input and trodes from activeParam file do not match');
            end
        elseif strcmp(spikeSortingParams.method,'useSpikeModelFromPreviousAnalysis')
            % do nothing to the spikesortingparams. just return the value
        else
            % here just repmat, and name the trodes
            temp = repmat(spikeDetectionParams,numTrodes,1);
            spikeDetectionParams = [];
            for i = 1:numTrodes
                trodeStr = createTrodeName(trodes{i});
                spikeDetectionParams.(trodeStr) = temp(i);
                spikeDetectionParams.(trodeStr).trodeChans = trodes{i};
            end
        end
     case numTrodes
        % make the spikeDetectionParams into a structure instead of an
        % array of structures
        temp = spikeDetectionParams;
        spikeDetectionParams = [];
        for i = 1:numTrodes
            trodeStr = createTrodeName(trodes{i});
            spikeDetectionParams.(trodeStr) = temp(i);
            spikeDetectionParams.(trodeStr).trodeChans = trodes{i};
        end
    otherwise
        spikeDetectionParams        
        numTrodes
        error('given parameter length for spikeDetectionParams and number of trodes do not match')
end

%% spikeSortingParams
switch length(spikeSortingParams)
    case 0
        % provide standard values
        temp.method = 'oSort';
        spikeSortingParams = [];
        for i = 1:numTrodes
            trodeStr = createTrodeName(trodes{i});
            spikeSortingParams.(trodeStr) = temp;
            spikeSortingParams.(trodeStr).trodeChans = trodes{i};
        end
    case 1
        % either we are given active paramfile location or we are given the param file
        % spikeDetectionParams
                % either we are given active paramfile location or we are given the param file
        % spikeDetectionParams
        if strcmp(spikeSortingParams.method,'activeSortingParams')
            % get the active paramfile and error check
             temp = load(spikeSortingParams.activeParamLocation,'spikeSortingParams');
             spikeSortingParams = temp.spikeSortingParams;
            % error check if the trodes are the same
            trodes = sort(trodes);
            paramTrodes = sort(fieldnames(spikeSortingParams));
            if ~all(strcmp(trodes,paramTrodes))
                error('trodes from input and trodes from activeParam file do not match');
            end
        else
            % here just repmat, and name the trodes
            temp = repmat(spikeSortingParams,numTrodes,1);
            spikeSortingParams = [];
            for i = 1:numTrodes
                trodeStr = createTrodeName(trodes{i});
                spikeSortingParams.(trodeStr) = temp(i);
                spikeSortingParams.(trodeStr).trodeChans = trodes{i};
            end
        end        
    case numTrodes
        % make the spikeSortingParams into a structure instead of an
        % array of structures
        temp = spikeSortingParams;
        spikeSortingParams = [];
        for i = 1:numTrodes
            trodeStr = createTrodeName(trodes{i});
            spikeSortingParams.(trodeStr) = temp(i);
            spikeSortingParams.(trodeStr).trodeChans = trodes{i};
        end
    otherwise
        spikeSortingParams
        numTrodes
        error('given parameter length for spikeSortingParams and number of trodes do not match')
end
detectionAndSortingParamsValidated = true;            
end
