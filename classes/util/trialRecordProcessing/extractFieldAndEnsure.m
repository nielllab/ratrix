function [out LUT] = extractFieldAndEnsure(trialRecords,fieldPath,ensureMode,LUT)
% this function extracts the given field from trialRecords using the provided fieldPath and ensureMode
%   ensureMode is one of {'scalar','scalarLUT','equalLengthVects',{'typedVector',type},'datenum','none'} where type specifies the type of vector
%
% for use by the general extractBasicFields and the stim-specific extractDetailFields so that NaNs are inserted instead of bailing on trials
% scalar - each trialRecord has a single scalar value at this field
% scalarLUT - each trialRecord has a single value at this field, but it may be a char that needs to be put into the LUT
% equalLengthVects - each trialRecord has a vector at this field, and the length of the vector is constant across all trials
% typedVector - each trialRecord has a vector at this field, and the type of the vector is consistent across all trials
% datenum - each trialRecord has a datevec at this field, and is converted to a datenum in a specific format
% isNotEmpty - each trialRecord may or may not have this field, and this will return 1 if it does, 0 if it doesnt (on a per-trial basis)
% NthValue = each trialRecord has a vector/matrix at this field, and we grab the N-th value of this vector for each trial
% numRequests - accesses trialRecords->phaseRecords->responseDetails->tries; returns size of this - 1 per trial
% none - just grab this field for each trial

% grab the mode if cell array, and set ensureType=type
if iscell(ensureMode) && length(ensureMode)==2
    ensureType=ensureMode{2};
    ensureMode=ensureMode{1};
end

% if fieldPath isnt a single element cell array, then follow it down to the last element
for i=1:length(fieldPath)-1
    if ismember(fieldPath{i},fields(trialRecords))
        trialRecords=[trialRecords.(fieldPath{i})];
    else
        out=nan*ones(1,length(trialRecords));
        return
    end
end
% now reset fieldPath to be only the last element
if ~isempty(fieldPath) % fieldPath should only be empty in the 'numRequests' and 'firstIRI' cases because these require exact fields and special handling
    fieldPath=fieldPath{end}; % fieldPath is now just a string
end

isPhased=isfield(trialRecords,'phaseRecords') && ~isempty(trialRecords(1).phaseRecords);

