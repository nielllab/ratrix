function commonName = commonNameForStim(stimType,params)
% default practice when you dont know how to treat the stim
classType = class(stimType);
commonName = classType;
end
