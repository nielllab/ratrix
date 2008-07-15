function compiledTrialRecords=loadCompiledTrialRecords(compiledFile,compiledRange,fieldNames)
%loads the compiled records in the specified range, for the requested (expected) field names
%won't allow a load if the names don't match.
%see getSmalls for similar function(more user friendly, less error checking)
%
%edf wrote it
%pmm becomes its own function, used to be part of compileTrailRecords

fprintf('\nloading %s...\n',compiledFile);
t=GetSecs;
ctr=load(compiledFile);
fprintf('elpased time: %g\n',GetSecs-t)
compiledTrialRecords=ctr.compiledTrialRecords;
trialNums=[compiledTrialRecords.trialNumber];
if ~all(trialNums==compiledRange(1):compiledRange(2)) || compiledRange(1)~=1
    compiledFile
    min(trialNums)
    max(trialNums)
    compiledRange
    error('compiledTrialRecord file found not to contain proper trial numbers')
end
if length(fieldNames)~=length(fields(compiledTrialRecords))
    fieldNames
    fields(compiledTrialRecords)
    error('compiled trial records have different fields than the targets');
end
for m=1:length(fieldNames)
    if ~ismember(fieldNames{m},fields(compiledTrialRecords))
        fieldNames
        fields(compiledTrialRecords)
        error('compiled trial records don''t contain all target fields');
    end
end

%cast all vectors to be doubles (for back compatibility, in case they were logicals) pmm
existingFields=fields(compiledTrialRecords);
for i=1:length(existingFields)
    if ~strcmp(class(compiledTrialRecords.(existingFields{i})),'double')
        compiledTrialRecords.(existingFields{i})=double(compiledTrialRecords.(existingFields{i}));
        disp(existingFields{i})
        warning('found a non-double vector, casting it as double')
    end
end