try
    switch ensureMode
        case 'scalar'
            out=ensureScalar({trialRecords.(fieldPath)});
        case 'scalarOrEmpty'
            out=ensureScalarOrEmpty({trialRecords.(fieldPath)});
        case 'scalarLUT'
            try
                out=ensureScalar({trialRecords.(fieldPath)});
            catch
                [out LUT]=addOrFindInLUT(LUT, {trialRecords.(fieldPath)});
            end
        case 'mixed'
            % this means that this field of trialRecords may have mixed types (specifically for trialRecords.type)
            % we try first to encode as a simple string, but if not, then assume it is a cell array of mixed types
            % only compiling the first string element of each cell array
            % for type, that means we throw away toggleStim/timedFrames/indexedFrames
            try
                ensureTypedVector({trialRecords.(fieldPath)},'char');
                [out LUT]=addOrFindInLUT(LUT, {trialRecords.(fieldPath)});
            catch
                [out LUT]=addOrFindInLUT(LUT, cellfun(@(x)x{1},{trialRecords.(fieldPath)},'UniformOutput',false));
            end
        case 'equalLengthVects'
            out=ensureEqualLengthVects({trialRecords.(fieldPath)});
        case 'typedVector'
            out=ensureTypedVector({trialRecords.(fieldPath)},ensureType);
        case 'datenum'
            out=datenum(reshape([trialRecords.(fieldPath)],6,length(trialRecords))')';
        case 'isDefinedAndNotEmpty'
            f=fields(trialRecords);
            if ~any(strcmp(fieldPath,f))
                out=zeros(size(trialRecords));
            else
                cellValues={trialRecords.(fieldPath)};
                %out = cell2mat(cellfun('isempty',cellValues,'UniformOutput',false));  %errors on structs
                out = ~cellfun(@(x) isempty(x),cellValues);
            end
        case 'NthValue'
            if ~isempty(ensureType)
                %get nth value of matrix
                if isfield(trialRecords,fieldPath)
                    cellValues={trialRecords.(fieldPath)};   
                    cellNth=repmat({ensureType},1,(length(trialRecords)));
                    out = cell2mat(cellfun(@takeNthValue,cellValues ,cellNth, 'UniformOutput',false));
                else
                    out=nan(size(trialRecords));
                    warning(sprintf('field missing and Nan''d: %s',fieldPath))
                end
                if any(size(out)~=size(trialRecords))
                    cellValues
                    out
                    size(out)
                    size(trialRecords)
                    error('should have one value per trial! failed!  maybe nans emptys in values?')
                end
       
            else
                error('should have one value per trial! failed! and nthValue is undefined')
            end
        case 'discrimStart'
            discrimPhaseStart = cellfun(@getDiscrimPhaseStart,{trialRecords.phaseRecords},'UniformOutput',false);
            phaseStarts = cellfun(@getPhaseStarts,{trialRecords.phaseRecords},'UniformOutput',false);
            trialStart= cellfun(@(x) x(1),phaseStarts,'UniformOutput',false);
            if any(cellfun(@iscell,discrimPhaseStart))
                discrimPhaseStart{cellfun(@iscell,discrimPhaseStart)}=nan;
                %replace the cells with nans in them with nans (and no cell)
            end
            out=cell2mat(discrimPhaseStart)-cell2mat(trialStart); 
        case 'discrimStartRaw'
            discrimPhaseStart = cellfun(@getDiscrimPhaseStart,{trialRecords.phaseRecords},'UniformOutput',false);
            out=cell2mat(discrimPhaseStart);
        case 'preResponseStartRaw'
            preResponsePhaseStart = cellfun(@getPreResponsePhaseStart,{trialRecords.phaseRecords},'UniformOutput',false);
            out=cell2mat(preResponsePhaseStart);
        case 'responseWindowStartSec'
            responseWindowStart = cellfun(@getResponseWindowStart,{trialRecords.trialManager},'UniformOutput',false);
            out=cell2mat(responseWindowStart);
        case 'responseWindowStopSec'
            responseWindowStop = cellfun(@getResponseWindowStop,{trialRecords.trialManager},'UniformOutput',false);
            out=cell2mat(responseWindowStop);
        case 'expectedPreRequestDurSec'
            expectedPreRequestDurSec = cellfun(@getExpectedPreRequestDurSec,{trialRecords.phaseRecords},{trialRecords.resolution},'UniformOutput',false);
            out=cell2mat(expectedPreRequestDurSec);
        case 'trialStartRaw'
            phaseStarts = cellfun(@getPhaseStarts,{trialRecords.phaseRecords},'UniformOutput',false);
            trialStart= cellfun(@(x) x(1),phaseStarts,'UniformOutput',false);
            out=cell2mat(trialStart);
        case {'responseTime','firstIRI','numRequests', 'lickTimesInCell','lickTimesInMatrix'}
            if isPhased
                % this has to be a cell array b/c phaseRecords aren't always the same across trials
                times = cellfun(@getTimesPhased,{trialRecords.phaseRecords},'UniformOutput',false);
                tries = cellfun(@getTriesPhased,{trialRecords.phaseRecords},'UniformOutput',false);
                phaseLabelPerLick = cellfun(@getPhaseLabelPerLick,{trialRecords.phaseRecords},'UniformOutput',false);
                discrimPhaseStart = cellfun(@getDiscrimPhaseStart,{trialRecords.phaseRecords},'UniformOutput',false);
            else
                % this has to be a cell array b/c times aren't always there across trials
                times = cellfun(@getTimesNonphased,{trialRecords.responseDetails},'UniformOutput',false);
                tries = cellfun(@getTriesNonphased,{trialRecords.responseDetails},'UniformOutput',false);
                %discrimPhaseStart %lick times is not back compatible yet
            end

            if isfield(trialRecords,'station')
                numPorts=[trialRecords.station];
                numPorts={numPorts.numPorts};
            else
                numPorts=num2cell(ones(1,length(trialRecords))*3); % default to 3 ports if not specified
            end
            allPorts=cellfun(@getAllPorts,numPorts,'UniformOutput',false);
            if isfield(trialRecords,'targetPorts') && isfield(trialRecords,'distractorPorts')
                responsePorts=cellfun(@union,{trialRecords.targetPorts},{trialRecords.distractorPorts},'UniformOutput',false);
                requestPorts=cellfun(@setdiff,allPorts,responsePorts,'UniformOutput',false);
            else
                responsePorts=cellfun(@union,num2cell(ones(1,length(trialRecords))),num2cell(ones(1,length(trialRecords))*3),...
                    'UniformOutput',false); % default responsePorts to [1 3]
                requestPorts=num2cell(ones(1,length(trialRecords))*2); % default requestPorts to [2]
            end
            % times is a cell array of VECTORS (each vector is all the times for a trial)
            % tries is a cell array of CELL ARRAYS (each inner cell array is all the tries for a trial)

            switch ensureMode
                case 'responseTime'
                    % could add a feature to check that all prior licks were only
                    % center licks... and error if not. but that would be slow.
                    if isPhased
                        out = cell2mat(cellfun(@getDiffFromFirstRequestToNextResponse,times,tries,requestPorts,responsePorts,phaseLabelPerLick,'UniformOutput',false));
                    else
                        out = cell2mat(cellfun(@diffFirstRequestLastResponse,times,tries,requestPorts,responsePorts,'UniformOutput',false));
                    end
                case 'firstIRI'
                    % elapsed time between first two requests
                    out = cell2mat(cellfun(@diffFirstTwoRequests,times,tries,requestPorts,'UniformOutput',false));
                case 'numRequests'
                    % now convert from a cell array of cell arrays to a vector of length-1's
                    out = cell2mat(cellfun(@getNumRequests,tries,requestPorts,responsePorts,'UniformOutput',false));
                case 'lickTimesInCell'
                    %SLOW TO LOAD -
                    %139.compiledTrialRecords.1-310780 - 114MB - 80 seconds  (takes <3 sec with matrix rep) 
                    out=times;  % un-normalized to stim, probably contains all phases, not just discrim
                    out=cellfun(@allResponsesTimesMinusDiscrimStart,times,discrimPhaseStart,'UniformOutput',false); %normalized to discrim start 
                case 'lickTimesInMatrix'       
                    maxLicksAllowed=5;  %03/13/10
                    % duc reasons that maxLicksAllowed should = 1
                    % because based on the new program one lick is all it
                    % needs to either be correctHits, falseAlarm or
                    % falseTrigger, there are no longer any "free" licks
                    % allowed since it is all rewarded or punished, licks
                    % during reinforcement phase doesn't get recorded. This
                    % way also saves memory.
                    
                    % philip chose this hard coded param on 12/14/09
                    %50 runs out of memory for rats with 300,000 trials, and captures 98% of goNoGo trials withless than 50 licks
                    %25 is okay, but throws out some data. we get all the
                    %last ones used to get alll the last ones, which favors the end reward lick,
                    %eventually getting to stim and pre-request
                    %maybe explicitly getting the pre-request and
                    %distrim-licks is a good idea ...
                  
                    lickTimesMatrix=nan(maxLicksAllowed,length(times));
                    for i=1:length(times)
                        if ~(iscell(times{i}) && isnan(times{i}{1})) % if nan, then no-licks to save
                            numLicksSaved=min(maxLicksAllowed,length(times{i}));
%                             lickTimesMatrix(1:numLicksSaved,i)=times{i}(end-numLicksSaved+1:end); old method gathers
%                             from the end -phil 03/13/10
                            %new method gathers from the front -phil
                            %03/13/10
                            lickTimesMatrix(1:numLicksSaved,i)=times{i}(1:numLicksSaved);
                        end
                    end
                    out=lickTimesMatrix;
            end
        case 'actualRewardDuration'
            if isPhased
                out = cell2mat(cellfun(@getRewardDursPhased,{trialRecords.phaseRecords},'UniformOutput',false));
            elseif isfield(trialRecords,'actualRewardDuration') % non-phased case
                out = cell2mat(cellfun(@getRewardDursNonphased,{trialRecords.actualRewardDuration},'UniformOutput',false));
            else
                out=NaN*ones(1,length(trialRecords));
            end
        case 'proposedRewardDuration'
            if isPhased
                out = cell2mat(cellfun(@getProposedRewardPhased,{trialRecords.phaseRecords},'UniformOutput',false));
            elseif isfield(trialRecords,'proposedRewardSizeULorMS') % non-phased case
                out = cell2mat(cellfun(@getProposedRewardNonphased,{trialRecords.proposedRewardSizeULorMS},'UniformOutput',false));
            else
                out=NaN*ones(1,length(trialRecords));
            end
        case 'proposedPenaltyDuration'
            if isPhased
                out = cell2mat(cellfun(@getProposedPenaltyPhased,{trialRecords.phaseRecords},'UniformOutput',false));
            elseif isfield(trialRecords,'proposedMsPenalty') % non-phased case
                out = cell2mat(cellfun(@getProposedPenaltyNonphased,{trialRecords.proposedMsPenalty},'UniformOutput',false));
            else
                out=NaN*ones(1,length(trialRecords));
            end
        case 'none'
            out=[trialRecords.(fieldPath)];
        case 'bin2dec' %note uses trialRecords.station.numPorts in order to pad w/ sig digits
            % ensureType is a cell array of numPorts
            ports={trialRecords.(fieldPath)};
            out = cell2mat(cellfun(@convertPortsToDec,ports,ensureType,'UniformOutput',false));
        case 'correct'
            if isfield(trialRecords,'trialDetails') % look here
                out=cell2mat(cellfun(@getCorrect,{trialRecords.trialDetails},'UniformOutput',false));
            else 
               % out=[trialRecords.correct];
               % edit 8/27/09 fli - use cellfun to avoid dropping empty 'correct' field
               % out=cell2mat(cellfun(@getCorrect,{trialRecords.correct},'UniformOutput',false)); 
               % fans method returns all nans, cuz none of the values in the cell are in the field 'correct'...
               % pmm applied this change to trunk starting from an idea on fan's uncommitted tag 1.0.1, sept 5th, 2009
                out=cell2mat(cellfun(@getCorrectExtractedFromField,{trialRecords.correct},'UniformOutput',false));      
            end
        otherwise
            ensureMode
            error('unsupported ensureMode');
    end
catch ex
    % if this field doesn't exist, fill with nans
    % pmm says: should check to see if the offending field was on the first trial or a latter trial.  error if not the first.
    getReport(ex)
    out=nan*ones(1,length(trialRecords));
end

end % end function

function out=takeNthValue(values,N)
if length(values)>=N
    out=values(N);
else
   out=nan; 
end
end

function out = getNumTries(responseDetails)
out=length(responseDetails.tries);
end

function out=getTriesPhased(phaseRecord)
out={};
for i=1:length(phaseRecord)
    out=[out phaseRecord(i).responseDetails.tries];
end
if isempty(out)
    out={NaN};
end
end

function out = getTriesNonphased(trialRecord)
if isfield(trialRecord,'tries')
    out = [trialRecord.tries];
else
    out= {NaN};
end
end

function out=diffFirstTwoRequests(times,tries,requestPorts)
out=nan;
which=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(requestPorts)==1),tries,'UniformOutput',false)));
if length(which)>=2
    out=times(which(2))-times(which(1));
