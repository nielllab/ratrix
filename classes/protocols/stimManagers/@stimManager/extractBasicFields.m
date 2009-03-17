function [out compiledLUT]=extractBasicFields(sm,trialRecords,compiledLUT)

%note many of these are actually restricted by the trialManager -- ie
%nAFC has scalar targetPorts, but freeDrinks doesn't.

bloat=false;
% fields to extract from trialRecords:
%   trialNumber
%   sessionNumber
%   date
%   station.soundOn
%   station.physicalLocation
%   station.numPorts
%   trainingStepNum
%   trainingStepName
%   protocolName
%   numStepsInProtocol
%   protocolVersion.manualVersion
%   protocolVersion.autoVersion
%   protocolVersion.protocolDate
%   correct
%   trialManagerClass
%   stimManagerClass
%   schedulerClass
%   criterionClass
%   reinforcementManagerClass
%   scaleFactor
%   type
%   targetPorts
%   distractorPorts
%   response
%   containedManualPokes
%   didHumanResponse
%   containedForcedRewards
%   didStochasticResponse

% ==============================================================================================
% start extracting fields
[out.trialNumber compiledLUT]                                =extractFieldAndEnsure(trialRecords,{'trialNumber'},'scalar',compiledLUT);
[out.sessionNumber compiledLUT]                              =extractFieldAndEnsure(trialRecords,{'sessionNumber'},'scalar',compiledLUT);
[out.date compiledLUT]                                       =extractFieldAndEnsure(trialRecords,{'date'},'datenum',compiledLUT);
[out.soundOn compiledLUT]                                    =extractFieldAndEnsure(trialRecords,{'station','soundOn'},'scalar',compiledLUT);
[out.physicalLocation compiledLUT]                           =extractFieldAndEnsure(trialRecords,{'station','physicalLocation'},'equalLengthVects',compiledLUT);
[out.numPorts compiledLUT]                                   =extractFieldAndEnsure(trialRecords,{'station','numPorts'},'scalar',compiledLUT);
[out.step compiledLUT]                                       =extractFieldAndEnsure(trialRecords,{'trainingStepNum'},'scalar',compiledLUT);
[out.trainingStepName compiledLUT]                           =extractFieldAndEnsure(trialRecords,{'trainingStepName'},'scalarLUT',compiledLUT);
[out.protocolName compiledLUT]                               =extractFieldAndEnsure(trialRecords,{'protocolName'},'scalarLUT',compiledLUT);
[out.numStepsInProtocol compiledLUT]                         =extractFieldAndEnsure(trialRecords,{'numStepsInProtocol'},'scalar',compiledLUT);
[out.manualVersion compiledLUT]                              =extractFieldAndEnsure(trialRecords,{'protocolVersion','manualVersion'},'scalar',compiledLUT);
[out.autoVersion compiledLUT]                                =extractFieldAndEnsure(trialRecords,{'protocolVersion','autoVersion'},'scalar',compiledLUT);
[out.protocolDate compiledLUT]                               =extractFieldAndEnsure(trialRecords,{'protocolVersion','date'},'datenum',compiledLUT);
% change correct to be something that needs to be computed if trialManagerClass=nAFC
[out.correct compiledLUT]                                    =extractFieldAndEnsure(trialRecords,{'trialDetails', 'correct'},'scalarOrEmpty',compiledLUT);
if all(isnan(out.correct)) % try trialRecords.correct
    [out.correct compiledLUT] = extractFieldAndEnsure(trialRecords,{'correct'},'scalar',compiledLUT);
end
if length(out.correct)~=length(trialRecords)
    out.correct=ones(1,length(trialRecords))*nan;
end

[out.trialManagerClass compiledLUT]                          =extractFieldAndEnsure(trialRecords,{'trialManagerClass'},'scalarLUT',compiledLUT);
[out.stimManagerClass compiledLUT]                           =extractFieldAndEnsure(trialRecords,{'stimManagerClass'},'scalarLUT',compiledLUT);
[out.schedulerClass compiledLUT]                             =extractFieldAndEnsure(trialRecords,{'schedulerClass'},'scalarLUT',compiledLUT);
[out.criterionClass compiledLUT]                             =extractFieldAndEnsure(trialRecords,{'criterionClass'},'scalarLUT',compiledLUT);
[out.reinforcementManagerClass compiledLUT]                  =extractFieldAndEnsure(trialRecords,{'reinforcementManagerClass'},'scalarLUT',compiledLUT);
[out.scaleFactor compiledLUT]                                =extractFieldAndEnsure(trialRecords,{'scaleFactor'},'equalLengthVects',compiledLUT);
[out.type compiledLUT]                                       =extractFieldAndEnsure(trialRecords,{'type'},'mixed',compiledLUT);
[out.targetPorts compiledLUT]                                =extractFieldAndEnsure(trialRecords,{'targetPorts'},{'typedVector','index'},compiledLUT);
[out.distractorPorts compiledLUT]                            =extractFieldAndEnsure(trialRecords,{'distractorPorts'},{'typedVector','index'},compiledLUT);
try
    out.result                                                   =ensureScalar(cellfun(@encodeResult,{trialRecords.result},out.targetPorts,out.distractorPorts,num2cell(out.correct),'UniformOutput',false));
catch
    ple
    out.result=ones(1,length(trialRecords))*nan;
