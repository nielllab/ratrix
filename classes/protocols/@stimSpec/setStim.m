function spec=setStim(spec,stim)
% stimSpec.stimulus set function
% sets the stimulus associated with the given stimSpec object

origSize=size(spec.stimulus);
newSize=size(stim);
if (length(origSize)==length(newSize) && all(size(stim)==size(spec.stimulus)))
    %do nothing -- keep same indexPulses cuz they're the right size
elseif isempty(spec.stimulus)
    spec.indexPulses=false(1,size(stim,3)); %dynamically creating error/reward stim
else
    struct(spec)
    error('dont know how to dynamically make these indexPulses -- someone already made them with incompatible size');
end

spec.stimulus = stim;

end
