function [compiledTrialRecords compiledDetails compiledLUT]=loadDetailedTrialRecords(compiledFile,compiledRange,fieldNames)
%loads the compiled detailed records in the specified range, for the requested (expected) field names
%won't allow a load if the names don't match.
%
%12/5/08 - also returns LUT for dynamic caching

fprintf('\nloading %s...\n',compiledFile);
t=GetSecs;
ctr=load(compiledFile);
fprintf('elapsed time: %g\n',GetSecs-t)
compiledTrialRecords=ctr.compiledTrialRecords;
if isfield(ctr,'compiledDetails')
    compiledDetails=ctr.compiledDetails;
else
    compiledDetails={};
end
if isfield(ctr,'compiledLUT')
    compiledLUT=ctr.compiledLUT;
else
    compiledLUT={};
end
trialNums=[compiledTrialRecords.trialNumber];

if ~all(trialNums==compiledRange(1):compiledRange(2)) || compiledRange(1)~=1
    compiledFile
    min(trialNums)
    max(trialNums)
    compiledRange
    error('compiledTrialRecords file found not to contain proper trial numbers')
end
if length(fieldNames)~=length(fields(compiledTrialRecords))
    fieldNames
    fields(compiledTrialRecords)
    warning('compiledTrialRecords have different fields than the targets (this is okay now because we have nan padding)');
end
for m=1:length(fieldNames)
    if ~ismember(fieldNames{m},fields(compiledTrialRecords))
        fieldNames
        fields(compiledTrialRecords)
        warning('compiledTrialRecords don''t contain all target fields (this is okay now because we have nan padding)');
    end
end

%cast all vectors to be doubles (for back compatibility, in case they were logicals) pmm
existingFields=fields(compiledTrialRecords);
for i=1:length(existingFields)
    %edf asks: why don't we like logicals?  why don't we test for logicals directly?
    %edf notes: structs are cells!  cuz matlab is awesome.
    c=compiledTrialRecords.(existingFields{i});
    if ~isa(c,'double') && ~iscell(compiledTrialRecords.(existingFields{i}))
        if ~any(cellfun(@(f)f(c),{@isinteger,@islogical}))
            class(c)
            warning('expecting ints or logicals')
        end
        compiledTrialRecords.(existingFields{i})=double(compiledTrialRecords.(existingFields{i}));
        disp(existingFields{i})
        warning('found a non-double vector, casting it as double') %edf asks: how do you know its a vector?
    end
end