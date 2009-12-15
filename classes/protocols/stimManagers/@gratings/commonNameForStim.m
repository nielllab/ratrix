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
    sweepType = '';
elseif length(find(stimAxes>1))==1
    complexStimType = false;
    sweepType = sweepTypes{stimAxes>1};
    sweepUnit = sweepUnits{stimAxes>1};
end

if params.annuli 
    if params.changeableAnnulusCenter
        annuliStr = 'with mannulus.';
    else
        annuliStr = 'with annulus.';
    end
else
    annuliStr = '';
end

if ~complexStimType
    commonName = sprintf('%s: %d %s %s waveform: %s.',sweepType,stimAxes(stimAxes>1),sweepUnit,annuliStr,params.waveform);
else
    commonName = 'complex grating stimulus';
end
end