end
end

function out=allResponsesTimesMinusDiscrimStart(times,discrimPhaseStart)
if iscell(times) && isnan(times{1})
    out=nan;
else    
    if length(discrimPhaseStart)==1
    out=[times]-[discrimPhaseStart];
    else
        error('expect discrimPhaseStart to be a single number for each trial')
    end
end
end

function out=diffFirstRequestLastResponse(times,tries,requestPorts,responsePorts)
out=nan;
first=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(requestPorts)==1),tries,'UniformOutput',false)),1,'first');
last=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(responsePorts)==1),tries,'UniformOutput',false)),1,'last');
if ~isempty(first) && ~isempty(last) && last>first
    out=times(last)-times(first);
end
end

function out = convertPortsToDec(portCellIn,numPortsCellIn)
out=zeros(1,numPortsCellIn);
out(portCellIn)=1;

out=bin2dec(num2str(out));
end

function out=getNumRequests(tries,requestPorts,responsePorts)
allRequests=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(requestPorts)==1),tries,'UniformOutput',false)));
allResponses=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(responsePorts)==1),tries,'UniformOutput',false)));
if isempty(allRequests)
    out=0;
    return;
else
    firstInd=find(allResponses>allRequests(1),1,'first');
    if isempty(firstInd)
        firstResponse=Inf;
    else
        firstResponse=allResponses(firstInd);
    end
    out=length(find(allRequests<firstResponse));
