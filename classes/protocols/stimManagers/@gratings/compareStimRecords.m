function paramsIdentical = compareStimRecords(stimType,params1,params2)
stimParameters = {'spatialFrequencies','driftfrequencies','orientations','phases','contrasts',...
        'location','durations','radii','annuli','numRepeats','doCombos','changeableAnnulusCenter','waveform'};
diffIn = {};
%==========================================================================
% BEGIN NUMERIC DATA TYPES
% check for spatialFrequencies
if isfield(params1,'spatialFrequencies') && isfield(params2,'spatialFrequencies') && ...
        length(params1.spatialFrequencies)==length(params2.spatialFrequencies) && ...
        all(sort(params1.spatialFrequencies)==sort(params2.spatialFrequencies))
    % do nothing
else
    diffIn{end+1} = {'spatialFrequencies'};
end

% check for driftfrequencies
if isfield(params1,'driftfrequencies') && isfield(params2,'driftfrequencies') && ...
        length(params1.driftfrequencies)==length(params2.driftfrequencies) && ...
        all(sort(params1.driftfrequencies)==sort(params2.driftfrequencies))
    % do nothing
else
    diffIn{end+1} = {'driftfrequencies'};
end

% check for orientations
if isfield(params1,'orientations') && isfield(params2,'orientations') && ...
        length(params1.orientations)==length(params2.orientations) && ...
        all(sort(params1.orientations)==sort(params2.orientations))
    % do nothing
else
    diffIn{end+1} = {'orientations'};
end

% check for phases
if isfield(params1,'phases') && isfield(params2,'phases') && ...
        length(params1.phases)==length(params2.phases) && ...
        all(sort(params1.phases)==sort(params2.phases))
    % do nothing
else
    diffIn{end+1} = {'phases'};
end

% check for contrasts
if isfield(params1,'contrasts') && isfield(params2,'contrasts') && ...
        length(params1.contrasts)==length(params2.contrasts) && ...
        all(sort(params1.contrasts)==sort(params2.contrasts))
    % do nothing
else
    diffIn{end+1} = {'contrasts'};
end

% check for location
if isfield(params1,'location') && isfield(params2,'location') && ...
        length(params1.location)==length(params2.location) && ...
        all(sort(params1.location)==sort(params2.location))
    % do nothing
else
    diffIn{end+1} = {'location'};
end

% check for durations
if isfield(params1,'durations') && isfield(params2,'durations') && ...
        length(params1.durations)==length(params2.durations) && ...
        all(sort(params1.durations)==sort(params2.durations))
    % do nothing
else
    diffIn{end+1} = {'durations'};
end

% check for radii
if isfield(params1,'radii') && isfield(params2,'radii') && ...
        length(params1.radii)==length(params2.radii) && ...
        all(sort(params1.radii)==sort(params2.radii))
    % do nothing
else
    diffIn{end+1} = {'radii'};
end
   
% check for annuli
if isfield(params1,'annuli') && isfield(params2,'annuli') && ...
        length(params1.annuli)==length(params2.annuli) && ...
        all(sort(params1.annuli)==sort(params2.annuli))
    % do nothing
else
    diffIn{end+1} = {'annuli'};
end

% check for numRepeats
if isfield(params1,'numRepeats') && isfield(params2,'numRepeats') && ...
        length(params1.numRepeats)==length(params2.numRepeats) && ...
        all(sort(params1.numRepeats)==sort(params2.numRepeats))
    % do nothing
else
    diffIn{end+1} = {'numRepeats'};
end
% END OF NUMERIC DATA TYPES
%==========================================================================
%==========================================================================
% BEGIN LOGICAL DATA TYPES

stimParameters = {'doCombos','changeableAnnulusCenter','waveform'};

% check for doCombos
if isfield(params1,'doCombos') && isfield(params2,'doCombos') && ...
        length(params1.doCombos)==length(params2.doCombos) && ...
        all(params1.doCombos==params2.doCombos)
    % do nothing
else
    diffIn{end+1} = {'doCombos'};
end

% check for changeableAnnulusCenter
if isfield(params1,'changeableAnnulusCenter') && isfield(params2,'changeableAnnulusCenter') && ...
        length(params1.changeableAnnulusCenter)==length(params2.changeableAnnulusCenter) && ...
        all(params1.changeableAnnulusCenter==params2.changeableAnnulusCenter)
    % do nothing
else
    diffIn{end+1} = {'changeableAnnulusCenter'};
end

% END LOGICAL DATA TYPES
%==========================================================================
%==========================================================================
% BEGIN STRING DATA TYPES

% check for waveform
if isfield(params1,'waveform') && isfield(params2,'waveform') && strcmp(params1.waveform,params2.waveform)
    % do nothing
else
    diffIn{end+1} = {'waveform'};
end

% END STRING DATA TYPES
%==========================================================================

paramsIdentical = isempty(diffIn);
end
