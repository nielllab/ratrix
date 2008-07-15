function ts = setStimManager(ts, stim)
if isa(stim, 'stimManager')
    ts.stimManager = stim ;
else
    class(stim)
    error('must be stimManager')
    
end