end
[out.containedAPause compiledLUT]                            =extractFieldAndEnsure(trialRecords,{'containedAPause'},'scalar',compiledLUT);
[out.containedManualPokes compiledLUT]                       =extractFieldAndEnsure(trialRecords,{'containedManualPokes'},'scalar',compiledLUT);
[out.didHumanResponse compiledLUT]                           =extractFieldAndEnsure(trialRecords,{'didHumanResponse'},'scalar',compiledLUT);
[out.containedForcedRewards compiledLUT]                     =extractFieldAndEnsure(trialRecords,{'containedForcedRewards'},'scalar',compiledLUT);
[out.didStochasticResponse compiledLUT]                      =extractFieldAndEnsure(trialRecords,{'didStochasticResponse'},'scalar',compiledLUT);
% 1/13/09 - need to peek into stimDetails to get correctionTrial (otherwise analysis defaults correctionTrial=0)
% need a try-catch here because this is potentially dangerous (stimDetails may not be the same for all trials, in which case this will error
% from the vector indexing
try
    [out.correctionTrial compiledLUT]                            =extractFieldAndEnsure(trialRecords,{'stimDetails','correctionTrial'},'scalar',compiledLUT);
catch
    ple
    out.correctionTrial=ones(1,length(trialRecords))*nan;
end    
% 1/14/09 - added numRequestLicks and firstILI
[out.numRequests compiledLUT]                                =extractFieldAndEnsure(trialRecords,{},'numRequests',compiledLUT);
[out.firstIRI compiledLUT]                                   =extractFieldAndEnsure(trialRecords,{},'firstIRI',compiledLUT);

% 3/5/09 - we need to calculate a 'response' field for analysis based either on trialRecords.response (old-style)
% or trialRecords.phaseRecords.responseDetails.tries (new-style) for the phase labeled 'discrim'
[out.response]                                               =getResponseFromTrialRecords(trialRecords);

% out.numRequests=ones(1,length(trialRecords))*nan;
% for i=1:length(trialRecords)
%     if isfield(trialRecords(i),'responseDetails') && isfield(trialRecords(i).responseDetails,'tries') && ...
%             ~isempty(trialRecords(i).responseDetails.tries) % if this field exists, overwrite the nan
%         out.numRequests(i)=size(trialRecords(i).responseDetails.tries,2)-1;
%     end
% end
% out.firstIRI=ones(1,length(trialRecords))*nan;
% for i=1:length(trialRecords)
%     if isfield(trialRecords(i),'responseDetails') && isfield(trialRecords(i).responseDetails,'times') && ...
%             ~isempty(trialRecords(i).responseDetails.times) && size(trialRecords(i).responseDetails.times,2)-1>=2
%         out.firstIRI(i)=diff(cell2mat(trialRecords(i).responseDetails.times(1:2)));
%     end
% end
try
verifyAllFieldsNCols(out,length(trialRecords));
catch
    keyboard
end
end

% ==================================================================
% HELPER FUNCTIONS

function out=encodeResult(result,targs,dstrs,correct)

if isa(result,'double') && all(result==1 | result==0)
    warning('edf sees double rather than logical response on osx 01.21.09 -- why?')
    result=logical(result);
end

if ischar(result)
    switch result
        case 'nominal'
            out=1;
        case 'multiple ports'
            out=-1;
        case 'none'
            out=-2;
        case 'manual kill'
            out=0;
        case 'shift-2 kill'
            out=-4;
        case 'server kill'
            out=-5;
        case 'manual flushPorts'
            out=-8;
        otherwise
            % 1/22/09 - if the response is 'manual training step %d'
            match=regexp(result,'manual training step \d+','match');
            if ~isempty(match)
                out=-7; % manually set training step
            else
                out=-6;
                result
                warning('unrecognized response')
            end
    end
else
    result
    class(result)
    error('unrecognized result type')
end

% if ismember(out,targs) == correct
%     %pass
% else
%     out
%     targs
%     correct
%     error('bad correct calc')
% end

if all(isempty(intersect(dstrs,targs)))
    %pass
else
    error('found intersecting targets and distractors')
end

end


function [out compiledLUT] = ensureScalarOrAddCellToLUT(fieldArray, compiledLUT)
% this function either returns a scalar array, or if it finds that fieldArray is a cell array, performs LUT processing on the fieldArray
% this allows extractBasicFields to support versions of trialRecords that dont use a LUT
try
    out=ensureScalar(fieldArray);
catch
    ensureTypedVector(fieldArray,'char'); % ensure that this is cell array of characters, otherwise no point using a LUT
    [out compiledLUT] = addOrFindInLUT(compiledLUT, fieldArray);
end

end % end function

function out = getResponseFromTrialRecords(trialRecords)
% Get the trialRecords.response field if it exists, otherwise look for trialRecords.phaseRecords.responseDetails.tries
% return -1 if neither exists...uh oh
out=ones(1,length(trialRecords))*-1;

if isfield(trialRecords,'response')
    out=cell2mat(cellfun(@decideResponse,{trialRecords.response},'UniformOutput',false));
end
if isfield(trialRecords,'phaseRecords') && isfield(trialRecords,'result') % these two 'if' cases should be mutually exclusive in latest code, but not always been the case
    out=cell2mat(cellfun(@getResponseFromTries,{trialRecords.phaseRecords},'UniformOutput',false));
end
end

function out = decideResponse(response)
resp=find(response);
if length(resp)==1 && ~ischar(response)
    out=resp;
else
    out=-1;
end
end % end function

function out = getResponseFromTries(phaseRecords)
try
    pInd=find(strcmp({phaseRecords.phaseLabel},'discrim'));
catch
    pInd=[];
end
% we assume the last try of the 'discrim' phase to be the response
if length(pInd)==1
    try
        tries=phaseRecords(pInd).responseDetails.tries;
        response=tries{end};
        out=decideResponse(response);
    catch
        out=-1;
    end
else
    out=-1;
end
end % end function



