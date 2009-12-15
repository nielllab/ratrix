function commonName = commonNameForStim(stimType,params)
classType = class(stimType);

if all(params.spatialDim == [1 1])
    if strcmp(params.distribution.type,'gaussian')
        commonName = 'ffgwn';
    elseif strcmp(params.distribution.type,'binary')
        commonName = 'ffbinwn';
    else
        commonName = classType;
    end
elseif params.spatialDim(1)==1
    commonName = 'h-bars';
elseif params.spatialDim(2)==1
    commonName = 'v-bars';
elseif strcmp(params.distribution.type,'binary')
    commonName = sprintf('%dX%d binary checkerboard',params.spatialDim(2),params.spatialDim(1));
else
    commonName = classType;
end
end
     
