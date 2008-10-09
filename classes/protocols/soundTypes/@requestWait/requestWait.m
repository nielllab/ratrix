function st=requestWait(duration)
% requestWait  class constructor. 
% This soundType plays the 'keepGoingSound' at the port = [requestOptions]
% when we are in the wait phase, and we get a request
% Does not care about framesElapsed
if ~isscalar(duration)
    error('duration must be a scalar');
end

a = soundType('keepGoingSound', duration);
st.name = 'keepGoingSound'; %name of the sound clip as a string
st.duration = duration; %number of ms to play this clip (as an argument to playLoop) - 0 = repeat forever (in case of no sound)

st = class(st, 'requestWait', a);

st = setSuper(st, st.soundType);
