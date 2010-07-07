function details = getDetailsFromNeuralRecords(neuralRecordLocation,requestedDetails)

% some constants
OTHER = 0;
NUM_CHUNKS = 1;
SAMPLING_RATE = 2;
SPECIFIC_CHUNK = 3;

% existence of variables error checks
if ~exist('neuralRecordLocation','var') || isempty(neuralRecordLocation)
    error('neuralRecordLocation is required for this function');
end
if ~exist('requestedDetails','var') || isempty(requestedDetails)
    error('requestedDetails is required for this function');
end

% quality control on inputs
if ~exist(neuralRecordLocation,'file')
    neuralRecordLocation
    error('neuralRecordLocation is not a file')
end

if ~iscell(requestedDetails)
    requestedDetails
    error('requestedDetails should be a cell')
end

% actual stuff.
maxAttempts = 5;
temp = stochasticLoad(neuralRecordLocation,requestedDetails,maxAttempts);
fieldsTemp = fieldnames(temp);

requestedDetailsType = OTHER;
if strcmp(requestedDetails,'numChunks')
    requestedDetailsType = NUM_CHUNKS;
elseif strcmp(requestedDetails,'samplingRate')
    requestedDetailsType = SAMPLING_RATE;
elseif strfind(requestedDetails{:},'chunk')==1
    requestedDetailsType = SPECIFIC_CHUNK;
end

switch requestedDetailsType
    case NUM_CHUNKS
        if isempty(fieldsTemp)
            warning('neuralRecordLocation: \n''%s'' \ndoes not have requestedDetails: \n''%s''',neuralRecordLocation,requestedDetails{1});
            warning('going to find number of chunks and appending information to \n''%s''',neuralRecordLocation)
            
            disp('checking chunk names... may be slow remotely...'); tic;
            chunkNames=who('-file',neuralRecordLocation);
            fprintf(' %2.2f seconds\n',toc)
            details=[];
            for i=1:length(chunkNames)
                [matches tokens] = regexpi(chunkNames{i}, 'chunk(\d+)', 'match', 'tokens');
                if length(matches) ~= 1
                    continue;
                else
                    chunkN = str2double(tokens{1}{1});
                    details(end+1)=chunkN;
                end
            end  
            % now save numChunks in neuralRecords
            numChunks = details;
            save(neuralRecordLocation,'numChunks','-append');
        else            
            details = temp.numChunks;
            details = sort(details);
        end
    case SAMPLING_RATE
        if isempty(fieldsTemp)
            error('samplingRate not found in neuralRecords');
        else
            details = temp.samplingRate;
        end
    case SPECIFIC_CHUNK
        if isempty(fieldsTemp)
            error('requested chunk : ''%s'' not found in neuralRecords',requestedDetails);
        else
            details = temp.(requestedDetails{:});
        end
    case OTHER
        error('unknown details requested');
    otherwise
        error('eh??');
end
end