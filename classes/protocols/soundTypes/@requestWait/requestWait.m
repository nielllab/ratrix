function st=requestWait()
% requestWait  class constructor. 
% This soundType plays the 'keepGoingSound' at the port = [requestOptions]
% when we are in the wait phase, and we get a request
% Does not care about framesElapsed


a = soundType('keepGoingSound', 250);
st.name = 'keepGoingSound'; %name of the sound clip as a string
st.duration = 250; %number of ms to play this clip (as an argument to playLoop) - 0 = repeat forever (in case of no sound)

st = class(st, 'requestWait', a);

st = setSuper(st, st.soundType);
