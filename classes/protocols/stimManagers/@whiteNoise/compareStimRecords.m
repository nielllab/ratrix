function [paramsIdentical diffIn] = compareStimRecords(stimType,params1,params2)
paramsList = {{'strategy'},{'spatialDim'},{'patternType'},{'distribution','type'}};
diffIn = {};

% checking for strategy
if isfield(params1,'strategy') && isfield(params2,'strategy') && strcmp(params1.strategy,params2.strategy)
    % do nothing
else
    diffIn{end+1} = {'strategy'};
end

% check for spatialDim
if isfield(params1,'spatialDim') && isfield(params2,'spatialDim') && all(params1.spatialDim==params2.spatialDim)
    % do nothing
else
    diffIn{end+1} = {'spatialDim'};
end

% check for patternType
if isfield(params1,'patternType') && isfield(params2,'patternType') && strcmp(params1.patternType,params2.patternType)
    % do nothing
else
    diffIn{end+1} = {'patternType'};
end

% check for distribution.type
if isfield(params1,'distribution') && isfield(params1.distribution,'type') && ...
        isfield(params2,'distribution') && isfield(params2.distribution,'type') && ...
        strcmp(params1.distribution.type,params2.distribution.type)
    % do nothing
else
    diffIn{end+1} = {'distribution','type'};
end

paramsIdentical = isempty(diffIn);
end
