function commonName = commonNameForStim(stimType,params)
classType = class(stimType);

numSpatialFrequencies = length(params.spatialFrequencies);
numDriftfrequencies = length(params.driftfrequencies);
numOrientations = length(params.orientations);

stimAxes = [numSpatialFrequencies numDriftfrequencies numOrientations];
sweepTypes = {'spatGr','tempGr','orGr'};
sweepUnits = {'spatFreqs.','tempFreqs.','orientations.'};

if length(find(stimAxes>1))>1
    complexStimType = true;
    stimIsSwept = true;
    sweepType = '';
elseif length(find(stimAxes>1))==1
    complexStimType = false;
    stimIsSwept = true;
    sweepType = sweepTypes{stimAxes>1};
    sweepUnit = sweepUnits{stimAxes>1};
else
    complexStimType = false;
    stimIsSwept = false;
end

if params.annuli 
    if isfield(params, 'changeableAnnulusCenter') && params.changeableAnnulusCenter
        annuliStr = 'with mannulus.';
    else
        annuliStr = 'with annulus.';
    end
else
    annuliStr = '';
end

if ~complexStimType && stimIsSwept
    if isfield(params,'waveform')
        commonName = sprintf('%s: %d %s %s waveform: %s.',sweepType,stimAxes(stimAxes>1),sweepUnit,annuliStr,params.waveform);
    else
        commonName = sprintf('%s: %d %s %s waveform: %s.',sweepType,stimAxes(stimAxes>1),sweepUnit,annuliStr,'not specified');
    end
elseif ~complexStimType && ~stimIsSwept
    if isfield(params,'waveform')
        commonName = sprintf('%s: %s waveform: %s.','No param sweep',annuliStr,params.waveform);
    else
        commonName = sprintf('%s: %s waveform: %s.','No param sweep',annuliStr,'not specified');
    end
else
    commonName = 'complex grating stimulus';
end
end