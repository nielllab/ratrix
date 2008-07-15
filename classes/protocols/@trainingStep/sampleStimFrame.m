function  out = sampleStimFrame(ts)
%returns a single image from calc stim movie

%out=sampleStimFrame(); one day?
if isa(ts.stimManager,'stimManager')
out=sampleStimFrame(ts.stimManager,class(ts.trialManager));
else
    out=[];
    warning('not a stimManager:  maybe the current class definitions don''t match the ratrix')
end