end
end

function out = getAllPorts(numPorts)
out=1:numPorts;
end

function out = getRewardDursPhased(phaseRecord)
out=sum([phaseRecord.actualRewardDurationMSorUL]);
end

function out = getRewardDursNonphased(dur)
% replace all emptys([]) with 0
if isempty(dur)
    out=0;
else
    out=dur*1000; % convert from secs to ms
end
end

function out = getProposedRewardPhased(phaseRecord)
out=sum([phaseRecord.proposedRewardDurationMSorUL]);
end

function out = getProposedRewardNonphased(dur)
% replace all emptys([]) with 0
if isempty(dur)
    out=0;
else
    out=dur; % already in ms
end
end

function out = getProposedPenaltyPhased(phaseRecord)
out=sum([phaseRecord.proposedPenaltyDurationMSorUL]);
end

function out = getProposedPenaltyNonphased(dur)
% replace all emptys([]) with 0
if isempty(dur)
    out=0;
else
    out=dur; % already in ms
end
end

function out = getCorrect(trialDetails)
out=nan;
if  isfield(trialDetails,'correct') && ~isempty(trialDetails.correct) 
    out=double(trialDetails.correct);
end
end

function out = getCorrectExtractedFromField(correctFieldInCell)
%handles trials prior to 'correct' being located at trialDetails.correct
out=nan;
if  ~isempty(correctFieldInCell) 
    out=double(correctFieldInCell);
end
end

